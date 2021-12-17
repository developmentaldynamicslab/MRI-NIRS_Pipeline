# MRI-NIRS_Pipeline

Processing pipeline for image reconstruction of fNIRS data.

## News:

* The latest update adds a short-source regression option.
* Clearer documentation
* Fix to a minor glitch in cases where we had non-sequential runs (e.g., run1 was fine, run2 was bad/missing, and run3 was fine). I updated the code to handle this case correctly. In the old code, this created a mis-match between the run counter (1,2 if two ok runs) and the run name (1,3 in this example).


## Before you start:

* Digitization templates can be created using the digitizeR package (www.github.com/samhforbes/digitizeR). This has it's own set of instructions.
* Keep the repository up to date on github and link the scripts/matlab folder into the matlab path
* Copy the ANTS folder (see ‘misc’) to the applications folder on your computer
* You will also need working versions of Homer2 and AtlasViewer

From there, follow the steps in the NeuroDOT_Pipeline_Instructions.docx found in the *files* subfolder.

To cite:

 Samuel H. Forbes, Sobanawartiny Wijeakumar, Adam T. Eggebrecht, Vincent A. Magnotta, and John P. Spencer "Processing pipeline for image reconstructed fNIRS analysis using both MRI templates and individual anatomy," Neurophotonics 8(2), 025010 (12 June 2021). https://doi.org/10.1117/1.NPh.8.2.025010
