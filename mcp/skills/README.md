my_agent/
│
├── main.py                 # The script below
└── skills/
    ├── db_diagnostic.md    # The DB tool markdown from the previous step
    └── git_helper.md       # Another modular skill markdown file

import os
import re
import yaml
from vllm import LLM, SamplingParams

# ---------------------------------------------------------
# 1. CORE UTILITIES FOR PROGRESSIVE DISCLOSURE
# ---------------------------------------------------------

def load_skills_discovery_index(skills_dir: str) -> dict:
    """
    Scans the skills directory and extracts ONLY metadata.
    This creates the lightweight 'Discovery Layer' (~50 tokens per skill).
    """
    discovery_index = {}
    
    if not os.path.exists(skills_dir):
        return discovery_index

    for file_name in os.listdir(skills_dir):
        if file_name.endswith('.md'):
            file_path = os.path.join(skills_dir, file_name)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Extract YAML Frontmatter
            match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
            if match:
                metadata = yaml.safe_load(match.group(1))
                skill_name = metadata.get('name')
                
                # Store the lightweight description and the full file path for later
                discovery_index[skill_name] = {
                    "description": metadata.get('description'),
                    "file_path": file_path
                }
    return discovery_index


def load_full_playbook(file_path: str) -> str:
    """
    Loads the heavy instruction body (Activation Layer).
    Executed ONLY when a skill is selected by the model.
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Strip out the YAML frontmatter to save token space
    return re.sub(r'^---\s*\n.*?\n---\s*\n', '', content, flags=re.DOTALL)


# ---------------------------------------------------------
# 2. RUNTIME AGENT LOOP (vLLM ENGINE)
# ---------------------------------------------------------

# Initialize the open-weight model using vLLM
# (Using a standard open-weight model like Mistral-7B-Instruct or Llama-3 as an example)
print("Initializing vLLM Engine...")
llm = LLM(model="mistralai/Mistral-7B-Instruct-v0.3", tensor_parallel_size=1)
sampling_params = SamplingParams(temperature=0.0, max_tokens=150)

# Build our Discovery Index from the local folder
SKILLS_DIRECTORY = "./skills"
discovery_index = load_skills_discovery_index(SKILLS_DIRECTORY)

# Format the lightweight Discovery Layer list for the System Prompt
discovery_prompt_snippet = ""
for name, data in discovery_index.items():
    discovery_prompt_snippet += f"- Skill Name: {name}\n  Trigger condition: {data['description']}\n"

# The user brings a real problem
user_problem = "Hey, our production database is throwing timeout flags and query execution times are spiking!"

# STAGE 1: Discovery Prompt Construction
system_prompt = f"""You are an advanced agent routing coordinator.
Analyze the user's issue and output EXACTLY the name of the skill needed to handle it.
If no skill matches, output 'NONE'. Do not include extra text.

Available Skills:
{discovery_prompt_snippet}
"""

conversation_history = [
    {"role": "system", "content": system_prompt},
    {"role": "user", "content": user_problem}
]

# Ask vLLM to route the task using our ultra-lean context window
print("\n--- STAGE 1: Evaluating Lean Discovery Window ---")
outputs = llm.chat(conversation_history, sampling_params=sampling_params)
selected_skill = outputs[0].outputs[0].text.strip()
print(f"Model Routing Decision: Injected into context -> [{selected_skill}]")

# STAGE 2: Dynamic Activation Layer Injection
if selected_skill in discovery_index:
    print(f"\n--- STAGE 2: Activating full [{selected_skill}] Playbook ---")
    
    # Fetch the deep instructions on-demand
    playbook_path = discovery_index[selected_skill]["file_path"]
    full_playbook_instructions = load_full_playbook(playbook_path)
    
    # Mutate the context: We inject the playbook right into the conversation flow
    activation_prompt = f"""You have activated the `{selected_skill}` capability. 
Follow these guidelines strictly to solve the issue:

{full_playbook_instructions}
"""
    
    # Update the chat history dynamically
    conversation_history.append({"role": "system", "content": activation_prompt})
    conversation_history.append({"role": "user", "content": "Proceed with Step 1 of the activated playbook."})
    
    # Run the model again, now fully specialized with the necessary tools and constraints
    execution_params = SamplingParams(temperature=0.2, max_tokens=500)
    outputs = llm.chat(conversation_history, sampling_params=execution_params)
    
    print("\n--- STAGE 3: Agent Execution Output ---")
    print(outputs[0].outputs[0].text)
else:
    print("\nNo specialized skill playbook needed. Proceeding with standard generalist weights.")
