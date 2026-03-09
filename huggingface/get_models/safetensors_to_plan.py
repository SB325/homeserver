import subprocess

if len(sys.argv) < 2:
    print("Usage: python safetensors_to_plan.py <model_path>")
    sys.exit(1)

model_dir = sys.argv[1]  
# Install tensorrt_llm
# pip install tensorrt_llm -U --pre --extra-index-url https://pypi.nvidia.com

# Convert Safetensors to Checkpoint
response = subprocess.run(
        f"python examples/llama/convert_checkpoint.py \
            --model_dir {model_dir} \
            --output_dir {model_dir} \
            --dtype float16 \
            --use_weight_only \
            --weight_only_precision int4",
        capture_output=True,  # Capture stdout and stderr
        text=True,           # Decode output as text (UTF-8 by default)
        shell=True           # Raise CalledProcessError if the command returns a non-zero exit code
    )

# Build The .plan
response = subprocess.run(
        f"trtllm-build --checkpoint_dir {model_dir}./model_ckpt_int4 \
             --output_dir {model_dir}./model_engine_int4 \
             --gemm_plugin float16 \
             --weight_only_precision int4",
        capture_output=True,  # Capture stdout and stderr
        text=True,           # Decode output as text (UTF-8 by default)
        shell=True           # Raise CalledProcessError if the command returns a non-zero exit code
    )