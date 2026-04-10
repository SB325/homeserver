#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 ./safetensors_to_onnx.py <model_repo_root>"
    exit 1
fi

# Assign the argument to a readable variable
REPO_ROOT=$1

echo "Starting vLLM with model: $MODEL_NAME"

# 1. Your list of models
MODELS_LIST=(
    # "Qwen/Qwen3-4B-Instruct-2507-FP8"                               # "Text Generation"
    # Qwen/Qwen3-4B-AWQ                                   # "Text Generation"
    # "Qwen/Qwen3.5-4B"                                   # "Image-Text to Text"
    Qwen/Qwen2.5-VL-3B-Instruct                            # "Image-Text to Text - Non thinking"
    # "stabilityai/stable-diffusion-xl-refiner-1.0"       # "Image to Image / Text to Image"
    # "Wan-AI/Wan2.2-TI2V-5B"                             # "Text to Video"
    # "facebook/mms-tts-eng"                              # "Text to Speech"
    # "nvidia/nemotron-colembed-vl-4b-v2"                 # "Text to Visual Document"
    # "sentence-transformers/all-MiniLM-L12-v2"           # "Sentence Similarity"
    # "openai/whisper-base"                               # "Speech to text"
    # "openai/whisper-small"                              # "Speech to text"
    # "TostAI/nsfw-text-detection-large"                  # "NSFW text model"
    # "Falconsai/nsfw_image_detection"                    # "NSFW image model"
    # "protectai/deberta-v3-base-prompt-injection"        # "Prompt Injection classifier"
)

# 2. Define where the repository should be created
# REPO_ROOT="/mnt/bulkStorage/llm/models"

# 3. Setup separators (comma and newline)
OLD_IFS=$IFS
IFS=$',\n'

echo "Creating Model Directory at: $REPO_ROOT"
mkdir -p "$REPO_ROOT"

for MODEL in ${MODELS_LIST[@]}; do
    # Clean whitespace
    MODEL_NAME=$(echo "$MODEL" | xargs)
    
    # Skip if the string is empty
    [ -z "$MODEL_NAME" ] && continue

    echo "--- Setting up: $MODEL_NAME ---"

    # Create the model folder and version '1' folder
    MODEL_DIR="$REPO_ROOT/$MODEL_NAME/1"
    sudo mkdir -p "$MODEL_DIR"
    sudo chmod -R 777 "$MODEL_DIR"
    echo "Created: $MODEL_DIR"
    ONNX_DIR="$MODEL_DIR/onnx"
    sudo mkdir -p $ONNX_DIR

    /home/sheldon/.local/bin/hf download $MODEL_NAME --local-dir "$MODEL_DIR" # --include "*.safetensors" "config.json" "tokenizer.json" "original/*" 

    HF_CONFIG="$MODEL_DIR/config.json"
    # FILES=("$MODEL_DIR/original/*.safetensors")
    # HOST_DIR="$MODEL_DIR/original/"
    FILES=("$MODEL_DIR"/*.safetensors)
    HOST_DIR="$MODEL_DIR"

    # if [  ${#FILES[@]} -eq 0 ]; then
    #     FILES=("$MODEL_DIR/*.safetensors")
    # fi

    # 2. Logic to detect model type from config.json
    echo "Number of Files present: ${#FILES[@]}"
    if [[ ${#FILES[@]} -ne 0 ]]; then
        # Extract the model_type field using jq
        MODEL_TYPE=$(jq -r '.model_type // empty' "$HF_CONFIG")
        echo "Detected Hugging Face model type: $MODEL_TYPE"
        
        # Logic to switch backends based on type if needed
        # (e.g., if you plan to use Fil for XGBoost or specialized backends)

        # Install Hugging Face Optimum with ONNX exporters
        ## pip install "optimum[exporters]" onnx onnxruntime-gpu
        # echo "Running nvidia/pytorch container..."
        # docker run -d \
        #     --gpus all \
        #     -dit --name \
        #     pytorch_ngc \
        #     -v $MODEL_DIR:/work \
        #     nvcr.io/nvidia/pytorch:26.02-py3 bash

        # echo "Done."

        # echo "Installing optimum, onnx, onnxruntime-gpu, accelerate..."

        # docker exec pytorch_ngc python -m pip install --upgrade pip
        # docker exec pytorch_ngc \
        #     python -m pip install \
        #     optimum[onnxruntime-gpu] \
        #     accelerate

        # echo "Done."

        # docker exec pytorch_ngc \
        #     optimum-cli export onnx \
        #     --model /work \
        #     --task text-generation-with-past \
        #     --trust-remote-code \
        #     /work/onnx

#         # echo "Quantizing the model to INT8..."
#         docker exec pytorch_ngc \
#             python -c '
# from optimum.onnxruntime import ORTOptimizer
# from optimum.onnxruntime.configuration import OptimizationConfig

# optimizer = ORTOptimizer.from_pretrained("/work/onnx_fp16")
# optimization_config = OptimizationConfig(optimization_level=99, fp16=True)
# optimizer.optimize(save_dir="/work/onnx_fp16_optimized", optimization_config=optimization_config)
# '

        # echo "Done."
        # echo "Stopping and Removing pytorch_ngc container..."
        # docker stop pytorch_ngc
        # docker rm pytorch_ngc

        # echo "Done."
    fi
done

# # Restore separator
# IFS=$OLD_IFS
# echo "--------------------------------"
# echo "Done!"