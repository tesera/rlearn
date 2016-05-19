library('jsonlite')

awslogs.createLogGroup <- function(logGroupName,
                                    region = "us-east-1",
                                    verbose = TRUE,
                                    debug = TRUE) {
    aws.cmd <- paste("aws logs create-log-group",
                    paste("--log-group-name ", logGroupName),
                    paste("--region ", region))
    system(aws.cmd, intern = FALSE, ignore.stdout = TRUE, ignore.stderr = verbose,
           wait=TRUE)
}

awslogs.createLogStream <- function(logGroupName, logStreamName, region = "us-east-1", verbose = TRUE, debug = TRUE) {
    aws.cmd <- paste("aws logs create-log-stream",
                    paste("--log-group-name ", logGroupName),
                    paste("--log-stream-name ", logStreamName),
                    paste("--region ", region))
    system(aws.cmd, intern = FALSE, ignore.stdout = TRUE, ignore.stderr = verbose,
           wait=TRUE)
}

awslogs.putLogEvents <- function(logGroupName, logStreamName, logEvents, sequenceToken, region = "us-east-1", verbose = TRUE, debug = TRUE) {
    aws.cmd <- paste("aws logs put-log-events",
                    paste("--log-group-name ", logGroupName),
                    paste("--log-stream-name ", logStreamName),
                    paste("--log-events ", logEvents),
                    ifelse(sequenceToken != 'NA', paste("--sequence-token ", sequenceToken), ""),
                    paste("--region ", region))
    res <- system(aws.cmd, intern = TRUE, ignore.stdout = FALSE, ignore.stderr = TRUE,
                  wait=TRUE)
    fromJSON(res)
}

awslogs.getLogEvents <- function(logGroupName, logStreamName, region = "us-east-1", verbose = TRUE, debug = TRUE) {
    aws.cmd <- paste("aws logs get-log-events",
                    paste("--log-group-name ", logGroupName),
                    paste("--log-stream-name ", logStreamName),
                    paste("--region ", region))
    res <- system(aws.cmd, intern = TRUE, ignore.stdout = FALSE, ignore.stderr = TRUE)
    fromJSON(res)
}

awslogs.deleteLogGroup <- function(logGroupName, logStreamName, region = "us-east-1", verbose = TRUE, debug = TRUE) {
    aws.cmd <- paste("aws logs delete-log-group",
                    paste("--log-group-name ", logGroupName),
                    paste("--region ", region))
    system(aws.cmd, intern = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE,
           wait=TRUE)
}
