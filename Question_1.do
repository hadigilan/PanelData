*set more off
*set linesize 240
*clear all

*************************************************************;
* (Note: Change path name if dta not in the working directory);

cd "C:\lab4"

use Guns.dta, clear
desc
* d

summarize

tabulate stateid
tabulate year stateid

*************************************************************;
* Question 1

log using Lab4_ques_1.log, replace

* Log files record everything that happens during a session
* replace option makes the current log file be replaced by a new one. otherwise you can use append option


*************************************************************;
*This dataset is a balanced panel

tabulate stateid year

*************************************************************;

gen lvio = ln(vio)
gen lrob = ln(rob)
gen lmur = ln(mur)

histogram vio
histogram lvio



*************************************************************;
tabulate year, generate(yr)

global yr_vars "yr2  yr3  yr4  yr5  yr6  yr7  yr8  yr9 yr10 yr11 yr12 yr13 yr14 yr15 yr16 yr17 yr18 yr19 yr20 yr21 yr22 yr23 " 

* global is a command to introduce macro avaliable across the programs in Stata 
* to refer to a global macro use $ operator before that macro
* here yr_vars is a set containing 22 dummy variables that we want to apply in our models 


* Alternatively, to break lines use delimiter
* #delimit ;
* global yr_vars "yr2  yr3  yr4  yr5  yr6  yr7  
* yr8  yr9 yr10 yr11 yr12 yr13 yr14 yr15 yr16 
* yr17 yr18 yr19 yr20 yr21 yr22 yr23 " ;
* #delimit cr


* it is not require to define these large number of dummies. it is enough to use i.year in the model. 


global basevars "incarc_rate density avginc pop pb1064 pw1064 pm1029"
* here basevars is the name of a set containing 7 base variables that we want to apply in our models

*************************************************************;

*pooled regression

* question 1;
reg lvio shall
reg lvio shall, vce(cluster stateid)

*regress lvio shall, vce(cluster stateid)


reg lvio shall $basevars, vce(cluster stateid)
reg lvio shall incarc_rate density avginc pop pb1064 pw1064 pm1029, vce(cluster stateid)


***************************************************************
*panel regressions

xtset stateid year

*** visualizing panel data set
xtline vio
xtline vio, overlay legend(off)


**** one-way model
xtreg lvio shall $basevars, fe vce(cluster stateid)
*regress lvio shall $basevars i.stateid, vce(cluster stateid)

* rho represents the variation in dependent var. which is explained by differences across individuals
di e(sigma_u)^2/(e(sigma_u)^2 + e(sigma_e)^2) 

**** two-way model
xtreg lvio shall $basevars $yr_vars, fe vce(cluster stateid)
xtreg lvio shall $basevars i.year, fe vce(cluster stateid)


**** joint test of time effects
test $yr_vars

***************************************************************


* question 1
reg lrob shall, vce(cluster stateid)
reg lrob shall $basevars, vce(cluster stateid)


* question 2 - Table 1 (remaining regressions);
xtreg lrob shall $basevars, fe vce(cluster stateid)
xtreg lrob shall $basevars $yr_vars, fe vce(cluster stateid)
test $yr_vars


* question 1;
reg lmur shall, vce(cluster stateid)
reg lmur shall $basevars, vce(cluster stateid)


* question 2 - Table 1 (remaining regressions)
xtreg lmur shall $basevars, fe vce(cluster stateid)
xtreg lmur shall $basevars $yr_vars, fe vce(cluster stateid)
test $yr_vars


*****
*
*random effects model in Stata
*xtreg y X, cluster(firm_id) robust sa /* sa = Swamy-Arora */

******** Huasman test
*xtreg ln_gdppc ln_trade ln_labor, fe 
*estimates store fixed 
*xtreg ln_gdppc ln_trade ln_labor, re 
*estimates store random 
*hausman fixed random, sigmamore
*
*******
*************************************************************;
log close
clear
