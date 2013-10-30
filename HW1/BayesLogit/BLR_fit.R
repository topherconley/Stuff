
##
#
# Logistic regression
# 
# Y_{i} | \beta \sim \textrm{Bin}\left(n_{i},e^{x_{i}^{T}\beta}/(1+e^{x_{i}^{T}\beta})\right)
# \beta \sim N\left(\beta_{0},\Sigma_{0}\right)
#
##

library(mvtnorm)
library(coda)

########################################################################################
########################################################################################
## Handle batch job arguments:

# 1-indexed version is used now.
args <- commandArgs(TRUE)

cat(paste0("Command-line arguments:\n"))
print(args)

####
# sim_start ==> Lowest simulation number to be analyzed by this particular batch job
###

#######################
sim_start <- 1000
length.datasets <- 200
#######################

if (length(args)==0){
  sinkit <- FALSE
  sim_num <- sim_start + 46
  set.seed(1330931)
} else {
  # Sink output to file?
  sinkit <- TRUE
  # Decide on the job number, usually start at 1000:
  sim_num <- sim_start + as.numeric(args[1])
  # Set a different random seed for every job number!!!
  set.seed(762*sim_num + 1330931)
}

# Simulation datasets numbered 1001-1200

########################################################################################
########################################################################################

#The core Metropolis within Gibbs algorithm is written in this file
source("BLR_metropolis_within_gibbs.R")
#################################################
# Set up the specifications:
beta.0 <- c(0,0)
p <- 2
Sigma.0.inv <- diag(rep(1.0,p))
# etc... (more needed here)
#################################################

# Read data corresponding to appropriate sim_num:
sim_data_file <- paste("data/blr_data_", sim_num, ".csv", sep = "")
data <- read.csv(file = sim_data_file)

# Extract X and y:
m <- data$n
y <- data$y
X <- as.matrix(data[,3:4])

# Fit the Bayesian model:
beta.chain <- bayes.logreg(m = m,y = y,X  = X,
                           beta.0 = beta.0, Sigma.0.inv = Sigma.0.inv,
                           niter=20000, burnin=5000,
                           print.every=1000, retune=100, verbose=FALSE)

# Extract posterior quantiles...
posterior.quantiles <- apply(beta.chain , MARGIN = 2, FUN = quantile, 
                             probs = seq(from = 0.01, to = 0.99, by = 0.01))
posterior.quantiles
# Write results to a (99 x p) csv file...
result_data_file <- paste("results/blr_res_", sim_num, ".csv", sep = "")
write.table(x = as.data.frame(posterior.quantiles), file = result_data_file, 
            row.names=FALSE, col.names=FALSE, sep=",")
# Go celebrate.

cat("done. :)\n")
#

#diagnostics
#library(MCMCpack)
#mcmc.beta.chain <- mcmc(beta.chain)
#plot(mcmc.beta.chain)
#
autocorr.plot(mcmc.beta.chain)

acf(mcmc.beta.chain)

