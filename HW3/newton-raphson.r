
newtonRaphson <- function(g, gprime, xInit, epsilon, maxIter, verbose = FALSE) {
  
  #constraints on the parameters
  stopifnot(is.function(g),
            is.function(gprime),
            epsilon > 0,
            is.integer(maxIter))
  
  #small update function
  eta <- function(u, g, gprime) {
    - g(u)  / gprime (u)
  }
  
  #initalize key variables
  x <- xInit
  converged <- FALSE
  iterCount <- 0
  
  while(!converged && iterCount < maxIter) {  
    
    if (verbose == TRUE) {
      cat("iteration: ", iterCount, "\n");
      cat("root (current): ", x, "\n");
    }
    iterCount <- iterCount + 1
    
    if ( abs(g(x))< epsilon ) {
      converged <- TRUE
    }
    
    x <- x + eta(x, g, gprime) 
  }
  return(x)
}