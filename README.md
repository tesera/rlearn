[![Codeship Status for tesera/rlearn](https://codeship.com/projects/ded1d970-e236-0133-4701-1ec7b6a28617/status?branch=master)](https://codeship.com/projects/145545)

# Learn R Library

## Components

### Variable Selection

Given a dataset, identify the subsets which can best represent the
information in the entire dataset.

Wraps the subselect library
<https://cran.r-project.org/web/packages/subselect/subselect.pdf>
which assesses ability of data subsets to represent entire datasets and
finds optimal subsets under various constraints

Computes total and between-group matrices of Sums of Squares and
Cross-Product (SSCP) deviations in linear discriminant analysis.
<http://www.ibm.com/support/knowledgecenter/SSLVMB_21.0.0/com.ibm.spss.statistics.help/alg_discriminant_basicstats_w.htm>
<http://sites.stat.psu.edu/~ajw13/stat505/fa06/12_1wMANOVA/03_1wMANOVA_multi.html>
<http://stats.stackexchange.com/questions/82959/how-is-manova-related-to-lda>
<http://stats.stackexchange.com/questions/48786/algebra-of-lda-fisher-discrimination-power-of-a-variable-and-linear-discriminan#48859>

The SSCP matrix is used to find subsets of variables which best represents
the information in the entire data set given a criterion (score function)
and constrains (number of variables in the subset). The Multivariate Linear
Chi-squared / Pillai-Bartlett trace is used to score the variable subsets
using class prediction rates and observed class frequencies.
<https://en.wikipedia.org/wiki/Contingency_table#Squared_normal_distributions_in_contingency_tables>

### Linear Discriminant Analysis

Given variable subsets as chosen by variable selection, calculate
discriminant functions and classification scores for each variable subset.
Jacknife/Leave-one-out cross validation is first used to calculate cross
tabulations (for confusion matrices) and error rates. Finally, LDA is run
on all observations, for each model, to get discriminant functions and
between/within group variance ratios for each model.

### Data processing

Data can be filtered on 1 column, with 1 value excluded. Degenerate
variables (standard deviation of 0) are removed from input data before
modeling. Variables which should be considered are included in a
configuration file. See tests/data/expected for examples.

## Installing

### Github via cloning

```console
$ git clone git@github.com:tesera/rlearn.git
$ cd rlearn
$ R CMD BUILD .
$ R CMD INSTALL rlearn_1.0.0.tar.gz
```

### Github direct install via devtools

```console
$ R
> library('devtools')
> install_github(repo="tesera/rlearn", ref="master", auth_token="<your_github_personal_access_token>")
```

## Development

```console
apt-get update && apt-get install -y libssl-dev libcurl4-openssl-dev texlive-latex-base texlive-latex-extra texinfo texlive-fonts-extra
export R_LIBS_USER=./rlibs
R -e 'install.packages(c("devtools", "logging", "subselect", "roxygen2", "testthat", "uuid", "tidyr", "dplyr"))'
```

## Testing (requires littler)
```console
docker-compose run dev
$ r ./test.r
```

## Contributing

- [R Styleguide](https://google.github.io/styleguide/Rguide.xml)
