####################################################################
#Cut oxy deoxy
# Use for removing extraneous columns from the Beta output
###################################################################
library(readr)
library(tidyr)
library(dplyr)
#To run, check packages are installed, change filepath and outputpath, then run all

filepath = '/Users/nfb15zpu/Documents/J-Files/Grants/Grant_NIH_2013_NIRS/NIHVWM2019/30NIH-VWM-Y1/' #where files are stored
outputpath <- '/Users/nfb15zpu/Documents/J-Files/Grants/Grant_NIH_2013_NIRS/NIHVWM2019/30NIH-VWM-Y1/Output2/' #output folder

file_list <- list.files(filepath, '.csv')
file_list2 <- as.list(file_list)
file_list3 <- lapply(file_list2, function(x) paste(filepath, x, sep = ''))
mylist <- lapply(file_list3, function(x) read_csv(x, col_names = F))

mylist2 <- lapply(mylist, function(x) x[1:3])

names(mylist2) <- file_list2

dir.create(outputpath)

for(i in 1:length(mylist2)){
  a <- paste(outputpath,file_list2[i], sep = '')
  write_csv(mylist2[[i]], a, col_names = F)
}
