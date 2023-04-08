test_that("make_models correctly generates models with intercepts", {
  vars <- c("A", "B", "C", "D")
  result <- make_models(vars = vars, ncores = 2, k = NULL, verbose = FALSE)
  expect_true(any(grepl("Distance ~ 1", result$form)))
})


test_that("make_models generates unique models", {
  vars <- c("A", "B", "C", "D")
  result <- make_models(vars = vars, ncores = 2, k = NULL, verbose = FALSE)
  expect_equal(nrow(result), nrow(unique(result)))
})

test_that("make_models verbose flag works as expected", {
  vars <- c("A", "B", "C", "D")
  result <- make_models(vars = vars, ncores = 2, k = 2, verbose = TRUE)
  expect_equal(nrow(result), 11)
  expect_equal(ncol(result), 1)
})



