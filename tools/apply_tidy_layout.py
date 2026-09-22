import json
from verify_mapping import NEW_POSITIONS

def main():
    with open('current_workflow_exported.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    is_list = isinstance(data, list)
    wf = data[0] if is_list else data

    for node in wf['nodes']:
        name = node['name']
        if name in NEW_POSITIONS:
            node['position'] = NEW_POSITIONS[name]
        else:
            print(f"Warning: node {name} not in mapping!")

    output_path = 'workflow_tidied.json'
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"Successfully saved updated workflow to {output_path}")

if __name__ == '__main__':
    main()
