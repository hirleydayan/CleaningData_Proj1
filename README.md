# run_analysis.R

run_analysis.R is a tool for reading and combining data from the 
"Human Activity Recognition Using Smartphones Dataset" project at
(http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones ).

A direct link for the data is follows:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The script reads all training and testing data sets, and combines the information
related to subjects and categories for each one of those data sets. 

It merges both data sets in a single set and filters all the columns related to
measurements of mean and standard deviation.

The script also groups by subject and activity  calculating the average of each 
variable for each activity and each subject groupped.

For downloading the data the followng function should be used:

```{r}
har.usd.data.download()

```

That function will download the data, unzip it and rename the folder to
"UCI_HAR_Dataset".

For processing the data and summarizing it on a single data set the following 
function should be called:

```{r}
har.usd.summarize()

```