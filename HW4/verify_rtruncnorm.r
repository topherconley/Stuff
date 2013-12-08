rm(list = ls())
setwd("~/myrepos/sta250/Stuff/HW4/")
source("rtruncnorm_cpu.r")
library(Rcpp)
sourceCpp("rtruncnorm_cpu.cpp")

############################################################################
#expected value of right truncation on (-Inf, b)
Eright <- function(mu, sigma, b) {
    stopifnot(is.finite(b))
    z_b <- (b - mu) / sigma 
    mu - sigma * ( dnorm(z_b) / pnorm(z_b) )
}

#expected value of left truncation on (a, Inf)
Eleft <- function(mu, sigma, a) {
    stopifnot(is.finite(a))
    z_a <- (a - mu) / sigma 
    mu + sigma * ( dnorm(z_a) / (1 -  pnorm(z_a) ) ) 
}

#expected value of two-sided truncation on (a, b)
Edouble <- function(mu, sigma, a, b) {
    z_a <- (a - mu) / sigma 
    z_b <- (b - mu) / sigma 
    numer <- dnorm(z_a) - dnorm(z_b)
    denom <- pnorm(z_b) - pnorm(z_a)
    mu + sigma * ( numer / denom )
}

#key parameters to simulation
max_tries_r <- 25L
N <- 1e4L
mu <- rep(2,N)
sd <- rep(1,N)

############################################################################
#plot the sampled output to graphically verify
#cpu
verify_rtruncnorm_cpu <- function(mu, sd, lo, hi, max_tries_r, test_type,
                                  theoretical_value, xlimits) {
    x <- rtruncnorm_cpu_rcpp(N, mu, sd, lo, hi, max_tries_r)
    #pdf(test_type)
    dx <- density(x)
    plot(density(rnorm(n = N, mean = mu, sd = sd)), type = 'l', 
         ylim = c(0, max(dx$y)),
         xlim = xlimits,
         main = test_type)
    lines(dx, col = "red")
    abline(v = theoretical_value, col = "blue", lwd = 2)
    abline(v = median(x), col = "red", lwd = 2)
    #dev.off()
}

#Set up the rcuda environment and corresponding functions
source("launch_rcuda_env.r")

#both cpu & gpu together
verify_rtruncnorm <- function(mu, sd, lo, hi, max_tries_r, test_type,
                                  theoretical_value, xlimits) {

  cpu_x <- rtruncnorm_cpu_rcpp(N, mu, sd, lo, hi, max_tries_r)
  gpu_x <- rtruncnorm_gpu(kernel, x = runif(N), N, mu, sd, lo, hi, 
                          computed_grid(N))
  
  plot_trunc <- function(x, hardware) {
    dx <- density(x)
    plot(density(rnorm(n = N, mean = mu, sd = sd)), type = 'l', 
         ylim = c(0, max(dx$y)),
         xlim = xlimits,
         main = paste(hardware, test_type))
    lines(dx, col = "red")
    abline(v = theoretical_value, col = "blue", lwd = 2)
    abline(v = median(x), col = "red", lwd = 2)
  }
  
  pdf(test_type)
  par(mfrow = c(1,2))
  #cpu
  set.seed(34)
  plot_trunc(cpu_x, "CPU")
  set.seed(34)
  plot_trunc(gpu_x, "GPU")
  dev.off()
}

############################################################################

#double truncation
lo <- rep(0,N)
hi <- rep(1.5, N)
verify_rtruncnorm(mu, sd, lo, hi, 
                  max_tries_r, "double truncation",
                  Edouble(mu[1], sd[1], lo[1], hi[1]),
                  c(-3,6))

#right truncation
lo <- rep(-Inf,N)
hi <- rep(-3,N)
verify_rtruncnorm(mu, sd, lo, hi, 
                  max_tries_r, "right truncation",
                  Eright(mu[1], sd[1], hi[1]), 
                  c(-4, 6))

#extreme right truncation
lo <- rep(-Inf,N)
hi <- rep(-7,N)
verify_rtruncnorm(mu, sd, lo, hi, 
                  max_tries_r, "extreme right truncation",
                  Eright(mu[1], sd[1], hi[1]), 
                  c(-8, -6.8))

#left truncation
lo <- rep(5,N) 
hi <- rep(Inf,N) 
verify_rtruncnorm(mu, sd, lo, hi, 
                  max_tries_r, "left truncation",
                  Eleft(mu[1], sd[1], lo[1]), 
                  c(-1.5, 6.5))

#extreme left truncation
lo <- rep(7,N) 
hi <- rep(Inf,N) 
verify_rtruncnorm(mu, sd, lo, hi, 
                  max_tries_r, "extreme left truncation",
                  Eleft(mu[1], sd[1], lo[1]), 
                  c(-1.5, 8.5))

#No truncation
lo <- rep(-Inf,N)
hi <- rep(Inf,N)
verify_rtruncnorm(mu, sd, lo, hi, 
                  max_tries_r, "no truncation",
                  Edouble(mu[1], sd[1], lo[1], hi[1]), 
                  c(-2, 6))


