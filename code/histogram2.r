---
title: "Modeling"
output: r
date: '2022-03-22'

#Histogram for scores for reviews above 50 word count
library(tidyverse)
library(here)
reviews <- read_csv(here("all_apps_reviews_nodupes.csv")) #look into saveRDS/writeRDS too
reviews$score
attach(reviews)
#create variable Word.Count
#fix encoding
reviews <- sample_n(reviews, 200) #remove this when you run it
reviews <- slice(reviews, 1:20) 
reviews <- mutate(reviews, 
                  word_count = str_count(
                    str_conv(content, encoding = 'UTF-8' ), 
                    '\\w+')) #to be fixed

#possibly(str_conv(encoding = 'UTF-8' ), "")

newdata <- filter(reviews, word_count > 50)
newdata$word_count


ggplot(newdata, aes(x = word_count)) +
     geom_histogram(stat = 'count') +
     ggtitle("Score Distribution of over 50 Word Count Reviews") +
     xlab("Review Scores") +
     ylab("# of reviews") +
     ylim(c(0,2000)) 
     scale_x_continuous(breaks = 10) #
     
#to add labels
  ?geom_label()
  ?geom_text()

# Histogram for distribution of all app reviews
hist(reviews$score, main="Distribution of All Scores Emergency App Reviews", xlab = "Review Scores", ylab = "# of reviews", 
     labels = TRUE, xlim=c(0,5), breaks=10, las=1, ylim = c(0,700000))

#Fixes notation
options(scipen=5)

#Selecting Thumbsupcount and score data
#subset => select
thumbsupdata <- subset(reviews, thumbsUpCount & score, select=c(thumbsUpCount, score))

#Histogram for Thumbs Up and Review Score
select=c(score, thumbsUpCount)
hist(thumbsupdata$score)
hist(thumbsupdata$score, main="# of Likes by Review Scores", xlab = "Review Scores", ylab = "# of reviews", ylim = c(0,60000), labels = TRUE)