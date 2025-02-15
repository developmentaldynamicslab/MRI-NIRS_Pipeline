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


This pipeline has been used in the following papers:

Defenderfer, Forbes, Wijeakumar, Hedrick, Plyler & Buss (2021): https://www.sciencedirect.com/science/article/pii/S1053811921006613

Lowery, Nikam & Buss (2022): https://www.nature.com/articles/s41598-022-14761-2

Wijeakumar, S., Forbes, S.H., Magnotta, V.A., Deoni, S., Jackson, K., Singh, V.P., Tiwari, M., Kumar, A. & Spencer, J.P. (2023). Stunting in the first year of life is associated with atypical activation of dorsal and ventral working memory and attention networks. Nature Human Behaviour, 7, 2199-2211. https://www.nature.com/articles/s41562-023-01725-3

Davidson, Shing, McKay, Rafetseder & Wijeakumar (2023): https://www.sciencedirect.com/science/article/pii/S1878929323000105?via%3Dihub#fig0015

Davidson, Caes, Shing, McKay, Rafetseder & Wijeakjumar (2023): https://onlinelibrary.wiley.com/doi/10.1111/mbe.12383

Davidson C, Theyer A, Amaireh G, Wijeakumar S. The impact of caregiver inhibitory control on infant visual working memory. Infant Behav Dev. 2024 Mar;74:101921. doi: 10.1016/j.infbeh.2023.101921. Epub 2024 Jan 11. PMID: 38211463.

Amaireh, G., Caes, L., Theyer, A., Davidson, C. & Wijeakumar, S. (2024). Caregiver executive functions are associated with infant visual working memory. Infant and Child Development. https://onlinelibrary.wiley.com/doi/10.1002/icd.2543

Theyer A, Davidson C, Amaireh G, Wijeakumar S. Association between caregiver and infant visual neurocognition. Infant Behav Dev. 2024 Sep;76:101975. doi: 10.1016/j.infbeh.2024.101975. Epub 2024 Jul 9. PMID: 38986217.

