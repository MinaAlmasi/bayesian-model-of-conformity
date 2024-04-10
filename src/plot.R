pacman::p_load(tidyverse, here, cmdstanr, posterior, ggpubr)

#' posterior_update_plot
#' @param draws_df a dataframe of draws from the posterior (from RData obj)
#' @param param_name the name of the parameter to plot
#' @param param_true the true value of the parameter
#' @param param_col the color of the parameter
#' @param title the title of the plot
posterior_update_plot <- function(posterior_samples, param_true, param_col, title){
    draws_df <- as_draws_df(posterior_samples$draws())
    
    plot <- ggplot(draws_df) +
      # posterior
      geom_density(aes(!!sym(param_col), fill = "Posterior"), alpha = 0.4) +
      
      # prior 
      geom_density(aes(!!sym(paste0(param_col, "_prior")), fill = "Prior"), alpha = 0.4) +
      
      # true value
      geom_vline(aes(xintercept = param_true, color = "True Value"), linetype = "dashed") +
      
      xlab(param_col) +
      ylab("Posterior Density") +
      labs(title=title) +
      scale_fill_manual(name = "Distribution",
                        values = c("Posterior" = "#005DFF", "Prior" = "#FF0000"),
                        labels = c("Posterior", "Prior")) +
      scale_color_manual(name = "",
                        values = "black",
                        labels = "True Value") +
      theme_bw() +
      theme(legend.position="bottom", 
            legend.title=element_blank(), 
            legend.key.size = unit(1, 'cm'), 
            legend.text = element_text(size = 12),
            legend.box.spacing = unit(5, "pt"),
            axis.text=element_text(size=12), 
            axis.title=element_text(size=16), 
            plot.title = element_text(size = 16)
            )

    return(plot)
}

## WEIGHTED BAYES ##
weighted_samples <- readRDS(here::here("data", "model_quality", "weighted_samples.rds"))
weighted_df <- read_csv(here::here("data", "simulated_data_weighted.csv"))

group_weight_plot <- posterior_update_plot(weighted_samples, param_true = weighted_df$Weight_group[1], param_col = "Weight_group", "Group Rating Weight (Weighted Bayes)")
first_weight_plot <- posterior_update_plot(weighted_samples, param_true = weighted_df$Weight_first[1], param_col = "Weight_first", "First Rating Weight (Weighted Bayes)")
bias_wb_plot <- posterior_update_plot(weighted_samples, param_true = weighted_df$Bias[1], param_col = "Bias", "Bias (Weighted Bayes)")


# save plot
ggsave(here::here("plots", "group_weight_plot_WB.jpg"), group_weight_plot, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "first_weight_plot_WB.jpg"), first_weight_plot, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "bias_plot_WB.jpg"), bias_wb_plot, width = 20, height = 10, units = "cm")

## SIMPLE BAYES ##
simple_samples <- readRDS(here::here("data", "model_quality", "simple_samples.rds"))
simple_df <- read_csv(here::here("data", "simulated_data_simple.csv"))

bias_sb_plot <- posterior_update_plot(simple_samples, param_true = simple_df$Bias[1], param_col = "Bias", "Bias (Simple Bayes)")

# save plot
ggsave(here::here("plots", "bias_plot_SB.jpg"), bias_sb_plot, width = 20, height = 10, units = "cm")