# MRI-NIRS_Pipeline
Pipeline for creation of MRI NIRS datasets

Protocol guide for running MCs is in files/PhotonMigration_Pipelin.docx
Optical properties are in files/OpticalProperties.xlsx

A sample runthrough with 10,000 photons is in images/samTestSubjectNew with the parameters used for segmentation documented in MRI_cleanup ... .sh
* Note the Adot files were too large to upload here, so they are in the same folder in the dropbox. Dropbox also had upload issues (sigh) so best to take just the Adot files from there if needed, or recreate them using the protocol.
* Note that the final created things are in the digitization subfolder of the subject folder - this is standard for both our pipelines.
* MRI_cleanup references Vince's autosegment script (the other version referenced in the protocol has extra code for reorienting, removing noise, multiplying etc). 

After running MCs, the next step is to create niftii files of the headvol and sensitivity profiles. For this, I have created a loop through script for 6 mo and 9 mo, called Sixloop.m and Nineloop.m. Both of those scripts call AVAdotVol3pt2nii.m and AVfwVol2AnatNii.m. Path names will need to be changed in the scripts. They should create a headvol.nii and nifty files for each of the channels.

Then, I change the filenames of the sensitivity files from AdotVol_S#_D#_C#.nii to A1.nii.. etc, for ease of reference across projects. The scripts that do these are MCs-convert_6mo.sh and MCs-convert_9mo.sh

Next, there is NIRS processing to extract the betas. More details on this later today. 

Moving on, next step – image reconstruction. The script is called ICs_6mo.m and ICs_9mo,m. Here, folder paths will need to be changed to be able to access the sensitivity profiles and the beta files. This should create beta images for each condition and chromophore (for each subject).

Next, I transform the beta images to the study template. The scripts that does this are called Transform_6mo.sh and Transform_9mo.sh. They both call out to registerCommon.sh.

The resolution is very fine at this point (< 1x1x1 mm3) and Group analyses always fails. It also might be a little pointless to have such fine precision for NIRS – but this is open to debate. Anyway, Resmapling.sh resamples the resolution to 2x2x2.

After this, I run a Group ANOVA. I have added a sample script called Load_MVM.txt.


