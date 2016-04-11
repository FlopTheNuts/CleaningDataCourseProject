### Download and unzip the source data if we don't already have it.

dataDir <- "~/R/data"

if (!file.exists(dataDir))
  dir.create(dataDir)

setwd(dataDir)

if (!file.exists("samsungData.zip"))
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "samsungData.zip", method="curl")

if (!file.exists("UCI HAR Dataset"))
  unzip("samsungData.zip")

samsungDataDir <- paste0(dataDir,"/UCI HAR Dataset")

### Load some libraries.  Not positive I'll need them... just in case.

library(dplyr)
library(tidyr)

setwd(samsungDataDir)

# read in the list of activities

activities <- tbl_df(read.table("activity_labels.txt", col.names = c("id","name")))

# read in the list of features, then find the subset of those we care about - std and mean

features = tbl_df(read.table("features.txt", col.names = c("id","name")))
subFeatures <- features[grep("mean|std", features$name),]

# read in the test data, and pare down to the columns we want

test <- tbl_df(read.table("./test/X_test.txt", col.names = features$name))
test <- select(test,subFeatures$id)

test_activities <- tbl_df(read.table("./test/y_test.txt", col.names = "activity"))

test_subjects <- tbl_df(read.table("./test/subject_test.txt", col.names = "subject"))

# combine the test data

test_data <- tbl_df(cbind(test_subjects, test_activities, test))

# read in the train data, and pare down to the columns we want

train <- tbl_df(read.table("./train/X_train.txt", col.names = features$name))
train <- select(train,subFeatures$id)

train_activities <- tbl_df(read.table("./train/y_train.txt", col.names = "activity"))

train_subjects <- tbl_df(read.table("./train/subject_train.txt", col.names = "subject"))

# combine the train data

train_data <- tbl_df(cbind(train_subjects,train_activities,train))

# combine all and make it long

samsung_data <- rbind(test_data,train_data)
samsung_data$activity <- factor(samsung_data$activity, levels = activities$id, labels = activities$name)
samsung_data <- tbl_df(melt(samsung_data, id.vars = c("subject", "activity"), variable.name = "feature"))

# calculate the means

means <- tbl_df(dcast(samsung_data, subject + activity ~ feature, mean))

# write out the results

write.table(means, "tidy_dataset.txt", row.names = FALSE, quote = FALSE)



