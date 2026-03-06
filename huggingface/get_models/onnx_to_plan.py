import tensorrt as trt
import os, sys
from pathlib import Path
import pdb

if len(sys.argv) < 2:
    print("Usage: python onnx_to_plan.py <model_path>")
    sys.exit(1)

# Configuration
onnx_model_dir = sys.argv[1]  # Folder containing config.json and .safetensors
if Path(onnx_model_dir).suffix.lower() != ".onnx":
    print("Please enter the full or relative path to an .onnx file")
    sys.exit(1)

onnx_dir = Path(onnx_model_dir).parent
output_dir = f"{Path(onnx_model_dir).parents[1]}/plan_output"

# Create logger, builder, network, and parser
logger = trt.Logger(trt.Logger.WARNING)
builder = trt.Builder(logger)
network = builder.create_network(1 << int(trt.NetworkDefinitionCreationFlag.EXPLICIT_BATCH))
parser = trt.OnnxParser(network, logger)
config = builder.create_builder_config()

# Load and parse the ONNX model
if not parser.parse_from_file(model=onnx_model_dir):
    print("Failed to parse ONNX file")
    sys.exit(1) 

# 1. Create the profile
profile = builder.create_optimization_profile()

# 2. Define the ranges for your dynamic inputs
# Format: [Min, Optimum, Max]
# Replace "input_ids" and the shapes with your actual model's input name and needs
min_shape = (1, 1)      # 1 Batch, 1 Token
opt_shape = (1, 512)   # Optimized for medium length prompts
max_shape = (1, 2048)   # Maximum safety limit for 16GB VRAM
for i in range(network.num_inputs):
    input_tensor = network.get_input(i)
    profile.set_shape(input_tensor.name, min_shape, opt_shape, max_shape)

# 3. Add the profile to the config
config.add_optimization_profile(profile)

# Enable FP16 and build engine
config.set_flag(trt.BuilderFlag.FP16)

# Limit builder to 4GB of workspace to leave room for the model weights
config.set_memory_pool_limit(trt.MemoryPoolType.WORKSPACE, 4 * 1024 * 1024 * 1024)
serialized_engine = builder.build_serialized_network(network, config)

# Save the engine
Path(output_dir).mkdir(parents=True, exist_ok=True)
with open(f"{output_dir}/model.plan", "wb") as f:
    f.write(serialized_engine)
print("Engine built successfully")

## Inference in Triton ##################
# import tensorrt as trt
# import pycuda.driver as cuda
# import pycuda.autoinit  # Automatically manages CUDA context
# import numpy as np

# # 1. Load the Engine
# logger = trt.Logger(trt.Logger.WARNING)
# with open("model.plan", "rb") as f, trt.Runtime(logger) as runtime:
#     engine = runtime.deserialize_cuda_engine(f.read())

# # 2. Create Context and Allocate Buffers
# context = engine.create_execution_context()

# # For simplicity, we assume your model has 1 input and 1 output
# # You must repeat this for every input (ids, mask, etc.)
# input_name = engine.get_tensor_name(0)
# output_name = engine.get_tensor_name(1)

# # Set the actual runtime shape (Must be within your Profile range!)
# context.set_input_shape(input_name, (1, 512)) 

# # Create host/device buffers
# host_in = cuda.pagelocked_empty(trt.volume((1, 512)), dtype=np.int32)
# host_out = cuda.pagelocked_empty(trt.volume(engine.get_tensor_shape(output_name)), dtype=np.float32)
# dev_in = cuda.mem_alloc(host_in.nbytes)
# dev_out = cuda.mem_alloc(host_out.nbytes)

# # 3. Execution
# # Fill host_in with your tokenized IDs here
# cuda.memcpy_htod(dev_in, host_in)
# context.execute_v2(bindings=[int(dev_in), int(dev_out)])
# cuda.memcpy_dtoh(host_out, dev_out)

# print("Inference Complete!")