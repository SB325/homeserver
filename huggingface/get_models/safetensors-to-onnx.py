import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, AutoConfig
from optimum.exporters.onnx import main_export
import os, sys
import pdb

if len(sys.argv) < 2:
    print("Usage: python safetensors_to_onnx.py <model_path>")
    sys.exit(1)

# Configuration
model_dir = sys.argv[1]  # Folder containing config.json and .safetensors
output_dir = f"{model_dir}/onnx_output"
# pdb.set_trace()

# 1. Initialize and Export
# 'export=True' triggers the ONNX conversion process automatically
# 'trust_remote_code=True' is required for custom architectures like gpt_oss
print(f"Starting export for model at: {model_dir}")
config = AutoConfig.from_pretrained(model_dir, trust_remote_code=True)
model = AutoModelForCausalLM.from_pretrained(
    pretrained_model_name_or_path=model_dir,
    config=config,
    trust_remote_code=False,
    low_cpu_mem_usage=False, # DISABLING this stops the meta-to-cpu movement
    device_map=None,         # ENSURE this is None
    torch_dtype=torch.float32
)

# # 3. RUN EXPORT
# print("Starting ONNX export via Optimum...")
try:
    main_export(
        model_name_or_path=model_dir,
        output=output_dir,
        task="text-generation",
        trust_remote_code=False,
        do_validation=True # Skip validation if it causes key errors
    )
except Exception as e:
    print(f"Export failed: {e}")
    # FALLBACK: If main_export fails, the model type might not be in Optimum's registry.
    print("Attempting direct torch.onnx export fallback...")
    # (Optional manual torch.onnx.export logic here)

# # 4. SAVE TOKENIZER
# tokenizer = AutoTokenizer.from_pretrained(model_dir, trust_remote_code=True)
# tokenizer.save_pretrained(output_dir)