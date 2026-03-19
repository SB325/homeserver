# Huggingface Model Conditioning
Download huggingface models
- Quantize
- Graph optimize
- Build TensorRT engine (.plan) files from .safetensors files

When running LLMs locally, model size must be minimized to leave space for
k-v cache if model size approaches available VRAM.

Use smaller models that fit on consumer GPUs, or quantize to 

- FP16 - Model size/2
- INT8 - Model size/4
- INT4 - Model size/8   

> [!TIP]
> vLLM inference accepts .safetensors directly. Therefore vLLM is preferable for simplicity without sacrificing performance.

To quantize, convert .safetensors to onnx (safetensors_to_onnx.sh)

TO create TensorRT engine, convert .safetensors to .plan (safetensors_to_plan.py) 

> [! WARNING]
> Configuring .plan with Triton Inference Server has not been successfully demonstrated.