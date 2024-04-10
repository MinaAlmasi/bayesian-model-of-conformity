pacman::p_load(tidyverse, here, cmdstanr, rstan, posterior)

fit_model <- function(df, stan_filepath){
    # prepare the data
    data <- list("Trials" = length(df$Trials), 
                "FirstRating" = df$FirstRating,
                "GroupRating" = df$GroupRating,
                "Choice" = df$Choice
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

## WEIGHTED BAYES ## 
weighted_stanpath = here::here("stan", "weighted_bayes.stan")
weighted_df <- read_csv(here::here("data", "simulated_data_weighted.csv"))

# fit 
weighted_samples <- fit_model(weighted_df, weighted_stanpath)

## SIMPLE BAYES ## 
simple_stanpath = here::here("stan", "simple_bayes.stan")
simple_df <- read_csv(here::here("data", "simulated_data_simple.csv"))

# fit
simple_samples <- fit_model(simple_df, simple_stanpath)
