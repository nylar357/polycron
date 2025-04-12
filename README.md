## Table of Contents                                                                                                                                                                                                                 
                                                                                                                                                                                                                                     
*   [What is Polycron?](#what-is-polycron)                                                                                                                                                                                           
*   [Why Use Polycron?](#why-use-polycron)                                                                                                                                                                                           
*   [How it Works: The Polymorphic Engine](#how-it-works-the-polymorphic-engine)                                                                                                                                                     
*   [Features](#features)                                                                                                                                                                                                            
*   [Installation](#installation)                                                                                                                                                                                                    
*   [Configuration (`polycron_config.yaml`)](#configuration-polycron_configyaml)                                                                                                                                                     
*   [Usage](#usage)                                                                                                                                                                                                                  
*   [**🚨 Safety Considerations**](#️ -safety-considerations)                                                                                                                                                                            [Dependencies](#dependencies)                                                                                                                                                                                                    
*   [Example Configuration](#example-configuration)                                                                                                                                                                                  
*   [Contributing](#contributing)                                                                                                                                                                                                    
*   [License](#license)                                                                                                                                                                                                              
                                                                                                                                                                                                                                     
---                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                     
## What is Polycron?                                                                                                                                                                                                                 
                                                                                                                                                                                                                                     
Polycron is a task scheduler script designed to run jobs (commands or scripts) at intervals, similar to the standard `cron` daemon. However, unlike `cron`'s fixed schedules, Polycron introduces **polymorphism** into task executio
n. This means the exact timing, and potentially other parameters, of job executions can vary based on predefined rules, adding an element of unpredictability or dynamic adaptation.                                                 
                                                                                                                                                                                                                                     
## Why Use Polycron?                                                                                                                                                                                                                 
                                                                                                                                                                                                                                     
*   **Less Predictable Schedules:** Useful in security scenarios where predictable cron timings might be exploited or detected (e.g., penetration testing, honeypots).                                                               
*   **Load Spreading:** Introduce jitter or randomization to avoid multiple heavy tasks starting at the exact same second across many systems.                                                                                       
*   **Dynamic Execution:** Potentially adapt job execution based on simple system state checks (though complex logic should be handled within the job script itself).                                                                
*   **Centralized Config:** Manage dynamically scheduled tasks through a configuration file.                                                                                                                                         
                                                                                                                                                                                                                                     
## How it Works: The Polymorphic Engine                                                                                                                                                                                              
                                                                                                                                                                                                                                     
Polycron operates based on a configuration file (e.g., `polycron_config.yaml`). It reads this file to understand the jobs to be run and the rules governing their execution.                                                         
                                                                                                                                                                                                                                     
1.  **Configuration Loading:** Polycron parses the configuration file at startup.                                                                                                                                                    
2.  **Job Definitions:** Each job has a `name`, the `command` to execute, and a `schedule_type`.                                                                                                                                     
3.  **Scheduling Logic:** Based on the `schedule_type` and its associated parameters, Polycron determines the *next* execution time for each job. This is where polymorphism occurs:                                                 
    *   **`fixed_interval`:** Runs roughly every X minutes/hours (like basic cron, but managed by Polycron).                                                                                                                         
    *   **`random_interval`:** Runs at a random interval between a defined `min` and `max` duration. The *exact* time is unpredictable within the bounds.                                                                            
    *   **`fixed_jitter`:** Runs based on a fixed base schedule (like `0 3 * * *`) but adds a random delay (jitter) up to a specified maximum.                                                                                       
    *   **(Future/Potential) `state_dependent`:** Execution might depend on the success/failure of a simple check command.                                                                                                           
4.  **Dispatcher Loop:** Polycron runs a main loop that continuously checks if any job's next scheduled execution time has arrived.                                                                                                  
5.  **Execution:** When a job is due, Polycron executes its defined `command` in a subprocess.                                               
6.  **Rescheduling:** After a job executes (or fails according to retry logic, if implemented), Polycron calculates its *next* polymorphic execution time based on its rules.
7.  **Logging:** Polycron logs its actions, including job executions, calculated run times, and any errors.

 # Features                                                                                                                                                   

**This is a Bash script demonstrating the concepts of polymorphism, cron job creation, and self-trace removal.  
**Ethical Use:** This script is provided for educational purposes only to demonstrate scripting techniques. Using such techniques for malicious purposes (e.g., hiding malware or unauthorized access) is illegal and unethical. You are responsible for how you use this code.       
**Polymorphism:** The polymorphism implemented here is basic (variable/function renaming, comment/whitespace changes). Sophisticated detection methods could still potentially identify patterns. Real-world polymorphic malware uses far more complex techniques.                    
**Trace Removal:** Trace removal, especially history cleaning, is unreliable and shell-dependent. Log entries created by the system (syslog, journald) are generally *not* removed by this script, as doing so usually requires root privileges and risks damaging the system or beingeasily detected. Deleting the script file itself is the most reliable part of the cleaning.                                                 
**Potential Bugs:** Self-modifying code is inherently complex and can be prone to bugs. Test carefully in a safe environment.            
**Permissions:** The script needs execute permissions (`chmod +x`). Adding a cron job requires the user running the script to have cron privileges. 
                                                                      
                                                                                                                                                              **Configuration:** Define the command (`payload_cmd_...`) and schedule (`cron_schedule_...`) for the cron job. A unique tag (`script_id_tag_...`) is generated based on the command to prevent adding the same job multiple times.                                                                                                                                                                                                                                     
2.  **Polymorphism (`mutate_self_...`):**                                                                         
    *   It reads its own code (`$0`).                                                                             
    *   It generates new random names for its variables and functions (those marked with `_xxxx` random suffixes).                                                                                                                   
    *   It uses `sed` to replace the *current* known names with the *newly generated* random names throughout the script.                                                                                                            
    *   It adds a random comment and a blank line at random locations for minor structural changes.                                                                                                                                  
    *   It writes this modified code to a temporary file.                                                         
    *   It makes the temporary file executable.                                                                   
    *   It *replaces* the original script file with the new, mutated version using `mv`. This prepares the script for a potential *next* execution, ensuring it looks different.                                                     
3.  **Cron Job Setup (`setup_cron_...`):**                                                                        
    *   Checks if the `crontab` command exists.                                                                   
    *   Lists the current user's crontab (`crontab -l`).                                                          
    *   Uses `grep -Fq` to check if a line containing the unique `script_id_tag_...` already exists. The tag ensures it doesn't add duplicate entries if the script runs again.                                                      
    *   If the tag isn't found, it appends the new cron job line (schedule + command + tag comment) to the existing crontab contents and pipes it back into `crontab -`.                                                             
4.  **Self-Cleaning (`clean_traces_...`):**                                                                       
    *   Attempts `history -c && history -w` to clear the *current* shell's history buffer. **This is unreliable** and easily circumvented or logged elsewhere.                                                                       
    *   Schedules the deletion of the script file itself (`rm -- "$script_abs_path"`) using `sleep 1 && rm ... &`. The `sleep` gives the main script time to exit, `&` runs it in the background, `nohup` (implied by `&` often, but explicit is safer) and `disown` attempt to detach it from the terminal, allowing `rm` to run even after the script's shell has exited. It uses the absolute path determined earlier. Output is redirected to `/dev/null`.
5.  **Main Logic (`main_logic_...`):**                                                                            
    *   Gets the absolute path of the script (`readlink -f "$0"`).                                                
    *   Calls the `setup_cron` function.                                                                          
    *   Calls the `mutate_self` function to change the script file on disk.                                                                                                                                                          
    *   Calls the `clean_traces` function to schedule self-deletion and attempt history clearing.                                                                                                                                    
    *   Exits.                                                                                                                                                                                                                  
                                                                                                                                                                                                                                     
## Installation                                                                                                                                                                                                                      
                                                                                                                                                                                                                                     
1.  **Clone the repository:**                                                                                                                                                                                                        
    ```bash                                                                                                                                                                                                                          
    git clone https://github.com/yourusername/polycron.git # Replace with your repo URL                                                                                                                                              
    cd polycron                                                                                                                                                                                                                      
    ```                                                                                                                                                                                                                              
                                                                                                                                                                                                                                     
2.  **Install Dependencies:**                                                                                                                                                                                                        
    (Assuming Python and PyYAML, adjust as needed)                                                                                                                                                                                   
    ```bash                                                                                                                                                                                                                          
    pip install -r requirements.txt                                                                                                                                                                                                  
    # Or: pip install PyYAML                                                                                                                                                                                                         
    ```
    ## 🚨 Safety Considerations                              

Running automated tasks requires careful attention to security and stability. Polycron adds complexity, so be extra vigilant.                                                                                                        

1.  **Principle of Least Privilege:**                                                                             
    *   **Run Polycron as a non-root user:** Create a dedicated user with minimal permissions specifically for running Polycron.                                                                                                     
    *   **Run Jobs with Minimal Permissions:** Ensure the commands/scripts defined in the config file only have the permissions they strictly need. Avoid running jobs as root unless absolutely necessary and fully understood.
    *   **`user` Directive:** Using the `user` field in the config requires careful setup (Polycron might need root initially or `sudo` rules). Prefer running Polycron itself as the target user if possible.

2.  **Command Injection:**                               
    *   **Never construct commands from untrusted input.** The `command` field in the config should contain static, fully-formed commands or script paths.                                                                           
    *   **Secure the Configuration File:** The `polycron_config.yaml` file dictates what gets executed. Treat it like code. Ensure only trusted users can modify it. Set strict file permissions (e.g., `chmod 600`).

3.  **Resource Management:**                             
    *   **Monitor Performance:** The unpredictable nature might lead to jobs running closer together than expected. Monitor system load, memory, and I/O.                                                                            
    *   **Avoid Resource Hogs:** Be mindful of jobs that consume significant resources. Random intervals could cause spikes.                                                                                                         
    *   **Job Overlap:** Polycron might not prevent a long-running job instance from overlapping with the next scheduled start. Design your jobs to handle this (e.g., use lockfiles) or accept the potential overlap.

4.  **Error Handling and Logging:**                                                                               
    *   **Check Logs Regularly:** Monitor Polycron's log file and the output/logs of the jobs it runs.                                                                                                                               
    *   **Job Failure:** Understand how Polycron handles job failures (does it retry? log and move on?). Implement error handling *within* your scripts where possible.                                                              

5.  **Filesystem Paths:**                                
    *   **Use Absolute Paths:** Always use absolute paths for commands, scripts, and output files in your configuration to avoid ambiguity related to the working directory.                                                         

6.  **Complexity:**                                      
    *   Polymorphic scheduling is inherently more complex than fixed cron schedules. Debugging timing issues can be more challenging. Start with simpler configurations and test thoroughly.

7.  **Testing:**                                         
    *   **Test Thoroughly:** Before deploying in a production environment, test Polycron and your job configurations extensively in a safe, isolated testing environment. Test edge cases and failure modes.

**Disclaimer:** Use Polycron responsibly. The authors are not responsible for any damage or security incidents caused by improper configuration or use of this script.                                                                                                                           
