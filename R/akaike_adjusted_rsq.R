#' Akaike-Adjusted R Squared Calculation with Model Averaging
#'
#' Calculates the adjusted R squared for each predictor using the Akaike
#' Information Criterion (AIC) and model averaging. AIC is used to compare the
#' performance of candidate models and select the best one. Then, the R squared
#' is adjusted based on the weight of evidence in favor of each model. The final
#' result is a long-format table of variable names and corresponding adjusted
#' R squared values.
#'
#' @param DF A data.frame containing the variables to calculate the adjusted
#'           R squared for. The data.frame should include the columns:
#'           "form", "AICc", "max_vif", "k", "DeltaAICc", "AICWeight", and "N".
#' @return A data.frame with columns "Variable" and "Full_Akaike_Adjusted_RSq".
#'         Each row represents a predictor, and its corresponding adjusted R
#'         squared value based on the Akaike-adjusted model averaging process.
#' @details The adjusted R squared is calculated as:
#'          \deqn{Adjusted R^2 = 1 - (RSS / (N - k - 1)) * ((N - 1) / (N - k - 1))}
#'          where RSS is the residual sum of squares, N is the sample size, and
#'          k is the number of predictors. The R squared is adjusted based on the
#'          weight of evidence in favor of each model, which is calculated as:
#'          \deqn{w_i = exp(-0.5 * DeltaAICc_i) / sum(exp(-0.5 * DeltaAICc))}
#'          where w_i is the weight of evidence in favor of the ith model, and
#'          DeltaAICc_i is the difference in AICc between the ith model and the
#'          best model. Model averaging uses the weights to combine the
#'          performance of different models in the final calculation of the
#'          adjusted R squared.
#'
#' @importFrom dplyr mutate_at vars matches everything select summarise_if
#' @importFrom tidyr pivot_longer
#'
#' @examples
#' library(data.table)
#' df <- data.table(
#'   form = c(1, 2, 3),
#'   AICc = c(10, 20, 30),
#'   max_vif = c(3, 4, 5),
#'   k = c(1, 2, 3),
#'   DeltaAICc = c(2, 5, 8),
#'   AICWeight = c(0.2, 0.5, 0.3),
#'   N = c(100, 100, 100),
#'   A1 = c(0.3, 0.5, NA),
#'   A2 = c(0.7, NA, 0.2),
#'   A3 = c(0.2, 0.3, 0.6)
#' )
#' akaike_adjusted_rsq(df)
#'
#' @export

akaike_adjusted_rsq <- function(DF) {
  AICc <- DeltaAICc <- max_vif <- AICWeight <- Model <- k <- N <- form <- value <- Variable <- Number_of_models <- Full_Akaike_Adjusted_RSq <- NULL
  Result <- DF |>
    dplyr::select(-AICc, -DeltaAICc, -matches("Model"), -max_vif, -k, -N) |>
    dplyr::mutate_if(is.numeric, ~ ifelse(is.na(.x), 0, .x)) |>
    tidyr::pivot_longer(cols = c(-form, -AICWeight), names_to = "Variable") |>
    dplyr::mutate(Full_Akaike_Adjusted_RSq = value * AICWeight, Number_of_models = ifelse(value == 0, 0, 1)) |>
    dplyr::group_by(Variable) |>
    dplyr::summarise_if(is.numeric, sum) |>
    dplyr::select(-value, -AICWeight) |>
    dplyr::arrange(dplyr::desc(Number_of_models), dplyr::desc(Full_Akaike_Adjusted_RSq))

  return(Result)
}
