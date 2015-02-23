library("data.table")
library("dplyr")

#'
#' Helper function for downloading data set from the web and adjusting folder 
#' name.
#'
har.usd.data.download <- function(){
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                      destfile = "getdata_projectfiles_UCI_HAR_Dataset.zip",
                      method = "curl")      
        unzip("getdata_projectfiles_UCI_HAR_Dataset.zip")
        file.rename("UCI HAR Dataset", "UCI_HAR_Dataset")
}
# 
# 

#'
#' This function reads all column names form features.txt file
#'
#' @param path The path to the features.txt file
#'
#' @return The features vector
#'
get.data.feature <- function(path) {
        if (!exists("header")){
                h <- read.table(paste(path, "features.txt", sep= "/"), 
                              stringsAsFactors = FALSE)
                headers <<- unclass(h[,2])
        }
        return(headers)
}
     
#'
#' This function reads all the activities from the activity_label.txt file.
#' 
#' @param path The path to the activity_label.txt file 
#' 
#' @retun The activities \code{data.table}
#'
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

#'
#' This function reads the data from, e.g training or testing, and
#' combine data related to column names, activities and subjects.
#' 
#' @param root.path The root path for the data
#' @param set The set name that is also related to data subpath.
#'
#' @return The full binded testing and training \code{data.table} 
#' with column names, named categories and related observation subjects.
#'
get.data.table <- function(root.path, set){
        
        path <- paste(root.path, set, sep = "/")
        
        table <- read.table(paste(path, "/X_", set, ".txt", sep =""))
        table <- as.data.table(table)
        table.header <- get.data.feature(root.path)
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

#'
#' This function summarizes the data sets from the  "Human Activity Recognition 
#' Using Smartphones Dataset" (HCA USD) project into a single data set.
#' It  reads all training and testing data sets, and combines the information
#' related to subjects and categories for each one of those data sets. 
#' It merges both training and test data sets in a single set and filters all 
#' the columns related to measurements of mean and standard deviation.
#' It also groups by subject and activity  calculating the average of each 
#' variable for each activity and each subject groupped.
#' 
#' @return The summarized HCA USD data set
#' 
har.usd.summarize <- function(){
        training.dataset <- get.data.table("UCI_HAR_Dataset", "train")
        testing.dataset  <- get.data.table("UCI_HAR_Dataset", "test")
        
        filter.regex <- "subject|activity|std\\(\\)|mean\\(\\)"
        training.dataset.filtered <- select(training.dataset, matches(filter.regex))
        testing.dataset.filtered  <- select(testing.dataset, matches(filter.regex))
        
        dataset.filtered <- merge(training.dataset.filtered, 
                                  testing.dataset.filtered, 
                                  by = colnames(training.dataset.filtered), 
                                  all = TRUE)
        dataset.f.grouped <- group_by(dataset.filtered, activity, subject)
        dataset.f.g.summarised <- summarise_each(dataset.f.grouped, funs(mean))
        write.table(dataset.f.g.summarised, file = "dataset.csv", row.name=FALSE)
        return (dataset.f.g.summarised)
}


