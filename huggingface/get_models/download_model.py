
from huggingface_hub import snapshot_download

model_name = "meta-llama/Meta-Llama-3-8B-Instruct"
# model_name = "LocoreMind/LocoOperator-4B"
snapshot_download(
    repo_id=model_name,
    local_dir=f"/mnt/bulkStorage/triton/models/{model_name}/1/",
    allow_patterns=["*.safetensors", "*.json"], # Only download weights and configs
    ignore_patterns=["*.msgpack", "*.h5"],      # Skip unwanted formats
    max_workers=16                              # Increase concurrency
)
