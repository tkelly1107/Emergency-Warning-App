---
title: "Extract app id from google url and clean up"
output: r
---

read.csv("C:\\Users\\recon\\OneDrive - Nova Southeastern University\\Emergency Communication data\\Emergency Com Data.csv", row.names = TRUE)
df1 <- Emergency_Com_Data
df1$appID = substr(df1$`Link to Google Play Store`,47,100)
df2 <- gsub("&hl=en_US&gl=US", "", df1$appID)
df2 <- gsub("&hl=en_", "", df2)
df2 <- gsub("&hl=en_US&", "", df2)
df2 <- gsub("&showAll", "", df2)
df2 <- gsub("&hl=gsw", "", df2)
df2 <- gsub("&hl=de", "", df2)
df2 <- gsub("US&", "", df2)
df2 <- gsub("&", "", df2)
Emergency_Com_Data$app_id <- df2
write.csv(Emergency_Com_Data,"C:\\Users\\recon\\OneDrive - Nova Southeastern University\\Emergency Communication data\\Emergency Com Data__appid.csv", row.names = TRUE)