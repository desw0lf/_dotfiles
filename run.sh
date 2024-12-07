#!/bin/bash

set -euo pipefail

# Enable debugging for troubleshooting (uncomment if needed)
#set -x

# Resolve the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: $SCRIPT_DIR"

# Config file specifying source and destination folders
CONFIG_FILE="$SCRIPT_DIR/config.txt"
ENV_FILE="$SCRIPT_DIR/.env"

# Ensure the config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file $CONFIG_FILE not found."
    exit 1
fi

# Load environment variables if an .env file exists
if [[ -f "$ENV_FILE" ]]; then
    echo "Loading environment variables from $ENV_FILE..."
    set -a # Automatically export variables
    source "$ENV_FILE"
    set +a
else
    echo "No .env file found. Injecting USER variable..."
fi

echo "==="
echo "==="

# Function to copy files or folders
replace_variables() {
    local input_file="$1"
    local output_file="$2"
    local current_user=$(whoami)

    awk '
    BEGIN {
        env_vars["USER"] = "'"$current_user"'"
        while ((getline var < "'"$ENV_FILE"'") > 0) {
            split(var, parts, "=")
            env_vars[parts[1]] = parts[2]
        }
    }
    {
        for (var in env_vars) {
            gsub("\\{\\{" var "\\}\\}", env_vars[var])
        }
        gsub("\\{\\{[^}]*\\}\\}", "")
        print
    }' "$input_file" > "$output_file"
}

copy_folder_or_file() {
    local src_path="$1"
    local dest_path="$2"
    local modify_contents="$3"

    dest_path="${dest_path/#\~/$HOME}"
    echo "Copying from $src_path to $dest_path..."

    if [[ ! -e "$src_path" ]]; then
        echo "Error: Source $src_path does not exist. Skipping..."
        return
    fi

    # If it's a directory and modify_contents is true, recursively replace variables
    if [[ -d "$src_path" && "$modify_contents" == "true" ]]; then
        mkdir -p "$dest_path"
        find "$src_path" -type f | while read -r file; do
            relative_path="${file#$src_path/}"
            dest_file="$dest_path/$relative_path"
            
            mkdir -p "$(dirname "$dest_file")"
            replace_variables "$file" "$dest_file"
        done
    # If it's a single file and modify_contents is true
    elif [[ -f "$src_path" && "$modify_contents" == "true" ]]; then
        mkdir -p "$(dirname "$dest_path")"
        replace_variables "$src_path" "$dest_path"
    # If modify_contents is false, use standard copy
    elif [[ -d "$src_path" ]]; then
        mkdir -p "$dest_path"
        rsync -av --exclude="_uncommon" "$src_path/" "$dest_path/"
    else
        cp "$src_path" "$dest_path"
    fi

    echo "Completed copying from $src_path to $dest_path."
    echo "---"
}

# Read the config file and process each mapping
while IFS='=' read -r src dest || [[ -n "$src" ]]; do
    # Skip empty lines or comments in the config file
    src=$(echo "$src" | xargs)
    dest=$(echo "$dest" | xargs)
    [[ -z "$src" || -z "$dest" || "$src" =~ ^# ]] && continue

    # Determine if contents should be modified
    modify_contents="false"
    if [[ "$src" =~ ^env:(.*) ]]; then
        src="${BASH_REMATCH[1]}" # Extract the actual source path
        modify_contents="true"
    fi

    # Debug: print mappings being processed
    echo "Processing mapping: $src -> $dest (Modify contents: $modify_contents)"

    # Resolve source folder or file relative to the script directory
    src_path="$SCRIPT_DIR/$src"
    dest_path="$dest"

    # Debug: print resolved paths
    echo "Resolved paths: Source = $src_path, Destination = $dest_path"

    copy_folder_or_file "$src_path" "$dest_path" "$modify_contents"
done < "$CONFIG_FILE"

echo "All tasks completed."
