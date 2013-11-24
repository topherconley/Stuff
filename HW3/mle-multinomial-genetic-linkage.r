
setwd("~/myrepos/sta250/Stuff/HW3/")

#genotype frequencies
countAB <- 125
countAb <- 18
countaB <- 20
countab <- 34

lambdaFunc <- function(theta) {
  1 - 2*theta + theta*theta
}

#log likelihood
logLik <- function(lambda) {
  countAB*log( 2 + lambda) + (countAb + countaB)*log (1 - lambda) + countab*log(lambda)
}

#first derivative of the log likelihood
logLikPrime <- function(lambda) {
  (countAB / (2 + lambda)) - ((countAb + countaB) / (1 - lambda)) + (countab / lambda)
}

#first derivative of the log likelihood
logLikDoublePrime <- function(lambda) {
  (-countAB / (2 + lambda)^2) - ((countAb + countaB) / (1 - lambda)^2) - (countab / lambda^2)
}


#find a good starting value for either algorithm
#0 <= theta <= 1
large.lambda <- lambdaFunc(0)
small.lambda <- lambdaFunc(1)
support <- seq(from = 0, to = 1, length = 1000)
plot(support, lambdaFunc(support), type = 'l')

#numerical accuracy
epsilon <- 1e-10
maxIter <- as.integer(1e5)

source("bisection.r")
lambdaBisection <- bisection(a = small.lambda, b = large.lambda, 
                             g = logLikPrime, epsilon = epsilon,
                             maxIter = maxIter)
lambdaBisection

source("newton-raphson.r")
lambdaNR <- newtonRaphson(g = logLikPrime, gprime  = logLikDoublePrime, 
                          xInit = 0.5, epsilon = epsilon, maxIter)
lambdaNR
