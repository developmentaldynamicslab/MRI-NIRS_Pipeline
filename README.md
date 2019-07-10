# MRI-NIRS_Pipeline
Pipeline for creation of MRI NIRS datasets

Protocol guide for running MCs is in files/PhotonMigration_Pipelin.docx
Optical properties are in files/OpticalProperties.xlsx

A sample runthrough with 10,000 photons is in images/samTestSubjectNew with the parameters used for segmentation documented in MRI_cleanup ... .sh
* Note the Adot files were too large to upload here, so they are in the same folder in the dropbox. Dropbox also had upload issues (sigh) so best to take just the Adot files from there if needed, or recreate them using the protocol.
* Note that the final created things are in the digitization subfolder of the subject folder - this is standard for both our pipelines.
* MRI_cleanup references Vince's autosegment script (the other version referenced in the protocol has extra code for reorienting, removing noise, multiplying etc). 
