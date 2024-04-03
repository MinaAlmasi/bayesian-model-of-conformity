pacman::p_load(tidyverse, here, cmdstanr, rstan, posterior)

stan_filepath = here::here("stan", "weighted_bayes.stan")

fit_model <- function(df){
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

df_filepath = here::here("data", "simulated_data_weighted.csv")
df <- read_csv(df_filepath)

samples <- fit_model(df)
