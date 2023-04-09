
<!-- README.md is generated from README.Rmd. Please edit that file -->

# AICcPerm

<!-- badges: start -->

[![R-CMD-check](https://github.com/Sustainscapes/AICcPerm/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Sustainscapes/AICcPerm/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/AICcPermanova)](https://CRAN.R-project.org/package=AICcPermanova)
[![Codecov test
coverage](https://codecov.io/gh/Sustainscapes/AICcPerm/branch/master/graph/badge.svg)](https://app.codecov.io/gh/Sustainscapes/AICcPerm?branch=master)
<!-- badges: end -->

The goal of AICcPerm is to generate an R package that does model
selection for Permanovas from the vegan packages, to install this
package you can use the remotes package and intall it as this:

``` r
remotes::install_github("Sustainscapes/AICcPerm")
```

## Generation of all possible models

For the generation of all possible models you can use the `make_models`
function, just as in this example

``` r
library(AICcPermanova)
AllModels <- make_models(vars = c("pH", "Sand", "Clay"), ncores = 2)
```

This will give you the following table:

| form                         |
|:-----------------------------|
| Distance \~ pH               |
| Distance \~ Sand             |
| Distance \~ Clay             |
| Distance \~ pH + Sand        |
| Distance \~ pH + Clay        |
| Distance \~ Sand + Clay      |
| Distance \~ pH + Sand + Clay |
| Distance \~ 1                |

Where you can see all possible models for tose 3 variables.

## AICc calculation

for this you can use the `AICc_permanova2`, this is an example of this:

``` r

library(vegan)
#> Loading required package: permute
#> Loading required package: lattice
#> This is vegan 2.6-4
data(dune)
data(dune.env)

# Run PERMANOVA using adonis2

Model <- adonis2(dune ~ Management*A1, data = dune.env)

# Calculate AICc
Table_permanova <- AICc_permanova2(Model)
```

This is shown in the following table

``` r
knitr::kable(Table_permanova)
```

|      AICc |   k |   N |
|----------:|----:|----:|
| -19.06395 |   8 |  20 |

## Full example

We will show the last function called `fit_models`, we will start by
using the datasets from the vegan package:

``` r
library(vegan)
data(dune)
data(dune.env)
```

And then generate all possible models for 3 of the variables:

``` r
AllModels <- make_models(vars = c("A1", "Moisture", "Manure"))
#> 1 of 3 ready 2023-04-09 05:51:19
#> 2 of 3 ready 2023-04-09 05:51:24
#> 3 of 3 ready 2023-04-09 05:51:26
```

We then get this table:

| form                               |
|:-----------------------------------|
| Distance \~ A1                     |
| Distance \~ Moisture               |
| Distance \~ Manure                 |
| Distance \~ A1 + Moisture          |
| Distance \~ A1 + Manure            |
| Distance \~ Moisture + Manure      |
| Distance \~ A1 + Moisture + Manure |
| Distance \~ 1                      |

After this, we make a model selection by fitting all possible models:

``` r
Fitted <- fit_models(all_forms = AllModels,
           veg_data = dune,
           env_data = dune.env,
           ncores = 4,
           method = "bray")
```

Which results in the following table:

| form                               |      AICc |  max_vif |        A1 |  Moisture |    Manure | Model |
|:-----------------------------------|----------:|---------:|----------:|----------:|----------:|------:|
| Distance \~ Moisture               | -30.36319 | 0.000000 |        NA | 0.4019903 |        NA |    NA |
| Distance \~ A1                     | -29.72347 | 0.000000 | 0.1681666 |        NA |        NA |    NA |
| Distance \~ 1                      | -28.52467 | 0.000000 |        NA |        NA |        NA |     0 |
| Distance \~ A1 + Moisture          | -28.21149 | 3.000000 | 0.0423034 | 0.2761272 |        NA |    NA |
| Distance \~ Manure                 | -25.21490 | 0.000000 |        NA |        NA | 0.3544714 |    NA |
| Distance \~ A1 + Manure            | -25.18745 | 4.000000 | 0.1209209 |        NA | 0.3072258 |    NA |
| Distance \~ Moisture + Manure      | -22.93984 | 4.000000 |        NA | 0.3005223 | 0.2530035 |    NA |
| Distance \~ A1 + Moisture + Manure | -18.59078 | 4.508169 | 0.0414517 | 0.2210532 | 0.2521518 |    NA |

If there is a block variable to be used, for example `Management` in the
`dune.env` object, you can change the above code by using the `strata`
argument:

``` r
Fitted2 <- fit_models(all_forms = AllModels,
           veg_data = dune,
           env_data = dune.env,
           ncores = 4,
           method = "bray",
           strata = "Management")
```

Which results in the following table:

| form                               |      AICc |  max_vif |        A1 |  Moisture |    Manure | Model |
|:-----------------------------------|----------:|---------:|----------:|----------:|----------:|------:|
| Distance \~ Moisture               | -30.36319 | 0.000000 |        NA | 0.4019903 |        NA |    NA |
| Distance \~ A1                     | -29.72347 | 0.000000 | 0.1681666 |        NA |        NA |    NA |
| Distance \~ 1                      | -28.52467 | 0.000000 |        NA |        NA |        NA |     0 |
| Distance \~ A1 + Moisture          | -28.21149 | 3.000000 | 0.0423034 | 0.2761272 |        NA |    NA |
| Distance \~ Manure                 | -25.21490 | 0.000000 |        NA |        NA | 0.3544714 |    NA |
| Distance \~ A1 + Manure            | -25.18745 | 4.000000 | 0.1209209 |        NA | 0.3072258 |    NA |
| Distance \~ Moisture + Manure      | -22.93984 | 4.000000 |        NA | 0.3005223 | 0.2530035 |    NA |
| Distance \~ A1 + Moisture + Manure | -18.59078 | 4.508169 | 0.0414517 | 0.2210532 | 0.2521518 |    NA |

## Selecting models

In order to select models we use the function `select_models` which will
select models with a max VIF of less than 5 and a delta AICc of less
than a parameter called delta_aicc which defaults to 2 if we use the
last model we used in the section above that would get us to:

``` r
Selected <- select_models(Fitted2)
```

which results in the following table:

| form                 |      AICc | max_vif |        A1 |  Moisture | Manure | Model | DeltaAICc |
|:---------------------|----------:|--------:|----------:|----------:|-------:|------:|----------:|
| Distance \~ Moisture | -30.36319 |       0 |        NA | 0.4019903 |     NA |    NA | 0.0000000 |
| Distance \~ A1       | -29.72347 |       0 | 0.1681666 |        NA |     NA |    NA | 0.6397207 |
| Distance \~ 1        | -28.52467 |       0 |        NA |        NA |     NA |     0 | 1.8385219 |
