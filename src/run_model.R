pacman::p_load(tidyverse, here, cmdstanr, rstan, posterior, brms)

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

convert_SecondRating <- function(df) {
    # compute posterior 
    second_rating_continuous <- df$SecondRating / 9
    
    # make a choice
    df$Choice <- rbinom(length(second_rating_continuous), 1, second_rating_continuous)
    df$ContinuousSecondRating <- second_rating_continuous

    return(df)
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

# transform the second rating of the data
real_df <- convert_SecondRating(real_df)

# add trials
real_df$Trials <- 1:nrow(real_df)

# change all 0s in group rating col to 4.5 to avoid errors when taking the logit of (0). This way, when we take the logit of 4.5/9, we get 0
real_df$GroupRating[real_df$GroupRating == 0] <- 4.5

# fit weighted bayes
weighted_samples_real <- fit_model(real_df, weighted_stanpath)
weighted_samples_real$save_object(here::here("data", "real_samples", "weighted_samples_real.rds"))

# fit simple bayes
simple_samples_real <- fit_model(real_df, simple_stanpath)
simple_samples_real$save_object(here::here("data", "real_samples", "simple_samples_real.rds"))

