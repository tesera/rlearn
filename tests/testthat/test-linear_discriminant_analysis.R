context("linear_discriminant_analysis")
library(rlearn)

logger.init()


## ------------------------------- Legacy -------------------------------------
test_that("lda matches legacy", {
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
                     priorDistributionIsSample=TRUE,
                     dataDir=outDir, writeIntermediateDataFiles=TRUE)

    expect_true(legacyMatchesExpectedOutput('PRIOR.csv'))
    expect_true(legacyMatchesExpectedOutput('CTABULATION.csv'))
    expect_true(legacyMatchesExpectedOutput('POSTERIOR.csv'))
    expect_true(legacyMatchesExpectedOutput('VARMEANS.csv'))
    expect_true(legacyMatchesExpectedOutput('DFUNCT.csv'))
    expect_true(legacyMatchesExpectedOutput('BWRATIO.csv'))
    expect_true(legacyMatchesExpectedOutput('CTABALL.csv'))
})

test_that("lda types are correct", {
    lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
    xVarSelectFileName <- system.file("extdata", "XVARSELV.csv", package = "rlearn")
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
                     priorDistributionIsSample=TRUE,
                     dataDir=outDir)

    prior <- ldaResult$lda.prior
    posterior <- ldaResult$lda.posterior
    ctabulation <- ldaResult$lda.ctabulation
    ctaball <- ldaResult$lda.ctaball
    varmeans <- ldaResult$lda.varmeans
    dfunctn <- ldaResult$lda.dfunct
    bwratio <- ldaResult$lda.bwratio

    expect_true(is.numeric(prior))
    expect_true(is.vector(prior))

    expect_true(is.data.frame(posterior))
    expect_true(all(sapply(posterior, is.numeric)))
    expect_false(any(sapply(posterior, is.factor)))

    expect_true(is.data.frame(ctabulation))
    expect_true(all(sapply(ctabulation, is.numeric)))
    expect_false(any(sapply(ctabulation, is.factor)))

    expect_true(is.data.frame(ctaball))
    expect_true(all(sapply(ctaball, is.numeric)))
    expect_false(any(sapply(ctaball, is.factor)))

    varmeansNumericCols <- c('VARSET2', 'CLASS2', 'MEANS2')
    expect_true(is.data.frame(varmeans))
    expect_true(all(sapply(varmeans[,varmeansNumericCols], is.numeric)))
    expect_false(any(sapply(varmeans, is.factor)))

    dfunctnNumericCols <- c('DFCOEF3')
    expect_true(is.data.frame(dfunctn))
    expect_true(all(sapply(dfunctn[,dfunctnNumericCols], is.numeric)))
    expect_false(any(sapply(dfunctn, is.factor)))

    bwratioNumericCols <- c('VARSET4', 'BTWTWCR4')
    expect_true(is.data.frame(bwratio))
    expect_true(all(sapply(bwratio[,bwratioNumericCols], is.numeric)))
    expect_false(any(sapply(bwratio, is.factor)))
})


## --------------------------- CalcClassPriorProbs -----------------------------
## for MASS:lda, if priors are provided, they must be in a numeric vector in the
## same order as the factor levels of the response variable
test_that("Class prior probs in same order as levels of response", {
    classObs <- c('c', 'b', 'b', 'b', 'b', 'c', 'c', 'a')

    y <- factor(classObs, levels=c('a', 'b', 'c'))
    knownPriors <- c(0.125, 0.500, 0.375)
    priors <- lda.calcPriorClassProbDist(y)
    expect_equal(priors, knownPriors)

    y <- factor(classObs, levels=c('b', 'c', 'a'))
    knownPriors <- c(0.500, 0.375, 0.125)
    priors <- lda.calcPriorClassProbDist(y)
    expect_equal(priors, knownPriors)
})

# ---------------------------------- LDA --------------------------------------
test_that("lda works with NAs in X", {
    lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
    xVarSelectFileName <- system.file("extdata", "XVARSELV.csv", package = "rlearn")
    outDir <- '/opt/rlearn/tests/data/output'

    xy <- read.csv(lviFileName, header=T, row.names=1)
    config <- read.csv(xVarSelectFileName,
                       header=T, row.names=1,
                       strip.white=TRUE,
                       na.strings = c("NA",""))
    xy[1,] <- NA
    ldaResult <- lda(xy,
                     config,
                     removeRowColName='SORTGRP',
                     removeRowValue=-1,
                     classVariableName='VAR47',
                     priorDistributionIsSample=TRUE)
    expect_true(is.list(ldaResult))
})

## --------------------------------- Orig -------------------------------------
## excludeRowValue = -1
## excludeRowVarName <- 'SORTGRP'
## classVariableName <- 'CLPRDP'
## priorDistribution <- 'SAMPLE'
## lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
## xVarSelectFileName <- system.file("extdata", "XVARSELV.csv", package = "rlearn")
## outDir <- '/opt/rlearn/tests/data/legacy'
## fsep <- .Platform$file.sep
## outFiles = c('PRIOR.csv', 'CTABULATION.csv', 'POSTERIOR.csv', 'CTABALL.csv', 'VARMEANS.csv', 'DFUNCT.csv', 'BWRATIO.csv')

## clear_files <- function() {
##     for (i in 0:length(outFiles)) {
##         if (file.exists(paste(outDir, outFiles[i], sep=fsep))) unlink(paste(outDir, outFiles[i], sep=fsep))
##     }
## }

## test_that("LoadDatasetAndAttachVariableNames can load a filename is processed", {
##     clear_files()
##     lda.LoadDatasetAndAttachVariableNames(lviFileName)
##     expect_that(length(lviVarNames) > 0, is_true())
##     expect_that(nLviRows > 0, is_true())
## })

## test_that("ExcludeRowsWithCertainVariableValues", {
##     lda.ExcludeRowsWithCertainVariableValues(excludeRowVarName, excludeRowValue)
##     expect_that(nLviRows > 0, is_true())
## })

## test_that("DeclareClassificationVariableAsFactor", {
##     lda.DeclareClassificationVariableAsFactor(classVariableName)
##     expect_that(nClasses > 0, is_true())
##     expect_that(nclassObs > 0, is_true())
## })

## test_that("ComputePriorClassProbabilityDistribution", {
##     lda.ComputePriorClassProbabilityDistribution(priorDistribution)
##     expect_that(length(priorDistribution) > 0, is_true())
## })

## test_that("WritePriorDistributionToFile", {
##     lda.WritePriorDistributionToFile(classVariableName, outDir)
##     expect_that(file.exists(paste(outDir, 'PRIOR.csv', sep=fsep)), is_true())
## })

## test_that("SelectXVariableSubset", {
##     lda.SelectXVariableSubset(xVarSelectFileName)

##     expect_that(nRows > 0, is_true())
##     expect_that(length(varNameList) > 0, is_true())
##     expect_that(nCols > 0, is_true())
## })

## test_that("RunMultipleLinearDiscriminantAnalysisMASSldaTakeOneLeaveOne", {
##     lda.RunMultipleLinearDiscriminantAnalysisMASSldaTakeOneLeaveOne()

##     expect_that(length(CTABULATION) > 0, is_true())
##     expect_that(length(POSTERIOR) > 0, is_true())
## })

## test_that("WriteMultipleLinearDiscriminantAnalysisMASSldaTOLOtoFile", {
##     lda.WriteMultipleLinearDiscriminantAnalysisMASSldaTOLOtoFile(outDir)

##     expect_that(file.exists(paste(outDir, 'CTABULATION.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'POSTERIOR.csv', sep=fsep)), is_true())
## })

## test_that("RunMultipleLinearDiscriminantAnalysisMASSlda", {
##     lda.RunMultipleLinearDiscriminantAnalysisMASSlda()

##     expect_that(length(CTABALL) > 0, is_true())
##     expect_that(length(VARMEANS) > 0, is_true())
##     expect_that(length(DFUNCT) > 0, is_true())
##     expect_that(length(BWRATIO) > 0, is_true())
## })

## test_that("WriteMultipleLinearDiscriminantAnalysisMASSlda", {
##     lda.WriteMultipleLinearDiscriminantAnalysisMASSlda(outDir)

##     expect_that(file.exists(paste(outDir, 'CTABALL.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'VARMEANS.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'DFUNCT.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'BWRATIO.csv', sep=fsep)), is_true())
## })

## test_that("Wrapper works", {
##     clear_files()
##     lda.RunLinearDiscriminantVariableAnalysis(lviFileName, xVarSelectFileName, excludeRowVarName, excludeRowValue, classVariableName, priorDistribution, outDir)

##     expect_that(file.exists(paste(outDir, 'PRIOR.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'CTABULATION.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'POSTERIOR.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'CTABALL.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'VARMEANS.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'DFUNCT.csv', sep=fsep)), is_true())
##     expect_that(file.exists(paste(outDir, 'BWRATIO.csv', sep=fsep)), is_true())
## })
