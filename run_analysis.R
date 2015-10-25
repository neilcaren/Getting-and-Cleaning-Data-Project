#load packages

library(dplyr)

#read in test data
testVector <- read.table("test/y_test.txt", header=FALSE)
testVectorSubjects <- read.table("test/subject_test.txt", header=FALSE)
testMatrixFeatures <- read.table("test/X_test.txt", header=FALSE)

#read in training data
trainVector <- read.table("train/y_train.txt", header=FALSE)
trainVectorSubjects <- read.table("train/subject_train.txt", header=FALSE)
trainMatrixFeatures <- read.table("train/X_train.txt", header=FALSE)

#read in features data
features <- read.table("features.txt", header = FALSE)

#get rid of factors
features$V2 <- as.character(features$V2)

#clean up variable names
features$V2 <- sub("(", "", features$V2, fixed = TRUE)
features$V2 <- sub(")", "", features$V2, fixed = TRUE)
features$V2 <- sub(",", "", features$V2, fixed = TRUE)


#read in activity table and update test and train vectors
activity_labels <- read.table("activity_labels.txt", header = FALSE)
testVector$V1 <- activity_labels$V2[testVector$V1]
trainVector$V1 <- activity_labels$V2[trainVector$V1]

#Merge Training and Test data
combinedTestData <- cbind(testVector,testVectorSubjects)
combinedTestData <- cbind(combinedTestData, testMatrixFeatures)

combinedTrainData <- cbind(trainVector,trainVectorSubjects)
combinedTrainData <- cbind(combinedTrainData, trainMatrixFeatures)

combinedData <- rbind(combinedTestData, combinedTrainData)

names(combinedData) [1:2]<- c("Activities", "Subject")
names(combinedData) [3:563] <- as.character(features$V2)

#create new dataset of just mean and STD values
logicalCalcFields <- grepl("std|mean", features$V2, ignore.case = TRUE)
logicalCalcFields <- append(logicalCalcFields, c(TRUE, TRUE), 0)
meanAndSTDDataSet <- combinedData[,logicalCalcFields]

#group data by activity and subject 
valuesBySubjectAndActivity <- group_by(meanAndSTDDataSet, Activities, Subject)
meanBySubjectAndActivity <- summarise_each(valuesBySubjectAndActivity, funs(mean))

#write new file to disk as csv file
write.csv(meanBySubjectAndActivity,"MeanBySubjectAndActivity.csv")

