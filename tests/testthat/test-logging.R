context("logger")

fsep <- .Platform$file.sep
# make a clean log group
awslogs.deleteLogGroup('rlearn-test')

test_that("logger writes to file", {
    log_file_path = paste('/tmp', 'logger_writes_to_file', sep=fsep)
    logger.init(log.toFile=TRUE, log.toConsole=FALSE, log.toAwslogs=FALSE,
                log.file=log_file_path, log.level='FINEST')

    loginfo('James Brown is the king of funk!')

    result <- readLines(log_file_path)
    log_regex <- '[0-9]{4}(-[0-9]{2}){2} ([0-9]{2}:?){3} INFO::James Brown is the king of funk!'
    expect_match(result, log_regex)

    logReset()
    file.remove(log_file_path)
})

test_that("log_parent_function_call works", {
    log_file_path = paste('/tmp', 'log_parent_function_call_works', sep=fsep)
    logger.init(log.toFile=TRUE, log.toConsole=FALSE, log.toAwslogs=FALSE,
                log.file=log_file_path, log.level='FINEST')

    logged_function <- function() log_parent_function_call()
    logged_function()

    result <- readLines(log_file_path)
    log_regex <- '[0-9]{4}(-[0-9]{2}){2} ([0-9]{2}:?){3} DEBUG::logged_function'
    expect_match(result, log_regex)

    logReset()
    file.remove(log_file_path)
})

test_that("logger writes to aws logs", {
    stream <- UUIDgenerate()
    logger.init(log.toFile=FALSE, log.toConsole=FALSE, log.toAwslogs=TRUE,
                awslogs.logGroup='rlearn-test', log.level='FINEST',
                awslogs.logStream=stream)

    loginfo('I even log to AWS!')
    result <- awslogs.getLogEvents('rlearn-test', stream)
    log_regex <- '[0-9]{4}(-[0-9]{2}){2} ([0-9]{2}:?){3} INFO::I even log to AWS!'
    expect_match(result$events$message, log_regex)

    logReset()
})

test_that("logger writes to aws logs twice", {
    stream <- UUIDgenerate()
    logger.init(log.toFile=FALSE, log.toConsole=FALSE, log.toAwslogs=TRUE,
                awslogs.logGroup='rlearn-test', log.level='FINEST',
                awslogs.logStream=stream)

    logdebug('I even log to AWS!')
    logdebug('I even log to AWS 2!')

    result <- awslogs.getLogEvents('rlearn-test', stream)
    log_regex <- '[0-9]{4}(-[0-9]{2}){2} ([0-9]{2}:?){3} DEBUG::I even log to AWS 2!'
    expect_match(result$events$message[2], log_regex)

    logReset()
})

test_that("logger can write list-like message to cloudwatch", {
    stream <- UUIDgenerate()
    logger.init(log.toFile=FALSE, log.toConsole=FALSE, log.toAwslogs=TRUE,
                awslogs.logGroup='rlearn-test', log.level='FINEST',
                awslogs.logStream=stream)

    logdebug('1,2,3,4,5,6')

    result <- awslogs.getLogEvents('rlearn-test', stream)
    log_regex <- '[0-9]{4}(-[0-9]{2}){2} ([0-9]{2}:?){3} DEBUG::1 2 3 4 5 6'
    expect_match(result$events$message[1], log_regex)

    logReset()
})

test_that("cloudwatch handler truncates long log messages", {
    stream <- UUIDgenerate()
    logger.init(log.toFile=FALSE, log.toConsole=FALSE, log.toAwslogs=TRUE,
                awslogs.logGroup='rlearn-test', log.level='FINEST',
                awslogs.logStream=stream)

    logdebug(LETTERS)

    result <- awslogs.getLogEvents('rlearn-test', stream)
    log_regex <-
        '[0-9]{4}(-[0-9]{2}){2} ([0-9]{2}:?){3} DEBUG::A\\.\\.\\. \\(truncated\\)'
    expect_match(result$events$message[1], log_regex)

    logReset()
})

test_that("lda is logged at info level", {
    stream <- UUIDgenerate()
    logger.init(log.toFile=FALSE, log.toConsole=FALSE, log.toAwslogs=TRUE,
                awslogs.logGroup='rlearn-test', log.level='INFO',
                awslogs.logStream=stream)


    lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
    xVarSelectFileName <- system.file("extdata", "XVARSELV.csv", package = "rlearn")
    outDir <- '/opt/rlearn/tests/data/output'

    xy <- read.csv(lviFileName, header=T, row.names=1)
    config <- read.csv(xVarSelectFileName,
                       header=T, row.names=1,
                       strip.white=TRUE,
                       na.strings = c("NA",""))

    ldaResult <- lda(xy,
                     config,
                     removeRowColName='SORTGRP',
                     removeRowValue=-1,
                     classVariableName='VAR47',
                     priorDistributionIsSample=TRUE)

    result <- awslogs.getLogEvents('rlearn-test', stream)

    logReset()
})

test_that("lda is logged at debug level", {
    stream <- UUIDgenerate()
    logger.init(log.toFile=FALSE, log.toConsole=FALSE, log.toAwslogs=TRUE,
                awslogs.logGroup='rlearn-test', log.level='DEBUG',
                awslogs.logStream=stream)


    lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
    xVarSelectFileName <- system.file("extdata", "XVARSELV.csv", package = "rlearn")
    outDir <- '/opt/rlearn/tests/data/output'

    xy <- read.csv(lviFileName, header=T, row.names=1)
    config <- read.csv(xVarSelectFileName,
                       header=T, row.names=1,
                       strip.white=TRUE,
                       na.strings = c("NA",""))

    ldaResult <- lda(xy,
                     config,
                     removeRowColName='SORTGRP',
                     removeRowValue=-1,
                     classVariableName='VAR47',
                     priorDistributionIsSample=TRUE)

    result <- awslogs.getLogEvents('rlearn-test', stream)

    logReset()
})

test_that("cloudwatch varsel logging works at debug level", {
    stream <- UUIDgenerate()
    logger.init(log.toFile=FALSE, log.toConsole=FALSE, log.toAwslogs=TRUE,
                awslogs.logGroup='rlearn-test', log.level='DEBUG',
                awslogs.logStream=stream)


    lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
    uniqueVarFilePath <- system.file("extdata", "UNIQUEVAR.csv", package = "rlearn")
    outDir <- '/opt/rlearn/tests/data/output'
    outFileName <- 'UCORCOEF.csv'
    outFilePath = paste(outDir, outFileName, sep=.Platform$file.sep)

    xy <- read.csv(lviFileName, header=T, row.names=1)
    uniquevar <- read.csv(uniqueVarFilePath, header=T, row.names=1,
                          #stringsAsFactors=FALSE,
                          strip.white=TRUE,
                          na.strings = c("NA",""))

    ucorcoef <- vs.getVarCorrelations(xy, uniquevar,
                                      removeRowValue=-1,
                                      removeRowColName='SORTGRP')

    result <- awslogs.getLogEvents('rlearn-test', stream)

    logReset()
})


# reset logger so additional tests use defaults
logger.init()
