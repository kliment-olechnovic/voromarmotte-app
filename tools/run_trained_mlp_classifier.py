import torch

from torch.utils.data import DataLoader, TensorDataset
import torch.nn as nn
import os
import argparse
import math
import sys

from mlp_classifier import MLPClassifier

def parse_args():
    parser = argparse.ArgumentParser(description="Run Trained Binary Classification MLP")
    parser.add_argument('--model-file', type=str, required=True)
    parser.add_argument('--data-file', type=str, required=True)
    parser.add_argument('--device-name', type=str, default='cpu')
    parser.add_argument('--batch-size', type=int, default=16384)
    parser.add_argument('--input-dim', type=int, required=True)
    parser.add_argument('--hidden-dim1', type=int, required=True)
    parser.add_argument('--hidden-dim2', type=int, required=True)
    parser.add_argument('--dropout-p', type=float, required=True)
    return parser.parse_args()

args = parse_args()

device = 'cpu'

model = MLPClassifier(args.input_dim, args.hidden_dim1, args.hidden_dim2, args.dropout_p).to(device)
model.load_state_dict(torch.load(args.model_file, map_location=device))
model.eval()

val_data = torch.load(args.data_file)
val_features = val_data[:, 1:]
val_dataset = TensorDataset(val_features)
val_loader = DataLoader(val_dataset, batch_size=args.batch_size, shuffle=False, pin_memory=False, num_workers=2, persistent_workers=True)

all_preds_raw = []

model.eval()
with torch.no_grad():
    for (val_features_batch,) in val_loader:
        val_features_batch = val_features_batch.to(device)
        val_logits = model(val_features_batch)
        preds_raw = torch.sigmoid(val_logits)
        all_preds_raw.extend(preds_raw.float().cpu().squeeze().tolist())

print('predicted_probability_to_persist')
for pred in all_preds_raw:
    print(f'{pred}')

