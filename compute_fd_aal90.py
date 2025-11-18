#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import numpy as np
import nibabel as nib
import pandas as pd
from scipy import ndimage
from sklearn.linear_model import LinearRegression


# Extract boundary
def extract_boundary(mask):
    struct = ndimage.generate_binary_structure(3, 1)
    eroded = ndimage.binary_erosion(mask, structure=struct, border_value=0)
    return mask & (~eroded)


# Box-counting surface
def box_count_surface(boundary, scales):
    Z, Y, X = boundary.shape
    scales_used, counts = [], []

    for s in scales:
        s_int = int(round(s))
        if s_int < 1:
            continue
        if Z < s_int or Y < s_int or X < s_int:
            continue

        nz, ny, nx = Z//s_int, Y//s_int, X//s_int
        if nz == 0 or ny == 0 or nx == 0:
            continue

        N = 0
        for iz in range(nz):
            for iy in range(ny):
                for ix in range(nx):
                    patch = boundary[
                        iz*s_int:(iz+1)*s_int,
                        iy*s_int:(iy+1)*s_int,
                        ix*s_int:(ix+1)*s_int
                    ]
                    if patch.any():
                        N += 1

        if N > 0:
            scales_used.append(s_int)
            counts.append(N)

    return np.array(scales_used), np.array(counts)


# Main
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--atlas", required=True)
    parser.add_argument("--labels_json", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    # Native Atlas
    print("[LOAD] Native Atlas :", args.atlas)
    atlas = nib.load(args.atlas).get_fdata().astype(int)
    shape = atlas.shape
    print("[INFO] Volume shape =", shape)

    # Labels JSON
    print("[LOAD] Labels JSON :", args.labels_json)
    with open(args.labels_json, "r", encoding="utf-8") as f:
        labels = json.load(f)

    # Filtrage AAL-90
    labels90 = [(d["id"], d["name"]) for d in labels if int(d["id"]) < 9000]
    print("[INFO] Count labels AAL-90 =", len(labels90))

    # ❗ Scale
    scales = np.array([22.5, 11.25, 5.625, 2.8125, 1.40625], dtype=float)
    print("[INFO] Scale (voxels) :", scales)

    rows = []

    for lbl, name in labels90:
        mask = (atlas == lbl)
        nvox = int(mask.sum())
        if nvox == 0:
            continue

        boundary = extract_boundary(mask)
        scales_used, counts = box_count_surface(boundary, scales)

        if len(scales_used) < 2:
            fd = np.nan
            r2 = np.nan
        else:
            X = np.log(1.0 / scales_used).reshape(-1, 1)
            y = np.log(counts + 1e-8)
            model = LinearRegression().fit(X, y)
            fd = float(model.coef_[0])
            yhat = model.predict(X)
            ss_res = float(np.sum((y - yhat)**2))
            ss_tot = float(np.sum((y - y.mean())**2)) + 1e-12
            r2 = 1 - ss_res / ss_tot

        rows.append({
            "roi_id": lbl,
            "roi_name": name,
            "n_vox": nvox,
            "fd": fd,
            "r2": r2,
            "n_scales": len(scales_used),
        })

    df = pd.DataFrame(rows)
    df.to_csv(args.out, index=False)
    print("[OK] FD AAL-90 écrite dans :", args.out)


if __name__ == "__main__":
    main()
