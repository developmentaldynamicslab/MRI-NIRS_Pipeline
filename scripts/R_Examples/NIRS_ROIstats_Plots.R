library(readr)
library(dplyr)
library(stringr)
library(ggplot2);theme_set(theme_classic(base_size = 20))
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
# load base data frames...

NIRSData <- read_csv("NIRS/GroupAnalyses_fullCPOct/Y1MRIs.csv") 
NIRSDataB <- read_csv("NIRS/GroupAnalyses_fullCPOct/Y1Templates.csv") 
NIRSDataC <- read_csv("NIRS/GroupAnalyses_fullCPOct/Y2MRIs.csv") 
NIRSDataD <- read_csv("NIRS/GroupAnalyses_fullCPOct/Y2Templates.csv") 
NIRSDataFull <- full_join(NIRSData, NIRSDataB)
NIRSDataFull <- full_join(NIRSDataFull, NIRSDataC)
NIRSDataFull <- full_join(NIRSDataFull, NIRSDataD) %>% 
  rename(IndiaCode = Subject)

write_csv(NIRSDataFull,"NIRS/Y1Y2CombinedROIStats.csv")

ses <- read_csv("data_final/SES_Combined_Final.csv") %>% 
  select(IndiaCode, SESEduStatus, BabyGender, MotherEduScore, SESScore, Income)

NIRSData2 <- NIRSDataFull %>% 
  inner_join(ses, NIRSDataFull, by='IndiaCode') 

##############################################################
#sample plot where all factors are included...
#note: I commented out 'geom_point' so range is reasonable -- if you want to see all the data
#including 'outlier' observations, you can uncomment this line.
#coord_cartesian allows you to fix the scale if desired (e.g., to match other plots)
#ggsave allows you to save the plot to a file...

#full list of effects for reference...
#group_by(IndiaCode, Effect, Cluster, Year, Cond, Chromophore, SESEduStatus, BabyGender, MotherEduScore,
#         SESScore, Income) %>%
 
 
##############################################################
#30SESEduxGenderxSSxHb
# avg across Year
NIRSData2_30 <- NIRSData2 %>%
  group_by(IndiaCode, Effect, Cluster, Cond, Chromophore, SESEduStatus, BabyGender, MotherEduScore,
           SESScore, Income) %>%
  summarise(
    Beta = mean(Beta)
  ) %>%
  ungroup() 

temp <- subset(NIRSData2_30, Effect == '30SESEduxGenderxSSxHb')
unique(temp$Cluster) #gives total -- if you used nzmean option, remember that you'll
#have double the number of clusters; odd clusters = mean, even clusters = nzmean

subset(NIRSData2_30, Cluster == '1' & Effect == '30SESEduxGenderxSSxHb') %>%
  mutate(SS = case_when(Cond == '1' ~ 'low',
                        Cond == '2' ~ 'med',
                        Cond == '3' ~ 'high',
                        is.na(Cond) ~ 'NA')) %>% 
  mutate(SS = fct_relevel(SS, c('low', 'med','high'))) %>% 
  ggplot(aes(x = SS, y = Beta, colour = Chromophore, group = Chromophore, fill = Chromophore)) +
  stat_smooth(method = 'lm', se = T) +
  geom_point(size = 3, position = position_jitter(width = .15), alpha = 0.6) +
#  coord_cartesian(ylim = c(-0.5, 0.5)) +
  theme(legend.title = element_blank(), legend.position = c(0.5, 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  labs(x = "Load", y ='Beta (µM)', subtitle = 'l-TPJ') +
  facet_grid(SESEduStatus~BabyGender) +
  geom_hline(yintercept = 0, linetype = "dashed")+
  ggsci::scale_fill_nejm() +
  ggsci::scale_color_nejm()
#  ggsave('Fig4_r-aIPS_clust1.pdf')

