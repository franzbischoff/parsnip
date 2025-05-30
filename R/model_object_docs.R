#' Model Specifications
#'
#' @description
#'
#' The parsnip package splits the process of fitting models into two steps:
#'
#' 1) Specify how a model will be fit using a _model specification_
#' 2) Fit a model using the model specification
#'
#' This is a different approach to many other model interfaces in R, like `lm()`,
#' where both the specification of the model and the fitting happens in one
#' function call. Splitting the process into two steps allows users to
#' iteratively define model specifications throughout the model development
#' process.
#'
#' This intermediate object that defines how the model will be fit is called
#' a _model specification_ and has class `model_spec`. Model type functions,
#' like [linear_reg()] or [boost_tree()], return `model_spec` objects.
#'
#' Fitted model objects, resulting from passing a `model_spec` to
#' [fit()][fit.model_spec()] or [fit_xy][fit_xy.model_spec()], have
#' class `model_fit`, and contain the original `model_spec` objects inside
#' them. See [?model_fit][model_fit] for more on that object type, and
#' [?extract_spec_parsnip][extract_spec_parsnip.model_fit] to
#' extract `model_spec`s from `model_fit`s.
#'
#' @details
#'
#' An object with class `"model_spec"` is a container for
#'  information about a model that will be fit.
#'
#' The main elements of the object are:
#'
#' * `args`: A vector of the main arguments for the model. The
#'  names of these arguments may be different from their
#'  counterparts n the underlying model function. For example, for a
#'  `glmnet` model, the argument name for the amount of the penalty
#'  is called "penalty" instead of "lambda" to make it more general
#'  and usable across different types of models (and to not be
#'  specific to a particular model function). The elements of `args`
#'  can `tune()` with the use of the
#'  [tune package](https://tune.tidymodels.org/). For more information
#'  see <https://www.tidymodels.org/start/tuning/>. If left to their
#'  defaults (`NULL`), the
#'  arguments will use the underlying model functions default value.
#'  As discussed below, the arguments in `args` are captured as
#'  quosures and are not immediately executed.
#'
#' * `...`: Optional model-function-specific
#'  parameters. As with `args`, these will be quosures and can be
#'  `tune()`.
#'
#' * `mode`: The type of model, such as "regression" or
#'  "classification". Other modes will be added once the package
#'  adds more functionality.
#'
#' * `method`: This is a slot that is filled in later by the
#'  model's constructor function. It generally contains lists of
#'  information that are used to create the fit and prediction code
#'  as well as required packages and similar data.
#'
#' * `engine`: This character string declares exactly what
#'  software will be used. It can be a package name or a technology
#'  type.
#'
#' This class and structure is the basis for how parsnip
#'  stores model objects prior to seeing the data.
#'
#' @section Argument Details:
#'
#' An important detail to understand when creating model
#'  specifications is that they are intended to be functionally
#'  independent of the data. While it is true that some tuning
#'  parameters are _data dependent_, the model specification does
#'  not interact with the data at all.
#'
#' For example, most R functions immediately evaluate their
#'  arguments. For example, when calling `mean(dat_vec)`, the object
#'  `dat_vec` is immediately evaluated inside of the function.
#'
#' parsnip model functions do not do this. For example, using
#'
#'\preformatted{
#'  rand_forest(mtry = ncol(mtcars) - 1)
#' }
#'
#' **does not** execute `ncol(mtcars) - 1` when creating the specification.
#' This can be seen in the output:
#'
#'\preformatted{
#'  > rand_forest(mtry = ncol(mtcars) - 1)
#'  Random Forest Model Specification (unknown)
#'
#'  Main Arguments:
#'    mtry = ncol(mtcars) - 1
#'}
#'
#' The model functions save the argument _expressions_ and their
#'  associated environments (a.k.a. a quosure) to be evaluated later
#'  when either [fit.model_spec()] or [fit_xy.model_spec()]  are
#'  called with the actual data.
#'
#' The consequence of this strategy is that any data required to
#'  get the parameter values must be available when the model is
#'  fit. The two main ways that this can fail is if:
#'
#' \enumerate{
#'   \item The data have been modified between the creation of the
#'    model specification and when the model fit function is invoked.
#'
#'   \item If the model specification is saved and loaded into a new
#'  session where those same data objects do not exist.
#' }
#'
#' The best way to avoid these issues is to not reference any data
#'  objects in the global environment but to use data descriptors
#'  such as `.cols()`. Another way of writing the previous
#'  specification is
#'
#'\preformatted{
#'  rand_forest(mtry = .cols() - 1)
#' }
#'
#' This is not dependent on any specific data object and
#' is evaluated immediately before the model fitting process begins.
#'
#'  One less advantageous approach to solving this issue is to use
#'  quasiquotation. This would insert the actual R object into the
#'  model specification and might be the best idea when the data
#'  object is small. For example, using
#'
#'\preformatted{
#'  rand_forest(mtry = ncol(!!mtcars) - 1)
#' }
#'
#' would work (and be reproducible between sessions) but embeds
#' the entire mtcars data set into the `mtry` expression:
#'
#'\preformatted{
#'  > rand_forest(mtry = ncol(!!mtcars) - 1)
#'  Random Forest Model Specification (unknown)
#'
#'  Main Arguments:
#'    mtry = ncol(structure(list(Sepal.Length = c(5.1, 4.9, 4.7, 4.6, 5, <snip>
#'}
#'
#' However, if there were an object with the number of columns in
#'  it, this wouldn't be too bad:
#'
#'\preformatted{
#'  > mtry_val <- ncol(mtcars) - 1
#'  > mtry_val
#'  [1] 10
#'  > rand_forest(mtry = !!mtry_val)
#'  Random Forest Model Specification (unknown)
#'
#'  Main Arguments:
#'    mtry = 10
#'}
#'
#' More information on quosures and quasiquotation can be found at
#' \url{https://adv-r.hadley.nz/quasiquotation.html}.
#'
#' @rdname model_spec
#' @name model_spec
NULL

#' Model Fit Objects
#'
#' @description
#'
#' Model fits are trained [model specifications][model_spec] that are
#' ready to [predict][predict.model_fit] on new data. Model fits have class
#' `model_fit` and, usually, a subclass referring to the engine
#' used to fit the model.
#'
#' @details
#'
#' An object with class `"model_fit"` is a container for
#'  information about a model that has been fit to the data.
#'
#' The main elements of the object are:
#'
#'   * `lvl`: A vector of factor levels when the outcome is
#'  a factor. This is `NULL` when the outcome is not a factor
#'  vector.
#'
#'   * `spec`: A `model_spec` object.
#'
#'   * `fit`: The object produced by the fitting function.
#'
#'   * `preproc`: This contains any data-specific information
#'  required to process new a sample point for prediction. For
#'  example, if the underlying model function requires arguments `x`
#'  and `y` and the user passed a formula to `fit`, the `preproc`
#'  object would contain items such as the terms object and so on.
#'  When no information is required, this is `NA`.
#'
#' As discussed in the documentation for [`model_spec`], the
#'  original arguments to the specification are saved as quosures.
#'  These are evaluated for the `model_fit` object prior to fitting.
#'  If the resulting model object prints its call, any user-defined
#'  options are shown in the call preceded by a tilde (see the
#'  example below). This is a result of the use of quosures in the
#'  specification.
#'
#' This class and structure is the basis for how \pkg{parsnip}
#'  stores model objects after seeing the data and applying a model.
#' @rdname model_fit
#' @name model_fit
#' @examplesIf !parsnip:::is_cran_check()
#'
#' # Keep the `x` matrix if the data are not too big.
#' spec_obj <-
#'   linear_reg() |>
#'   set_engine("lm", x = ifelse(.obs() < 500, TRUE, FALSE))
#' spec_obj
#'
#' fit_obj <- fit(spec_obj, mpg ~ ., data = mtcars)
#' fit_obj
#'
#' nrow(fit_obj$fit$x)
NULL

