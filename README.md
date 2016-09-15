[![Codeship Status for tesera/rlearn](https://codeship.com/projects/ded1d970-e236-0133-4701-1ec7b6a28617/status?branch=master)](https://codeship.com/projects/145545)

# rlearn

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

There are a couple installation options

- clone and install with `R CMD`
- use `devtools` to instrall directly from github
- install into a docker container using the provided `Dockerfile`

Docker is the suggested method, as it provides a more consistent environment.

### R CMD

```console
$ git clone git@github.com:tesera/rlearn.git
$ cd rlearn
$ R CMD BUILD .
$ R CMD INSTALL rlearn_1.0.0.tar.gz
```

### Devtools

```console
$ R
> library('devtools')
> install_github(repo="tesera/rlearn", ref="master", auth_token="<your_github_personal_access_token>")
```

### Docker

Clone the repository and build the docker image

```console
$ git clone git@github.com:tesera/rlearn.git
$ cd rlearn
$ docker built -t rlearn .

```

Grab a coffee, building the image will take a few minutes

```
Step 1 : FROM r-base:latest
latest: Pulling from library/r-base
9cd73496e13f: Downloading [=============================>                     ] 24.73 MB/42.07 MB
f10af350cd29: Download complete
eea7b33eea97: Download complete
c91475e50472: Download complete
1e5e5f6785b4: Download complete
8c4091261ff6: Downloading [>                                                  ] 5.919 MB/322.1 MB
...
```

To test if the image built successfully, run the following command

```console
docker run -it rlearn
```

That should drop you into an interactive R session where you can import and use rlearn

```
> library(rlearn)
> 
```

## Usage

Start R

```console
$ R
# or, if you are using docker
$ 
```

## Development

### Setup
All contributors are welcome! To get started developing on `rlearn` you will need docker

One you are setup with docker, clone this repo

```console
$ git clone git@github.com:tesera/rlearn.git
```

Enter the top level directory

```console
cd rlearn
docker-compose run dev
```

Now you are in the docker container - install the dependencies required for rlearn

``` console
r install-dependencies.r
```

And you're all set to make changes to rlearn!

To use your active development version of rlearn start an R session in the
docker container

``` console
docker-compose run dev R
```

And load all the package resources

```
library(devtools)
load_all('.')
```

### Testing

Unit tests are written using the
[testthat](https://cran.r-project.org/web/packages/testthat/index.html)
package.

Unit tests are required for new functionality. Changes to existing codebase should not break existing tests, or existing tests should be updated if appropriate.

Run the tests as follows

```console
docker-compose run dev
$ r ./test.r
```

### Documentation

### Contribution Guidelines

- If you would like to contribute changes to rlearn, please follow [this guide](http://kbroman.org/github_tutorial/pages/fork.html) to fork, clone, create a branch, make your changes, push your branch to your fork, and open a pull request. Don't forget to run the tests!
- Please follow the [Wickham Style](http://adv-r.had.co.nz/Style.html) for your contributions to rlearn.

## Getting Help

For assistance with usage or development of rlearn, please file an issue on the [issue tracker](https://github.com/tesera/rlearn/issues).
