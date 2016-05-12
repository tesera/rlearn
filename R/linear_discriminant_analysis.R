library(MASS)
library(dplyr)

##' @title Linear Discriminant Analysis Wrapper
##'
##' @param xy data frame of observations
##' @param config data frame containing model definitions
##' @param excludeRowVarName
##' @param excludeRowValue
##' @param priorDistributionIsSample TRUE to use sample frequency to calculate priors
##' @param dataDir directory path to write intermediate data files
##' @param writeIntermediateDataFiles TRUE to write intermediate data to disk
##' @param attachOutput TRUE to attach to global environment,
##' @param modelsFirstVarColumnIndex index of the first column which corresponds
##' to a model variable
##' mainly for python clients
##'
##' @return
lda <- function(xy, config,
                removeRowColName, removeRowValue,
                classVariableName, priorDistributionIsSample,
                dataDir, writeIntermediateDataFiles=FALSE, attachOutput=FALSE,
                modelsFirstVarColumnIndex=4) {
    log_parent_function_call()

    xy[] <- lapply(xy, convertToStringIfFactor)
    config[] <- lapply(config, convertToStringIfFactor)
    xy <- removeRowsByColValue(xy, removeRowValue, removeRowColName)
    y <- classificationVariableToFactor(xy, classifiedVarName=classVariableName)
    if (length(levels(y))==1) {
        msg <- sprintf('Response variable, %s, is degenerate',
                       classVariableName)
        logerror(msg)
        stop(msg)
    }

    classPriorProbs <- lda.calcPriorClassProbDist(y, priorDistributionIsSample)
    ctabPost <- lda.runLooLdaForModels(y, xy, config, classPriorProbs,
                                       modelsFirstVarCol=modelsFirstVarColumnIndex)
    ldaResult <- lda.runLdaAllDataForModels(y, xy, config, classPriorProbs,
                                            modelsFirstVarCol=modelsFirstVarColumnIndex)

    retList <- list(
        lda.prior=classPriorProbs,
        lda.posterior=ctabPost$POSTERIOR,
        lda.ctabulation=ctabPost$CTABULATION,
        lda.ctaball=ldaResult$CTABALL,
        lda.varmeans=ldaResult$VARMEANS,
        lda.dfunctn=ldaResult$DFUNCT,
        lda.bwratio=ldaResult$BWRATIO
    )

    if (attachOutput) {
        attach(retList)
        return()
    }

    ## TODO: remove when legacy checks confirmed
    if (!writeIntermediateDataFiles) return(retList)

    write.csv(classPriorProbs,
              file = paste(dataDir, 'PRIOR.csv', sep=getPathSep()),
              row.names=FALSE)
    write.csv(ctabPost$POSTERIOR,
              file = paste(dataDir, 'POSTERIOR.csv', sep=getPathSep()),
              row.names=FALSE)
    write.csv(ctabPost$CTABULATION,
              file = paste(dataDir, 'CTABULATION.csv', sep=getPathSep()),
              row.names=FALSE)
    write.csv(ldaResult$CTABALL,
              file=paste(dataDir, 'CTABALL.csv', sep=getPathSep()),
              row.names=FALSE, na="")
    write.csv(ldaResult$VARMEANS,
              file=paste(dataDir, 'VARMEANS.csv', sep=getPathSep()),
              row.names=FALSE, na="")
    write.csv(ldaResult$DFUNCT,
              file=paste(dataDir, 'DFUNCT.csv', sep=getPathSep()),
              row.names=FALSE, na="")
    write.csv(ldaResult$BWRATIO,
              file=paste(dataDir, 'BWRATIO.csv', sep=getPathSep()),
              row.names=FALSE, na="")
}


##' @title Get prior distribution to be used in Discriminant Analysis
##'
##' Calculate prior class distributions. If y is observations (yIsSample=TRUE) priors
##' are the proprtion each class appears in the data. if y is are unique classes,
##' each class is assumed to occur with equal probability
##'
##' @param y factor vector of classes, either observed or unique
##' @param yIsSample TRUE if \param{y} is observations of classes
##'
##' @return data.frame of priors for classes
lda.calcPriorClassProbDist <- function(y, yIsSample=TRUE) {
    log_parent_function_call()
    nObs <- length(y)
    nClasses <- length(levels(y))

    if (yIsSample) {
        d <- dplyr::data_frame(CLASS=y)
        priorDistribution <- d %>%
                               group_by(CLASS) %>%
                               summarise(PRIORD=n()/nObs)
        priorDistribution <- priorDistribution$PRIORD
    } else {
        priorDistribution <- rep(1/nClasses,nClasses)
    }

    return(priorDistribution)
}


##' @title Leave One Out LDA for several models
##'
##' @param y factor vector of classes
##' @param x data frame of observations
##' @param models data frame of model definitions, rows define variable sets
##' @param yClassPriors numeric vector of class priors in order of levels
##' of \param{y}
##'
##' @return list with two data frames - class tabulation and ?posteriors
lda.runLooLdaForModels <- function(y, x, models, yClassPriors, modelsFirstVarCol=4) {
    log_parent_function_call()

    PREDCLASS <- CTAB <- VARSET <- UERROR <- EVARSET <- NVAR <- REFCLASS <- c()

    modelsNumRows <- length(models[,1])
    modelsNumCols <- length(models)
    nClasses <- length(levels(y))

    for (i in 1:modelsNumRows) {
        totalError <- 0

        ## get the logical index of the row which does not have 'N'for the var columns
        ## fill the dummy dataframe with the subset of x matching the above subvector
        modelVarCols <- colnames(models)[modelsFirstVarCol:modelsNumCols]
        logdebug('Columns: %s are being used to identify variables for models',
                 modelVarCols)
        varsInModeliIndex <- models[i,modelsFirstVarCol:modelsNumCols] != 'N'
        varsInModeliNames <- models[i,modelsFirstVarCol:modelsNumCols][varsInModeliIndex]
        missingVarIndex <- !(varsInModeliNames %in% colnames(x))
        if(any(missingVarIndex)){
            stop('Columns: ', varsInModeliNames[missingVarIndex], ' missing from X')
        }

        nVariables <- length(varsInModeliNames)
        xSub <- dplyr::select_(x, .dots=varsInModeliNames) # select by vector of colnames and leave as df
        sel <- complete.cases(xSub)
        xSub <- xSub[sel, , drop=FALSE]
        y <- y[sel]
        nObs <- sum(sel)
        uniqueClasses <- sort(unique(y))
        classNumberList <- as.numeric(levels(uniqueClasses))

        lvi.lda <- MASS::lda(xSub, y, prior=yClassPriors, CV=TRUE)

        class.pred <- lvi.lda$class # Predictions
        class.table <- table(y, class.pred) # Contingency table

        for (m in 1:nClasses) {
            for (n in 1:nClasses) {
                VARSET <- c(VARSET, as.integer(i))
                REFCLASS <- c(REFCLASS, classNumberList[m])
                PREDCLASS <- c(PREDCLASS, classNumberList[n])
                CTAB <- c(CTAB,class.table[m,n])
                }}
        for  (q in 1:nObs) {
            totalError = totalError + max(lvi.lda$posterior[q,])
        }

        totalError <- 1 - totalError/nObs
        UERROR <- c(UERROR,totalError)
        EVARSET <- c(EVARSET,as.integer(i))
        NVAR <- c(NVAR, nVariables)
    }

    CTABULATION <- data.frame(VARSET, REFCLASS, PREDCLASS, CTAB)
    POSTERIOR <- data.frame(VARSET=EVARSET, NVAR, UERROR)

    return(list(CTABULATION=CTABULATION, POSTERIOR=POSTERIOR))
}


##' @title Run Multiple Discriminant Analysis - All Data
##'
##' @param y factor vector of classes
##' @param x data frame of observations
##' @param models data frame of model definitions, rows define variable sets
##' @param yClassPriors numeric vector of class priors in order of levels
##' of \param{y}
##'
##' @return list with 4 data frames - class tabulations, variable means,
##' discr. functions and variance ratios
lda.runLdaAllDataForModels <- function(y, x, models, yClassPriors, modelsFirstVarCol=4) {
    log_parent_function_call()

    modelsNumRows <- length(models[,1])
    modelsNumCols <- length(models)
    nClasses <- length(levels(y))

    ## TODO: initialize with lengths to avoid copy
    REFCLASS <- PREDCLASS <- CTAB <- VARSET <- VARSET2 <- CLASS2 <- c()
    VARNAMES2 <- MEANS2 <- VARSET3 <- DFCOEF3 <- VARNAMES3 <- FUNCLABEL3 <- c()
    VARSET4 <- FUNCLABEL4 <- BTWTWCR4 <- c()

    for (i in 1:modelsNumRows) {
        ## get the logical index of the row which does not have 'N'for the var columns
        ## fill the dummy dataframe with the subset of x matching the above subvector
        modelVarCols <- colnames(models)[modelsFirstVarCol:modelsNumCols]
        logdebug('Columns %s are being used to identify variables for models',
                 modelVarCols)
        varsInModeliIndex <- models[i,modelsFirstVarCol:modelsNumCols] != 'N'
        varsInModeliNames <- models[i,modelsFirstVarCol:modelsNumCols][varsInModeliIndex]
        missingVarIndex <- !(varsInModeliNames %in% colnames(x))
        if (any(missingVarIndex)){
            stop('Columns: ', varsInModeliNames[missingVarIndex], ' missing from X')
        }

        xSub <- dplyr::select_(x, .dots=varsInModeliNames) # select by vector of colnames and leave as df
        sel <- complete.cases(xSub)
        xSub <- xSub[sel, , drop=FALSE]
        y <- y[sel]

        varNames <- names(xSub)
        nVar <- length(varNames)

        lvi.lda = MASS::lda(xSub, y, yClassPriors, CV=FALSE)

        class.pred = predict(lvi.lda)
        class.table = table(y, class.pred$class)
        nDiscFunctions = length(lvi.lda$scaling[1,])

        uniqueClasses <- sort(unique(y))
        classNumberList <- as.numeric(levels(uniqueClasses))

        ## Compile actual veruss predicted cross tabulation tables
        for (m in 1:nClasses) {
            for (n in 1:nClasses) {
                VARSET <- c(VARSET,i)
                REFCLASS <- c(REFCLASS, classNumberList[m])
                PREDCLASS <- c(PREDCLASS, classNumberList[n])
                CTAB <- c(CTAB,class.table[m,n])
            }
        }

        ## Compile mean variable values by class
        for (n in 1:nVar) {
            for (m in 1: nClasses) {
                VARSET2 <- c(VARSET2,i)
                CLASS2 <- c(CLASS2, classNumberList[m])
                VARNAMES2 <- c(VARNAMES2, varNames[n])
                MEANS2 <- c(MEANS2,lvi.lda$means[m,n])
            }
        }

        ## Compile Discriminant Function Coefficients
        for (n in 1: nDiscFunctions){
            for (m in 1:nVar)   {
                VARSET3 <- c(VARSET3, i)
                VARNAMES3 <- c(VARNAMES3, varNames[m])
                FUNCLABEL3 <- c(FUNCLABEL3,gsub(" ","",paste("LN",toString(n))))
                DFCOEF3 <- c(DFCOEF3,lvi.lda$scaling[m,n])
            }
        }

        ## Get Discriminant Function Bewtween Within Variance Ratios
        for (n in 1: nDiscFunctions){
            VARSET4 <- c(VARSET4, i)
            FUNCLABEL4 <- c(FUNCLABEL4,gsub(" ","",paste("LN",toString(n))))
            BTWTWCR4 <- c(BTWTWCR4,lvi.lda$svd[n])
        }
    }

    CTABALL <- data.frame(VARSET,REFCLASS,PREDCLASS,CTAB, stringsAsFactors=FALSE)
    VARMEANS <- data.frame(VARSET2, CLASS2, VARNAMES2,MEANS2, stringsAsFactors=FALSE)
    DFUNCT <- data.frame(VARSET3, VARNAMES3,FUNCLABEL3,DFCOEF3, stringsAsFactors=FALSE)
    BWVARRATIO <- data.frame(VARSET4,FUNCLABEL4,BTWTWCR4, stringsAsFactors=FALSE)

    return(
        list(CTABALL=CTABALL, VARMEANS=VARMEANS, DFUNCT=DFUNCT,
             BWRATIO=BWVARRATIO)
    )
}
