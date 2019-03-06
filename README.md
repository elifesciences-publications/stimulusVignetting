

### This code is associated with the paper from Roth et al., "Stimulus vignetting and orientation selectivity in human visual cortex". eLife, 2018. http://dx.doi.org/10.7554/eLife.37241

# Stimulus vignetting code

The code in this repository contains all the MATLAB software used to analyze the data and generate the figures for the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). Stimulus vignetting and orientation selectivity in human visual cortex. (DOI: 10.7554/eLife.37241).

This code depends heavily on three other software packages: [mrTools](https://github.com/justingardner/mrTools), [mgl](https://github.com/justingardner/mgl), and the steerable pyramid. We have included a version of the steerable pyramid written by David Heeger ([DOI: 10.1109/18.119725](https://ieeexplore.ieee.org/document/119725/)), which is distinct from the steerable pyramid code distributed by Eero Simoncelli’s [LCV gitHub repository](https://github.com/LabForComputationalVision/matlabPyrTools).

To generate the figures in the paper, download the data from OSF ([DOI: 10.17605/OSF.IO/TBJRF](https://osf.io/tbjrf/)) and run the following functions. If things don’t work out, please contact Zvi Roth  ([zvi.roth@mail.huji.ac.il](mailto:zvi.roth@mail.huji.ac.il)) and Eli Merriam ([elisha.merriam@nih.gov](mailto:elisha.merriam@nih.gov)).

Order in which to run scripts:

* makeFigure1.m
* makeFigure2.m
* makeFigure3.m
* saveCorrData.m
* makeFigure5.m
* saveData.m
* makeStimuli.m
* modelOutput.m
* avgModelOutput.m
* savePrfModel.m
* makeFigure6.m
* saveOriData.m
* makeFigure7a.m
* makeFigure7b.m
