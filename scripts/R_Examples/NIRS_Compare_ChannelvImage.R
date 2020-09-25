library(lme4)
library(readr)
library(dplyr)
library(stringr)
library(ggplot2);theme_set(theme_classic(base_size = 20))
library(lubridate)
library(plyr)

#Pull up the data
CData <- read.csv("CorrelationsByChannel.csv")
hist(CData$Corr)

CData %>%
  ggplot(aes(x = Corr, colour = Chromophore, fill = Chromophore)) +
  geom_histogram(binwidth = 0.05) +
  labs(x = "Correlation (r)", y ='Frequency') +
  geom_vline(xintercept = 0.25, linetype = "dashed") +
  coord_flip() +
  theme(legend.position = c(.8,.2)) +
  ggsci::scale_fill_nejm() +
  ggsci::scale_color_nejm() +
  ggsave('NIRS_ChImage_Correlations_Hist.pdf')

HbLowCorr <- subset(CData, Corr < 0.25)
#write.csv(HbLowCorr,'data_in_progress/Y2-20_LowCorrelations.csv')
HbHighCorr <- subset(CData, Corr >= 0.25)
HbNACorr <- subset(CData, Corr == 'NaN')

#uncomment SS lines below if you want to include Cond
CData %>%
  ggplot(aes(x = Channel, y = Corr, colour = Chromophore, group = Chromophore, fill = Chromophore)) +
  geom_point() +
  theme(legend.title = element_blank(),
        legend.position = c(.8,.2),
        plot.subtitle = element_text(hjust = 0.5)) +
  labs(x = "Channel", y ='Correlation (r)') +
  facet_grid(~Subject) +
  geom_hline(yintercept = 0.25, linetype = "dashed")+
  ggsci::scale_fill_nejm() +
  ggsci::scale_color_nejm() +
  ggsave('NIRS_ChImage_Correlations.pdf')

summary(HbHighCorr)


