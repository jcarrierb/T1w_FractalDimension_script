#!/usr/bin/env bash
set -euo pipefail

##############################
# User paramaters
##############################

SUBJ="ExamplePatient"
T1_NATIVE="ExamplePatient_T1w_brain.nii.gz"

AAL_NII="AAL_MNI_SPM12.nii.gz"
AAL_LABELS_JSON="AAL_SPM12_labels.json"

OUT_ATLAS_NATIVE="AAL_in_native.nii.gz"
OUT_CSV="FD_AAL90_${SUBJ}.csv"

##############################
# STEP 0 — AAL from Nilearn
##############################

echo "[STEP 0] get AAL SPM12 from Nilearn…"

python3 << 'EOF'
import json
import nibabel as nib
from nilearn import datasets

print("[NILEARN] download AAL SPM12…")
aal = datasets.fetch_atlas_aal(version="SPM12")

# Save AAL MNI
nii = nib.load(aal["maps"])
nib.save(nii, "AAL_MNI_SPM12.nii.gz")

# Save label in JSON
labels = [{"id": int(i), "name": n} for i, n in zip(aal["indices"], aal["labels"])]

with open("AAL_SPM12_labels.json", "w", encoding="utf-8") as f:
    json.dump(labels, f, indent=2)

print("[OK] AAL MNI + labels JSON created.")
EOF

##############################
# CHECK ENV
##############################

echo "[CHECK] FSLDIR = ${FSLDIR:-"(undefined)"}"
MNI_REF="${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz"

if [ -z "${FSLDIR:-}" ]; then
  echo "[ERROR] FSLDIR undefined."
  exit 1
fi
if [ ! -f "${T1_NATIVE}" ]; then
  echo "[ERROR] T1_NATIVE missing : ${T1_NATIVE}"
  exit 1
fi
if [ ! -f "${MNI_REF}" ]; then
  echo "[ERROR] MNI_REF missing : ${MNI_REF}"
  exit 1
fi

echo "------------------------------------------------------"
echo "[INFO] Subject          : ${SUBJ}"
echo "[INFO] Native T1        : ${T1_NATIVE}"
echo "[INFO] AAL MNI          : ${AAL_NII}"
echo "[INFO] Labels JSON      : ${AAL_LABELS_JSON}"
echo "[INFO] MNI ref          : ${MNI_REF}"
echo "------------------------------------------------------"

##############################
# STEP 1 — FLIRT
##############################

echo "[STEP 1] FLIRT (T1 → MNI)…"

flirt -in "${T1_NATIVE}" -ref "${MNI_REF}" \
      -omat T1_to_MNI_aff.mat \
      -out T1_to_MNI_aff.nii.gz \
      -dof 12 -cost corratio

echo "[OK] FLIRT done"

##############################
# STEP 2 — FNIRT
##############################

echo "[STEP 2] FNIRT (nonlin MNI)…"

fnirt --in="${T1_NATIVE}" --ref="${MNI_REF}" \
      --aff=T1_to_MNI_aff.mat \
      --cout=T1_to_MNI_warpcoef.nii.gz \
      --iout=T1_to_MNI_nonlin.nii.gz \
      --config=T1_2_MNI152_2mm

echo "[OK] FNIRT done"

##############################
# STEP 3 — INVWARP
##############################

echo "[STEP 3] INVWARP…"

invwarp --warp=T1_to_MNI_warpcoef.nii.gz \
        --out=MNI_to_T1_warp.nii.gz \
        --ref="${T1_NATIVE}"

echo "[OK] INVWARP done"

##############################
# STEP 4 — APPLYWARP
##############################

echo "[STEP 4] APPLYWARP AAL → NATIVE…"

applywarp --ref="${T1_NATIVE}" \
          --in="${AAL_NII}" \
          --warp=MNI_to_T1_warp.nii.gz \
          --out="${OUT_ATLAS_NATIVE}" \
          --interp=nn

echo "[OK] Native Atlas written in : ${OUT_ATLAS_NATIVE}"

##############################
# STEP 5 — PYTHON FD AAL-90
##############################

echo "[STEP 5] Compute FD surface AAL-90…"

python3 compute_fd_aal90.py \
    --atlas "${OUT_ATLAS_NATIVE}" \
    --labels_json "${AAL_LABELS_JSON}" \
    --out "${OUT_CSV}"

echo "====================================================="
echo "          PIPELINE DONE — NO ERROR"
echo "====================================================="
echo "[RESULT] FD AAL-90 (volumique) : ${OUT_CSV}"
