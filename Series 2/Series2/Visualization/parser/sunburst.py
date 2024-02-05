import csv
import json
from collections import defaultdict

def parse_csv_to_json(csv_data):
    root = None
    file_counts = defaultdict(int)
    subfolders = defaultdict(lambda: {"name": "", "children": []})

    for row in csv_data:
        path, size = row
        parts = [part for part in path.split('/') if part]

        try:
            src_index = parts.index('src')
        except ValueError:
            continue

        relevant_path = parts[src_index + 1:]

        if root is None:
            file_counts[relevant_path[0]] += 1
            if file_counts[relevant_path[0]] > 1:
                root = {"name": relevant_path[0], "children": []}

        if root is None or parts[src_index + 1] != root["name"]:
            continue

        subfolder_name = relevant_path[1] if len(relevant_path) > 1 else ""
        if subfolder_name and subfolder_name not in subfolders:
            subfolders[subfolder_name]["name"] = subfolder_name

        file_name = relevant_path[-1]
        subfolders[subfolder_name]["children"].append({"name": file_name, "size": int(size)})

    for subfolder in subfolders.values():
        if subfolder["name"]:
            root["children"].append(subfolder)

    return json.dumps(root, indent=2) if root else None

def save_json_output(json_data, output_file_path):
    if json_data:
        with open(output_file_path, 'w', encoding='utf-8') as file:
            file.write(json_data)
    else:
        print("No valid root found for the JSON structure.")

def process_csv_to_json(csv_file_path, json_output_path):
    try:
        with open(csv_file_path, 'r', encoding='utf-8') as file:
            csv_reader = csv.reader(file)
            next(csv_reader)
            json_result = parse_csv_to_json(csv_reader)
            if json_result:
                save_json_output(json_result, json_output_path)
                return True
            else:
                return False
    except Exception as e:
        print(f"An error occurred: {e}")
        return False

csv_file_path = 'Export.csv'
json_output_path = 'export_files/output.json'
process_success = process_csv_to_json(csv_file_path, json_output_path)
if process_success:
    print("JSON file generated successfully.")
else:
    print("Failed to generate JSON file.")
