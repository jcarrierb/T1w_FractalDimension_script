# T1w_FractalDimension_script
Attempt to create a script based on the T1w_FractalDimension paper (https://github.com/Radiology-Morrison-lab-UCSF/T1w_FractalDimension) that calculates the fractal dimension of the provided example dataset.

### Result
Using the example dataset and the configuration above, the pipeline yields a Pearson correlation coefficient of **R = 0.45** between this script’s FD values and the reference values from the [T1w_FractalDimension paper/repository](https://github.com/Radiology-Morrison-lab-UCSF/T1w_FractalDimension/blob/main/ExamplePatient_FractalDimension_ROIS.csv).

### Conclusion

The Pearson correlation coefficient (R = 0.45) suggests a statistically significant but weak positive association between the variables. This indicates that while the relationship exists, it explains only a modest proportion of the variance. Further code adjustments are required to improve the confidence level of the findings.


### Step 0

Make sure all requirements are installed (see the requirements.txt file).

### Step 1

Clone the repository:

git clone https://github.com/Radiology-Morrison-lab-UCSF/T1w_FractalDimension.git

Or download only the example file:
ExamplePatient_T1w_brain.nii.gz

### Step 2

Save the example file (ExamplePatient_T1w_brain.nii.gz) in the same folder as those scripts.

### Step 3

Open a terminal, navigate to the root folder of this program, and run the following command :

WSL:
bash pipeline_FD_AAL90.sh






### References

T1w_FractalDimension — Original UCSF implementation of the fractal dimension analysis described in the paper:
https://github.com/Radiology-Morrison-lab-UCSF/T1w_FractalDimension

FractalBrain Toolkit — Python package for fractal analysis of 3D brain volumes:
https://github.com/chiaramarzi/fractalbrain-toolkit

FSL (FMRIB Software Library) — Suite of tools for MRI and brain image processing used in this pipeline (BET, FLIRT, FNIRT, etc.):
https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
