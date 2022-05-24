appsover20words <- read.csv("C:\\Users\\recon\\OneDrive - Nova Southeastern University\\Desktop\\MostReviewedAppsOver20Words.csv")
set.seed(62704)
sampledata <- appsover20words[sample(nrow(appsover20words), 200), ]
write.csv(sampledata,"C:\\Users\\recon\\OneDrive - Nova Southeastern University\\Desktop\\Random200Sample.csv", row.names = TRUE)
