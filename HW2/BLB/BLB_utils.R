
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

plot_blb_se <- function(result_file = "final/blb_lin_reg_data_s5_r50_SE.txt") {
  blb_se <- read.table(file = result_file, header = TRUE)
  #par(cex = 0.5)
  plot(blb_se[,1], pch = 19, cex = 0.65, 
       main = "Bag of Little Bootstraps: Linear Model Standard Errors",
       ylab = "standard errors (beta)",
       xlab = "Index of beta")
  sm <- smooth.spline(x = seq_along(blb_se[,1]), blb_se[,1])
  lines(sm$x, sm$y, col = "blue", lwd = 5)
  abline(h = 0.01, col = "red", lwd = 3)
}
#pdf("blb_lin_reg_se.pdf")
#plot_blb_se()
#dev.off()
