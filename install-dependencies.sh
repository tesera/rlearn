#!/usr/bin/env sh

R -e "libs_dir <- Sys.getenv('R_LIBS_USER');\
      unlink(libs_dir, recursive=TRUE);\
      dir.create(libs_dir, showWarnings = FALSE);\
      install.packages('devtools');\
      library(devtools);\
      update(dev_package_deps('.', dependencies=TRUE))"
