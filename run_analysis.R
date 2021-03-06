## I will start with merging Test_set(x_test) and Test_label (y_test) together with cbind 
## then I will do the same with training - merging Training_set (x_train) and Training_label (y_train) together with cbind.
## then, I will combine each merge together with rbind to get a big dataset.
## note: subject/x/y_test and subject/x/y_train have the same column name v1. 
## I will rename the column name in y_test/ train to activity and subject_test/ train to subject to avoid confusion.

setwd("d:/users/wittha/Documents/RStudio/Module 3_FinanlAssignment/UCI HAR Dataset/test/")
Test_subject <- read.table("subject_test.txt", fill=FALSE, strip.white=TRUE)  ## Read Subject_test
Test_set <- read.table("X_test.txt", fill=FALSE, strip.white=TRUE)  ## Read x_test
Test_label <- read.table("y_test.txt", fill=FALSE, strip.white=TRUE)  ## Read y_test
colnames(Test_label)[1] <- "activity"  ## Rename column name to activity label which is what the column is showing.
colnames(Test_subject)[1] <- "subject"  ## Rename column name to activity label which is what the column is showing.
## below is to combine x_test and y_test together. I merge the data and keep it in test_data
Test_dataset<-Test_subject
Test_dataset<-cbind(Test_dataset, Test_label)
Test_dataset<-cbind(Test_dataset, Test_set)

## do the same thing as test_data
setwd("d:/users/wittha/Documents/RStudio/Module 3_FinanlAssignment/UCI HAR Dataset/train/")
Training_subject <- read.table("subject_train.txt", fill=FALSE, strip.white=TRUE)  ## Read Subject_training
Training_set <- read.table("X_train.txt", fill=FALSE, strip.white=TRUE)  ## Read x_train
Training_label <- read.table("y_train.txt", fill=FALSE, strip.white=TRUE)  ## Read y_train
colnames(Training_label)[1] <- "activity"  ## Rename column name to activity label which is what the column is showing.
colnames(Training_subject)[1] <- "subject"  ## Rename column name to activity label which is what the column is showing.
## below is to combine x_test and y_test together. I merge the data and keep it in train_data
Training_dataset<-Training_subject
Training_dataset<-cbind(Training_dataset, Training_label)
Training_dataset<-cbind(Training_dataset, Training_set)

## 1. Merges the training and the test sets to create one data set.
## Now I have test and train dataset with the same number of columns and all columns are in the same order.
## I then can merge Test and Training dataset. I will do it with rbind and I will call it Combined_dataset
Combined_dataset<-Test_dataset
Combined_dataset<-rbind(Combined_dataset, Training_dataset)


## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## I will read features that have mean and standard deviation (std) in the name from feature.txt
setwd("d:/users/wittha/Documents/RStudio/Module 3_FinanlAssignment/UCI HAR Dataset/")
activity_label <- read.table("activity_labels.txt", fill=FALSE, strip.white=TRUE)  ## Read acitivity_label
feature <- read.table("features.txt", fill=FALSE, strip.white=TRUE)  ## Read feature

## Read features that have mean and standard deviation (std) in its name
## note: since I'm not sure if all spelling is lower case, I will use [] format to check both upper/lower cases
SelectedMeasure <- grep("([Mm]ean|[Ss]td)",feature$V2)  ## get index of features that are mean and std dev
FeatureName <- grep("([Mm]ean|[Ss]td)",feature$V2, value=TRUE)  ## read the values of features that are mean and std dev
## now I will subset the combined dataset to only the columns corresponding to selectedMeasure
## looking at my combined dataset, the indexed columns are shifted by 2 columns because I have subject and activity at the front.
## I will have to add 2 to selectedMeasure so v1 in feature is v1 in combined dataset (column 3)
## also include subject and activity in the subset dataset
SelectedMeasure <- SelectedMeasure + 2
SelectedMeasure <- c(1,2,SelectedMeasure)
# now I will subset data by including only columns in SelectedMeasure.
Subset_dataset <- Combined_dataset[, SelectedMeasure]


## 3. Uses descriptive activity names to name the activities in the data set
## replace activity name (1-6) in the activity label to descriptive activity names
Subset_dataset[["activity"]] <- activity_label[match(Subset_dataset[["activity"]],activity_label[["V1"]] ) , "V2"]


## 4. Appropriately labels the data set with descriptive variable names.
## I will take the featurename which I extracted earlier to name the columns
names(Subset_dataset)[3:88] <- c(FeatureName)


## 5. creates a second, independent tidy data set with the average of each variable for each activity and each subject.
## I use dplyr and pipeline operaions to group data by subject and activity and then find mean across all columns.
library(dplyr)
tidy_data <- Subset_dataset %>%
  group_by(subject, activity) %>%
  summarise_at(vars(-(subject:activity)), funs(mean(., na.rm=TRUE)))

write.table(tidy_data,"tidy_data.txt",sep="\t",row.names=FALSE)

## I will generate codebook of this tidydata by this function. I will edit texts once the file is generated.
library(dataMaid)
makeCodebook(tidy_data)
