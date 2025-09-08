import onnxruntime as ort
import numpy as np
import os
import argparse
import sys

def sigmoid(x):
    return 1.0 / (1.0 + np.exp(-x))

def parse_args():
    parser = argparse.ArgumentParser(description="Run Trained Binary Classification MLP")
    parser.add_argument('--onnx-file', type=str, required=True)
    parser.add_argument('--data-file', type=str, required=True)
    parser.add_argument('--batch-size', type=int, default=16384)
    return parser.parse_args()

args = parse_args()

sess = ort.InferenceSession(args.onnx_file, providers=["CPUExecutionProvider"])
input_name = sess.get_inputs()[0].name
output_name = sess.get_outputs()[0].name

val_data = np.loadtxt(args.data_file, delimiter="\t", dtype=np.float32, skiprows=0)
val_features = val_data[:, 1:]

print("predicted_probability_to_persist")

for start in range(0, val_features.shape[0], args.batch_size):
    batch = val_features[start:start + args.batch_size]
    outputs = sess.run([output_name], {input_name: batch})[0]
    out = outputs
    if out.ndim == 2 and out.shape[1] == 1:
        out = out[:, 0]
    out = sigmoid(out)
    for v in out.tolist():
        print(f"{float(v)}")

