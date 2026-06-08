-- Carely: Local Development Seed Data
-- Run after migrations. Uses deterministic UUIDs for reproducibility.

-- Disable RLS for seeding (local dev only)
SET session_replication_role = replica;

-- ============================================================
-- TEST USERS (auth.users)
-- Creates a test agency owner so the foreign key on agencies.owner_id
-- is satisfied without any manual steps.
-- Login: owner@carely.test / password: carely-dev-2024
-- ============================================================

INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  role,
  aud
)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'owner@carely.test',
  crypt('carely-dev-2024', gen_salt('bf')),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"full_name": "Dev Owner"}',
  now(),
  now(),
  'authenticated',
  'authenticated'
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- AGENCY
-- ============================================================

INSERT INTO agencies (id, name, owner_id, slug, created_at, updated_at)
VALUES (
  '10000000-0000-0000-0000-000000000001',
  'Luv N Home Care',
  '00000000-0000-0000-0000-000000000001',
  'luv-n-home',
  now(),
  now()
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- DEFAULT ONBOARDING PACKET
-- ============================================================

INSERT INTO onboarding_packets (id, agency_id, name, is_default, created_at, updated_at)
VALUES (
  '20000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001',
  'Default Onboarding Packet',
  true,
  now(),
  now()
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- FORM SECTIONS
-- ============================================================

INSERT INTO form_sections (id, packet_id, title, description, order_index, is_required)
VALUES
  (
    '30000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001',
    'Personal Information',
    'Full legal name, date of birth, address, and contact details.',
    1,
    true
  ),
  (
    '30000000-0000-0000-0000-000000000002',
    '20000000-0000-0000-0000-000000000001',
    'Emergency Contact',
    'Name and phone number of a person to contact in an emergency.',
    2,
    true
  ),
  (
    '30000000-0000-0000-0000-000000000003',
    '20000000-0000-0000-0000-000000000001',
    'Work Eligibility',
    'Confirmation of legal authorization to work in the United States.',
    3,
    true
  ),
  (
    '30000000-0000-0000-0000-000000000004',
    '20000000-0000-0000-0000-000000000001',
    'Health Disclosures',
    'Any health conditions that may affect ability to perform care duties.',
    4,
    true
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- DOCUMENT REQUIREMENTS
-- ============================================================

INSERT INTO document_requirements (id, packet_id, name, description, is_required, has_expiry, order_index)
VALUES
  (
    '40000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001',
    'Government-Issued Photo ID',
    'Driver license, state ID, or passport.',
    true,
    true,
    1
  ),
  (
    '40000000-0000-0000-0000-000000000002',
    '20000000-0000-0000-0000-000000000001',
    'Social Security Card',
    'Original Social Security card.',
    true,
    false,
    2
  ),
  (
    '40000000-0000-0000-0000-000000000003',
    '20000000-0000-0000-0000-000000000001',
    'CPR / First Aid Certification',
    'Current CPR and first aid certification from an approved provider.',
    true,
    true,
    3
  ),
  (
    '40000000-0000-0000-0000-000000000004',
    '20000000-0000-0000-0000-000000000001',
    'TB Test Results',
    'Tuberculosis test or chest X-ray results dated within the past 12 months.',
    true,
    true,
    4
  ),
  (
    '40000000-0000-0000-0000-000000000005',
    '20000000-0000-0000-0000-000000000001',
    'Background Check Authorization',
    'Signed authorization for criminal background check.',
    true,
    false,
    5
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- SAMPLE CAREGIVERS (no auth.users accounts yet)
-- ============================================================

INSERT INTO caregivers (
  id, agency_id, user_id,
  first_name, last_name, email, phone,
  invite_token, invite_sent_at,
  onboarding_status,
  created_at, updated_at
)
VALUES
  (
    '50000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    NULL,
    'Maria', 'Santos',
    'maria.santos@example.com',
    '555-0101',
    'invite-token-maria-santos-001',
    now(),
    'not_started',
    now(), now()
  ),
  (
    '50000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    NULL,
    'James', 'Okafor',
    'james.okafor@example.com',
    '555-0102',
    'invite-token-james-okafor-002',
    now() - interval '2 days',
    'in_progress',
    now() - interval '2 days', now()
  ),
  (
    '50000000-0000-0000-0000-000000000003',
    '10000000-0000-0000-0000-000000000001',
    NULL,
    'Priya', 'Nair',
    'priya.nair@example.com',
    '555-0103',
    'invite-token-priya-nair-003',
    now() - interval '5 days',
    'pending_review',
    now() - interval '5 days', now()
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- PACKET ASSIGNMENTS
-- ============================================================

INSERT INTO caregiver_packet_assignments (id, caregiver_id, packet_id, assigned_at)
VALUES
  (
    '60000000-0000-0000-0000-000000000001',
    '50000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001',
    now()
  ),
  (
    '60000000-0000-0000-0000-000000000002',
    '50000000-0000-0000-0000-000000000002',
    '20000000-0000-0000-0000-000000000001',
    now() - interval '2 days'
  ),
  (
    '60000000-0000-0000-0000-000000000003',
    '50000000-0000-0000-0000-000000000003',
    '20000000-0000-0000-0000-000000000001',
    now() - interval '5 days'
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- SAMPLE FORM RESPONSES (for in_progress caregiver)
-- ============================================================

INSERT INTO form_responses (id, caregiver_id, section_id, response_data, is_complete, submitted_at, last_saved_at)
VALUES
  (
    '70000000-0000-0000-0000-000000000001',
    '50000000-0000-0000-0000-000000000002',
    '30000000-0000-0000-0000-000000000001',
    '{"first_name": "James", "last_name": "Okafor", "dob": "1988-03-14", "address": "123 Elm St, Springfield, IL 62701", "phone": "555-0102"}',
    true,
    now() - interval '1 day',
    now() - interval '1 day'
  ),
  (
    '70000000-0000-0000-0000-000000000002',
    '50000000-0000-0000-0000-000000000002',
    '30000000-0000-0000-0000-000000000002',
    '{"name": "Linda Okafor", "relationship": "Spouse", "phone": "555-0199"}',
    true,
    now() - interval '1 day',
    now() - interval '1 day'
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- COMPLIANCE CHECKLIST ITEMS (for all three caregivers)
-- ============================================================

-- Caregiver 1 (Maria Santos) — not_started, all incomplete
INSERT INTO compliance_checklist_items (id, caregiver_id, item_type, reference_id, label, is_required, is_complete)
SELECT
  gen_random_uuid(),
  '50000000-0000-0000-0000-000000000001',
  'form_section',
  id,
  title,
  is_required,
  false
FROM form_sections
WHERE packet_id = '20000000-0000-0000-0000-000000000001'
ON CONFLICT DO NOTHING;

INSERT INTO compliance_checklist_items (id, caregiver_id, item_type, reference_id, label, is_required, is_complete)
SELECT
  gen_random_uuid(),
  '50000000-0000-0000-0000-000000000001',
  'document',
  id,
  name,
  is_required,
  false
FROM document_requirements
WHERE packet_id = '20000000-0000-0000-0000-000000000001'
ON CONFLICT DO NOTHING;

-- Caregiver 2 (James Okafor) — in_progress, first two form sections complete
INSERT INTO compliance_checklist_items (id, caregiver_id, item_type, reference_id, label, is_required, is_complete, completed_at)
VALUES
  (gen_random_uuid(), '50000000-0000-0000-0000-000000000002', 'form_section', '30000000-0000-0000-0000-000000000001', 'Personal Information',  true, true,  now() - interval '1 day'),
  (gen_random_uuid(), '50000000-0000-0000-0000-000000000002', 'form_section', '30000000-0000-0000-0000-000000000002', 'Emergency Contact',      true, true,  now() - interval '1 day'),
  (gen_random_uuid(), '50000000-0000-0000-0000-000000000002', 'form_section', '30000000-0000-0000-0000-000000000003', 'Work Eligibility',       true, false, NULL),
  (gen_random_uuid(), '50000000-0000-0000-0000-000000000002', 'form_section', '30000000-0000-0000-0000-000000000004', 'Health Disclosures',     true, false, NULL)
ON CONFLICT DO NOTHING;

INSERT INTO compliance_checklist_items (id, caregiver_id, item_type, reference_id, label, is_required, is_complete)
SELECT
  gen_random_uuid(),
  '50000000-0000-0000-0000-000000000002',
  'document',
  id,
  name,
  is_required,
  false
FROM document_requirements
WHERE packet_id = '20000000-0000-0000-0000-000000000001'
ON CONFLICT DO NOTHING;

-- Caregiver 3 (Priya Nair) — pending_review, all form sections complete
INSERT INTO compliance_checklist_items (id, caregiver_id, item_type, reference_id, label, is_required, is_complete, completed_at)
VALUES
  (gen_random_uuid(), '50000000-0000-0000-0000-000000000003', 'form_section', '30000000-0000-0000-0000-000000000001', 'Personal Information', true, true, now() - interval '4 days'),
  (gen_random_uuid(), '50000000-0000-0000-0000-000000000003', 'form_section', '30000000-0000-0000-0000-000000000002', 'Emergency Contact',    true, true, now() - interval '4 days'),
  (gen_random_uuid(), '50000000-0000-0000-0000-000000000003', 'form_section', '30000000-0000-0000-0000-000000000003', 'Work Eligibility',     true, true, now() - interval '3 days'),
  (gen_random_uuid(), '50000000-0000-0000-0000-000000000003', 'form_section', '30000000-0000-0000-0000-000000000004', 'Health Disclosures',   true, true, now() - interval '3 days')
ON CONFLICT DO NOTHING;

INSERT INTO compliance_checklist_items (id, caregiver_id, item_type, reference_id, label, is_required, is_complete, completed_at)
SELECT
  gen_random_uuid(),
  '50000000-0000-0000-0000-000000000003',
  'document',
  id,
  name,
  is_required,
  true,
  now() - interval '2 days'
FROM document_requirements
WHERE packet_id = '20000000-0000-0000-0000-000000000001'
ON CONFLICT DO NOTHING;

-- ============================================================
-- RE-ENABLE RLS
-- ============================================================

SET session_replication_role = DEFAULT;
