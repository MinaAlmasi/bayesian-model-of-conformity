pacman::p_load(here, loo, tibble)

# read in data
weighted_samples <- readRDS(here::here("data", "real_samples", "weighted_samples_real.rds"))
simple_samples <- readRDS(here::here("data", "real_samples", "simple_samples_real.rds"))

# get loo
weighted_samples_loo <- weighted_samples$loo(save_psis = TRUE, cores=3)
simple_samples_loo <- simple_samples$loo(save_psis = TRUE, cores=3)

# compare 
loo_compare(weighted_samples_loo, simple_samples_loo)

# plot differential elpd
n_data_points <- nrow(weighted_samples_loo$pointwise)

elpd <- tibble(
    n = seq(n_data_points),
    diff_elpd = simple_samples_loo$pointwise[, "elpd_loo"]  - weighted_samples_loo$pointwise[, "elpd_loo"] 
)

elpd_plot <- ggplot(elpd, aes(x = n, y = diff_elpd)) +
    geom_point(alpha = .1) +
    #xlim(.5,1.01) +
    #ylim(-1.5,1.5) +
    geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
    theme_bw()

# save plot
ggsave(here::here("plots", "diff_elpd.jpg"), elpd_plot, width = 20, height = 10, units = "cm")
