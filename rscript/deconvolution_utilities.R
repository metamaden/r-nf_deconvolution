#!/usr/bin/env R

# Author: Sean Maden
#
# Main utilities and functions for deconvolution operations.
#

bias <- function(true.proportions, pred.proportions){
  true.proportions - pred.proportions
}

rmse_types <- function(true.proportions, pred.proportions){
  error <- bias(true.proportions, pred.proportions)
  rmse <- sqrt(mean(error)^2)
  return(rmse)
}

predict_proportions <- function(Z, Y, strict.method = "nnls", 
                                method.args = "", verbose = FALSE){
  # predict_proportions
  #
  # Z : signature matrix
  # Y : bulk matrix
  # strict_method : deconvolution method
  # method.args : additional method arguments
  # verbose : whether to show verbose messages
  #
  if(verbose){message("getting cell type proportion predictions...")}
  
  # format string arguments
  cond <- method.args %in% c("", "NA")|is.na(method.args)
  if(!cond){
    method.args <- paste0(",",method.args)
  } else{
    method.args <- ""
  }
  method <- tolower(strict.method)
  
  # parse methods
  if(method == "nnls"){
    if(verbose){message("using method nnls...")}
    command.string <- paste0("nnls::nnls(Z, Y",method.args,")$x")
  } else if(method == "music"){
    if(verbose){message("using method MuSiC...")}
    if(method.args == ""){
      if(verbose){message("getting mean library sizes by type...")}
      S <- unlist(lapply(unique.celltypes, function(ci){
        mean(colSums(mexpr[,cd[,celltype.variable]==ci]))
      }))
      if(verbose){message("setting variances by gene...")}
      Sigma <- matrix(0, ncol = 1, nrow = nrow(Z))
      method.args <- ",S = S, Sigma = Sigma, nu = 1e-10, iter.max = 100, eps = 0"
    }
    command.string <- paste0("music.basic(Y = Y, X = Z",method.args,")$p.weight")
  } else{
    if(verbose){message("Returning unmodified point prediction outputs.")}
  }
  
  # get proportion predictions
  p <- eval(parse(text = command.string))
  if(verbose){message("completed proportion predictions.")}
  return(p)
}

