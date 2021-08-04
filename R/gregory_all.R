#' gregory_all
#'
#' This function runs the Generalized Regression Operating on Resolutions of Y estimator, also know as GREGORY, on a set of data.
#' @param plot_df A data frame containing the response variable, predictors, estimation unit, and resolution unit for each "plot"
#' @param resolution A character specifying the resolution column name within the other dataframes
#' @param estimation A character specifying the estimation column name within the other dataframes
#' @param pixel_estimation_means A dataframe with a column for the estimation unit and a column for the mean response variable value per that estimation unit
#' @param proportions A dataframe with three columns: one for resolution, one for estimation, and one for the proportion of a resolution area found in each estimation area
#' @param formula Formula to be used for the model, names should be consistent with the column names in plot_df and pixel_estimation_means
#' @param prop A character specifying the column name of the proportion found in proportions
#' @keywords forest
#' @importFrom  magrittr %>%
#' @export
#' @example R/examples/gregory_all_example.R
#' @return A dataframe with each row representing each estimation unit and its estimate.

  
gregory_all <- function(
  plot_df, #all plot data (totaldata)
  resolution, #character, name of resolution in dfs
  estimation, #character, name of estimation in dfs
  pixel_estimation_means, #means of predictors per plot df
  proportions, #estimation resolution prop df
  formula, #formula for model
  prop #character, name of percent
){
  
  #error messages
  #first, check classes
  
  if(!is.data.frame(plot_df)) {
    stop("plot_df needs a data.frame object. 
         You have provided a ", class(plot_df), " object.")
  }
  
  if(!is.character(resolution)) {
    stop("resolution needs a character object. 
         You have provided a ", class(resolution), " object.")
  }
  
  if(!is.character(estimation)) {
    stop("estimation needs a character object. 
         You have provided a ", class(estimation), " object.")
  }
  
  if(!is.data.frame(pixel_estimation_means)) {
    stop("pixel_estimation_means needs a data.frame object. 
         You have provided a ", class(pixel_estimation_means), " object.")
  }
  
  if(!is.data.frame(proportions)) {
    stop("proportions needs a data.frame object. 
         You have provided a ", class(proportions), " object.")
  }
  
  if(class(y ~ x) != class(formula)) {
    stop("formula needs a formula object. 
         You have provided a ", class(formula), " object.")
  }
  
  if(!is.character(prop)) {
    stop("prop needs a character object. 
         You have provided a ", class(prop), " object.")
  }
  
  #others
  
  if(resolution == estimation) {
    stop("resolution and estimation should be different. Do you mean to use GREG?")
  }
  
  #plot_df errors
  #make sure it has stuff
  
  if(!(resolution %in% names(plot_df))) {
    stop("resolution must be a column within plot_df.")
  }
  
  if(!(estimation %in% names(plot_df))) {
    stop("estimation must be a column within plot_df.")
  }
  
  #pixel_estimation_means errors
  #make sure it has stuff
  
  if(!(estimation %in% names(pixel_estimation_means))) {
    stop("estimation must be a column within pixel_estimation_means.")
  }
  
  #proportions errors
  
  if(!(resolution %in% names(proportions))) {
    stop("resolution must be a column within proportions.")
  }
  
  if(!(estimation %in% names(proportions))) {
    stop("estimation must be a column within proportions.")
  }
  
  if(!(prop %in% names(proportions))) {
    stop("prop must be a column within proportions.")
  }
  
  #NA errors
  
  if(any(is.na(plot_df))) {
    stop("plot_df has NA values")
  }
  
  if(any(is.na(pixel_estimation_means))) {
    stop("pixel_estimation_means has NA values")
  }
  
  if(any(is.na(proportions))) {
    stop("proportions has NA values")
  }
  
  #i want to get betas for every province
  #so first make a list of the provinces
  
  provinces <- proportions %>%
    dplyr::select(.data[[resolution]]) %>%
    dplyr::pull() %>%
    unique()
  
  #get betas for each province
  
  betas <- provinces %>%
    purrr::map_dfr(.f = function(.){
      
      #this is to avoid weird bug
      period_two <- .
      
      x_sample_filtered <- plot_df %>%
        dplyr::filter(.data[[resolution]] == period_two)
      
      
      model <- stats::lm(formula,
                  data = x_sample_filtered)
      
      result <- data.frame(resolution = .,
                           variable = names(model$coefficients),
                           beta = unname(model$coefficients))
      
      result[is.na(result)] <- 0
      
      names(result)[[1]] <- resolution
      
      return(result)
      
    })
  
  #now let's get those predictors
  
  predictors <- betas  %>%
    dplyr::select(variable) %>%
    dplyr::pull() %>%
    unique()
  
  predictors <- predictors[!predictors %in% "(Intercept)"]
  
  #now let's get the weighted betas
  
  weighted_beta_df <- dplyr::left_join(proportions, betas, by = resolution) %>%
    dplyr::mutate(weighted_beta = beta * .data[[prop]]) %>%
    dplyr::select(.data[[estimation]],
                  .data[[resolution]],
                  variable,
                  weighted_beta)
  
  
  #now lets pivot the n means(maybe ask for this as input?)
  
  
  N_df <- dplyr::select(pixel_estimation_means,
                        c(estimation, predictors))
  
  N_df <- tidyr::pivot_longer(N_df, !.data[[estimation]],
                              names_to = "variable",
                              values_to = "mean_N")
  
  #now combine with betas
  
  term_df <- dplyr::left_join(weighted_beta_df, N_df, by = c(estimation, "variable"))
  
  #now let's get the N means
  
  n_df <- plot_df %>%
    dplyr::group_by(.data[[estimation]]) %>%
    dplyr::summarize(across(predictors, mean), .groups = 'drop') %>%
    tidyr::pivot_longer(!.data[[estimation]],
                        names_to = "variable",
                        values_to = "mean_n")
  
  #then join N to the term_df
  
  term_df <- dplyr::left_join(term_df, n_df, by = c(estimation, "variable"))
  
  #replace na's from join (intercept) with 1's
  
  term_df$mean_n[is.na(term_df$mean_n)] <- 1
  term_df$mean_N[is.na(term_df$mean_N)] <- 1
  
  term_df <- term_df %>%
    dplyr::mutate(term_n = weighted_beta * mean_n,
                  term_N = weighted_beta * mean_N) %>%
    dplyr::group_by(.data[[estimation]]) %>%
    dplyr::summarize(term_n = sum(term_n),
                     term_N = sum(term_N), .groups = 'drop') %>%
    dplyr::mutate(term = term_N - term_n) %>%
    dplyr::select(.data[[estimation]], term)
  
  #get Y var
  
  y <- all.vars(formula)[1]
  
  #get y_bars
  
  y_bar_df <- plot_df %>%
    dplyr::group_by(.data[[estimation]]) %>%
    dplyr::summarize(y_bar = mean(.data[[y]]), .groups = 'drop')
  
  #join with the rest and get the final result
  
  result <- dplyr::left_join(term_df, y_bar_df, by = estimation) %>%
    dplyr::mutate(estimate = y_bar + term) %>%
    dplyr::select(.data[[estimation]], estimate)
  
  return(result)
  
}