import json

# Target positions mapping
NEW_POSITIONS = {
    # === ZONE 1: Ingestion & Security Gate (Y = 1000) ===
    "WhatsApp Universal Ingestion Webhook": [8500, 1000],
    "WhatsApp Input Normalizer": [8740, 1000],
    "Find Existing Inbound Event": [8980, 1000],
    "Drop Duplicate Inbound Event": [9220, 1000],
    "Send Immediate Receipt (WhatsApp)": [9460, 1000],
    "Restore Normalized Input After Receipt": [9700, 1000],
    "Apply Soft Rate Limit": [9940, 1000],
    "If Soft Rate Limit Exceeded": [10180, 1000],
    "Send Rate Limit Queue Notice": [10440, 820],

    # === ROUTER WATERFALL (X = 10440) ===
    "If Is Deterministic Report": [10440, 1000],
    "If Is Export Command": [10440, 1180],
    "If Is Fast Command (Menu/Greeting)": [10440, 1360],

    # === ZONE 2: Deterministic Report Track (Y = 520) ===
    "Fetch Deterministic Report Data": [10740, 520],
    "Build Deterministic Report": [11000, 520],
    "Send Deterministic Report": [11260, 520],

    # === ZONE 3: Excel Spreadsheet Export Track (Y = 740) ===
    "Fetch User Transactions for Export": [10740, 740],
    "Format Rows for Spreadsheet": [11000, 740],
    "If Has Transactions to Export": [11260, 740],
    "Generate Excel Spreadsheet": [11520, 680],
    "Convert Spreadsheet to Base64": [11780, 680],
    "Send WhatsApp Spreadsheet Document": [12040, 680],
    "Send No Data Alert (WhatsApp)": [11520, 820],

    # === ZONE 4: Fast Command (Menu/Greeting) Instant Response (Y = 1360) ===
    "Prepare Instant Response (Menu/Greeting)": [10740, 1360],

    # === ZONE 5: AI Multimodal Financial Agent Cascade (Y = 1600) ===
    "Send Progress Notification (WhatsApp)": [10740, 1600],
    "Attach WA Multimodal Data": [11000, 1600],

    # Tier 1 - Gemini Utama
    "UMKMense AI Financial Agent (Gemini Utama)": [11300, 1600],
    "Google Gemini Model (Akun 1 - Utama)": [11300, 1420],
    "Reset Context for Gemini 2": [11560, 1600],

    # Tier 2 - Gemini Cadangan 1
    "UMKMense AI Financial Agent (Gemini Cadangan 1)": [11820, 1600],
    "Google Gemini Model (Akun 2 - Cadangan 1)": [11820, 1420],
    "Reset Context for Gemini 3": [12080, 1600],

    # Tier 3 - Gemini Cadangan 2
    "UMKMense AI Financial Agent (Gemini Cadangan 2)": [12340, 1600],
    "Google Gemini Model (Akun 3 - Cadangan 2)": [12340, 1420],
    "Reset Context for Groq": [12600, 1600],

    # Tier 4 - Groq 120B
    "UMKMense AI Financial Agent (Groq GPT OSS 120B)": [12860, 1600],
    "Groq Cloud Model (Akun Groq - Penyelamat 14.400)": [12860, 1420],
    "Reset Context for Vibe": [13120, 1600],

    # Tier 5 - Vibe Luna
    "UMKMense AI Financial Agent (Vibe Luna)": [13380, 1600],
    "Vibe AI Model (Cadangan Darurat)": [13380, 1420],
    "Reset Context for Vibe Grok 4.5": [13640, 1600],

    # Tier 6 - Vibe Grok 4.5
    "UMKMense AI Financial Agent (Vibe Grok 4.5)": [13900, 1600],
    "Vibe AI Model (Grok 4.5)": [13900, 1420],
    "Reset Context for Vibe Grok 4.6": [14160, 1600],

    # Tier 7 - Vibe Grok 4.6
    "UMKMense AI Financial Agent (Vibe Grok 4.6)": [14420, 1600],
    "Vibe AI Model (Grok 4.6)": [14420, 1420],

    # Shared Outbound Node
    "Send WhatsApp Message (Evolution API)": [14720, 1600],

    # AI Shared Tools & Memory (Y = 1860)
    "WA User-Isolated Memory": [11820, 1860],
    "insert_transaction": [12120, 1860],
    "get_transactions": [12420, 1860],
    "financial_summary": [12720, 1860],
    "tool_payment_reminder": [13020, 1860],
    "tool_void_transaction": [13320, 1860],

    # === ZONE 6: Kasbon Autonomous Scheduled Monitor (Y = 2160) ===
    "Realtime Minute WA Kasbon Monitor": [8500, 2160],
    "Fetch Due Data Table (WA)": [8760, 2160],
    "Check Due Kasbon (WA Engine)": [9020, 2160],
    "Prepare Reminder State Update": [9280, 2160],
    "Persist Reminder Sent State": [9540, 2160],
    "Restore Reminder Dispatch Payload": [9800, 2160],
    "Send Due Alert to WhatsApp (Evolution API)": [10060, 2160],
    "Prepare Final Reminder State": [10320, 2160],
    "Persist Final Reminder Sent State": [10580, 2160],
}

def main():
    with open('current_workflow_exported.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    wf = data[0] if isinstance(data, list) else data

    existing_node_names = set(n['name'] for n in wf['nodes'])
    mapped_names = set(NEW_POSITIONS.keys())

    missing_in_mapping = existing_node_names - mapped_names
    extra_in_mapping = mapped_names - existing_node_names

    print(f"Total existing nodes: {len(existing_node_names)}")
    print(f"Total mapped nodes: {len(mapped_names)}")
    print(f"Missing in mapping: {missing_in_mapping}")
    print(f"Extra in mapping: {extra_in_mapping}")

    # Check for any overlapping positions
    positions_seen = {}
    overlaps = []
    for name, pos in NEW_POSITIONS.items():
        pos_key = tuple(pos)
        if pos_key in positions_seen:
            overlaps.append((name, positions_seen[pos_key], pos))
        else:
            positions_seen[pos_key] = name

    if overlaps:
        print("WARNING: Overlaps found:", overlaps)
    else:
        print("SUCCESS: Zero overlapping coordinates!")

if __name__ == '__main__':
    main()
