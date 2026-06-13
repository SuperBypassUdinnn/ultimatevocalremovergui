import struct
import json
import torch

def load_safetensors(path):
    """
    Pure Python loader for .safetensors files that doesn't require the 
    `safetensors` pip package. Useful in sandboxed environments.
    """
    with open(path, 'rb') as f:
        # Read the 8-byte uint64 header length
        header_len = struct.unpack('<Q', f.read(8))[0]
        
        # Read and parse the JSON header
        header_bytes = f.read(header_len)
        header = json.loads(header_bytes.decode('utf-8'))
        
        state_dict = {}
        
        for key, value in header.items():
            if key == "__metadata__":
                continue
                
            dtype_str = value['dtype']
            shape = value['shape']
            data_offsets = value['data_offsets']
            
            # Map safetensors dtype to torch dtype
            if dtype_str == "F32":
                dt = torch.float32
            elif dtype_str == "F16":
                dt = torch.float16
            elif dtype_str == "BF16":
                dt = torch.bfloat16
            elif dtype_str == "F64":
                dt = torch.float64
            elif dtype_str == "I64":
                dt = torch.int64
            elif dtype_str == "I32":
                dt = torch.int32
            elif dtype_str == "I16":
                dt = torch.int16
            elif dtype_str == "I8":
                dt = torch.int8
            elif dtype_str == "U8":
                dt = torch.uint8
            elif dtype_str == "BOOL":
                dt = torch.bool
            else:
                raise ValueError(f"Unsupported safetensors dtype: {dtype_str}")
                
            # Read the raw byte data for this tensor
            f.seek(8 + header_len + data_offsets[0])
            size = data_offsets[1] - data_offsets[0]
            raw_data = f.read(size)
            
            # Create torch tensor from buffer and reshape
            tensor = torch.frombuffer(bytearray(raw_data), dtype=dt).clone()
            tensor = tensor.view(shape)
            
            state_dict[key] = tensor
            
    return state_dict
