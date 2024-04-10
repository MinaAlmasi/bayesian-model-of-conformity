data {
    int<lower=0> Trials;
    array[Trials] int Choice;
    vector[Trials] FirstRating; 
    vector[Trials] GroupRating;
}

transformed data {
  vector[Trials] logit_scaled_FirstRating;
  vector[Trials] logit_scaled_GroupRating;
  // scale the ratings to be between 0 and 1
  logit_scaled_FirstRating = logit(FirstRating/9);
  logit_scaled_GroupRating = logit(GroupRating/9);
}

parameters {
    real Bias;
}


model {
    // define priors 
    target += normal_lpdf(Bias | 0, 1);

    // compute likelihood
    for (Trial in 1:Trials) {
        target += bernoulli_logit_lpmf(Choice[Trial] | Bias + logit_scaled_FirstRating[Trial] + logit_scaled_GroupRating[Trial]);
        }
}

generated quantities{
    // define variables
    array[Trials] real log_lik;
    real Bias_prior;

    // save priors 
    Bias_prior = normal_rng(0, 1) ;
  
    // save likelihood
    for (Trial in 1:Trials){
        log_lik[Trial] = bernoulli_logit_lpmf(Choice[Trial] | Bias + logit_scaled_FirstRating[Trial] + logit_scaled_GroupRating[Trial]);
}
}
