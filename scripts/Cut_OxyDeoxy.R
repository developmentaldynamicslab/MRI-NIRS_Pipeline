library(readr)
library(tidyr)
library(dplyr)

file_list <- list.files('/Users/nfb15zpu/Documents/J-Files/Grants/Grant_NIH_2013_NIRS/NIHVWM2019/30NIH-VWM-Y1NEW/Final_O', '.csv')
file_list2 <- as.list(file_list)
file_list3 <- lapply(file_list2, function(x) paste('/Users/nfb15zpu/Documents/J-Files/Grants/Grant_NIH_2013_NIRS/NIHVWM2019/30NIH-VWM-Y1NEW/Final_O/', x, sep = ''))
mylist <- lapply(file_list3, function(x) read_csv(x, col_names = F))
#View(mylist[[1]])

mylist2 <- lapply(mylist, function(x) x[1:3])

names(mylist2) <- file_list2

dir <- '/Users/nfb15zpu/Documents/J-Files/Grants/Grant_NIH_2013_NIRS/NIHVWM2019/30NIH-VWM-Y1NEW/Output2/'
dir.create(dir)

for(i in 1:length(mylist2)){
  a <- paste(dir,file_list2[i], sep = '')
  write_csv(mylist2[[i]], a, col_names = F)
}
