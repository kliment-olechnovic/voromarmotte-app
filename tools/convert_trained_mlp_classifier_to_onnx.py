import torch
import torch.nn as nn
import os
import argparse
import sys

from mlp_classifier import MLPClassifier

def parse_args():
    parser = argparse.ArgumentParser(description="Run Trained Binary Classification MLP")
    parser.add_argument('--model-file', type=str, required=True)
    parser.add_argument('--onnx-file', type=str, required=True)
    parser.add_argument('--input-dim', type=int, required=True)
    parser.add_argument('--hidden-dim1', type=int, required=True)
    parser.add_argument('--hidden-dim2', type=int, required=True)
    parser.add_argument('--dropout-p', type=float, required=True)
    parser.add_argument("--opset", type=int, default=17)
    return parser.parse_args()

args = parse_args()

device = 'cpu'

model = MLPClassifier(args.input_dim, args.hidden_dim1, args.hidden_dim2, args.dropout_p).to(device)
model.load_state_dict(torch.load(args.model_file, map_location=device))
model.eval()

export_model = model

dummy = torch.randn(1, args.input_dim, dtype=torch.float32, device=device)

out_name = "logits"

torch.onnx.export(
    export_model,
    dummy,
    args.onnx_file,
    input_names=["input"],
    output_names=[out_name],
    dynamic_axes={"input": {0: "batch"}, out_name: {0: "batch"}},
    opset_version=args.opset,
    do_constant_folding=True,
)

