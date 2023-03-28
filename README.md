
<!-- README.md is generated from README.Rmd. Please edit that file -->

# AICcPerm

<!-- badges: start -->

[![R-CMD-check](https://github.com/Sustainscapes/AICcPerm/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Sustainscapes/AICcPerm/actions/workflows/R-CMD-check.yaml)
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
library(AICcPerm)
AllModels <- make_models(vars = c("pH", "Sand", "Clay"), ncores = 2, Distance = "JaccardDistance")
```

This will give you the following table:

| form                                | AICc | max_vif |
|:------------------------------------|:-----|:--------|
| JaccardDistance \~ pH               | NA   | NA      |
| JaccardDistance \~ Sand             | NA   | NA      |
| JaccardDistance \~ Clay             | NA   | NA      |
| JaccardDistance \~ pH + Sand        | NA   | NA      |
| JaccardDistance \~ pH + Clay        | NA   | NA      |
| JaccardDistance \~ Sand + Clay      | NA   | NA      |
| JaccardDistance \~ pH + Sand + Clay | NA   | NA      |
| JaccardDistance \~ 1                | NA   | NA      |

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
