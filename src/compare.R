pacman::p_load(here, loo)

# read in data
weighted_samples <- readRDS(here::here("data", "real_samples", "weighted_samples_real.rds"))
simple_samples <- readRDS(here::here("data", "real_samples", "simple_samples_real.rds"))

# get loo
weighted_samples_loo <- weighted_samples$loo(save_psis = TRUE, cores=3)
simple_samples_loo <- simple_samples$loo(save_psis = TRUE, cores=3)

# compare 
loo_compare(weighted_samples_loo, simple_samples_loo)

