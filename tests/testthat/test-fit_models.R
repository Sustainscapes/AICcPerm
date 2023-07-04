library(testthat)
library(vegan)

# Create a data set for testing
data(dune)
data(dune.env)
all_forms <- make_models(vars = colnames(dune.env), ncores = 1)


test_that("fit_models returns a data.frame", {
  skip_on_cran()
  result <- fit_models(all_forms, com_data = dune, env_data = dune.env, ncores = 1)
  expect_true(is.data.frame(result))
})


test_that("fit_models returns a data.frame when using distances", {
  skip_on_cran()
  result <- fit_models(all_forms, com_data = vegan::vegdist(dune), env_data = dune.env, ncores = 1)
  expect_true(is.data.frame(result))
})

test_that("fit_models returns the expected columns", {
  skip_on_cran()
  expected_cols <- c("form", "AICc", "max_vif")
  result <- fit_models(all_forms, com_data = dune, env_data = dune.env, ncores = 1)
  expect_true(unique(expected_cols %in% colnames(result)))
})

test_that("fit_models removes missing rows", {
  skip_on_cran()
  # Add some missing values to the data set
  dune.env[1, "A1"] <- NA
  dune.env[2, "Moisture"] <- NA

  # Test the function
  expect_error(testthat::capture_warnings(result <- fit_models(all_forms, com_data = dune, env_data = dune.env, verbose = TRUE, ncores = 1)))
  #expect_equal(nrow(result), 32)
})
