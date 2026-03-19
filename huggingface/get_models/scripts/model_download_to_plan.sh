#!/bin/bash

# 1. Your list of models
MODELS_LIST=(
    "meta_llama/Meta_Llama_3-8B_Instruct"               # "Text Generation"
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

    
    # Check if dir is empty before running
    # source .venv/bin/activate
    # python download_model.py "$MODEL_NAME"

    sudo mkdir -p $MODEL_DIR/1/model_ckpt
    sudo chmod 777 -R $MODEL_DIR/1/model_ckpt
    sudo mkdir -p $MODEL_DIR/1/plan_output
    sudo chmod 777 -R $MODEL_DIR/1/plan_output

    docker run -d --gpus all --ipc=host \
        --ulimit memlock=-1 --ulimit stack=67108864 \
        -v $MODEL_DIR/1:/model_in \
        -v $MODEL_DIR/1/model_ckpt:/model_out \
        -v $MODEL_DIR/1/plan_output:/engine_outputs \
        --name tensorrt-llm \
        nvcr.io/nvidia/tensorrt-llm/release:1.3.0rc6

    echo "--- Creating Model Checkpoint for $MODEL_NAME ---"
    docker exec tensorrt-llm \
            python examples/models/core/llama/convert_checkpoint.py \
            --model_dir /model_in \
            --output_dir /model_out \
            --dtype float16 \
=            --weight_only_precision int4 

    echo "--- Converting safetensors to plan format ---"
    docker exec tensorrt-llm \
            trtllm-build --checkpoint_dir /model_out \
             --output_dir /engine_outputs \
             --max_batch_size 4 \
             --max_input_len 2048 \
             --gemm_plugin float16 \
             --max_seq_len 2048
    # Context window  = max_input_len + max_output_len
    
    # Check to see if plan file has been created. If so, move it up a level
    FILE_PATH="$MODEL_DIR/1/plan_output/rank0.engine"

    if [ -f "$FILE_PATH" ]; then
        echo "✅ Success: Moving $FILE_PATH to it's parent directory to be found by triton for inference."
        mv $MODEL_DIR/1/plan_output/* $MODEL_DIR/1/
    else
        echo "❌ Error: $FILE_PATH not created. Check logs."
        exit 1
    fi
    
    # remove tensorrt-llm container
    docker stop tensorrt-llm
    docker rm tensorrt-llm
done

# ./examples/models/core/commandr/convert_checkpoint.py
# ./examples/models/core/gemma/convert_checkpoint.py
# ./examples/models/core/enc_dec/convert_checkpoint.py
# ./examples/models/core/mllama/convert_checkpoint.py
# ./examples/models/core/vit/convert_checkpoint.py
# ./examples/models/core/bert/convert_checkpoint.py
# ./examples/models/core/internlm2/convert_checkpoint.py
# ./examples/models/core/mamba/convert_checkpoint.py
# ./examples/models/core/whisper/convert_checkpoint.py
# ./examples/models/core/phi/convert_checkpoint.py
# ./examples/models/core/nemotron_nas/convert_checkpoint.py
# ./examples/models/core/glm-4-9b/convert_checkpoint.py
# ./examples/models/core/qwen/convert_checkpoint.py
# ./examples/models/core/gpt/convert_checkpoint.py
# ./examples/models/core/recurrentgemma/convert_checkpoint.py
# ./examples/models/core/llama/convert_checkpoint.py
# ./examples/models/contrib/dbrx/convert_checkpoint.py
# ./examples/models/contrib/mpt/convert_checkpoint.py
# ./examples/models/contrib/falcon/convert_checkpoint.py
# ./examples/models/contrib/deepseek_v2/convert_checkpoint.py
# ./examples/models/contrib/bloom/convert_checkpoint.py
# ./examples/models/contrib/deepseek_v1/convert_checkpoint.py
# ./examples/models/contrib/opt/convert_checkpoint.py
# ./examples/models/contrib/stdit/convert_checkpoint.py
# ./examples/models/contrib/gptneox/convert_checkpoint.py
# ./examples/models/contrib/baichuan/convert_checkpoint.py
# ./examples/models/contrib/dit/convert_checkpoint.py
# ./examples/models/contrib/mmdit/convert_checkpoint.py
# ./examples/models/contrib/gptj/convert_checkpoint.py
# ./examples/models/contrib/cogvlm/convert_checkpoint.py
# ./examples/models/contrib/grok/convert_checkpoint.py
# ./examples/medusa/convert_checkpoint.py
# ./examples/redrafter/convert_checkpoint.py
# ./examples/eagle/convert_checkpoint.py