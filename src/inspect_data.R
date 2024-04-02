pacman::p_load(ggplot2, tidyverse)

# read data
data <- read.csv("data/sc_df_clean.csv")
feedback_counts <- data %>% 
  group_by(Feedback) %>%
  summarize(n = n())
  
print(feedback_counts)

# plot distribution of the feedback column
plot <- ggplot(data, aes(x = Feedback)) +
  geom_histogram(binwidth = 1, fill = "skyblue", color = "black") +
  labs(title = "Distribution of feedback",
       x = "Feedback",
       y = "Frequency") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# save plot
ggsave("plots/feedback_distribution.jpg", plot, width = 10, height = 10, units = "cm")
