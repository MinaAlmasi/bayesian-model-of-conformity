# script for simulating 
pacman::p_load(brms, here)

#' Bayes Agent that can function as a SimpleBayes (when both weights are 0.5)
#' bias: bias of the participant (noise)
#' rating_participant: rating of the participant
#' rating_group: rating of the entire group
#' weight_p: the weight of the participant
#' weight_g: the weight of the group
Bayes_Agent <- function(bias, rating_participant, rating_group, weight_p, weight_g) {    
    # divide the numbers by nine (to make them between 0 and 1) and do the logit transformation
    logit_participant <- brms::logit_scaled(rating_participant / 9)
    logit_group <- brms::logit_scaled(rating_group / 9)
    
    # compute posterior 
    second_rating_continuous <- brms::inv_logit_scaled(bias + logit_participant * weight_p + logit_group * weight_g)
    
    # put onto the right scale
    second_rating_discrete <- round(second_rating_continuous * 9, 0)
    
    # make a choice
    choice <- rbinom(1, 1, second_rating_continuous)

    return(list(second_rating_discrete = second_rating_discrete, choice = choice))
}

simulate_bayes<- function(bias=0, weight_p, weight_g){
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
    result <- Bayes_Agent(bias, rating_participant, rating_group, weight_p, weight_g)
    second_rating <- result$second_rating_discrete
    choice <- result$choice

    return(list(FirstRating = rating_participant, GroupRating = rating_group, SecondRating = second_rating, Choice=choice, Bias=bias))
}


# simulate the data (for one agent to do model quality checks)
n_trials = 36
weight_g = 0.8
weight_f = 0.1
bias = 0

# initialize the data frame
simulated_data <- data.frame(matrix(ncol=8, nrow=n_trials))
colnames(simulated_data) <- c("Trials", "FirstRating", "GroupRating", "SecondRating", "Choice", "Bias", "Weight_first", "Weight_group")

print("Simulating and saving data...")
# simulate the data
for (i in 1:n_trials) {
    result <- simulate_bayes(bias, weight_f, weight_g)
    simulated_data[i,] <- c(i, result$FirstRating, result$GroupRating, result$SecondRating, result$Choice, result$Bias, weight_f, weight_g)
}

# save 
save_filepath = here::here("data", "simulated_data_weighted.csv")
write.csv(simulated_data, save_filepath)

