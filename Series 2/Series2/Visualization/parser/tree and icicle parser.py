import csv
import json



def parse_csv_to_json(csv_data):
    root = None
    paths_processed = {}

    for row in csv_data:
        path, size = row
        parts = [part for part in path.split('/') if part]

        try:
            src_index = parts.index('src')
        except ValueError:
            continue

        relevant_path = parts[src_index + 1:]

        if root is None:
            for part in relevant_path:
                if part not in paths_processed:
                    paths_processed[part] = set()
                else:
                    root = {"name": part, "children": []}
                    break

        if root is None or parts[src_index + 1] != root["name"]:
            continue

        current_level = root["children"]
        for part in relevant_path[1:-1]:
            for child in current_level:
                if child["name"] == part:
                    break
            else:
                child = {"name": part, "children": []}
                current_level.append(child)
            current_level = child["children"]

        file_name = relevant_path[-1]
        current_level.append({"name": file_name, "size": int(size)})

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