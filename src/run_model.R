pacman::p_load(tidyverse, here, cmdstanr, rstan, posterior, brms)

fit_model <- function(df, stan_filepath){
    # prepare the data
    data <- list("Trials" = length(df$Trials), 
                "FirstRating" = df$FirstRating,
                "GroupRating" = df$GroupRating,
                "SecondRating" = df$SecondRating
                 )
    
    # compile the model
    model <- cmdstan_model(stan_filepath, cpp_options = list(stan_threads = TRUE))
    
    # fit the model
    samples <- model$sample(
        data = data,
        seed = 420,
        threads_per_chain = 4,
        iter_warmup = 1000,
        iter_sampling = 2000,
        refresh = 500,
        max_treedepth = 10,
        adapt_delta = 0.99
    )
    
    return(samples)
}

### SIMULATED DATA ###
## WEIGHTED BAYES ## 
weighted_stanpath = here::here("stan", "weighted_bayes.stan")
weighted_df <- read_csv(here::here("data", "simulated_data_weighted.csv"))

# fit 
weighted_samples <- fit_model(weighted_df, weighted_stanpath)

# save 
weighted_samples$save_object(here::here("data", "simulated_samples", "weighted_samples.rds"))

## SIMPLE BAYES ## 
simple_stanpath = here::here("stan", "simple_bayes.stan")
simple_df <- read_csv(here::here("data", "simulated_data_simple.csv"))

# fit
simple_samples <- fit_model(simple_df, simple_stanpath)

# save 
simple_samples$save_object(here::here("data", "simulated_samples", "simple_samples.rds"))

### REAL DATA ###
real_df <- read_csv(here::here("data", "sc_df_clean.csv"))

# add trials
real_df$Trials <- 1:nrow(real_df)

# remove all rows that have a group rating of 0 (these are the ones that were not rated by the group)
real_df <- real_df %>% filter(GroupRating != 0)

# fit weighted bayes
weighted_samples_real <- fit_model(real_df, weighted_stanpath)
weighted_samples_real$save_object(here::here("data", "real_samples", "weighted_samples_real.rds"))

# fit simple bayes
simple_samples_real <- fit_model(real_df, simple_stanpath)
simple_samples_real$save_object(here::here("data", "real_samples", "simple_samples_real.rds"))

