
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this.  -->

# gregRy

<!-- badges: start -->

<!-- badges: end -->

The goal of `gregRy` is to make the GREGORY estimator easily available
to use.

## Installation

The development version of `gregRy` is available from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("olekwojcik/gregRy")
```

## Example Computations

The package `gregRy` does not contain a dataset, which is why our
example utilizes the package
[pdxTrees](https://github.com/mcconvil/pdxTrees)

### GREGORY

``` r
library(gregRy)
#load and wrangle data

# Overall dataset to create estimates with
# Includes response variable and predictors

dat <- get_pdxTrees_parks() %>%
  as.data.frame() %>%
  drop_na(DBH, Crown_Width_NS, Tree_Height) %>%
  filter(Condition != "Dead") %>%
  select(UserID, Tree_Height, Crown_Width_NS, DBH, Condition, Family)

dat_est <- dat %>%
  filter(Family == "Pinaceae")
predictors <- c("Crown_Width_NS", "DBH")

dat_x_bar <- dat %>%
  dplyr::group_by(Family) %>%
  dplyr::summarize(dplyr::across(predictors,
                                mean)) %>%
  tidyr::pivot_longer(!Family,
                            names_to = "variable",
                            values_to = "mean")
dat_count_est <- dat %>%
  group_by(Family) %>%
  summarize(count = n())

# Create dataset of proportions using estimation and resolution

dat_prop <- left_join(dat, dat_count_est, by = "Family") %>%
  group_by(Condition, Family) %>%
  summarize(prop = n()/count) %>%
  distinct() %>%
  ungroup()

# Create dataset of means of 'pixel' data

dat_x_means <- get_pdxTrees_parks() %>%
  as.data.frame() %>%
  drop_na(DBH, Crown_Width_NS, Tree_Height) %>%
  dplyr::summarize(DBH = mean(DBH), Crown_Width_NS = mean(Crown_Width_NS),
            Tree_Height = mean(Tree_Height))

dat_x_bar_new <- dat_x_bar %>%
  filter(variable == "Crown_Width_NS") %>%
  mutate(Crown_Width_NS = mean) %>%
  select(Family, Crown_Width_NS)
```

To use GREGORY, we need 3 different datasets.

The first dataset is the overall data:

``` r
print(head(dat))
#>   UserID Tree_Height Crown_Width_NS  DBH Condition   Family
#> 1      1         105             44 37.4      Fair Pinaceae
#> 2      2          94             49 32.5      Fair Pinaceae
#> 3      3          23             28  9.7      Fair Rosaceae
#> 4      4          28             38 10.3      Poor Fagaceae
#> 5      5         102             43 33.2      Fair Pinaceae
#> 6      6          95             35 32.1      Fair Pinaceae
```

The second dataset is the means of the predictors at the estimation
level (Family estimates):

``` r
print(head(dat_x_bar_new))
#> Warning: `...` is not empty.
#> 
#> We detected these problematic arguments:
#> * `needs_dots`
#> 
#> These dots only exist to allow future extensions and should be empty.
#> Did you misspecify an argument?
#> # A tibble: 6 x 2
#>   Family        Crown_Width_NS
#>   <chr>                  <dbl>
#> 1 Adoxaceae              20   
#> 2 Altingiaceae           40.6 
#> 3 Anacardiaceae          19.2 
#> 4 Aquifoliaceae          14.9 
#> 5 Araliaceae              9   
#> 6 Arecaceae               9.67
```

The third dataset is contains both the resolution and estimation, with
the proportion of resolution in the given estimation unit:

``` r
print(head(dat_prop))
#> Warning: `...` is not empty.
#> 
#> We detected these problematic arguments:
#> * `needs_dots`
#> 
#> These dots only exist to allow future extensions and should be empty.
#> Did you misspecify an argument?
#> # A tibble: 6 x 3
#>   Condition Family         prop
#>   <chr>     <chr>         <dbl>
#> 1 Fair      Adoxaceae     1    
#> 2 Fair      Altingiaceae  0.907
#> 3 Fair      Anacardiaceae 0.75 
#> 4 Fair      Aquifoliaceae 0.875
#> 5 Fair      Araliaceae    1    
#> 6 Fair      Arecaceae     1
```

``` r
# Create GREGORY estimates
x1 <- gregory_all(plot_df = dat %>% drop_na(),
            resolution = "Condition",
            estimation = "Family",
            pixel_estimation_means = dat_x_bar_new,
            proportions = dat_prop,
            formula = Tree_Height ~ Crown_Width_NS,
            prop = "prop")
```

``` r
hist(x1$estimate, main = "GREGORY estimates of Tree Height using Crown Width as a Predictor", xlab = "Estimate")
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

### GREG
