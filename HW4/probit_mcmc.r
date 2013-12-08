library(Rcpp)
sourceCpp("rtruncnorm_cpu.cpp")

probit_mcmc <- function(
  y,           # vector of length n 
  X,           # (n x p) design matrix
  beta_0,      # (p x 1) prior mean
  Sigma_0_inv, # (p x p) prior precision 
  niter,       # number of post burnin iterations
  burnin,      # number of burnin iterations
  GPU)         # logical: use the GPU for Z sampling
{

  if (GPU) {
    source("launch_rcuda_env.r")
    block_grid_dims <- computed_grid(N)
  }
  
  library(mvtnorm)
  library(coda)
  #############
  #initialize
  #############
  N <- length(y)
  p <- length(beta_0)
  #storage
  beta <- matrix(nrow = niter + burnin, ncol = p)
  beta[1,] <- beta_0;
  sigma_z <- rep(1, times = N)
  z <- rnorm(N, mean = X %*% beta_0, sd = sigma_z)
  y_equals_zero <- y == 0
  lo <- ifelse(y_equals_zero, -Inf, 0)
  hi <- ifelse(y_equals_zero, 0, Inf)  
  Sigma_beta_inv <- t(X) %*% X + Sigma_0_inv
  Sigma_beta <- solve(Sigma_beta_inv)

  #gibbs sampler: sample from full conditionals 
  for(t in seq_len(niter + burnin - 1)) {
    mu_z.t <- X %*% beta[t,]  
    if (GPU) {
      z <- rtruncnorm_gpu(kernel, x = runif(N), N, mu, sd, lo, hi, 
                          block_grid_dims)
    } else {
      z <- rtruncnorm_cpu_rcpp(N, mu_z.t, sigma_z, lo, hi, 25) 
    }
    mu_beta <- Sigma_beta %*% (Sigma_0_inv%*%beta_0 + colSums(X*z) )
    beta[t + 1,] <- rmvnorm(1, mean = mu_beta, sigma =  Sigma_beta)
  }
  
  #return the betas
  mcmc(data = beta[(burnin + 1):niter,])
}

# convenience wrapper function for multiple runs of different data chunks
# for this homework assigment.
run_mcmc <- function(data, niter, burnin, GPU) {
  # number of variables
  p <- dim(data)[2]  - 1
  #run the mcmc
  probit_mcmc(y = data$y, X = as.matrix(data[,2:dim(data)[2]]), 
              beta_0 = rep(0, p), Sigma_0_inv = matrix(0,p,p),
              niter, burnin, GPU = FALSE)    
}

validate_mcmc <- function(mcmc_obj, par_file, plot.trace = FALSE) {
  library(coda)
  library(xtable)
  #estimates
  post.beta <- colMeans(mcmc_obj)
  true.beta <- read.table(par_file, header = TRUE)[,1]
  if (plot.trace) {
    pdf(paste0(par_file,".pdf"))
    plot(as.mcmc(mcmc_obj))
    dev.off()  
  }
  
  mat <- as.matrix(mcmc_obj)
  posterior.quantiles <- apply( mat, MARGIN = 2, FUN = quantile, 
                                probs = c(0.01, 0.99))
  xtable(rbind(posterior.quantiles, post.beta, true.beta))
}
