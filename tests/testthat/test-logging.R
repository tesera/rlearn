context("logger")

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
    logger.init(log.toFile=FALSE, log.toConsole=FALSE, log.toAwslogs=TRUE,
                awslogs.logGroup = 'rlearn-test', awslogs.logStream='my-test-stream', log.level='FINEST')

    loginfo('I even log to AWS!')

    result <- awslogs.getLogEvents('rlearn-test', 'my-test-stream')
    log_regex <- '[0-9]{4}(-[0-9]{2}){2} ([0-9]{2}:?){3} INFO::I even log to AWS!'
    expect_match(result$events['message'], log_regex)

    logReset()
    awslogs.deleteLogGroup('rlearn-test')
})

test_that("logger writes to aws logs twice", {
    logger.init(log.toFile=FALSE, log.toConsole=FALSE, log.toAwslogs=TRUE,
                awslogs.logGroup = 'rlearn-test', awslogs.logStream='my-test-stream', log.level='FINEST')

    loginfo('I even log to AWS!')
    loginfo('I even log to AWS 2!')

    result <- awslogs.getLogEvents('rlearn-test', 'my-test-stream')
    log_regex <- '[0-9]{4}(-[0-9]{2}){2} ([0-9]{2}:?){3} INFO::I even log to AWS 2!'
    expect_match(result$events[2,'message'], log_regex)

    logReset()
    awslogs.deleteLogGroup('rlearn-test')
})
