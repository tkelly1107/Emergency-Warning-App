---
title: "Clean Mongo Atlas data"
output: html_notebook
#This code connects to MongoDB Atlas, cleans the data then re-inserts it back into MongoDB
#Then it prints a csv file to shared folder of check text error log
---
library(mongolite)
connection_string = 'mongodb+srv://admin:MeltemINFP2020@googlecluster.z2zrj.mongodb.net/app_proj_db'
review_collection = mongo(collection="review_collection", db="app_proj_db", url=connection_string)
review_collection$iterate()$one()
alldata <- review_collection$find('{}')

library(dplyr)
library(textshape)
library(lexicon)
library(textclean)
library(readr)
library(tidyverse)

filter_empty_row(alldata)
filter_NA(alldata)
unique(alldata)
alldata %>% distinct(reviewId, .keep_all = TRUE)

review_collection$remove('{}')
review_collection$insert(alldata)

library(textclean)
checktext_results <- check_text(alldata$content)
write.csv(checktext_results,"C:\\Users\\recon\\OneDrive - Nova Southeastern University\\Emergency Communication data\\Data\\temp files\\checktext_results.csv", row.names = TRUE)