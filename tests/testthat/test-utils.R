context("utils")


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


## ---------------------- legacyMatchesRefactored ------------------------------
test_that("Expected check works", {
    outDirExpected <- '/opt/rlearn/tests/data/expected'
    outDir <- '/opt/rlearn/tests/data/output'

    fsep <- .Platform$file.sep
    legacyFile <- paste(outDirExpected, 'test_data.csv', sep=fsep)
    refactoredFile <- paste(outDir, 'test_data.csv', sep=fsep)

    dat <- generateRandomDataFrame(10,10)

    write.csv(dat, file=legacyFile, row.names=FALSE, na="")
    write.csv(dat+0.01, file=refactoredFile, row.names=FALSE, na="")

    expect_true(
        legacyMatchesExpectedOutput('test_data.csv',
                                    outDirExpected=outDirExpected, outDir=outDir,
                                    tol=0.1)
    )
    file.remove(legacyFile, refactoredFile)
})


## ------------------------ selectXVariableSubset -------------------------------
test_that("selectXVariableSubset works with valid input", {
    skip('TODO')
    expect_true(FALSE)
})
