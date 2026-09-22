import json

with open('current_workflow_exported.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

wf = data[0] if isinstance(data, list) else data
conn = wf['connections']
nodes = {n['name']: n for n in wf['nodes']}

print('=== ALL NODES BY TYPE ===')
type_groups = {}
for name, n in nodes.items():
    t = n.get('type', 'unknown')
    type_groups.setdefault(t, []).append(name)

for t, names in type_groups.items():
    print(f'\n[{t}] ({len(names)}):')
    for nm in names:
        print(f'  - {nm}')

print('\n=== CONNECTIONS GRAPH (MAIN FLOW) ===')
for src, targets in conn.items():
    if 'main' in targets:
        for idx, branch in enumerate(targets['main']):
            b_str = ', '.join([x['node'] for x in branch])
            print(f'{src} [main:{idx}] -> {b_str}')

print('\n=== NON-MAIN CONNECTIONS (ai_languageModel, ai_memory, ai_tool) ===')
for src, targets in conn.items():
    for k, v in targets.items():
        if k != 'main':
            for branch in v:
                b_str = ', '.join([x['node'] for x in branch])
                print(f'{src} [{k}] -> {b_str}')
