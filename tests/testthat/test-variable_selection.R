context("variable_selection")
library(rlearn)


## ------------------------------- Legacy -------------------------------------
test_that("vs.selectVars xvarselv matches legacy", {
    lviFileName <- system.file("extdata", "ANALYSIS.csv", package = "rlearn")
    xVarSelectFileName <- system.file("extdata", "XVARSELV1.csv", package = "rlearn")
    outDir <- '/opt/rlearn/tests/data/output'
    outFileName <- 'VARSELECT.csv'
    outFilePath = paste(outDir, outFileName, sep=.Platform$file.sep)

    xy <- read.csv(lviFileName, header=T, row.names=1)
    config <- read.csv(xVarSelectFileName, header=T, row.names=1,
                       strip.white=TRUE,
                       na.strings = c("NA",""))

    solsum <- vs.selectVars(
        xy, config,
        yName='VAR47', removeRowValue=-1, removeRowColName='SORTGRP',
        improveCriteriaVarName='xi2', minNumVar=1, maxNumVar=10, nSolutions=10
    )

    write.csv(solsum, file=outFilePath, row.names=FALSE, na="")

    expect_true(legacyMatchesExpectedOutput(outFileName))

    numericCols <- c('UID', 'MODELID', 'SOLTYPE', 'SOLNUM', 'KVAR', 'VARNUM')
    charCols <- c('VARNAME')

    expect_true(is.data.frame(solsum))
    expect_true(
        all(sapply(solsum[,numericCols], is.numeric))
    )
    expect_true(
        all(sapply(solsum[,charCols], is.character))
    )
})

test_that("vs.getVarCorrelations ucorcoef matches legacy", {
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

    write.csv(ucorcoef, file=outFilePath, row.names=FALSE, na="")

    expect_true(legacyMatchesExpectedOutput('UCORCOEF.csv'))

    numericCols <- c('CORCOEF')
    charCols <- c('VARNAME1', 'VARNAME2')

    expect_true(is.data.frame(ucorcoef))
    expect_true(
        all(sapply(ucorcoef[,numericCols], is.numeric))
    )
    expect_true(
        all(sapply(ucorcoef[,charCols], is.character))
    )
})


## --------------------- removeRowsByColValue ---------------------------------
test_that("removeRowsByColValue returns same data if no matches", {
    dat <- generateRandomDataFrame(100,2, binary=TRUE)
    datNew <- removeRowsByColValue(dat, 500, 'X1')
    expect_true(identical(dat, datNew))
})

test_that("removeRowsByColValue returns same if column name missing", {
    dat <- generateRandomDataFrame(100,2, binary=TRUE)
    missingColName <- 'X100'
    datNew <- removeRowsByColValue(dat, 500, missingColName)
    expect_true(identical(dat, datNew))
})

test_that("removeRowsByColValue returns fewer rows than input", {
    dat <- generateRandomDataFrame(100,2, binary=TRUE)
    datNew <- removeRowsByColValue(dat, 1, 'X1')
    expect_true(length(dat[,1]) > length(datNew[,1]))
})


## --------------------- ClassificationVarToFactor -----------------------------
test_that("vs.classificationVariableToFactor works with valid input", {
    skip('TODO')
    expect_true(FALSE)
})


test_that("vs.classificationVariableToFactor stops if variable not in data", {
    skip('TODO')
    expect_true(FALSE)
})


## ------------------------ removeDegenerateCols -------------------------------
test_that("vs.removeDegenerateColumns works with valid input", {
    datOrig <- generateRandomDataFrame(100,10)
    datOrig[,1] <- 0
    datNew <- vs.removeDegenerateColumns(datOrig)

    nOrig <- length(datOrig)
    nNew <- length(datNew)
    expect_lt(nNew, nOrig)
    expect_equal(nNew, nOrig-1)
})

test_that("vs.removeDegenerateColumns works with non numeric input", {
    skip('TODO')
    expect_true(FALSE)
})

## ---------------------------------- LDA --------------------------------------
test_that("vs.runLDA works with valid input", {
    skip('TODO')
    expect_true(FALSE)
})

## ---------------------------------- Improve -----------------------------------
test_that("vs.improveVariableSelection works with valid input", {
    skip('TODO')
    expect_true(FALSE)
})

## ---------------------------------- Flatten -----------------------------------
test_that("vs.flattenVariableNameSubsets works with valid input", {
    skip('TODO')
    expect_true(FALSE)
})

## ---------------------------- getUniqueVarSubset ------------------------------
test_that("vs.getUniqueVarSubset works with valid input", {
    skip('TODO')
    expect_true(FALSE)
})

test_that("vs.getUniqueVarSubset errors if var missing from observations", {
    skip('TODO')
    expect_true(FALSE)
})
