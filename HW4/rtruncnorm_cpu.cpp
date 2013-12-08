#include <Rcpp.h>
using namespace Rcpp;
  
// [[Rcpp::export]]
NumericVector rtruncnorm_cpu_rcpp(int n, 
        NumericVector mu, 
        NumericVector sigma,
        NumericVector lo,
        NumericVector hi, 
        int max_tries) {

    

    //init return value
    NumericVector vals(n);
    //init state of RNG 
    RNGScope scope;

    NumericVector uniform_input(1,1.0);
    for (int idx = 0; idx < n; idx++)  {
        bool accepted = false;
        int iter_count = 0;
        while (!accepted && iter_count < max_tries) {
            iter_count = iter_count + 1;
            //NumericVector z_val = qnorm(runif(uniform_input));
            vals[idx] = mu[idx] + sigma[idx] * R::rnorm(0, 1); 
            if (vals[idx] > lo[idx] && vals[idx] <= hi[idx]) {
                accepted = true;
            }
        }
 
        if (!accepted) {
            double mu_tmp = mu[idx];
            double lo_tmp = lo[idx];
            bool right_trunc;
            if (hi[idx] <  mu_tmp) {
                right_trunc = true;
                mu_tmp = -1 * mu_tmp;
                lo_tmp = -1 * hi[idx];
            } else {
                //left truncation
                right_trunc = false;
            }

            double mu_minus = ( lo_tmp  - mu_tmp ) / sigma[idx];
            double alpha =  ( mu_minus + sqrt(mu_minus*mu_minus + 4) ) / 2;
            while (!accepted) {
         
                double z = mu_minus - log (R::runif(0,1)) / alpha; 
                double psi = 0;
                double offset1 = alpha - z;
                double offset2 = 0;
                if (mu_minus < alpha) { 
                    psi  = exp( -0.5 * offset1*offset1 );
                } else {
                    offset2 = mu_minus - alpha;
                    psi = exp( -0.5 * ( offset1*offset1 + offset2*offset2 ) );
                }
          
                if (R::runif(0,1) <= psi) {
                    if (right_trunc) {
                        vals[idx] = -1 * ( mu_tmp + sigma[idx]*z );
                    } else {
                        vals[idx] = mu_tmp + sigma[idx]*z;
                    }
                    accepted = true;
                }

            }  //END while loop
        } // END Robert rejection-sampling.
    }
    return vals;
} // END rtruncnorm_cpu
