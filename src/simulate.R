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
    
    # make ratings (we add 1 to make it between 1 and 8)
    SecondRating <- rbinom(1, 7, second_rating_continuous) + 1

    return(SecondRating)
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
    SecondRating <- Bayes_Agent(bias, rating_participant, rating_group, weight_p, weight_g)

    return(list(FirstRating = rating_participant, GroupRating = rating_group, SecondRating = SecondRating, Bias=bias))
}


# simulate the data (for one agent to do model quality checks)
n_trials <- 3000
weight_g <- c(0.9, 0.5)
weight_f <- c(0.1, 0.5)
bias <- 0
file_names <- c("simulated_data_weighted.csv", "simulated_data_simple.csv")
set.seed(124)

for (j in 1:2) {
    # initialize the data frame
    simulated_data <- data.frame(matrix(ncol=7, nrow=n_trials))
    colnames(simulated_data) <- c("Trials", "FirstRating", "GroupRating", "SecondRating", "Bias", "Weight_first", "Weight_group")

    print("Simulating and saving data...")
    # simulate the data
    for (i in 1:n_trials) {
        result <- simulate_bayes(bias, weight_f[j], weight_g[j])
        simulated_data[i,] <- c(i, result$FirstRating, result$GroupRating, result$SecondRating, result$Bias, weight_f[j], weight_g[j])
    }
    # save 
    save_filepath = here::here("data", file_names[j])
    write.csv(simulated_data, save_filepath)
}