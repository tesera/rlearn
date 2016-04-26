##' @title Check thet files match in two directories
##'
##' @param fileName
##' @param outDirExpected
##' @param outDir
##'
##' @return TRUE if file contents are identical
legacyMatchesExpectedOutput <- function(fileName,
                                          outDirExpected='/opt/rlearn/tests/data/expected',
                                          outDir='/opt/rlearn/tests/data/output') {
    fsep <- .Platform$file.sep

    legacyFile = paste(outDirExpected, fileName, sep=fsep)
    refactoredFile = paste(outDir, fileName, sep=fsep)

    legacyData <- read.csv(legacyFile,
                           header=TRUE,
                           stringsAsFactors=FALSE,
                           strip.white=TRUE, na.strings = c("NA",""))
    refactoredData <- read.csv(refactoredFile,
                               header=TRUE,
                               stringsAsFactors=FALSE,
                               strip.white=TRUE, na.strings = c("NA",""))

    match <- identical(legacyData, refactoredData)
    return(match)
}


##' @title Generate random data
##'
##' @param nrow number of rows
##' @param ncol number of columns
##' @param binary TRUE if data should be binary (1/0)
##'
##' @return data.frame
generateRandomDataFrame <- function(nrow, ncol, binary=TRUE) {
    if (binary){
        mat <- matrix(sample(0:1, nrow*ncol, replace=TRUE), ncol=ncol)
    } else {
        mat <- matrix(runif(nrow*ncol), ncol=ncol)
    }
    return(data.frame(mat))
}


##' @title Log a function call
##'
##' The name of the function where this function is called will be
##' logged at debug level
log_parent_function_call <- function(){
    msg <- sys.call(-1)
    logdebug(msg)
}

##' @title System path separator
##'
##' @return path separator string
getPathSep <- function() .Platform$file.sep


##' @title Filter data
##'
##' @param xy input data
##' @param removeRowValue value for which rows should be removed
##' @param removeRowColName column in which \param{removeRowValue} is checked
##'
##' @return filted dataframe
removeRowsByColValue <- function(xy, removeRowValue, removeRowColName) {
    log_parent_function_call()

    if (!(removeRowColName %in% names(xy))) {
        logwarn('Column %s is not present in data', removeRowColName)
        return(xy)
    }

    if (!(removeRowValue %in% xy[,removeRowColName])) {
        logwarn('Value %s is not in column %s', removeRowValue, removeRowColName)
        return(xy)
    }

    loginfo('Deleting rows with value %s in column %s.',
            removeRowValue, removeRowColName)

    ## TODO: use dplyr
    sel <- xy[removeRowColName] == removeRowValue
    xy <- xy[!sel,]
    removed <- sum(sel)
    remaining <- sum(!sel)

    loginfo('%d rows removed, %d rows remaining.', removed, remaining)
}

##' @title Make response variable a factor
##'
##' @param xy input data
##' @param classifiedVarName name of column for response variable
##'
##' @return vector of classification variable observations as factor
classificationVariableToFactor <- function(xy, classifiedVarName) {
    log_parent_function_call()
    newClassVector <- unlist(xy[classifiedVarName])
    newClassFactor <- factor(newClassVector)

    nObs <- length(newClassFactor)
    nClasses <- length(levels(newClassFactor))
    loginfo('The classification has %d observations of %d classes',
            nObs, nClasses)

    return(newClassFactor)
}


##' @title Subset observations to eligible features
##'
##' @param xy input data
##' @param config XVARSELV1.csv or XVARSELV.csv
##' @param xVarSelectCriteria ??? #: TODO ???
##'
##' @return input data subsetted to variables in \param{config}
selectXVariableSubset <- function(xy, config, xVarSelectCriteria) {
    log_parent_function_call()

    ## Get the number of rows or X-variables in config
    nRowsConf <- length(config[,1])
    varNameList <- config[,1]

    ## Allocate data frame
    nObs <- length(xy[,1])
    nClassOrig <- length(xy[1,])
    dummy <- rep(0,nObs)
    xDataset <- data.frame(dummy)

    ## Get the list of elgible x and y variables and put them in a vector
    for (i in 1:nRowsConf) {
        if (config[i,2] == xVarSelectCriteria) {
            xDataset[,varNameList[i]] <- xy[varNameList[i]]
        }
    }

    xDataset$dummy <- NULL
    # Create a vector of xDataset names
    xVarCount <- length(xDataset)
    loginfo(
        "%d of %d possible variables have been selected into new dataframe, xDataset",
        xVarCount, nClassOrig)

    return(xDataset)
}


convertToStringIfFactor <- function(x){
    if(!is.factor(x)){
        return(x)
    }

    return(as.character(x))
}
