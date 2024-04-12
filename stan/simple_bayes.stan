data {
    int<lower=0> Trials;
    vector[Trials] SecondRating;
    vector[Trials] FirstRating; 
    vector[Trials] GroupRating;
}

transformed data {
  vector[Trials] logit_scaled_FirstRating;
  vector[Trials] logit_scaled_GroupRating;
  // scale the ratings to be between 0 and 1
  logit_scaled_FirstRating = logit(FirstRating/9);
  logit_scaled_GroupRating = logit(GroupRating/9);
  
  // scale ratings to be between 0 and 7 
  vector[Trials] SecondRatingZero;
  SecondRatingZero = SecondRating - 1;
}

parameters {
    real Bias;
}


model {
    // define variables
    real Weight_first;
    real Weight_group;

    // define priors 
    target += normal_lpdf(Bias | 0, 1);

    // weights (fixed in SimpleBayes)
    Weight_first = 0.5;
    Weight_group = 0.5;

    // compute likelihood
    for (Trial in 1:Trials) {
         target += binomial_logit_lpmf(SecondRatingZero[Trial] | 7, Bias + Weight_first * logit_scaled_FirstRating[Trial] + Weight_group * logit_scaled_GroupRating[Trial]);
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
        log_lik[Trial] = binomial_logit_lpmf(SecondRatingZero[Trial] | 7, Bias + Weight_first * logit_scaled_FirstRating[Trial] + Weight_group * logit_scaled_GroupRating[Trial]);
}
}
