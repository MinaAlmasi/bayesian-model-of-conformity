data {
    int<lower=0> Trials;
    array[Trials] int SecondRating;
    vector[Trials] FirstRating; 
    vector[Trials] GroupRating;
}

transformed data {
    vector[Trials] logit_scaled_FirstRating;
    vector[Trials] logit_scaled_GroupRating;
    // scale the ratings to be between 0 and 1
    logit_scaled_FirstRating = logit(FirstRating/9);
    logit_scaled_GroupRating = logit(GroupRating/9);

    // rescale SecondRating
    array[Trials] int SecondRatingZero;
    for (i in 1:Trials){
        SecondRatingZero[i] = SecondRating[i] - 1;
    }
}

parameters {
    real Bias;       
}


model {
    // define priors 
    target += normal_lpdf(Bias | 0, 1);

    // compute likelihood
    target += binomial_logit_lpmf(SecondRatingZero | 7, Bias + 0.5 * logit_scaled_FirstRating + 0.5 * logit_scaled_GroupRating);
}

generated quantities{
    // define variables
    vector[Trials] log_lik;
    real Bias_prior;

    // save priors 
    Bias_prior = normal_rng(0, 1);
  
    // save likelihood
    for (Trial in 1:Trials){
        log_lik[Trial] = binomial_logit_lpmf(SecondRatingZero[Trial] | 7, Bias + 0.5 * logit_scaled_FirstRating[Trial] + 0.5 * logit_scaled_GroupRating[Trial]);
    }
}
