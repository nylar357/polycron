# **How to Use:**                          

# 1.  Save the code above as a Bash script (e.g., `poly_engine.sh`).                 
# 2.  Make it executable: `chmod +x poly_engine.sh`.                                 
# 3.  Run it: `./poly_engine.sh`.          

# Each time you run it, it will:           
# *   Display the original payload.        
# *   Randomly select one of the defined transformation techniques.                  
# *   Apply that technique to the payload.                                           
# *   Print the resulting polymorphic Bash script to the standard output.                                                                                               

# You can redirect the output to a file: `./poly_engine.sh > polymorphic_variant_$(date +%s).sh`                                                                        

# **Further Enhancements (More Complex):**                                           

# *   **Layering:** Apply multiple techniques sequentially (e.g., add junk, *then* base64 encode).                                                                      
# *   **Variable Renaming:** Parse the script (extremely hard in pure Bash, better with `awk` or dedicated tools) and replace variable names with random ones consistently.
# *   **Function Renaming:** Similar to variable renaming.                           
# *   **Code Flow Obfuscation:** Insert useless conditional branches (`if true; then ... fi`) or reorder independent commands.                                          
# *   **More Obfuscation:** Use different encodings (hex, octal), command substitution tricks (`$(which echo)` instead of `echo`), etc.                                 
# *   **Parameterization:** Allow passing the payload via file or stdin instead of hardcoding it.                                                                       
# *   **Robustness:** Add error checking; handle more complex Bash syntax (which this basic example will likely break).                        

#!/bin/bash                                                                                                                                                           
                                                                                                                                                                      
# --- Configuration ---                                                                                                                                               
                                                                                                                                                                      
# Define the payload (the code to be transformed)                                                                                                                     
# IMPORTANT: Keep this relatively simple for this basic engine.                                                                                                       
# Avoid complex quoting or structures that might break transformations.                                                                                               
read -r -d '' PAYLOAD <<'EOF'                                                                                                                                         
# --- Start of Payload ---                                                                                                                                            
MESSAGE="Hello from the Polymorphic Payload!"                                                                                                                         
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")                                                                                                                                
echo "[$TIMESTAMP] $MESSAGE"                                                                                                                                          
COUNT=3                                                                                                                                                               
echo "Looping $COUNT times..."                                                                                                                                        
for (( i=1; i<=COUNT; i++ )); do                                                                                                                                      
  echo " -> Iteration $i"                                                                                                                                             
  sleep 0.2                                                                                                                                                           
done                                                                                                                                                                  
echo "Payload execution finished."                                                                                                                                    
# --- End of Payload ---                                                                                                                                              
EOF                                      

# --- Polymorphism Techniques ---        
# Technique 1: Base64 Encode the entire payload                                    
apply_base64_encoding() {                
  local payload="$1"                     
  local encoded_payload                  
  # Use -w0 to prevent line wrapping in base64 output                              
  encoded_payload=$(echo "$payload" | base64 -w0)                                  

  # Create the polymorphic script using a decoder stub                             
  cat << EOF                             
#!/bin/bash                              
# Polymorphic Variant: Base64 Encoded                                              
# Timestamp: $(date +%s)                 
# Decoder:                               
encoded_data="$encoded_payload"          
eval "\$(echo "\$encoded_data" | base64 -d)"                                       
# Alternative execution: echo "\$encoded_data" | base64 -d | bash                  
exit \$? # Preserve exit code            
EOF                                      
}                                        

# --- Polymorphism Techniques ---   

# Technique 2: Add Junk Code (Comments, No-ops)                                    
apply_junk_code() {                      
  local payload="$1"                     
  local junked_payload=""                
  local junk_options=(                   
    "#"                             # Empty comment                                
    "# Random Junk: $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20)"                                                                                             
    ":"                             # Bash no-op command                           
    "true"                          # Bash no-op command                           
    "_junkvar_$$=$RANDOM"           # Unused variable (simple)                     
  )                                      
  # Process payload line by line         
  while IFS= read -r line; do            
    # Append original line               
    junked_payload+="$line"$'\n'         
    # Randomly add junk after some lines (e.g., 30% chance)                        
    if (( RANDOM % 10 < 3 )); then       
      local random_junk="${junk_options[ RANDOM % ${#junk_options[@]} ]}"                                                                                             
      junked_payload+="$random_junk"$'\n'                                          
    fi                                   
  done <<< "$payload"                    

  # Wrap the junked payload in a basic script structure                            
  cat << EOF                             
#!/bin/bash                              
# Polymorphic Variant: Junk Code Added                                             
# Timestamp: $(date +%s)                 

$junked_payload                          
exit \$? # Preserve exit code            
EOF                                      
}                                        

# Technique 3: Simple String Obfuscation (using printf \xNN)                       
# WARNING: Very basic, only targets the specific MESSAGE string in the payload                                                                                        
apply_string_obfuscation() {             
  local payload="$1"                     
  local target_string="Hello from the Polymorphic Payload!"                        
  local obfuscated_string_cmd            

  # Generate printf command with hex escapes for the target string                 
  obfuscated_string_cmd=$(printf '\\x%02x' $(echo -n "$target_string" | od -An -t x1 | tr -d ' \n'))                                                                  
  obfuscated_string_cmd="\"\$(printf '${obfuscated_string_cmd}')\""                

  # Replace the literal string in the payload                                      
  # Using awk for slightly more robust replacement than sed for this case                                                                                             
  local obfuscated_payload               
  obfuscated_payload=$(awk -v search="\"$target_string\"" -v replace="$obfuscated_string_cmd" '{gsub(search, replace)}1' <<< "$payload")    
  # Wrap the modified payload            
  cat << EOF                             
#!/bin/bash                              
# Polymorphic Variant: String Obfuscation (Basic)                                  
# Timestamp: $(date +%s)                 

$obfuscated_payload                      
exit \$? # Preserve exit code            
EOF                                      
}                                        

# Technique 4: Variable Wrapper + Eval                                             
apply_var_eval() {                       
    local payload="$1"                   
    # Generate a random variable name                                              
    local var_name="_polydat_$(head /dev/urandom | tr -dc a-z | head -c 8)"                                                                                           

    # Escape payload for use within double quotes and variable assignment                                                                                             
    # Simple escaping: Escape backslashes, double quotes, and dollar signs                                                                                            
    local escaped_payload                
    escaped_payload=$(echo "$payload" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\\$/g')                                                                         

    cat << EOF                           
#!/bin/bash                              
# Polymorphic Variant: Variable Wrapper + Eval                                     
# Timestamp: $(date +%s)                 

$var_name="$escaped_payload"             

eval "\$${var_name}"                     
exit \$? # Preserve exit code            
EOF                                      
}                                        


# --- Polymorphism Engine Main Logic ---              
echo "--- Polymorphism Engine ---"       
echo "Original Payload:"                 
echo "-------------------------"         
echo "$PAYLOAD"                          
echo "-------------------------"         
echo                                     

# Array of function names representing the techniques                              
techniques=(                             
  apply_base64_encoding                  
  apply_junk_code                        
  apply_string_obfuscation               
  apply_var_eval                         
  # Add more technique functions here                                              
)                                        

# Randomly choose one technique to apply                                           
num_techniques=${#techniques[@]}         
chosen_index=$(( RANDOM % num_techniques ))                                        
chosen_technique=${techniques[chosen_index]}                                       

echo "Applying Technique: $chosen_technique"                                       

# Execute the chosen technique function, passing the payload                       
# and capture the output (the polymorphic script)                                  
polymorphic_script=$("$chosen_technique" "$PAYLOAD")                               

echo                                     
echo "Generated Polymorphic Script:"                                               
echo "-----------------------------"                                               
echo "$polymorphic_script"               
echo "-----------------------------"                                               
echo                                     
# --- Optional: Execute the generated script to verify ---                         
# echo "Executing generated script..."                                             
# echo "--- Output ---"                  
# bash <(echo "$polymorphic_script")                                               
# echo "--- End Output ---"              

echo "Engine finished."                  
