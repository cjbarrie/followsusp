library(tidylog)
library(dplyr)
options(scipen = 999)

origin_path <- "data/raw/follower_lists/"
fls <- list.files(origin_path)

#note: removed 88 accounts because fewer than 5 or no followers
#these are archived in folder "data/raw/removed_lists"

suspended_followers_all <- list()

for(i in seq_along(fls)) {
  
  cat("Reading in account #", i, " of ", length(fls), "\n")
  suspended_followers <- read.table(paste0(origin_path, fls[i]), sep='\t')
  suspended_id <- gsub(".txt", "", fls[i])
  colnames(suspended_followers) <- suspended_id
  
  suspended_followers_all[[i]] <- suspended_followers
}

saveRDS(suspended_followers_all, "data/output/suspended_followers_all.rds")

# TODO
# check accounts against alt-right lists or similar to select
# take a sample of 100-1000 followers for each account
# collect tweets of followers for 60 days before and 60 days after suspension
# measure rate of tweeting
# measure toxicity of tweets