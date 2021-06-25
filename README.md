
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this.  -->

# Insert Package Name

<!-- badges: start -->

<!-- badges: end -->

The goal of `gregRy` is to make the GREGORY estimator easily available
to use.

    #> Warning: package 'pdxTrees' was built under R version 4.0.5

## Installation

The development version of `gregRy` is available from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("olekwojcik/gregRy")
```

## About the data

The package `gregRy` does not contain a dataset, which is why our
example utilizes the package [pdxTrees]()

## Example Computations

### GREGORY

    #> Note: Using an external vector in selections is ambiguous.
    #> i Use `all_of(predictors)` instead of `predictors` to silence this message.
    #> i See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
    #> This message is displayed once per session.
    #> `summarise()` ungrouping output (override with `.groups` argument)
    #> `summarise()` ungrouping output (override with `.groups` argument)
    #> `summarise()` regrouping output by 'Condition', 'Family' (override with `.groups` argument)

``` r
gregory_all(plot_df = dat %>% drop_na(),
            resolution = "Condition",
            estimation = "Family",
            pixel_estimation_means = dat_x_bar_new,
            proportions = dat_prop,
            formula = Tree_Height ~ Crown_Width_NS,
            prop = "prop")
#> Warning: `...` is not empty.
#> 
#> We detected these problematic arguments:
#> * `needs_dots`
#> 
#> These dots only exist to allow future extensions and should be empty.
#> Did you misspecify an argument?
#> # A tibble: 51 x 2
#>    Family         estimate
#>    <chr>             <dbl>
#>  1 Adoxaceae          30  
#>  2 Altingiaceae       67.5
#>  3 Anacardiaceae      19.2
#>  4 Aquifoliaceae      24.5
#>  5 Araliaceae         10  
#>  6 Arecaceae          22  
#>  7 Betulaceae         44.5
#>  8 Bignoniaceae       45.5
#>  9 Cannabaceae        39.4
#> 10 Caprifoliaceae     19  
#> # ... with 41 more rows
```

### GREG
