from huggingface_hub import snapshot_download

if len(sys.argv) < 2:
    print("Usage: python download_model.py <model_name>")
    sys.exit(1)

model_name = sys.argv[1]

snapshot_download(
    repo_id=model_name,
    local_dir=f"/mnt/bulkStorage/triton/models/{model_name}/1/",
    allow_patterns=["*.safetensors", "*.json"], # Only download weights and configs
    ignore_patterns=["*.msgpack", "*.h5"],      # Skip unwanted formats
    max_workers=16                              # Increase concurrency
)