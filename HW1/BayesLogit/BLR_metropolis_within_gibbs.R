

log.posterior <- function(mu.0, Sigma.0.inv, beta, y, m, X) {  
  #key functions
  log.prior <- function(mu.0, Sigma.0.inv, beta) {
    log( dmvnorm(x = beta, mean = mu.0, sigma = Sigma.0.inv) )
  }
  
  log.lik <- function(beta, y, m, X) {
    expit <- function(x, beta) {
      eEta <- exp( x %*% beta) 
      eEta / (1 + eEta)
    }
    sum( log( dbinom(x = y, size = m, prob = expit(X,beta)) ) )
  }
  log.prior(mu.0, Sigma.0.inv, beta) + log.lik(beta, y, m, X)
}


proposal <- function(theta.t, sd.tune) {
  rnorm(n = 1, mean = theta.t, sd = sd.tune)
}


check.proposal.var <-function(n.accept, n.iter.block , psd, 
                              verbose) {
  stopifnot(length(psd) == length(n.accept))
  if (verbose) {
    print("------------Retuned Parameters------------")
    print("Original:")
    print(psd)  
  }
  
  for (k in seq_along(psd)) {
    arate <- n.accept[k]/n.iter.block
    if (verbose) {
      print("Current Acceptance Rate:")
      print(arate)  
    }
    
    if (arate < 0.1) {
      psd[k] <- psd[k]*0.25
    } else if (0.1 <= arate & arate < 0.3) {
      psd[k] <- psd[k]*0.5
    } else if (0.6 < arate & arate <= 0.9) {
      psd[k] <- psd[k]*2
    } else if (arate > 0.9) {
      psd[k] <- psd[k]*4
    } else{
      #no retuning necessary for kth proposal variance
    }
  }
  if (verbose){
    print("Retuned:")
    print(psd)  
  }
  return(psd)
}

"bayes.logreg" <- function(m,y,X,beta.0,Sigma.0.inv,
                           niter=10000,burnin=1000,
                           print.every=1000,retune=100,
                           verbose=TRUE){
  
  #prior mean on beta
  mu.0 <- rep(0, times = length(beta.0))
  #proposal standard deviation (tuning parameter)
  psd <- rep(1, times = length(beta.0))
  #acceptance rate
  accept.count <- rep(0, times = length(beta.0))
  burnin.count <- rep(0, times = length(beta.0))
  retune.check.index <- seq(from = retune, to = burnin, by = retune) 
  
  #print every
  progress.index <- seq(from = print.every, to = niter, by = print.every)
  #################################
  #metropolis hastings within gibbs
  #################################
  
  #container of markov chain for beta 
  beta.chain <- matrix(nrow = niter, ncol = length(beta.0))
  #initial state provided by user (should not matter what it is in the end)
  beta.current <- beta.0
  print("Percent completed:")
  for (t in seq_len(niter)) {
    
    if(any(progress.index == t)) {
      cat(paste(round(100*t/niter, 3), "\t")); flush.console();
    }
    
    #retune proposal variance checks (within burnin time)
    if (any(retune.check.index == t)) {
      psd <- check.proposal.var(n.accept = burnin.count, 
                                n.iter.block = retune , psd = psd,
                                verbose)
      #reset the count
      burnin.count <- rep(0, times = length(beta.0))
    }    
    
    for (j in seq_along(beta.current)) {
      
      #propose a new scalar candidate for beta.current[j]
      beta.prop <- proposal(theta.t = beta.current[j], sd.tune = psd[j])
      #only difference between candidate and current is the jth position
      beta.star <- beta.current
      beta.star[j] <- beta.prop 
      
      #decision to accept or reject
      log.alpha <- log.posterior(mu.0, Sigma.0.inv, beta.star, y, m, X) -
        log.posterior(mu.0, Sigma.0.inv, beta.current, y, m, X)
      log.u <- log(runif(n = 1))
      acceptance <- log.u < log.alpha
      if (acceptance) {
        #update the current beta for all subsequent dimensions of beta
        beta.current[j] <- beta.prop
        #keep separate accceptance rates
        if (burnin < t) {
          accept.count[j] <- accept.count[j] + 1
        } else {
          burnin.count[j] <- burnin.count[j] + 1 
        }
      } else {
        #reject proposal and keep current beta as is.
      }
    }
    #store the results of the metropois hastings within Gibbs for time point t
    beta.chain[t,] <- beta.current
  }
  cat("\n------------------------------\n"); flush.console();
  post.burnin.index <- (burnin + 1):niter
  
  print("Percent acceptance for each parameter:")
  print(round(100*accept.count/length(post.burnin.index), 3))  
  return(beta.chain[post.burnin.index,])
}
