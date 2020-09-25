library(readr)
library(dplyr)
library(stringr)
library(ggplot2);theme_set(theme_classic(base_size = 24))
library(lme4)
library(lmerTest)
library(plotly)
library(languageR)
library(ggstatsplot)
library(effects)
library(tidyr)
library(forcats)
library(patchwork)


##############################################################
NIRSData <- read.csv("TsHb_WLCT_ChildTest.csv")

#cluster 1
Hb <- subset(NIRSData, Cluster == '1' & Effect == 'ChildTest')

#calc average over subjects...
Hb <- Hb %>%
  group_by(Subject, Cond, Chromophore, Time) %>%
  summarise(
    Mean = mean(Mean)
  ) %>%
  ungroup() 

Hb %>%
  ggplot(aes(x = Time, y = Mean, colour = Chromophore, group = Chromophore, fill = Chromophore)) +
  stat_summary(geom = 'pointrange', fun.data = 'mean_se', alpha = 0.5) +
  stat_smooth(se = F) +
  #  coord_cartesian(ylim = c(-0.5, 0.5)) +
  theme(legend.title = element_blank(), legend.position = 'none',
        plot.subtitle = element_text(hjust = 0.5)) +
  labs(x = "Time (s)", y ='Weighted M Beta (µM)', subtitle = 'Cluster 1') +
  facet_wrap(~Cond) +
  geom_hline(yintercept = 0, linetype = "dashed")+
  ggsci::scale_fill_nejm() +
  ggsci::scale_color_nejm() +
  ggsave('TsHb_Cluster1.pdf')





