library(peRspective) #see: https://github.com/favstats/peRspective 
library(tidyverse)
library(tidylog)

# usethis::edit_r_environ()
tweets <- readRDS("data/testdata/testweets.rds")

tweets$date <- as.Date(tweets$created_at)

set.seed(123L)

models <- c(peRspective::prsp_models)
models_subset <- models[c(1:5, 7, 9:10, 12, 14)]
models_subset

toxtwts <- tweets %>%
  prsp_stream(text = text,
              text_id = tweet_id, 
              score_model = models_subset,
              verbose = T,
              safe_output = T)

colnames(toxtwts) <- c("tweet_id", "error", models_subset)

tweets <- tweets %>%
  left_join(toxtwts, by = "tweet_id")

ggplot(tweets) +
  geom_point(aes(date, TOXICITY), alpha = .2) +
  geom_smooth(aes(date, TOXICITY), col = "red") +
  theme(axis.text=element_text(size=25),
        legend.text=element_text(size=25),
        legend.title =element_text(size=25),
        axis.title =element_text(size=25))