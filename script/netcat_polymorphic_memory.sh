# Function to obfuscate a script using base64
obfuscate_base64() {
    local input_file="$1"
    local output_file="$2"

    # Ensure the input file exists
    if [[! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' not found." >&2
        return 1
    fi

    # Encode the entire input script into a single Base64 string
    encoded_payload=$(base64 -w 0 "$input_file")

    # Create the obfuscated wrapper script
    cat > "$output_file" << EOL
#!/usr/bin/env bash

# Encoded payload
PAYLOAD="$encoded_payload"

# Decode and execute the payload in memory
eval "\$(echo "\$PAYLOAD" | base64 -d)"
EOL

    # Make the output script executable
    chmod +x "$output_file"
    echo "Obfuscation complete. Output saved to: $output_file"
}