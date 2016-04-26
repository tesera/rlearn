library(subselect)
library(tidyr)
library(dplyr)

##' @title Select important variables from observations
##'
##' @param xy
##' @param config
##' @param yName
##' @param removeRowValue
##' @param removeRowColName
##' @param xVarSelectCriteria
##' @param minNumVar
##' @param maxNumVar
##' @param nSolutions
##' @param attachOutput TRUE to attach to global environment,
##' mainly for python clients
##'
##' @return dataframe of variables and models as selected by ldaHmat and improve
vs.selectVars <- function(xy, config,
                          yName='CLPRDP',
                          removeRowValue=-1,
                          removeRowColName='SORTGRP',
                          xVarSelectCriteria='X',
                          improveCriteriaVarName='xi2',
                          minNumVar=1, maxNumVar=10, nSolutions=10) {
    log_parent_function_call()

    xy[] <- lapply(xy, convertToStringIfFactor)
    config[] <- lapply(config, convertToStringIfFactor)
    xy <- removeRowsByColValue(xy, removeRowValue, removeRowColName)
    y <- classificationVariableToFactor(xy, classifiedVarName=yName)
    x <- selectXVariableSubset(xy, config, xVarSelectCriteria)
    x <- vs.removeDegenerateColumns(x)
    ldaResult <- vs.runLDA(y, x)
    lviVariableSets <- vs.improveVariableSelection(ldaResult,
                                                   minNumVar, maxNumVar,
                                                   nSolutions,
                                                   improveCriteriaVarName)
    variableSetsSummary <- vs.flattenVariableNameSubsets(lviVariableSets,
                                                         xNames=names(x))

    df <- as.data.frame(variableSetsSummary)
    return(df)
}

##' @title Calculate variable pairwise correlations
##'
##' @param xy observations
##' @param removeRowValue
##' @param removeRowColName
##' @param attachOutput TRUE to attach to global environment,
##' mainly for python clients
##'
##' @return data.frame of pairwise variable correlations
vs.getVarCorrelations <- function(xy, uniqueVars,
                                  removeRowValue=-1,
                                  removeRowColName='SORTGRP') {

    xy[] <- lapply(xy, convertToStringIfFactor)
    uniqueVars[] <- lapply(uniqueVars, convertToStringIfFactor)
    xy <- removeRowsByColValue(xy, removeRowValue, removeRowColName)
    xUniqueVarsSubset <- vs.getUniqueVarsSubset(uniqueVars, xy)
    xUniqueCor <- vs.calcCorrelationMatrix(xUniqueVarsSubset)
    xUniqueCorPretty <- vs.flattenPairwiseCorrelationMatrix(xUniqueCor)

    df <- as.data.frame(xUniqueCorPretty)
    return(df)
}


##' @title Subset data to columns with information
##'
##' @param x dataframe
##'
##' @return \param{x} dataframe with degenerate variables removed
vs.removeDegenerateColumns <- function(x) {
    log_parent_function_call()

    sdNotZero <- function(x) sd(x) != 0
    origNumVars <- length(x)

    x <- Filter(sdNotZero, x)
    filteredNumVars <- length(x)

    loginfo("%d degenerate variables have been removed from x, %d remain",
            origNumVars-filteredNumVars, filteredNumVars)

    return(x)
}


##' @title Run LDA
##'
##' https://cran.r-project.org/web/packages/subselect/subselect.pdf
##'
##' @param y response variable as factor
##' @param x explanatory variables as data frame
##'
##' @return ???
## TODO: rename?
vs.runLDA <- function(y, x) {
    log_parent_function_call()
    lviHmat <- ldaHmat(x,y)
    return(lviHmat)
}


##' @title Improve routine
##'
##' Improve model selection under constraints
##'
##' @param lviHmat ouput from ldaHmat
##' @param minNumVar minimum number of variables desired for model
##' @param maxNumVar maximum number of variables desired for model
##' @param nSolutions number of solutions to find for model
##'
##' @return ???
vs.improveVariableSelection <- function(lviHmat, minNumVar, maxNumVar,
                                        nSolutions, criteriaVarName) {
    log_parent_function_call()

    lviVariableSets <- improve(lviHmat$mat,
                               kmin = minNumVar,
                               kmax = maxNumVar,
                               nsol=nSolutions,
                               H=lviHmat$H,
                               r=lviHmat$r,
                               crit=criteriaVarName,
                               force=TRUE,
                               setseed=TRUE)
    return(lviVariableSets)
}


##' @title Extract variable name subsets from variable selection process
##'
##' Create a new dataframe with all of the variable names
##' Inupt array is a 3 dimensional array Where rows are lda solutions from 1 to m number of
##' variables. Columns are variable names from 1 ("Var.1") to x ("Var.x")
##'
##' @param lviVariableSets result of call to improve()
##' @param xNames names of X variables used in improve()
##'
##' @return dataframe summarizing models
vs.flattenVariableNameSubsets <- function(lviVariableSets, xNames) {
    log_parent_function_call()

    arrayDim <- dim(lviVariableSets$subsets)
    maxSolutions <- arrayDim[1]
    maxVariables <- arrayDim[2]
    maxSolutionTypes <- arrayDim[3]

    SOLTYPE <- c()
    SOLNUM <- c()
    VARNAME <- c()
    VARNUM <- c()
    KVAR <- c()
    MODELID <- c()
    UID <- c()
    mindex <- 0
    uid <- 0

    ## TODO: vectors are copied on every nested iteration.
    ##       probably an optimization here
    for (k in 1:maxSolutionTypes){
        for (i in 1: maxSolutions) {
            mindex <- mindex + 1
            for (j in 1:maxVariables){
                if (lviVariableSets$subsets[i,j,k] > 0) {
                    uid <- uid + 1
                    UID <- c(UID, uid)
                    MODELID <- c(MODELID, mindex)
                    SOLTYPE <- c(SOLTYPE,k)
                    SOLNUM <- c(SOLNUM,i)
                    VARNUM <- c(VARNUM,lviVariableSets$subsets[i,j,k])
                    VARNAME <- c(VARNAME,xNames[lviVariableSets$subsets[i,j,k]])
                    KVAR <- c(KVAR,j)
                }
            }
        }
    }
    solutionSummary <- data.frame(UID,MODELID,SOLTYPE,SOLNUM,KVAR,VARNUM,VARNAME,
                                  stringsAsFactors=FALSE)

    return(solutionSummary)
}


## TODO: combine with vs.selectXvariablesubset
## TODO: are unique vars actually orthogonal/independent vars? all
##       the vars are uniqely named, after all. where does UNIQVAR.csv
##       originate?
##' @title Subset observations to
##'
##' Unique vars defined in UNIQVAR.csv
##'
##' @param uniqueVars 1 row data.frame with values corresponding to names of
##' unique variables
##' @param xy observations with columns that must all be present
##' in \param{uniqueVars}
##'
##' @return dataframe of xy subsetter to vars in uniqueVars
vs.getUniqueVarsSubset <- function(uniqueVars, xy) {
    log_parent_function_call()

    if(length(uniqueVars[,1]) != 1) logerror('uniqueVars should have only one row!')

    nCols <- length(uniqueVars)
    nObs <- length(xy[,1])
    dummy <- rep(0,nObs)
    xDataset <- data.frame(dummy)

    for (j in 1:nCols) {
        xDataset[,uniqueVars[1,j]] <- xy[,uniqueVars[1,j]]
    }
    xDataset$dummy <- NULL

    return(xDataset)
}


##' @title Correlation Matrix
##'
##' @param x data.frame of observations
##'
##' @return pairwise correlation matrix, dimnames correspond to x variables
vs.calcCorrelationMatrix <- function(x) {
    log_parent_function_call()
    corMat <- cor(x)
    return(corMat)
}

##' @title Pretty correlation matrix as data frame
##'
##' @param corMat pairwise correlation matrix
##'
##' @return 3 column data.frame with pairwise variable correlations
vs.flattenPairwiseCorrelationMatrix <- function(corMat) {
    log_parent_function_call()

    d <- data.frame(corMat)
    d$VARNAME1 <- rownames(d)
    dPretty <- tidyr::gather(d, VARNAME2, CORCOEF, -VARNAME1)
    # TODO: remove once legacy match confirmed
    dPretty <- dplyr::arrange(dPretty, VARNAME1, VARNAME2)
    return(dPretty)
}
