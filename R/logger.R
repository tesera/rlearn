library('logging')
library('uuid')

## TODO: move to utils
##' @title Get environment variable
##'
##' @param envvar name of environment variable (case sensitive)
##' @param default if \param{envvar} not defined in environment
##'
##' @return string, value of environment variable or default
get_envvar_or_default <- function(envvar, default=""){
    envvar <- Sys.getenv(envvar)
    envvar <- ifelse(envvar != "", envvar, default)
    return(envvar)
}

log_level <- get_envvar_or_default('LOGGING_LEVEL', 'INFO')
aws_logs <- get_envvar_or_default('AWS_LOGS', 'false')
aws_logs_bool <- tolower(aws_logs) == 'true'
aws_region <- get_envvar_or_default('AWS_REGION', 'us-east-1')
aws_logs_group <- get_envvar_or_default('AWS_LOGS_GROUP', 'rlearn')
aws_logs_stream <- get_envvar_or_default('AWS_LOGS_STREAM', UUIDgenerate())

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

logger.init <- function(log.level = 'INFO',
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
