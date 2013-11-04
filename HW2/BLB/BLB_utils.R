
###############################################################################
#'@title BLB indexer
#'@description index S subsets and R replications from S*R boostrap procedures
#'@return A vector (s,r) of the index s in 1,..., S, and r in 1,...,R.
#'@examples
#'#see that it works
#'sapply(1:250, function(i) sr_index(i, S, R))
sr_index <- function(jobnum, S, R) {

  #error
  if( jobnum > S*R) {
    stop("job number greater than largest possible index")
  }
  
  #delimiter of the S subsets
  SR <- S*R
  s_delim <- seq(from = R, to = SR, by = SR / S) + 1
  #offset of R replications
  r_offset <- seq(from = 0, to = SR - R, by = R)
  
  s <- which(jobnum< s_delim)[1]
  r <- jobnum - r_offset[s]
  c(s,r)
}

