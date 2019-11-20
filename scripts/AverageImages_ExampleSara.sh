outputDir='/Volumes/DDLab/Projects/HyperWB/Data/ImageRecon_Parent/Output'
outputDir2='/Volumes/DDLab/Projects/HyperWB/Data/ImageRecon_Parent'
Images=`ls $outputDir/*.nii`
for j in $Images
  do
    fName=`basename $j`
    origImg=${fName%.nii}
    mv $outputDir/${origImg}.nii $outputDir/${origImg}_orig.nii
    3dcalc -a $j -b $outputDir/${origImg}_orig.nii -expr '(a+b)/2' -prefix $outputDir/${origImg}.nii
  done
