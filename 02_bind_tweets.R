library(academictwitteR)
library(tidylog)
library(dplyr)
library(fst)
options(scipen = 999)

#bind json files

origin_path <- "data/tweetdata/"
fls <- list.files(origin_path)

flpaths <- paste0(origin_path, fls)

tweets_all <- data.frame()
  
for (i in seq_along(flpaths)) {
    cat("Binding tweets from ",
        "followers folder number ",
        i,
        "of ",
        length(flpaths),
        "\n")
  if (length(list.files(flpaths[i])) > 1) {
    
    tweets <- bind_tweets(flpaths[i])
    
    saveRDS(tweets, paste0("data/tweetdata_bound/", fls[i], ".rds"))
  }
  else{
    next
  }
}

# bind rds files

origin_path <- "data/tweetdata_bound/"
destination_path <- "data/fulldata/"
fls <- list.files(origin_path)

flpaths <- paste0(origin_path, fls)

tweets_all <- data.frame()
for (i in seq_along(flpaths)) {
  cat("Reading tweets from ",
      "followers folder number ",
      i,
      "of ",
      length(flpaths),
      "\n")
  
  tweets <- readRDS(flpaths[i])
  
  if (nrow(tweets) >= 1) {
  
  tweets$date <- as.Date(tweets$created_at)
  tweets$retweets <- tweets$public_metrics$retweet_count
  tweets$replies <- tweets$public_metrics$reply_count
  tweets$likes <- tweets$public_metrics$like_count
  tweets$quotes <- tweets$public_metrics$quote_count
  tweets$impressions <- tweets$public_metrics$impression_count
  tweets <- tweets %>%
    select(author_id, text, date, retweets, replies, likes, quotes, impressions)
  
  tweets$suspended_account_followed <- gsub(".rds", "",fls[i])
  
  tweets_all <- rbind(tweets_all, tweets)
  
  write_fst(tweets_all, paste0(destination_path, "fulldata.fst")) }
  
  else{
    next
  }
}