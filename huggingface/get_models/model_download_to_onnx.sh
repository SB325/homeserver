#!/bin/bash

# 1. Your list of models
MODELS_LIST=(
    # "meta_llama/Meta_Llama_3-8B_Instruct"               # "Text Generation"
    # "stabilityai/stable-diffusion-xl-refiner-1.0"       # "Image to Image / Text to Image"
    # "openai/whisper-small"                              # "Speech to text"
    # "OpenMOSS-Team/MOSS-TTSD-v1.0"                      # "Text to Speech"
    # "nvidia/nemotron-colembed-vl-4b-v2"                 # "Visual Document Retrieval"
    # "sentence-transformers/all-MiniLM-L12-v2"           # "Sentence Similarity"
    # "TostAI/nsfw-text-detection-large"                  # "NSFW text model"
    # "Falconsai/nsfw_image_detection"                    # "NSFW image model"
    # "protectai/deberta-v3-base-prompt-injection"        # "Prompt Injection classifier"
)

# 2. Define where the repository should be created
REPO_ROOT="/mnt/bulkStorage/triton/models"

# 3. Setup separators (comma and newline)
OLD_IFS=$IFS
IFS=$',\n'

echo "Creating Triton Repository at: $REPO_ROOT"
mkdir -p "$REPO_ROOT"

for MODEL in ${MODELS_LIST[@]}; do
    # Clean whitespace
    MODEL_NAME=$(echo "$MODEL" | xargs)
    
    # Skip if the string is empty
    [ -z "$MODEL_NAME" ] && continue

    echo "--- Setting up: $MODEL_NAME ---"

    # Create the model folder and version '1' folder
    MODEL_DIR="$REPO_ROOT/$MODEL_NAME"
    sudo mkdir -p "$MODEL_DIR/1"
    sudo chmod -R 777 "$MODEL_DIR/1"

    source .venv/bin/activate

    # Check if dir is empty before running
    python download_model.py "$MODEL_NAME"

    # Creates onnx_output/ directory
    python safetensors-to-onnx.py "$MODEL_DIR/1"

    # Creates plan_output/ directory with quantized TensorRT model inside
    python onnx_to_plan.py "$MODEL_DIR/1/onnx_output"
done