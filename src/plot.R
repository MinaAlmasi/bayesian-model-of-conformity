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
      
      # plot true value as a vertical line if it is not NA
      {if(!is.na(param_true))geom_vline(aes(xintercept = param_true, color = "True Value"), linetype = "dashed")} +
      
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

draw_trace_plots <- function(posterior_samples_list, param_col, title){
  draws_df <- as_draws_df(posterior_samples_list$draws())
  
  plot <- ggplot(draws_df, aes(.iteration, !!sym(param_col), group = .chain, color = .chain)) +
    geom_line() +
    labs(title = title, x = "Iteration", y = "Value") +
    theme_bw()+
    theme(legend.position="bottom", 
          legend.title=element_blank(), 
          legend.key.size = unit(0.4, 'cm'), 
          legend.text = element_text(size = 10),
          legend.box.spacing = unit(5, "pt"),
          axis.text=element_text(size=10), 
          axis.title=element_text(size=12), 
          plot.title = element_text(size = 14)
          )

  return(plot)
}

### SIMULATED DATA ###
## WEIGHTED BAYES ##
weighted_samples <- readRDS(here::here("data", "simulated_samples", "weighted_samples.rds"))
weighted_df <- read_csv(here::here("data", "simulated_data_weighted.csv"))

group_weight_plot <- posterior_update_plot(weighted_samples, param_true = weighted_df$Weight_group[1], param_col = "Weight_group", "Group Rating Weight (Weighted Bayes)")
bias_wb_plot <- posterior_update_plot(weighted_samples, param_true = weighted_df$Bias[1], param_col = "Bias", "Bias (Weighted Bayes)")

group_weight_trace_wb <- draw_trace_plots(weighted_samples, "Weight_group", "Group Rating Weight (Weighted Bayes)")
bias_trace_wb <- draw_trace_plots(weighted_samples, "Bias", "Bias (Weighted Bayes)")

# save plot
ggsave(here::here("plots", "group_weight_plot_WB.jpg"), group_weight_plot, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "bias_plot_WB.jpg"), bias_wb_plot, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "group_weight_trace_WB.jpg"), group_weight_trace_wb, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "bias_trace_WB.jpg"), bias_trace_wb, width = 20, height = 10, units = "cm")

## SIMPLE BAYES ##
simple_samples <- readRDS(here::here("data", "simulated_samples", "simple_samples.rds"))
simple_df <- read_csv(here::here("data", "simulated_data_simple.csv"))

bias_sb_plot <- posterior_update_plot(simple_samples, param_true = simple_df$Bias[1], param_col = "Bias", "Bias (Simple Bayes)")
bias_trace_sb <- draw_trace_plots(simple_samples, "Bias", "Bias (Simple Bayes)")

# save plot
ggsave(here::here("plots", "bias_plot_SB.jpg"), bias_sb_plot, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "bias_trace_SB.jpg"), bias_trace_sb, width = 20, height = 10, units = "cm")

### REAL DATA ###
## WEIGHTED BAYES ##
weighted_samples_real <- readRDS(here::here("data", "real_samples", "weighted_samples_real.rds"))
group_weight_plot_real <- posterior_update_plot(weighted_samples_real, param_true = NA, param_col = "Weight_group", "Group Rating Weight (Weighted Bayes)")
bias_plot_real <- posterior_update_plot(weighted_samples_real, param_true = NA, param_col = "Bias", "Bias (Weighted Bayes)")
group_weight_trace_wb_real <- draw_trace_plots(weighted_samples_real, "Weight_group", "Group Rating Weight (Weighted Bayes)")
bias_trace_wb_real <- draw_trace_plots(weighted_samples_real, "Bias", "Bias (Weighted Bayes)")

# save plot
ggsave(here::here("plots", "group_weight_plot_WB_real.jpg"), group_weight_plot_real, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "bias_plot_WB_real.jpg"), bias_plot_real, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "group_weight_trace_WB_real.jpg"), group_weight_trace_wb_real, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "bias_trace_WB_real.jpg"), bias_trace_wb_real, width = 20, height = 10, units = "cm")

## SIMPLE BAYES ##
simple_samples_real <- readRDS(here::here("data", "real_samples", "simple_samples_real.rds"))
bias_sb_plot_real <- posterior_update_plot(simple_samples_real, param_true = NA, param_col = "Bias", "Bias (Simple Bayes)")
bias_trace_sb_real <- draw_trace_plots(simple_samples_real, "Bias", "Bias (Simple Bayes)")

# save plot
ggsave(here::here("plots", "bias_plot_SB_real.jpg"), bias_sb_plot_real, width = 20, height = 10, units = "cm")
ggsave(here::here("plots", "bias_trace_SB_real.jpg"), bias_trace_sb_real, width = 20, height = 10, units = "cm")