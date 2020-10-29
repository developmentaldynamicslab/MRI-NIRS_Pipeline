library(readr)
library(dplyr)
library(stringr)
library(ggplot2);theme_set(theme_classic(base_size = 24))
library(lme4)
library(lmerTest)
library(plotly)
library(languageR)
library(ggstatsplot)
#source('misc/flatviolin.R')
library(effects)
library(tidyr)
library(forcats)
library(patchwork)

ITI1 <- read_csv("NIRS/Y1_ITI_Distribution.csv")
ITI2 <- read_csv("NIRS/Y2_ITI_Distribution.csv")
ITIs <- full_join(ITI1,ITI2)

qplot(ITIs$ITI, geom="histogram",
      xlim=c(0,100),
      binwidth=1)

ITIshort <- subset(ITIs, ITI < 30)
qplot(ITIshort$ITI, geom="histogram",
      xlim=c(0,30),
      binwidth=1) 
summary(ITIshort)

ITIshortY1 <- subset(ITIs, ITI < 30 & AnalysisLabel == 'Y1')
qplot(ITIshortY1$ITI, geom="histogram",
      xlim=c(0,30),
      binwidth=1) 
summary(ITIshortY1)

ITIshortY2 <- subset(ITIs, ITI < 30 & AnalysisLabel == 'Y2')
qplot(ITIshortY2$ITI, geom="histogram",
      xlim=c(0,30),
      binwidth=1) 
summary(ITIshortY2)

#extract data for explorations in matlab
ITIshortData <- subset(ITIs, ITI < 30) %>% 
  select(ITI)
