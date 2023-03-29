#' Create models with different combinations of variables
#'
#' @param vars A character vector of variables to use for modeling
#' @param ncores An integer specifying the number of cores to use for parallel processing
#' @param k maximum number of variables in a model, default is NULL
#' @return A data frame containing all the models and their AICc scores
#'
#' @importFrom parallel makeCluster
#' @importFrom doParallel registerDoParallel
#' @importFrom foreach foreach %dopar%
#' @importFrom purrr reduce
#' @importFrom dplyr bind_rows distinct mutate
#' @importFrom utils combn
#' @export
#'
#' @examples
#' make_models(vars = c("A", "B", "C", "D"),
#'             ncores = 2)
#'
#' # using k as a way to limit number of variables
#' make_models(vars = c("A", "B", "C", "D"),
#'             ncores = 2, k = 2)

make_models <- function(vars, ncores = 2, k = NULL) {
  AICc <- form <- j <- NULL
  # create list of variables to use for modeling
  vars <- unlist(strsplit(vars, "\\s*,\\s*"))

  # set response and dataset variables
  dataset <- "Distance"

  forms <- list()

  if(is.null(k)){
    MaxVars <- length(vars)
  }

  if(!is.null(k)){
    MaxVars <- k
  }

  # loop over different numbers of variables to include in models
  for(i in 1:MaxVars) {
    test <- combn(vars, i, simplify = F)
    cl <- parallel::makeCluster(ncores)
    doParallel::registerDoParallel(cl)

    # loop over all combinations of variables and create a list of formulas
    formulas <- foreach::foreach(j = 1:length(test), .combine = "rbind", .packages = c("dplyr")) %dopar% {
      df <- data.frame(form = NA, AICc = NA)
      temp <- paste(dataset, "~", paste(test[[j]], collapse = " + "))
      df$form <- temp
      gc()
      df
    }
    parallel::stopCluster(cl)
    message(paste(i, "of", MaxVars, "ready", Sys.time()))
    forms[[i]] <- formulas
  }

  # combine all formulas into a single data frame and add the null model
  all_forms <- forms |>
    purrr::reduce(dplyr::bind_rows) |>
    dplyr::distinct(form, AICc, .keep_all = T) |>
    dplyr::mutate(max_vif = NA)
  null_mod <- data.frame(form = paste(dataset, "~ 1", collapse = ""), AICc = NA) |>
    dplyr::mutate(max_vif = NA)
  all_forms <- all_forms |>  bind_rows(null_mod)

  return(all_forms)
}
