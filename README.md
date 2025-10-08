# T1w_FractalDimension_script
Attempt to create a script based on the T1w_FractalDimension paper (https://github.com/Radiology-Morrison-lab-UCSF/T1w_FractalDimension) that calculates the fractal dimension of the provided example dataset.


Step 0

Make sure all requirements are installed (see the requirements.txt file).

Step 1

Clone the repository:

git clone https://github.com/Radiology-Morrison-lab-UCSF/T1w_FractalDimension.git


Or download only the example file:
ExamplePatient_T1w_brain.nii.gz

Step 2

Save the example file (ExamplePatient_T1w_brain.nii.gz) in the same folder as this script.

Step 3

Open a terminal, navigate to the root folder of this program, and run the following command (replace the paths with your own):

python pipeline_examplepatient_aal_fd.py \
  --t1 "/mnt/***your_path***/ExamplePatient_T1w_brain.nii.gz" \
  --out-root "/mnt/***your_path***" \
  --voxel 0.8 \
  --no-lcc \
  --run-fract
