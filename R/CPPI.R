

# Data needed:

#Active_Asset: Return on EU Equity and return series from 1e)
#Reserve_Asset: Zero Coupon Bond prices


Current_CPPI_System <- function(L_trigger, L_target, T = 10yr) {
  initial c_0 <- 100
  
  80 is invested in reserve
  20 is invested in active asset
  
  MVA_0 = 20
  MVR_0 = 80
  
  Guarentee = 80/price of 10yrZCB
  
  Change numeraire such that A_0 = 1
  
  for i in (1:120){
    
    A_i = (1+return on active)*A_(i-1)
    R_i = G_0*exp(-(T-t_i) * z_{T-t_i} (t_i))
    
    If L_i = (Ai+Ri)/(Ri) > L_trigger then rebalance st.
      A_i + R_i = L_target * Guarentee_i * P_{T_ti}(ti)
      
  }
}

## Is the return stochastic? Do the simulation a lot of times and get a distribution of guarentees
## Plot the distribution of these


CPPI_System_with_Multiplier


