% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/variable_selection.R
\name{vs.getUniqueVarsSubset}
\alias{vs.getUniqueVarsSubset}
\title{Subset observations to

Unique vars defined in UNIQVAR.csv}
\usage{
vs.getUniqueVarsSubset(uniqueVars, xy)
}
\arguments{
\item{uniqueVars}{1 row data.frame with values corresponding to names of
unique variables}

\item{xy}{observations with columns that must all be present
in \param{uniqueVars}}
}
\value{
dataframe of xy subsetter to vars in uniqueVars
}

