library ("dplyr")

#Getting data
filename <- "cleaningdata.zip"
if (!file.exists(filename)){
	url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	download.file(url, filename)
}


if(!file.exists("UCI HAR Dataset")){
	unzip(filename)
}


#1. Merge the train and test dataset

#train data
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

#test data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

#merge data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)


#2. Extract measurements on mean and std dev

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("classLabels", "activityName"))
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("index", "featureNames"))

selectedCols <- grep("-(mean|std).*", as.character(features[,2]))
selectedColNames <- features[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)

#3. Labels the data set with descriptive variable names 

selectedColNames <- gsub("Acc", "Accelerometer", selectedColNames)
selectedColNames <- gsub("Gyro", "Gyroscope", selectedColNames)
selectedColNames <- gsub("BodyBody", "Body", selectedColNames)
selectedColNames <- gsub("Mag", "Magnitude", selectedColNames)
selectedColNames <- gsub("^t", "Time", selectedColNames)
selectedColNames <- gsub("^f", "Frequency", selectedColNames)
selectedColNames <- gsub("tBody", "TimeBody", selectedColNames)

x_data <- x_data[selectedCols]
mergedData <- cbind(subject_data, y_data, x_data)
colnames(mergedData) <- c("Subject", "Activity", selectedColNames)

#4. Descriptive activity names
mergedData$Activity <- activity_labels[mergedData$Activity, 2]


#5. Create independent tidy data set
TidyData <- mergedData %>% group_by(Subject, Activity) %>% summarise_all(list(mean))
write.table(TidyData, "TidyData.txt", row.name = FALSE, quote = FALSE)

