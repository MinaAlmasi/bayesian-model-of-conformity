# script for simulating 

#' Bayes Agent that can function as a SimpleBayes (when both weights are 0.5)
#' rating_participant: rating of the participant
#' rating_group: rating of the entire group
#' weight_p: the weight of the participant
#' weight_g: the weight of the group
Bayes_Agent <- function(rating_participant, rating_group, weight_p, weight_g) {
    # check if total sum of weights is 1
    if (weight_p + weight_g != 1) {
        stop("The sum of the weights should be 1")
    }
    
    # divide the numbers by nine (to make them between 0 and 1) and do the logit transformation
    logit_participant <- brms::logit_scaled(rating_participant / 9)
    logit_group <- brms::logit_scaled(rating_group / 9)
    
    # compute posterior 
    second_rating_continuous <- brms::inv_logit_scaled(logit_participant * weight_p + logit_group * weight_g)
    
    # put onto the right scale
    second_rating_discrete <- round(second_rating_continuous * 9, 0)

    return(second_rating_discrete)
}

simulate_bayes <- function(weight_p, weight_g){
    # simulate participant ratings
    rating_participant <- sample(c(1:8), 1, replace=TRUE, prob=c(1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8))
    
    # set an initial invalid value for the group rating
    rating_group <- -1

    # iterate until the group rating is valid
    while (rating_group < 1 | rating_group > 8) {
        # draw a feedback (from -3 to 3 but no 1s as in the real experiment)
        feedback <- sample(c(-3,-2,0,2,3), 1, replace=TRUE, prob=c(0.2, 0.2, 0.2, 0.2, 0.2))

        # determine group rating
        rating_group <- rating_participant + feedback
    }

    # calculate the second rating (for the participant)
    second_rating <- Bayes_Agent(rating_participant, rating_group, weight_p, weight_g)

    return(list(rating_participant = rating_participant, rating_group = rating_group, second_rating = second_rating))
}

rating = Bayes_Agent(rating_participant = 7, rating_group = 1, weight_p = 0.8, weight_g = 0.2)
print(rating)

simulate_bayes(weight_p = 0.8, weight_g = 0.2)
