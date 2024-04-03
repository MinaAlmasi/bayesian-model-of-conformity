data {
    int<lower=0> Trials;
    array[Trials] int Choice;
    array[Trials] real <lower = 1, upper = 8> FirstRating; 
    array[Trials] real <lower = 1, upper = 8> GroupRating;
}

transformed data {
  array[Trials] real logit_scaled_FirstRating;
  array[Trials] real logit_scaled_GroupRating;
  // scale the ratings to be between 0 and 1
  logit_scaled_FirstRating = logit(FirstRating/9);
  logit_scaled_GroupRating = logit(GroupRating/9);
}

parameters {
    real Bias;
    real Weight_first;       
    real Weight_group;
}


model {
    // define priors 
    target += normal_lpdf(Bias | 0, 1);
    target += beta_lpdf(Weight_first | 1, 1);
    target += beta_lpdf(Weight_group | 1, 1);

    // compute likelihood
    for (Trial in 1:Trials) {
        target += bernoulli_logit_lpmf( Choice[Trial] | Bias + Weight_first * logit_scaled_FirstRating[Trial] + Weight_group * logit_scaled_GroupRating[Trial]);
        }
}

generated quantities{
    // define variables
    array[Trials] real log_lik;
    real Bias_prior;
    real Weight_first_prior;
    real Weight_group_prior;

    // save priors 
    bias_prior = normal_rng(0, 1) ;
    Weight_first_prior = beta_rng(Weight_first | 1, 1);
    Weight_group_prior = beta_rng(Weight_group | 1, 1);
  
    // save likelihood
    for (Trial in 1:Trials){
        log_lik[Trial]= bernoulli_logit_lpmf(y[Trial] | bias + Weight_first * logit_scaled_FirstRating[Trial] + Weight_group * logit_scaled_GroupRating[Trial]);
}
}