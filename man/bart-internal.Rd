% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bart.R
\name{bart-internal}
\alias{bart-internal}
\alias{bartMachine_interval_calc}
\alias{dbart_predict_calc}
\title{Model predictions}
\usage{
bartMachine_interval_calc(new_data, obj, ci = TRUE, level = 0.95)

dbart_predict_calc(obj, new_data, type, level = 0.95, std_err = FALSE)
}
\arguments{
\item{new_data}{A rectangular data object, such as a data frame.}

\item{obj}{A parsnip object.}

\item{ci}{Confidence (TRUE) or prediction interval (FALSE)}

\item{level}{Confidence level.}

\item{type}{A single character value or \code{NULL}. Possible values
are "numeric", "class", "prob", "conf_int", "pred_int", "quantile", "time",
"hazard", "survival", or "raw". When \code{NULL}, \code{predict()} will choose an
appropriate value based on the model's mode.}

\item{std_err}{Attach column for standard error of prediction or not.}
}
\value{
With the exception of \code{type = "raw"}, the results of
\code{predict.model_fit()} will be a tibble as many rows in the output
as there are rows in \code{new_data} and the column names will be
predictable.

For numeric results with a single outcome, the tibble will have
a \code{.pred} column and \code{.pred_Yname} for multivariate results.

For hard class predictions, the column is named \code{.pred_class}
and, when \code{type = "prob"}, the columns are \code{.pred_classlevel}.

\code{type = "conf_int"} and \code{type = "pred_int"} return tibbles with
columns \code{.pred_lower} and \code{.pred_upper} with an attribute for
the confidence level. In the case where intervals can be
produces for class probabilities (or other non-scalar outputs),
the columns will be named \code{.pred_lower_classlevel} and so on.

Quantile predictions return a tibble with a column \code{.pred}, which is
a list-column. Each list element contains a tibble with columns
\code{.pred} and \code{.quantile} (and perhaps other columns).

Using \code{type = "raw"} with \code{predict.model_fit()} will return
the unadulterated results of the prediction function.

For censored regression:
\itemize{
\item \code{type = "time"} produces a column \code{.pred_time}.
\item \code{type = "hazard"} results in a column \code{.pred_hazard}.
\item \code{type = "survival"} results in a list column containing tibbles with a
\code{.pred_survival} column.
}

For the last two types, the results are a nested tibble with an overall
column called \code{.pred} with sub-tibbles with the above format.

In the case of Spark-based models, since table columns cannot
contain dots, the same convention is used except 1) no dots
appear in names and 2) vectors are never returned but
type-specific prediction functions.

When the model fit failed and the error was captured, the
\code{predict()} function will return the same structure as above but
filled with missing values. This does not currently work for
multivariate models.
}
\description{
Apply a model to create different types of predictions.
\code{predict()} can be used for all types of models and uses the
"type" argument for more specificity.
}
\details{
If "type" is not supplied to \code{predict()}, then a choice
is made:
\itemize{
\item \code{type = "numeric"} for regression models,
\item \code{type = "class"} for classification, and
\item \code{type = "time"} for censored regression.
}

\code{predict()} is designed to provide a tidy result (see "Value"
section below) in a tibble output format.
\subsection{Interval predictions}{

When using \code{type = "conf_int"} and \code{type = "pred_int"}, the options
\code{level} and \code{std_error} can be used. The latter is a logical for an
extra column of standard error values (if available).
}

\subsection{Censored regression predictions}{

For censored regression, a numeric vector for \code{time} is required when
survival or hazard probabilities are requested. Also, when
\code{type = "linear_pred"}, censored regression models will by default be
formatted such that the linear predictor \emph{increases} with time. This may
have the opposite sign as what the underlying model's \code{predict()} method
produces. Set \code{increasing = FALSE} to suppress this behavior.
}
}
\examples{
library(dplyr)

lm_model <-
  linear_reg() \%>\%
  set_engine("lm") \%>\%
  fit(mpg ~ ., data = mtcars \%>\% dplyr::slice(11:32))

pred_cars <-
  mtcars \%>\%
  dplyr::slice(1:10) \%>\%
  dplyr::select(-mpg)

predict(lm_model, pred_cars)

predict(
  lm_model,
  pred_cars,
  type = "conf_int",
  level = 0.90
)

predict(
  lm_model,
  pred_cars,
  type = "raw",
  opts = list(type = "terms")
)
}
\keyword{internal}