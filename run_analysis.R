# download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
#              destfile = "getdata_projectfiles_UCI_HAR_Dataset.zip",
#              method = "curl")
# unzip("getdata_projectfiles_UCI_HAR_Dataset.zip")

library("data.table")
library("dplyr")

get.data.header <- function(path) {
        if (!exists("header")){
                h <- read.table(paste(path, "features.txt", sep= "/"), 
                              stringsAsFactors = FALSE)
                headers <<- unclass(h[,2])
        }
        return(headers)
}
              
get.activities <- function(path) {
        
        if (!exists("header")){
                activities <- read.table(
                        paste(path, "activity_labels.txt", sep= "/"), 
                        stringsAsFactors = FALSE)
                activities <- as.data.table(activities)
                setnames(activities, c("number", "activity"))
                activities <<- mutate(activities, number = as.character(number))
        }
        
        return(activities)
}

get.data.table <- function(root.path, set){
        
        path <- paste(root.path, set, sep = "/")
        
        table <- read.table(paste(path, "/X_", set, ".txt", sep =""))
        table <- as.data.table(table)
        table.header <- get.data.header(root.path)
        setnames(table, table.header)
        
        ## Training subject column
        subjects <- read.table(paste(path, "/subject_", set, ".txt", sep = ""))
        setnames(subjects, "subject")
        
        ## Training activity column
        activities <- read.table(paste(path, "/y_", set, ".txt", sep = ""))
        setnames(activities, "activity")
        
        ## Bind columns
        table.full <- cbind(subjects, activities, table)
        table.full <- as.data.table(table.full)
        table.full <- mutate(table.full, subject = as.factor(subject), 
                             activity = as.character(activity))
        
        activities.table <- get.activities(root.path)
        
        for (act.number in activities.table$number){
                table.full$activity[table.full$activity %in% act.number] <- 
                        activities.table$activity[activities.table$number %in% 
                                                          act.number]
        }        
        
        return(table.full)
}

# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for 
#    each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
training.dataset <- get.data.table("UCI_HAR_Dataset", "train")
testing.dataset  <- get.data.table("UCI_HAR_Dataset", "test")

filter.regex <- "subject|activity|std\\(\\)|mean\\(\\)"
training.dataset.filtered <- select(training.dataset, matches(filter.regex))
testing.dataset.filtered  <- select(testing.dataset, matches(filter.regex))

dataset.filtered <- merge(training.dataset.filtered, 
                          testing.dataset.filtered, 
                          by = colnames(training.dataset.filtered), 
                          all = TRUE)

# 5. From the data set in step 4, creates a second, independent tidy data 
#    set with the average of each variable for each activity and each subject. 
dataset.f.grouped <- group_by(dataset.filtered, activity, subject)
dataset.f.g.summarised <- summarise_each(dataset.f.grouped, funs(mean))
write.table(dataset.f.g.summarised, file = "dataset.csv", row.name=FALSE)


