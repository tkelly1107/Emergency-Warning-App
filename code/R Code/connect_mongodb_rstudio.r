---
title: "Connecting to Mongo Atlas"
output: html_notebook
---


library(mongolite)
connection_string = 'mongodb+srv://admin:@googlecluster.z2zrj.mongodb.net/app_proj_db'
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

