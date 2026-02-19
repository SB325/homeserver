# Text Generation
hf download openai/gpt-oss-20b model.safetensors.index.json --cache-dir /mnt/bulkStorage/triton/models
hf download Qwen/Qwen3-32B model.safetensors.index.json --cache-dir /mnt/bulkStorage/triton/models
hf download meta-llama/Llama-3.1-70B-Instruct model.safetensors.index.json --cache-dir /mnt/bulkStorage/triton/models
hf download nvidia/Llama-3_3-Nemotron-Super-49B-v1_5-NVFP4 model.safetensors.index.json --cache-dir /mnt/bulkStorage/triton/models
# Image-Text to Text
hf download Qwen/Qwen3-VL-8B-Instruct model.safetensors.index.json --cache-dir /mnt/bulkStorage/triton/models
# Image to Image / Text to Image
hf download stabilityai/stable-diffusion-xl-refiner-1.0 --cache-dir /mnt/bulkStorage/triton/models
# Text to Video
hf download Wan-AI/Wan2.2-T2V-A14B-Diffusers --cache-dir /mnt/bulkStorage/triton/models
# Text to Speech
hf download OpenMOSS-Team/MOSS-TTSD-v1.0 --cache-dir /mnt/bulkStorage/triton/models
# Text to Visual Document
hf download nvidia/nemotron-colembed-vl-4b-v2 --cache-dir /mnt/bulkStorage/triton/models
# Sentence Similarity
hf download sentence-transformers/all-MiniLM-L12-v2 --cache-dir /mnt/bulkStorage/triton/models
