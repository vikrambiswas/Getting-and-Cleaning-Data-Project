#Code should be able to do the following 5 things: 
# 1) Merges the training and the test sets to create one data set.
# 2) Extracts only the measurements on the mean and standard deviation for each measurement.
# 3) Uses descriptive activity names to name the activities in the data set
# 4) Appropriately labels the data set with descriptive variable names.
# 5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Loading Packages and Committing Data
> packages <- c("data.table", "reshape2")
> sapply(packages, require, character.only=TRUE, quietly=TRUE)
#data.table   reshape2 
#     TRUE       TRUE 
> path <- getwd()
> url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
> download.file(url, file.path(path, "dataFiles.zip"))
#trying URL 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
#Content type 'application/zip' length 62556944 bytes (59.7 MB)
#downloaded 59.7 MB

> unzip(zipfile = "dataFiles.zip")

#Loading Activity Labels and Features
> activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
+ , col.names = c("classLabels", "activityName"))
> features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
+ , col.names = c("index", "featureNames"))
> featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
> measurements <- features[featuresWanted, featureNames]
> measurements <- gsub('[()]', '', measurements)
> train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
> data.table::setnames(train, colnames(train), measurements)

#Loading Train Data Sets
> trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
+ , col.names = c("Activity"))
> trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
+ , col.names = c("SubjectNum"))
> train <- cbind(trainSubjects, trainActivities, train)

#Loading Test Data Sets
> test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
> data.table::setnames(test, colnames(test), measurements)
> testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
+ , col.names = c("Activity"))
> testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
+ , col.names = c("SubjectNum"))
> test <- cbind(testSubjects, testActivities, test)

#Merging Data Sets
> combined <- rbind(train, test)

#Converting classLabels to activityName
> combined[["Activity"]] <- factor(combined[, Activity]
+ , levels = activityLabels[["classLabels"]]
+ , labels = activityLabels[["activityName"]])
> combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
> combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
> combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)
> data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
