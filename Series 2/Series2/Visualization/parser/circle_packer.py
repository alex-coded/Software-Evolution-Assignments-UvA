import csv
import json

def build_hierarchy(starting_folder, paths):
    root = {"name": "flare", "children": []}
    for path, size in paths:
        parts = path.split('/')
        if parts[1] != starting_folder:
            continue
        node = root
        for i, part in enumerate(parts[2:]):
            next_node = None
            for child in node.get("children", []):
                if child["name"] == part:
                    next_node = child
                    break

            if next_node is None:
                if i == len(parts[2:]) - 1:
                    next_node = {"name": part, "value": size}
                else:
                    next_node = {"name": part, "children": []}
                node.setdefault("children", []).append(next_node)

            node = next_node

    return root

def parse_csv_and_generate_json(csv_file):
    paths = []
    with open(csv_file, newline='') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)
        for row in reader:
            path = row[0]
            try:
                size = int(row[1])
            except ValueError:
                continue
            src_index = path.index('/src/') + 1
            trimmed_path = path[src_index:].strip('/')
            paths.append((trimmed_path, size))

    starting_folder = find_starting_point(paths)
    if not starting_folder:
        raise ValueError("Could not find a starting folder with multiple subfolders.")

    hierarchy = build_hierarchy(starting_folder, paths)
    return json.dumps(hierarchy, indent=2)

def find_starting_point(paths):
    folder_counts = {}
    for path, _ in paths:
        parts = path.split('/')
        if len(parts) > 2:
            folder = parts[1]
            folder_counts[folder] = folder_counts.get(folder, 0) + 1

    for folder, count in folder_counts.items():
        if count > 1:
            return folder
    return None


def save_json_to_file(json_data, output_file):
    with open(output_file, 'w') as file:
        file.write(json_data)


csv_file = 'Export.csv'
output_json_file = 'export_files/output.json'

json_output = parse_csv_and_generate_json(csv_file)
save_json_to_file(json_output, output_json_file)
