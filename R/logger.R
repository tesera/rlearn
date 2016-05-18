library('logging')
library('uuid')


log_level <- Sys.getenv('LOGGING_LEVEL', 'INFO')
aws_logs <- Sys.getenv('AWS_LOGS', 'false')
aws_logs_bool <- tolower(aws_logs) == 'true'
aws_region <- Sys.getenv('AWS_REGION', 'us-east-1')
aws_logs_group <- Sys.getenv('AWS_LOGS_GROUP', 'rlearn')
aws_logs_stream <- Sys.getenv('AWS_LOGS_STREAM', UUIDgenerate())

cloudwatch <- function(msg, handler, ...) {
    if(length(list(...)) && 'dry' %in% names(list(...)))
        return(TRUE)
    awslogs.createLogGroup(with(handler, logGroupName), with(handler, region))
    awslogs.createLogStream(with(handler, logGroupName),
                            with(handler, logStreamName),
                            with(handler, region))
    epoch = as.integer(as.POSIXct( Sys.time() ))*1000
    logEvents = sprintf('"timestamp=%s,message=%s"', epoch, msg)
    res <- awslogs.putLogEvents(with(handler, logGroupName),
                                with(handler, logStreamName),
                                logEvents,
                                with(handler, nextSequenceToken),
                                region = with(handler, region))
    handler$nextSequenceToken <- res$nextSequenceToken
}

logger.init <- function(log.level = log_level,
                        log.toConsole = FALSE,
                        log.toFile = TRUE,
                        log.file = 'rlearn.log',
                        log.toAwslogs = aws_logs_bool,
                        awslogs.region = aws_region,
                        awslogs.logGroup = aws_logs_group,
                        awslogs.logStream = aws_logs_stream) {
    logReset()

    if (log.toConsole) basicConfig(level = log.level)

    if (log.toFile) addHandler(writeToFile, file = log.file, level = log.level)

    if (log.toAwslogs) addHandler(cloudwatch,
                                  region = awslogs.region,
                                  logGroupName = awslogs.logGroup,
                                  logStreamName = awslogs.logStream,
                                  nextSequenceToken = 'NA',
                                  level = log.level)
    setLevel(log.level)
}
