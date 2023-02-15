library(academictwitteR) # see: https://github.com/cjbarrie/academictwitteR
library(readr)
library(dplyr)
library(tidylog)
library(stringr)
options(scipen = 999)

#get dates of account suspensions
suspdates <- read_csv("data/raw/tracked-suspensions.csv")

#read in follower lists
suspended_followers_all <-
  readRDS("data/output/suspended_followers_all.rds")

susp_popular <- suspdates %>%
  filter(Followers>=5000) %>%
  pull(`Twitter ID`)

# suspnames_all <- as.numeric(c())
# for (i in seq_along(suspended_followers_all)) {
#   suspname <- colnames(suspended_followers_all[[i]])
#   suspnames_all <- as.numeric(c(suspnames_all, suspname))
# 
# }
# 
# susp_popular[!(susp_popular %in% suspnames_all)]

# suspnames_all <- as.numeric(c())
# for (i in seq_along(suspended_followers_pop)) {
#   suspname <- colnames(suspended_followers_pop[[i]])
#   suspnames_all <- as.numeric(c(suspnames_all, suspname))
# 
# }

# susp_populardf <- suspdates %>%
#   filter(`Twitter ID` %in% suspnames_all)

# some of the accounts listed in suspdates are not actually in the raw data
#TODO look into why this is

suspended_followers_pop <- list()

for (i in seq_along(suspended_followers_all)) {
  suspname <- colnames(suspended_followers_all[[i]])
  if (str_detect(suspname, paste0("\\b", susp_popular, "\\b", collapse = "|"))) {
    suspended_followers_pop[[i]] <- suspended_followers_all[[i]]
  }
}

suspended_followers_pop <- suspended_followers_pop[lengths(suspended_followers_pop) != 0]


for (i in seq_along(suspended_followers_pop)) {
  #get suspended account ID for file naming
  suspended_account = colnames(suspended_followers_pop[[i]])
  #make data path for saving
  data_path_for_follower_tweets = paste0("data/tweetdata_popular/", suspended_account)
  #get date-time of suspension
  suspdatetime = suspdates[suspdates$`Twitter ID` == suspended_account, 4]
  suspdate = as.Date(suspdatetime$`Suspension detected`)
  #get date 30 days before
  suspdateb = suspdate - 30
  #get date 30 days after
  suspdatea = suspdate + 30
  #format per Twitter API requirements
  suspdateb_tformat = paste0(as.character(suspdateb), "T00:00:00Z")
  suspdatea_tformat = paste0(as.character(suspdatea), "T00:00:00Z")
  #get followers of suspended account
  followers = suspended_followers_pop[[i]][[suspended_account]]
  
  #sample followers
  set.seed(123L)
  
  followers_sample <- sample(followers, 1000, replace = F)
  
  #get tweets of followers
  for (j in seq_along(followers_sample)) {
    cat(
      "Ingesting tweets of follower #",
      j,
      " of ",
      length(followers_sample),
      "for suspended account # ",
      i,
      " of ",
      length(suspended_followers_pop),
      "\n"
    )
    
    error <- tryCatch(
      get_all_tweets(
        users = followers_sample[[j]],
        start_tweets = suspdateb_tformat,
        end_tweets = suspdatea_tformat,
        data_path = data_path_for_follower_tweets,
        bind_tweets = F,
        n = Inf,
        verbose = F
      ),
      error = function(e)
        e
    )
    if (inherits(error, 'error')) {
      next
    }
    
  }
}