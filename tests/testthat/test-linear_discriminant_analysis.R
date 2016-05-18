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
    skip('TODO')
    lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
    xVarSelectFileName <- system.file("extdata", "XVARSELV.csv", package = "rlearn")
    outDir <- '/opt/rlearn/tests/data/output'

    xy <- read.csv(lviFileName, header=T, row.names=1)
    config <- read.csv(xVarSelectFileName,
                       header=T, row.names=1,
                       strip.white=TRUE,
                       na.strings = c("NA",""))
    xy[1,'VAR1091'] <- NA
    ldaResult <- lda(xy,
                     config,
                     removeRowColName='SORTGRP',
                     removeRowValue=-1,
                     classVariableName='VAR47',
                     priorDistributionIsSample=TRUE)
    expect_true(is.list(ldaResult))
})


test_that("lda raises useful error if yvar is degenerate", {
    lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
    xVarSelectFileName <- system.file("extdata", "XVARSELV.csv", package = "rlearn")
    outDir <- '/opt/rlearn/tests/data/output'

    xy <- read.csv(lviFileName, header=T, row.names=1)
    config <- read.csv(xVarSelectFileName,
                       header=T, row.names=1,
                       strip.white=TRUE,
                       na.strings = c("NA",""))

    xy$Y <- 1
    expect_error(lda(xy,
                     config,
                     removeRowColName='SORTGRP',
                     removeRowValue=-1,
                     classVariableName='Y',
                     priorDistributionIsSample=TRUE),
                 'Response variable, Y, is degenerate')
})

test_that("lda raises if variable in config not found in columns of X", {
    lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
    xVarSelectFileName <- system.file("extdata", "XVARSELV.csv", package = "rlearn")
    outDir <- '/opt/rlearn/tests/data/output'

    xy <- read.csv(lviFileName, header=T, row.names=1)
    config <- read.csv(xVarSelectFileName,
                       header=T,
                       strip.white=TRUE,
                       na.strings = c("NA",""))

    expect_error(lda(xy,
                     config,
                     removeRowColName='SORTGRP',
                     removeRowValue=-1,
                     classVariableName='VAR47',
                     priorDistributionIsSample=TRUE),
                 'missing from X')
})
