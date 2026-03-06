#!/bin/bash

# 1. Your list of models
MODELS_LIST=(
    # "openai/gpt-oss-20b"                                # "Text Generation - this model holds weights in non standard format that is not easy to convert to onnx."
    # "Qwen/Qwen3-32B"                                    # "Text Generation"
    "meta-llama/Llama-3.1-70B-Instruct"                 # "Text Generation"
    # "nvidia/Llama-3_3-Nemotron-Super-49B-v1_5-NVFP4"    # "Text Generation"
    # "Qwen/Qwen3-VL-8B-Instruct"                         # "Image-Text to Text"
    # "stabilityai/stable-diffusion-xl-refiner-1.0"       # "Image to Image / Text to Image"
    # "Wan-AI/Wan2.2-T2V-A14B-Diffusers"                  # "Text to Video"
    # "OpenMOSS-Team/MOSS-TTSD-v1.0"                      # "Text to Speech"
    # "nvidia/nemotron-colembed-vl-4b-v2"                 # "Text to Visual Document"
    # "sentence-transformers/all-MiniLM-L12-v2"           # "Sentence Similarity"
    # "openai/whisper-base"                               # "Speech to text"
    # "openai/whisper-small"                              # "Speech to text"
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

    # /home/sheldon/.local/bin/hf download $MODEL_NAME --include "*.safetensors" "config.json" "tokenizer.json" --local-dir "$MODEL_DIR/1" --quiet
    /home/sheldon/.local/bin/hf download $MODEL_NAME --local-dir "$MODEL_DIR/1" --include "*.safetensors" "config.json" "tokenizer.json" "original/*" 

    HF_CONFIG="$MODEL_DIR/1/config.json"
    # FILES=("$MODEL_DIR/1/original/*.safetensors")
    # HOST_DIR="$MODEL_DIR/1/original/"
    FILES=("$MODEL_DIR/1"/*.safetensors)
    HOST_DIR="$MODEL_DIR/1/"

    if [  ${#FILES[@]} -eq 0 ]; then
        FILES=("$MODEL_DIR/1"/*.safetensors)
        HOST_DIR="$MODEL_DIR/1/"
    done

    # 2. Logic to detect model type from config.json
    BACKEND="tensorrt"
    if [ -e "${FILES[0]}" ]; then
        # Extract the model_type field using jq
        MODEL_TYPE=$(jq -r '.model_type // empty' "$HF_CONFIG")
        echo "Detected Hugging Face model type: $MODEL_TYPE"
        
        # Logic to switch backends based on type if needed
        # (e.g., if you plan to use Fil for XGBoost or specialized backends)

        # Install Hugging Face Optimum with ONNX exporters
        # pip install "optimum[exporters]" onnx onnxruntime-gpu
        # Ensure TensorRT is installed (often pre-installed in Triton/PyTorch NGC containers)
        # If not, install the Python bindings
        # pip install tensorrt
        docker run --gpus all -dit --name pytorch_ngc \
            -v $HOST_DIR:/work \
            nvcr.io/nvidia/pytorch:26.02-py3 bash

        docker exec pytorch_ngc python -m pip install --upgrade pip
        docker exec pytorch_ngc python -m pip install optimum[exporters,onnxruntime] onnx onnxruntime-gpu accelerate

        # --model: path to the folder containing your .safetensors and config.json
        # --task: specifies the model type (e.g., text-generation, sequence-classification)
        # docker exec pytorch_ngc pip install torch==2.4.1 --index-url https://download.pytorch.org/whl/cu121
        docker exec pytorch_ngc optimum-cli export onnx --model /work --task text-generation /work/onnx-out

        # Replace <path_to_trtexec> with the actual path if not in your $PATH
        docker exec trtexec --onnx=/work/model.onnx \
                --saveEngine=/work/model.plan \
                --fp16 \
                --verbose

        docker stop pytorch_ngc
        docker rm pytorch_ngc

        # Create a basic config.pbtxt
        cat <<EOF > "$MODEL_DIR/config.pbtxt"
name: "$MODEL_NAME"
platform: "tensorrt_plan"
backend: "$BACKEND"
max_batch_size: 8
EOF

        echo "Created: $MODEL_DIR/1/"
        echo "Created: $MODEL_DIR/config.pbtxt"
    else
        echo "No config.json or .safetensors found at $MODEL_DIR/1. Skipping."
        echo "/home/sheldon/.local/bin/hf download $MODEL_NAME --include \"*.safetensors\" \"config.json\" \"tokenizer.json\" --local-dir \"$MODEL_DIR/1\" --quiet"
    fi  
done

# Restore separator
IFS=$OLD_IFS
echo "--------------------------------"
echo "Done!"