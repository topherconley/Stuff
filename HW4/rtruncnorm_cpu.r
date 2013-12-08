rtruncnorm_cpu <- function(n, mu, sigma, 
                           lo, hi,
                           max_tries) {
    vals <- rep(NA, times = n);
    for (idx in seq_len(n)) {
#Rejection Sampling:
#    (i) First try two-sided truncation naive approach. It works for cases 
#        where: |high - low| >> 0. which will be true for this homework 
#        assignment. This code is not robust to really tricky two-sided 
#        truncation. because the probability of sampling from that region 
#        is high. 
#    (ii) When that fails for the one-sided tail regions, that have a small 
#        probability of being sampled, then apply the Robert approach. 
#
        accepted = 0;
        iter_count = 0;
        while (accepted == 0 && iter_count < max_tries) {
            iter_count = iter_count + 1;
            vals[idx] = mu[idx] + sigma[idx] * qnorm(runif(1)); 
#accepted or not?
            if (vals[idx] > lo[idx] && vals[idx] <= hi[idx]) {
                accepted = 1;
            }
        }

#If it never accepted, then for this assignment we can assume that
#  we have a case of heavy right or left truncation where we are 
#  trying to sample from only one of the tails. 
#  
        if (accepted == 0) {

#right truncation requires adaptation because the Robert-rejection 
#sampling for one-sided truncation defaults to left truncation

#indicate whether it is right truncated to flip the sign of the 
#sampled value if right_trunc = 1.
            right_trunc = 0;
            if (hi[idx] <  mu[idx]) {
                right_trunc = 1;
                mu[idx] = -1 * mu[idx];
                lo[idx] = -1 * hi[idx];
            } else {
#left truncation
                right_trunc = 0;
            }

#see Appendix A below
            mu_minus = ( lo[idx]  - mu[idx] ) / sigma[idx];

#/****************************************/
#/* left truncation, right tail sampling*/

#step 0: set the optimal rate parameter for the exponential 
#  distribution
            alpha =  ( mu_minus + sqrt(mu_minus*mu_minus + 4) ) / 2;
            while (accepted == 0) {
#step 1:generate: z ~ Expo(\alpha, \mu_minus)
# by the inv-cdf transform (since z is continous)

                z = mu_minus - log (runif(1)) / alpha; 

#step 2: compute ratio h(z) / ( M * g(z) ) */
                psi = 0;
                offset1 = alpha - z;
                offset2 = 0;
                if (mu_minus < alpha) { 
                    psi  = exp( -0.5 * offset1*offset1 );
                } else {
                    offset2 = mu_minus - alpha;
                    psi = exp( -0.5 * ( offset1*offset1 + offset2*offset2 ) );
                }
                u <- runif(1)
#accepted the sample
                if (u <= psi) {
                    if (right_trunc == 1) {
                        vals[idx] = -1 * ( mu[idx] + sigma[idx]*z );
                    } else {
                        vals[idx] = mu[idx] + sigma[idx]*z;
                    }
                    accepted = 1;
                }

            } # END while loop
        } # END Robert rejection-sampling.
    }
    vals
} # END rtruncnorm_cpu
