

bisection <- function(a, b, g, epsilon, maxIter, verbose = FALSE) {
  
  #constraints on the paramters
  stopifnot(g(a) * g(b) < 0, 
            a < b,
            epsilon > 0, 
            is.function(g),
            is.integer(maxIter))
  
  #initialize
  lower <- a
  upper <- b
  converged <- FALSE
  iterCount <- 0 
  
  while (!converged && iterCount < maxIter) {
    
    
    if (verbose == TRUE) {
      cat("iteration: ", iterCount, "\n");
      cat("root (current): ", center, "\n");
    }
    
    iterCount <- iterCount + 1
    center <- (lower + upper) / 2
    if ( abs(g(center)) < epsilon) {
      converged <- TRUE
    } else {
      if ( g(lower) * g(center) < 0) {
        upper <- center
      } else {
        #g(center) * g(upper) < 0
        lower <- center
      }
    }
  }
  return(center)
}


