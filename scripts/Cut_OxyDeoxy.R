library(readr)
library(tidyr)
library(dplyr)

file_list <- list.files('/Volumes/USB DISK/Final_O/', '.csv')
file_list2 <- as.list(file_list)
file_list3 <- lapply(file_list2, function(x) paste('/Volumes/USB DISK/Final_O/', x, sep = ''))
mylist <- lapply(file_list3, function(x) read_csv(x, col_names = F))
#View(mylist[[1]])

mylist2 <- lapply(mylist, function(x) x[1:3])

names(mylist2) <- file_list2

dir <- '/Volumes/USB DISK/Output2/'
dir.create(dir)

for(i in 1:length(mylist2)){
  a <- paste(dir,file_list2[i], sep = '')
  write_csv(mylist2[[i]], a, col_names = F)
}
