import tensorrt as trt
import os, sys
from pathlib import Path
import pdb

if len(sys.argv) < 2:
    print("Usage: python onnx_to_plan.py <model_path>")
    sys.exit(1)

# Configuration
onnx_model_dir = sys.argv[1]  
if Path(onnx_model_dir).suffix.lower() != ".onnx":
    print("Please enter the full or relative path to an .onnx file")
    sys.exit(1)

onnx_dir = Path(onnx_model_dir).parent
output_dir = f"{Path(onnx_model_dir).parents[1]}"

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
with open(f"{output_dir}/model.plan", "wb") as f:
    f.write(serialized_engine)
print("Engine built successfully")
