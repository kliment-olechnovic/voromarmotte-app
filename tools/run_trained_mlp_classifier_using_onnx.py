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
    return parser.parse_args()

args = parse_args()

so = ort.SessionOptions()
so.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL

sess = ort.InferenceSession(args.onnx_file, providers=["CPUExecutionProvider"])
sess_input = sess.get_inputs()[0]  
input_name = sess_input.name
input_shape = sess_input.shape
output_name = sess.get_outputs()[0].name

val_raw = np.fromfile(args.data_file, dtype=np.float32)

n_cols = input_shape[-1]
val_features = val_raw.reshape(-1, n_cols)

logits = sess.run([output_name], {input_name: val_features})[0]

out = sigmoid(logits)

print("predicted_probability_to_persist")

np.savetxt(sys.stdout, out.reshape(-1, 1), fmt="%.10g")

