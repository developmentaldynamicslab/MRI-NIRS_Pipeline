outputDir='/Users/nfb15zpu/Documents/J-Files/Grants/Grant_NIH_2013_NIRS/NIHVWM2019/ImageRecon_30NIH_UEA_Y1'
outputDir2='/Users/nfb15zpu/Documents/J-Files/Grants/Grant_NIH_2013_NIRS/NIHVWM2019/ImageRecon_30NIH_UEA_Y1/SecondSession'
Images=`ls $outputDir2/*.nii`
for j in $Images
  do
    fName=`basename $j`
    origImg=${fName%.nii}   
    mv $outputDir/${origImg}.nii $outputDir/${origImg}_orig.nii
    3dcalc -a $j -b $outputDir/${origImg}_orig.nii -expr '(a+b)/2' -prefix $outputDir/${origImg}.nii
  done
