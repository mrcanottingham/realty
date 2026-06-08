-- Carely: Caregiver Onboarding Schema
-- Phase: Database Schema & Caregiver Onboarding Core

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE onboarding_status AS ENUM (
  'not_started',
  'in_progress',
  'pending_review',
  'approved',
  'flagged'
);

CREATE TYPE signature_method AS ENUM (
  'drawn',
  'typed'
);

CREATE TYPE document_status AS ENUM (
  'pending',
  'uploaded',
  'approved',
  'rejected',
  'expired'
);

CREATE TYPE actor_role AS ENUM (
  'agency_owner',
  'caregiver',
  'system'
);

-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE agencies (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL,
  owner_id   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  slug       TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE caregivers (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id               UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  user_id                 UUID REFERENCES auth.users(id) ON DELETE SET NULL,

  first_name              TEXT,
  last_name               TEXT,
  email                   TEXT NOT NULL,
  phone                   TEXT,

  invite_token            TEXT UNIQUE NOT NULL DEFAULT gen_random_uuid()::TEXT,
  invite_sent_at          TIMESTAMPTZ,
  invite_accepted_at      TIMESTAMPTZ,

  onboarding_status       onboarding_status NOT NULL DEFAULT 'not_started',
  onboarding_completed_at TIMESTAMPTZ,

  approved_by             UUID REFERENCES auth.users(id),
  approved_at             TIMESTAMPTZ,
  flagged_reason          TEXT,

  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE onboarding_packets (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id  UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  name       TEXT NOT NULL DEFAULT 'Default Onboarding Packet',
  is_default BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE caregiver_packet_assignments (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caregiver_id UUID NOT NULL REFERENCES caregivers(id) ON DELETE CASCADE,
  packet_id    UUID NOT NULL REFERENCES onboarding_packets(id) ON DELETE RESTRICT,
  assigned_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (caregiver_id, packet_id)
);

CREATE TABLE form_sections (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  packet_id   UUID NOT NULL REFERENCES onboarding_packets(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL,
  is_required BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE form_responses (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caregiver_id  UUID NOT NULL REFERENCES caregivers(id) ON DELETE CASCADE,
  section_id    UUID NOT NULL REFERENCES form_sections(id) ON DELETE CASCADE,
  response_data JSONB NOT NULL DEFAULT '{}',
  is_complete   BOOLEAN NOT NULL DEFAULT false,
  submitted_at  TIMESTAMPTZ,
  last_saved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (caregiver_id, section_id)
);

CREATE TABLE document_requirements (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  packet_id   UUID NOT NULL REFERENCES onboarding_packets(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  description TEXT,
  is_required BOOLEAN NOT NULL DEFAULT true,
  has_expiry  BOOLEAN NOT NULL DEFAULT false,
  order_index INTEGER NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE caregiver_documents (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caregiver_id     UUID NOT NULL REFERENCES caregivers(id) ON DELETE CASCADE,
  requirement_id   UUID REFERENCES document_requirements(id) ON DELETE SET NULL,

  file_name        TEXT NOT NULL,
  file_path        TEXT NOT NULL,
  file_size_bytes  INTEGER,
  mime_type        TEXT,

  status           document_status NOT NULL DEFAULT 'pending',
  uploaded_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at      TIMESTAMPTZ,
  reviewed_by      UUID REFERENCES auth.users(id),
  rejection_reason TEXT,

  expires_at       DATE,

  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE signature_requests (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caregiver_id      UUID NOT NULL REFERENCES caregivers(id) ON DELETE CASCADE,
  packet_id         UUID NOT NULL REFERENCES onboarding_packets(id),

  document_name     TEXT NOT NULL,
  document_text     TEXT,

  signed_at         TIMESTAMPTZ,
  signature_method  signature_method,
  signature_data    TEXT,

  signer_ip         TEXT,
  signer_user_agent TEXT,

  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (caregiver_id, packet_id, document_name)
);

CREATE TABLE compliance_checklist_items (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caregiver_id  UUID NOT NULL REFERENCES caregivers(id) ON DELETE CASCADE,

  item_type     TEXT NOT NULL CHECK (item_type IN ('form_section', 'document', 'signature')),
  reference_id  UUID NOT NULL,

  label         TEXT NOT NULL,
  is_required   BOOLEAN NOT NULL DEFAULT true,
  is_complete   BOOLEAN NOT NULL DEFAULT false,
  completed_at  TIMESTAMPTZ,
  flagged       BOOLEAN NOT NULL DEFAULT false,
  flagged_reason TEXT,

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE audit_log (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id    UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  caregiver_id UUID REFERENCES caregivers(id) ON DELETE SET NULL,
  actor_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  actor_role   actor_role NOT NULL,
  event_type   TEXT NOT NULL,
  event_detail JSONB,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- INDEXES
-- ============================================================

-- agencies
CREATE INDEX idx_agencies_owner_id ON agencies(owner_id);
CREATE INDEX idx_agencies_slug ON agencies(slug);

-- caregivers
CREATE INDEX idx_caregivers_agency_id ON caregivers(agency_id);
CREATE INDEX idx_caregivers_user_id ON caregivers(user_id);
CREATE INDEX idx_caregivers_invite_token ON caregivers(invite_token);
CREATE INDEX idx_caregivers_onboarding_status ON caregivers(agency_id, onboarding_status);
CREATE INDEX idx_caregivers_email ON caregivers(agency_id, email);

-- onboarding_packets
CREATE INDEX idx_onboarding_packets_agency_id ON onboarding_packets(agency_id);

-- caregiver_packet_assignments
CREATE INDEX idx_cpa_caregiver_id ON caregiver_packet_assignments(caregiver_id);
CREATE INDEX idx_cpa_packet_id ON caregiver_packet_assignments(packet_id);

-- form_sections
CREATE INDEX idx_form_sections_packet_id ON form_sections(packet_id);
CREATE INDEX idx_form_sections_order ON form_sections(packet_id, order_index);

-- form_responses
CREATE INDEX idx_form_responses_caregiver_id ON form_responses(caregiver_id);
CREATE INDEX idx_form_responses_section_id ON form_responses(section_id);

-- document_requirements
CREATE INDEX idx_doc_requirements_packet_id ON document_requirements(packet_id);

-- caregiver_documents
CREATE INDEX idx_caregiver_documents_caregiver_id ON caregiver_documents(caregiver_id);
CREATE INDEX idx_caregiver_documents_requirement_id ON caregiver_documents(requirement_id);
CREATE INDEX idx_caregiver_documents_status ON caregiver_documents(caregiver_id, status);
CREATE INDEX idx_caregiver_documents_expires_at ON caregiver_documents(expires_at) WHERE expires_at IS NOT NULL;

-- signature_requests
CREATE INDEX idx_signature_requests_caregiver_id ON signature_requests(caregiver_id);
CREATE INDEX idx_signature_requests_packet_id ON signature_requests(packet_id);

-- compliance_checklist_items
CREATE INDEX idx_cci_caregiver_id ON compliance_checklist_items(caregiver_id);
CREATE INDEX idx_cci_caregiver_complete ON compliance_checklist_items(caregiver_id, is_complete);
CREATE INDEX idx_cci_reference_id ON compliance_checklist_items(reference_id);

-- audit_log
CREATE INDEX idx_audit_log_agency_id ON audit_log(agency_id);
CREATE INDEX idx_audit_log_caregiver_id ON audit_log(caregiver_id);
CREATE INDEX idx_audit_log_created_at ON audit_log(agency_id, created_at DESC);

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER agencies_updated_at
  BEFORE UPDATE ON agencies
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER caregivers_updated_at
  BEFORE UPDATE ON caregivers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER onboarding_packets_updated_at
  BEFORE UPDATE ON onboarding_packets
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER caregiver_documents_updated_at
  BEFORE UPDATE ON caregiver_documents
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER compliance_checklist_items_updated_at
  BEFORE UPDATE ON compliance_checklist_items
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE agencies                     ENABLE ROW LEVEL SECURITY;
ALTER TABLE caregivers                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_packets           ENABLE ROW LEVEL SECURITY;
ALTER TABLE caregiver_packet_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_sections                ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_responses               ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_requirements        ENABLE ROW LEVEL SECURITY;
ALTER TABLE caregiver_documents          ENABLE ROW LEVEL SECURITY;
ALTER TABLE signature_requests           ENABLE ROW LEVEL SECURITY;
ALTER TABLE compliance_checklist_items   ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log                    ENABLE ROW LEVEL SECURITY;

-- Helper: is the current user the owner of a given agency_id?
-- Used inline in policies to avoid repeated subquery verbosity.

-- --------------------------------------------------------
-- agencies
-- --------------------------------------------------------

CREATE POLICY "agency_owner_select" ON agencies
  FOR SELECT USING (owner_id = auth.uid());

CREATE POLICY "agency_owner_insert" ON agencies
  FOR INSERT WITH CHECK (owner_id = auth.uid());

CREATE POLICY "agency_owner_update" ON agencies
  FOR UPDATE USING (owner_id = auth.uid());

-- --------------------------------------------------------
-- caregivers
-- --------------------------------------------------------

CREATE POLICY "owner_select_caregivers" ON caregivers
  FOR SELECT USING (
    agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
  );

CREATE POLICY "owner_insert_caregivers" ON caregivers
  FOR INSERT WITH CHECK (
    agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
  );

CREATE POLICY "owner_update_caregivers" ON caregivers
  FOR UPDATE USING (
    agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
  );

-- Caregivers can read and update their own row only
CREATE POLICY "caregiver_select_own" ON caregivers
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "caregiver_update_own" ON caregivers
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- --------------------------------------------------------
-- onboarding_packets
-- --------------------------------------------------------

CREATE POLICY "owner_select_packets" ON onboarding_packets
  FOR SELECT USING (
    agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
  );

CREATE POLICY "owner_insert_packets" ON onboarding_packets
  FOR INSERT WITH CHECK (
    agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
  );

CREATE POLICY "owner_update_packets" ON onboarding_packets
  FOR UPDATE USING (
    agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
  );

-- Caregivers can read packets they are assigned to
CREATE POLICY "caregiver_select_assigned_packet" ON onboarding_packets
  FOR SELECT USING (
    id IN (
      SELECT cpa.packet_id
      FROM caregiver_packet_assignments cpa
      JOIN caregivers c ON c.id = cpa.caregiver_id
      WHERE c.user_id = auth.uid()
    )
  );

-- --------------------------------------------------------
-- caregiver_packet_assignments
-- --------------------------------------------------------

CREATE POLICY "owner_select_assignments" ON caregiver_packet_assignments
  FOR SELECT USING (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "owner_insert_assignments" ON caregiver_packet_assignments
  FOR INSERT WITH CHECK (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "caregiver_select_own_assignment" ON caregiver_packet_assignments
  FOR SELECT USING (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );

-- --------------------------------------------------------
-- form_sections
-- --------------------------------------------------------

CREATE POLICY "owner_select_form_sections" ON form_sections
  FOR SELECT USING (
    packet_id IN (
      SELECT id FROM onboarding_packets
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "owner_insert_form_sections" ON form_sections
  FOR INSERT WITH CHECK (
    packet_id IN (
      SELECT id FROM onboarding_packets
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "owner_update_form_sections" ON form_sections
  FOR UPDATE USING (
    packet_id IN (
      SELECT id FROM onboarding_packets
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

-- Caregivers can read sections for packets they are assigned to
CREATE POLICY "caregiver_select_form_sections" ON form_sections
  FOR SELECT USING (
    packet_id IN (
      SELECT cpa.packet_id
      FROM caregiver_packet_assignments cpa
      JOIN caregivers c ON c.id = cpa.caregiver_id
      WHERE c.user_id = auth.uid()
    )
  );

-- --------------------------------------------------------
-- form_responses
-- --------------------------------------------------------

CREATE POLICY "owner_select_form_responses" ON form_responses
  FOR SELECT USING (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "caregiver_select_own_responses" ON form_responses
  FOR SELECT USING (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );

CREATE POLICY "caregiver_insert_own_responses" ON form_responses
  FOR INSERT WITH CHECK (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );

CREATE POLICY "caregiver_update_own_responses" ON form_responses
  FOR UPDATE USING (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );

-- --------------------------------------------------------
-- document_requirements
-- --------------------------------------------------------

CREATE POLICY "owner_select_doc_requirements" ON document_requirements
  FOR SELECT USING (
    packet_id IN (
      SELECT id FROM onboarding_packets
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "owner_insert_doc_requirements" ON document_requirements
  FOR INSERT WITH CHECK (
    packet_id IN (
      SELECT id FROM onboarding_packets
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "owner_update_doc_requirements" ON document_requirements
  FOR UPDATE USING (
    packet_id IN (
      SELECT id FROM onboarding_packets
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

-- Caregivers can read requirements for packets they are assigned to
CREATE POLICY "caregiver_select_doc_requirements" ON document_requirements
  FOR SELECT USING (
    packet_id IN (
      SELECT cpa.packet_id
      FROM caregiver_packet_assignments cpa
      JOIN caregivers c ON c.id = cpa.caregiver_id
      WHERE c.user_id = auth.uid()
    )
  );

-- --------------------------------------------------------
-- caregiver_documents
-- --------------------------------------------------------

CREATE POLICY "owner_select_caregiver_documents" ON caregiver_documents
  FOR SELECT USING (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "owner_update_caregiver_documents" ON caregiver_documents
  FOR UPDATE USING (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "caregiver_select_own_documents" ON caregiver_documents
  FOR SELECT USING (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );

CREATE POLICY "caregiver_insert_own_documents" ON caregiver_documents
  FOR INSERT WITH CHECK (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );

CREATE POLICY "caregiver_update_own_documents" ON caregiver_documents
  FOR UPDATE USING (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  )
  WITH CHECK (
    -- Caregivers can only update file metadata, not review fields
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );

-- --------------------------------------------------------
-- signature_requests
-- --------------------------------------------------------

CREATE POLICY "owner_select_signature_requests" ON signature_requests
  FOR SELECT USING (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "owner_insert_signature_requests" ON signature_requests
  FOR INSERT WITH CHECK (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "caregiver_select_own_signatures" ON signature_requests
  FOR SELECT USING (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );

CREATE POLICY "caregiver_update_own_signatures" ON signature_requests
  FOR UPDATE USING (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
    AND signed_at IS NULL  -- cannot re-sign after signing
  );

-- --------------------------------------------------------
-- compliance_checklist_items
-- --------------------------------------------------------

CREATE POLICY "owner_select_checklist" ON compliance_checklist_items
  FOR SELECT USING (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "owner_insert_checklist" ON compliance_checklist_items
  FOR INSERT WITH CHECK (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

CREATE POLICY "owner_update_checklist" ON compliance_checklist_items
  FOR UPDATE USING (
    caregiver_id IN (
      SELECT id FROM caregivers
      WHERE agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
    )
  );

-- Caregivers can read their own checklist items to track progress
CREATE POLICY "caregiver_select_own_checklist" ON compliance_checklist_items
  FOR SELECT USING (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );

-- --------------------------------------------------------
-- audit_log
-- --------------------------------------------------------

CREATE POLICY "owner_select_audit_log" ON audit_log
  FOR SELECT USING (
    agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
  );

-- Inserts are allowed for the owner, the caregiver themselves, and system-level operations.
-- Application code is responsible for setting actor_role correctly.
CREATE POLICY "owner_insert_audit_log" ON audit_log
  FOR INSERT WITH CHECK (
    agency_id IN (SELECT id FROM agencies WHERE owner_id = auth.uid())
  );

CREATE POLICY "caregiver_insert_audit_log" ON audit_log
  FOR INSERT WITH CHECK (
    caregiver_id IN (SELECT id FROM caregivers WHERE user_id = auth.uid())
  );
