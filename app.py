import streamlit as st

def agent_realty_app():
    st.set_page_config(page_title="Agent Realty - Property Scout AI", layout="centered")
    
    st.title("🏘️ Meet Agent Realty")
    st.subheader("Your Nationwide AI for Off-Market Property Discovery")

    st.image("https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Agent_icon.svg/1024px-Agent_icon.svg.png", width=150)

    st.markdown("""
    **Agent Realty** is your boots-on-the-ground AI scout, engineered to identify distressed properties across **all 50 states**.
    
    Whether you're looking for:
    - 🏚️ Vacant homes  
    - 🔧 Properties needing major repairs  
    - 🚨 Code violation listings  
    - 🏞️ Land deals with hidden value  
    
    Agent Realty delivers fresh, off-market leads straight to your system in real time.

    > 💡 Perfect for flippers, wholesalers, and buy-and-hold investors.

    ---
    **No sleep. No missed deals. Just relentless opportunity.**
    """)

    st.success("✅ Leads delivered directly to your inbox and Google Sheets!")
    st.info("Need Agent Realty integrated with your CRM or SMS alerts? Let’s talk integration.")

# To run this locally, use:
# streamlit run your_script_name.py

agent_realty_app()
