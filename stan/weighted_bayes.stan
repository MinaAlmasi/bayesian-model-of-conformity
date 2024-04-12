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
    real <lower = 0, upper = 1> Weight_group;
}


model {
    // def variables
    real Weight_first;
    

    // define priors 
    target += normal_lpdf(Bias | 0, 1);
    target += beta_lpdf(Weight_group | 1, 1);

    // compute likelihood
    Weight_first = 1 - Weight_group;
    target += binomial_logit_lpmf(SecondRatingZero | 7, Bias + Weight_first * logit_scaled_FirstRating + Weight_group * logit_scaled_GroupRating);
}

generated quantities{
    // define variables
    vector[Trials] log_lik;
    real Bias_prior;
    real Weight_group_prior;
    real Weight_first;

    // save priors 
    Bias_prior = normal_rng(0, 1) ;
    Weight_group_prior = beta_rng(1, 1);
  
    // save likelihood
    Weight_first = 1 - Weight_group;
    for (Trial in 1:Trials){
        log_lik[Trial] = binomial_logit_lpmf(SecondRatingZero[Trial] | 7, Bias + Weight_first * logit_scaled_FirstRating[Trial] + Weight_group * logit_scaled_GroupRating[Trial]);
    }
}
