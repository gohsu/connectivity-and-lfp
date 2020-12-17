### David's messy script

library(tidyverse)

library(cancensus)

df <- df %>% as_tibble %>% st_as_sf

df$residuals <- resid(model_all)

df %>% 
  count(cma_uid, sort = TRUE)

df %>% 
  # filter(cma_uid == "24462") %>% 
  # filter(cma_uid == "35535") %>% 
  filter(cma_uid == "59933") %>% 
  ggplot() +
  geom_sf(aes(fill = residuals), colour = "transparent") +
  scale_fill_viridis_c(limits = c(-15, 20)) +
  theme_minimal()

df %>% 
  st_drop_geometry() %>% 
  group_by(region_name) %>% 
  summarize(mean_residual = mean(residuals)) %>% 
  ggplot() +
  geom_histogram(aes(mean_residual))
  

install.packages("lme4")
library(lme4)

df_no_geom %>% as_tibble()

df_vars <- df_no_geom[iv_colnames]
df_vars$region_name <- df$region_name
df_vars$lfp_female <- df_no_geom$lfp_female

lmer(lfp_female ~ . -region_name + (1 | region_name), data=df_vars) %>% 
  summary()

lm(lfp_female ~ . -lfp_male -region_name, data=df_vars) %>% summary()

lm(lfp_male ~ . -lfp_female -region_name, data=df_vars) %>% summary()