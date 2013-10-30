
########################
#working directory & start clean
rm(list = ls())
setwd("~/myrepos//sta250/Stuff/HW1/BayesLogit/")
########################

#####################################
#read in #cancer data set
#parse it to meaningful
#objects in terms of {m, y, X}

data <- read.table("breast_cancer.txt", header = TRUE)#, na.strings = "?")

#check that there are no missing values, otherwise send error message
check.missing <- na.fail(data)
#this data is not in grouped format as the previous simulation
m  <- rep(1, times = dim(data)[1])
#Call malignant cases as "success" and redefine response in terms of {1,0}
y <- ifelse(data$diagnosis == "M", 1, 0)
covariate.index <- 1:10
X <- cbind(rep(1, times = dim(data)[1]), scale(as.matrix(data[,covariate.index])))
colnames(X) <- c("intercept", names(data)[covariate.index])
####################################

#################################################
# Set up the model specifications:
p <- dim(X)[2]
beta.0 <- rep(0, times = p)
Sigma.0.inv <- diag(rep(1000,p))
#################################################

##################################################
#Load the key algorithmic functions
source("BLR_metropolis_within_gibbs.R")
##################################################


######################################################################
# Fit the Bayesian model:
beta.chain <- bayes.logreg(m = m,y = y,X  = X,
                           beta.0 = beta.0, Sigma.0.inv = Sigma.0.inv,
                           niter=5e4, burnin=2e4,
                           print.every=1000, retune=500, verbose=FALSE)
#####################################################################

#save the results
#save(list = ls(), file = "real_data_output_long.rda")


#########################################################################
#diagnostics
load("real_data_output_long.rda")

######################################################################
#trace plot diagnostics

library(MCMCpack)
library(coda)
mcmc.beta.chain <- mcmc(beta.chain)
plot(mcmc.beta.chain)
effectiveSize(mcmc.beta.chain)
#acceptance rates
acc.rate <- 100*(1 - rejectionRate(mcmc.beta.chain))
acc.rate.mat <- matrix(acc.rate, nrow = 1, ncol = 11)
colnames(acc.rate.mat) <- names(acc.rate)
library(xtable)
xtable(acc.rate.mat)

#autocorrelation
autocorr.plot(mcmc.beta.chain)
#lag 1
beta.ac1 <- sapply(1:p, function(i) autocorr(mcmc.beta.chain, lags = 1)[,,i])

beta.ac1 <- as.data.frame(beta.ac)
names(beta.ac1) <- paste("beta", 1:11, sep = "")
xtable(beta.ac1)

######################################################################
#experimental: thinning the mcmc chain
thin.index <- seq(from = 1, to = 8e4, by = 5)

thin.beta.chain <- beta.chain[thin.index,]
mcmc.thin.beta.chain <- mcmc(thin.beta.chain)
autocorr.plot(mcmc.beta.chain)


######################################################################
# Extract posterior quantiles...
posterior.quantiles <- apply(beta.chain , MARGIN = 2, FUN = quantile, 
                             probs = c(0.025, 0.975))
colnames(posterior.quantiles) <- paste("beta", 1:11, sep = "")
xtable(posterior.quantiles)
######################################################################

######################################################################
#posterior predictive analysis
pdf("real_data_posterior_predictive.pdf")
beta.post.pred.mean <- post.predictive(n.pred = 5000, posterior = beta.chain, y = y, X = X, stat = mean)
beta.post.pred.sd <- post.predictive(n.pred = 5000, posterior = beta.chain, y = y, X = X, stat = sd)
par(mfrow = c(1,2))
library(RColorBrewer)
brew.col <- brewer.pal(n = 4, "RdBu")
hist(beta.post.pred.mean, 40, col = brew.col[4], main = "Mean Post. Predictive", xlab = "mean")
abline(v = mean(y), col  = brew.col[1], lwd = 4)
hist(beta.post.pred.sd, 40, col = brew.col[4], main = "Std. Dev. Post Predictive", xlab = "std. dev")
abline(v = sd(y), col  = brew.col[1], lwd = 4)
dev.off()
######################################################################

