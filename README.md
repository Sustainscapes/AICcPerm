
<!-- README.md is generated from README.Rmd. Please edit that file -->

# AICcPermanova

<!-- badges: start -->

[![R-CMD-check](https://github.com/Sustainscapes/AICcPerm/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Sustainscapes/AICcPerm/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/AICcPermanova)](https://CRAN.R-project.org/package=AICcPermanova)
[![Codecov test
coverage](https://codecov.io/gh/Sustainscapes/AICcPerm/branch/master/graph/badge.svg)](https://app.codecov.io/gh/Sustainscapes/AICcPerm?branch=master)
<!-- badges: end -->

The aim of the AICcPerm repository is to provide an R package that
enables model selection for Permanovas from the vegan package. To
install this package, you can use the remotes package to install its
development version:

``` r
remotes::install_github("Sustainscapes/AICcPerm")
```

Alternatively, you can install the stable version from CRAN:

``` r
install.packages("AICcPermanova")
```

## Generating all possible models

To generate all possible models, you can use the `make_models` function.
For example:

``` r
library(AICcPermanova)
AllModels <- make_models(vars = c("pH", "Sand", "Clay"), ncores = 2)
```

This function will create a table of all possible models for the
specified variables, which you can see in the following table:

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

Where you can see all possible models for those 3 variables.

## Calculating AICc

To calculate AICc, you can use the AICc_permanova2 function. Here’s an
example of how to use it:

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

The results of this calculation are displayed in the following table:

``` r
knitr::kable(Table_permanova)
```

|      AICc |   k |   N |
|----------:|----:|----:|
| -19.06395 |   8 |  20 |

In this example, we used the adonis2 function to run a PERMANOVA
analysis on the dune dataset with the Management and A1 variables. We
then calculated AICc using the AICc_permanova2 function

## Full example

In this section, we’ll provide a complete example of the AICcPerm
package workflow. First, we need to load datasets from the vegan
package:

``` r
library(vegan)
data(dune)
data(dune.env)
```

Next, we’ll generate all possible first-order models for this dataset:

``` r
AllModels <- make_models(vars = c("A1", "Moisture", "Management", "Use", "Manure"))
#> 1 of 5 ready 2023-04-10 07:03:32
#> 2 of 5 ready 2023-04-10 07:03:38
#> 3 of 5 ready 2023-04-10 07:03:45
#> 4 of 5 ready 2023-04-10 07:03:52
#> 5 of 5 ready 2023-04-10 07:03:55
```

This results in 32 possible models, which are shown in the following
table:

| form                                                  |
|:------------------------------------------------------|
| Distance \~ A1                                        |
| Distance \~ Moisture                                  |
| Distance \~ Management                                |
| Distance \~ Use                                       |
| Distance \~ Manure                                    |
| Distance \~ A1 + Moisture                             |
| Distance \~ A1 + Management                           |
| Distance \~ A1 + Use                                  |
| Distance \~ A1 + Manure                               |
| Distance \~ Moisture + Management                     |
| Distance \~ Moisture + Use                            |
| Distance \~ Moisture + Manure                         |
| Distance \~ Management + Use                          |
| Distance \~ Management + Manure                       |
| Distance \~ Use + Manure                              |
| Distance \~ A1 + Moisture + Management                |
| Distance \~ A1 + Moisture + Use                       |
| Distance \~ A1 + Moisture + Manure                    |
| Distance \~ A1 + Management + Use                     |
| Distance \~ A1 + Management + Manure                  |
| Distance \~ A1 + Use + Manure                         |
| Distance \~ Moisture + Management + Use               |
| Distance \~ Moisture + Management + Manure            |
| Distance \~ Moisture + Use + Manure                   |
| Distance \~ Management + Use + Manure                 |
| Distance \~ A1 + Moisture + Management + Use          |
| Distance \~ A1 + Moisture + Management + Manure       |
| Distance \~ A1 + Moisture + Use + Manure              |
| Distance \~ A1 + Management + Use + Manure            |
| Distance \~ Moisture + Management + Use + Manure      |
| Distance \~ A1 + Moisture + Management + Use + Manure |
| Distance \~ 1                                         |

### Avoiding multicollinearity

After generating all the models, it’s important to check for
multicollinearity. We can use the `filter_vif` function to filter out
models that have a high degree of collinearity (defined as having a
maximum value of VIF of 5 or more):

``` r
NonColinear <- filter_vif(all_forms = AllModels, env_data = dune.env)
```

This reduces the number of models to 21

### Fittng the models

After filtering out collinear models, we can fit all the remaining
non-collinear models by using the `fit_models` function:

``` r
Fitted <- fit_models(all_forms = NonColinear,
           veg_data = dune,
           env_data = dune.env,
           ncores = 4,
           method = "bray")
```

This results in a table of fitted models ordered by AICc, which is
displayed below:

| form                                         |  max_vif |       AICc |   k |   N |        A1 |  Moisture | Management |       Use |    Manure | Model |
|:---------------------------------------------|---------:|-----------:|----:|----:|----------:|----------:|-----------:|----------:|----------:|------:|
| Distance \~ Moisture                         | 0.000000 | -30.363195 |   4 |  20 |        NA | 0.4019903 |         NA |        NA |        NA |    NA |
| Distance \~ A1                               | 0.000000 | -29.723474 |   2 |  20 | 0.1681666 |        NA |         NA |        NA |        NA |    NA |
| Distance \~ 1                                | 0.000000 | -28.524673 |   1 |  20 |        NA |        NA |         NA |        NA |        NA |     0 |
| Distance \~ Management                       | 0.000000 | -28.439405 |   4 |  20 |        NA |        NA |  0.3416107 |        NA |        NA |    NA |
| Distance \~ A1 + Moisture                    | 3.000000 | -28.211489 |   5 |  20 | 0.0423034 | 0.2761272 |         NA |        NA |        NA |    NA |
| Distance \~ A1 + Management                  | 3.000000 | -28.206906 |   5 |  20 | 0.1025557 |        NA |  0.2759998 |        NA |        NA |    NA |
| Distance \~ A1 + Use                         | 2.000000 | -27.243308 |   4 |  20 | 0.1723656 |        NA |         NA | 0.1328680 |        NA |    NA |
| Distance \~ Moisture + Use                   | 3.000000 | -26.706730 |   6 |  20 |        NA | 0.3850987 |         NA | 0.1117773 |        NA |    NA |
| Distance \~ Moisture + Management            | 3.000000 | -26.219635 |   7 |  20 |        NA | 0.2678801 |  0.2075005 |        NA |        NA |    NA |
| Distance \~ Use                              | 0.000000 | -26.001561 |   3 |  20 |        NA |        NA |         NA | 0.1286690 |        NA |    NA |
| Distance \~ Manure                           | 0.000000 | -25.214897 |   5 |  20 |        NA |        NA |         NA |        NA | 0.3544714 |    NA |
| Distance \~ A1 + Manure                      | 4.000000 | -25.187448 |   6 |  20 | 0.1209209 |        NA |         NA |        NA | 0.3072258 |    NA |
| Distance \~ A1 + Moisture + Use              | 3.000000 | -24.004036 |   7 |  20 | 0.0499753 | 0.2627084 |         NA | 0.1194492 |        NA |    NA |
| Distance \~ Management + Use                 | 3.000000 | -23.493146 |   6 |  20 |        NA |        NA |  0.3003444 | 0.0874027 |        NA |    NA |
| Distance \~ Moisture + Manure                | 4.000000 | -22.939843 |   8 |  20 |        NA | 0.3005223 |         NA |        NA | 0.2530035 |    NA |
| Distance \~ A1 + Moisture + Management       | 3.000000 | -22.910428 |   8 |  20 | 0.0449952 | 0.2103196 |  0.2101923 |        NA |        NA |    NA |
| Distance \~ A1 + Management + Use            | 3.000000 | -21.475776 |   7 |  20 | 0.0759437 |        NA |  0.2039225 | 0.0607907 |        NA |    NA |
| Distance \~ Use + Manure                     | 4.000000 | -19.071272 |   7 |  20 |        NA |        NA |         NA | 0.0872434 | 0.3130459 |    NA |
| Distance \~ A1 + Moisture + Manure           | 4.508169 | -18.590778 |   9 |  20 | 0.0414517 | 0.2210532 |         NA |        NA | 0.2521518 |    NA |
| Distance \~ Moisture + Management + Use      | 3.648562 | -15.655183 |   9 |  20 |        NA | 0.2194405 |  0.1346862 | 0.0389631 |        NA |    NA |
| Distance \~ A1 + Moisture + Management + Use | 4.710040 |  -8.837299 |  10 |  20 | 0.0274588 | 0.1709557 |  0.1121697 | 0.0214267 |        NA |    NA |

If there is a block variable to be used (such as Use in the dune.env
object), you can specify it using the strata argument:

``` r
Fitted2 <- fit_models(all_forms = NonColinear,
           veg_data = dune,
           env_data = dune.env,
           ncores = 4,
           method = "bray",
           strata = "Use")
```

This results in a table of fitted models that takes into account the
block variable, which is displayed below:

| form                                         |  max_vif |       AICc |   k |   N |        A1 |  Moisture | Management |       Use |    Manure | Model |
|:---------------------------------------------|---------:|-----------:|----:|----:|----------:|----------:|-----------:|----------:|----------:|------:|
| Distance \~ Moisture                         | 0.000000 | -30.363195 |   4 |  20 |        NA | 0.4019903 |         NA |        NA |        NA |    NA |
| Distance \~ A1                               | 0.000000 | -29.723474 |   2 |  20 | 0.1681666 |        NA |         NA |        NA |        NA |    NA |
| Distance \~ 1                                | 0.000000 | -28.524673 |   1 |  20 |        NA |        NA |         NA |        NA |        NA |     0 |
| Distance \~ Management                       | 0.000000 | -28.439405 |   4 |  20 |        NA |        NA |  0.3416107 |        NA |        NA |    NA |
| Distance \~ A1 + Moisture                    | 3.000000 | -28.211489 |   5 |  20 | 0.0423034 | 0.2761272 |         NA |        NA |        NA |    NA |
| Distance \~ A1 + Management                  | 3.000000 | -28.206906 |   5 |  20 | 0.1025557 |        NA |  0.2759998 |        NA |        NA |    NA |
| Distance \~ A1 + Use                         | 2.000000 | -27.243308 |   4 |  20 | 0.1723656 |        NA |         NA | 0.1328680 |        NA |    NA |
| Distance \~ Moisture + Use                   | 3.000000 | -26.706730 |   6 |  20 |        NA | 0.3850987 |         NA | 0.1117773 |        NA |    NA |
| Distance \~ Moisture + Management            | 3.000000 | -26.219635 |   7 |  20 |        NA | 0.2678801 |  0.2075005 |        NA |        NA |    NA |
| Distance \~ Use                              | 0.000000 | -26.001561 |   3 |  20 |        NA |        NA |         NA | 0.1286690 |        NA |    NA |
| Distance \~ Manure                           | 0.000000 | -25.214897 |   5 |  20 |        NA |        NA |         NA |        NA | 0.3544714 |    NA |
| Distance \~ A1 + Manure                      | 4.000000 | -25.187448 |   6 |  20 | 0.1209209 |        NA |         NA |        NA | 0.3072258 |    NA |
| Distance \~ A1 + Moisture + Use              | 3.000000 | -24.004036 |   7 |  20 | 0.0499753 | 0.2627084 |         NA | 0.1194492 |        NA |    NA |
| Distance \~ Management + Use                 | 3.000000 | -23.493146 |   6 |  20 |        NA |        NA |  0.3003444 | 0.0874027 |        NA |    NA |
| Distance \~ Moisture + Manure                | 4.000000 | -22.939843 |   8 |  20 |        NA | 0.3005223 |         NA |        NA | 0.2530035 |    NA |
| Distance \~ A1 + Moisture + Management       | 3.000000 | -22.910428 |   8 |  20 | 0.0449952 | 0.2103196 |  0.2101923 |        NA |        NA |    NA |
| Distance \~ A1 + Management + Use            | 3.000000 | -21.475776 |   7 |  20 | 0.0759437 |        NA |  0.2039225 | 0.0607907 |        NA |    NA |
| Distance \~ Use + Manure                     | 4.000000 | -19.071272 |   7 |  20 |        NA |        NA |         NA | 0.0872434 | 0.3130459 |    NA |
| Distance \~ A1 + Moisture + Manure           | 4.508169 | -18.590778 |   9 |  20 | 0.0414517 | 0.2210532 |         NA |        NA | 0.2521518 |    NA |
| Distance \~ Moisture + Management + Use      | 3.648562 | -15.655183 |   9 |  20 |        NA | 0.2194405 |  0.1346862 | 0.0389631 |        NA |    NA |
| Distance \~ A1 + Moisture + Management + Use | 4.710040 |  -8.837299 |  10 |  20 | 0.0274588 | 0.1709557 |  0.1121697 | 0.0214267 |        NA |    NA |

## Model Selection

To select models, we use the select_models function, which chooses
models with a maximum VIF of less than 5 and a delta AICc less than a
specified threshold, delta_aicc. By default, delta_aicc is set to 2.

We can use the Fitted2 object generated in the previous section to
select models:

``` r
Selected <- select_models(Fitted2)
```

The resulting table displays the selected models:

| form                   | max_vif |      AICc |   k |   N |        A1 |  Moisture | Management | Model | DeltaAICc | AICWeight |
|:-----------------------|--------:|----------:|----:|----:|----------:|----------:|-----------:|------:|----------:|----------:|
| Distance \~ Moisture   |       0 | -30.36319 |   4 |  20 |        NA | 0.4019903 |         NA |    NA | 0.0000000 | 0.3988462 |
| Distance \~ A1         |       0 | -29.72347 |   2 |  20 | 0.1681666 |        NA |         NA |    NA | 0.6397207 | 0.2896622 |
| Distance \~ 1          |       0 | -28.52467 |   1 |  20 |        NA |        NA |         NA |     0 | 1.8385219 | 0.1590653 |
| Distance \~ Management |       0 | -28.43941 |   4 |  20 |        NA |        NA |  0.3416107 |    NA | 1.9237896 | 0.1524263 |

Note that the models in the table satisfy the criteria for maximum VIF
and delta AICc as specified in the `select_models` function.

### Summary weighted by AICc

finally you can do a summarized r squared weighted by AICc using the
`akaike_adjusted_rsq` function as seen bellow:

``` r
Summary <- akaike_adjusted_rsq(Selected)
```

which results in the following table:

| Variable   | Full_Akaike_Adjusted_RSq |
|:-----------|-------------------------:|
| A1         |                0.0487115 |
| Moisture   |                0.1603323 |
| Management |                       NA |
