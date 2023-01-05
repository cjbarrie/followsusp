library(tidylog)
library(dplyr)
options(scipen = 999)

origin_path <- "data/raw/follower_lists/"
fls <- list.files(origin_path)

test <- read.table(paste0(origin_path, fls[1]), sep='\t')

# TODO
# check accounts against alt-right lists or similar to select
# take a sample of 100-1000 followers for each account
# collect tweets of followers for 60 days before and 60 days after suspension
# measure rate of tweeting
# measure toxicity of tweets