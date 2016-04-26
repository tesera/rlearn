#!/usr/bin/env bash

rm -rf rlibs
mkdir rlibs

install2.r -l $R_LIBS_USER devtools subselect testthat roxygen2 logging uuid dplyr tidyr
