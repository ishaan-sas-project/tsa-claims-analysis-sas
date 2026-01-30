/**************************************************************************
 Program Name : tsa_claims_analysis.sas
 Project      : TSA Claims Analysis (2002–2017)
 Curated       : Ishaan
 Description  :
   End-to-end analysis of TSA claims data using Base SAS. The program
   imports raw data, performs data cleaning and validation, conducts
   exploratory and state-level analysis, and generates an automated
   PDF report using ODS and graphics.

 Instructions:
   - Update file paths before running
   - Dataset is not included in the GitHub repository
**************************************************************************/

/* ACCESSING DATA */

libname tsa "/home/u64418144/ECRB94/data";
options validvarname=v7;

proc import datafile="/home/u64418144/ECRB94/data/TSAClaims2002_2017.csv" 
		dbms=csv 
		out=tsa.claims_cleaned 
		replace;
		guessingrows=max;
run;

/* EXPLORING DATA */

proc contents data=tsa.claims_cleaned varnum;
run;
proc freq data=tsa.claims_cleaned;
tables claim_site disposition claim_type date_received incident_date statename state/ nocum nopercent;
format date_received incident_date year4.;
run;
proc print data=tsa.claims_cleaned;
where date_received<incident_date;
format date_received incident_date date9.;
run;

/* PREPARING DATA */

proc sort data=tsa.claims_cleaned out=tsa.claims_nodups noduprecs;
by Claim_Number;
run;

proc sort data=tsa.claims_nodups;
by incident_date;
run;

data tsa.claims_cleaning;
set tsa.claims_nodups;
if claim_site in ("-" , " ") then claim_site= "unknown";
if disposition in ("-" , " ") then disposition= 'unknown';
else if disposition = "Closed: Canceled" then disposition='Closed:Canceled';
else if disposition ="losed: Contractor Claim" then disposition='Closed:Contractor Claim';
if claim_type in ("-" , " ") then claim_type= "unknown";
else if claim_type in ("Passenger Property Loss/Personal Injur","Passenger Property Loss/Personal Injury") then claim_type='Passenger Property Loss';
else if claim_type ="Property Damage/Personal Injury" then claim_type='Property Damage';
state=upcase(state);
statename=propcase(statename);
if (incident_date>date_received or
date_received=. or
incident_date=. or 
year(incident_date)<2002 or
year(incident_date)>2017 or
year(date_received)<2002 or
year(date_received)>2017) then Date_issues="needs review";
else Date_issues="Fine";
format date_received incident_date date9. close_amount dollar12.2;
label airport_code="airport code" 
airport_name="airport name"
claim_site="claim site"
claim_type="claim type" 
date_received="date received" 
incident_date="incident date"
close_amount="close amount"
date_issues="date issues"
item_category="item category";
drop county city;
run;
proc freq data=tsa.claims_cleaning;
tables claim_site disposition claim_type date_issues / nocum nopercent;
run;

/* ANALYZING DATA */

%let statename=Florida;

%let outpath=/home/u64418144/ECRB94/reports;
ods pdf file="&outpath/claims_report.pdf" style=pearl pdftoc=1 ;
ods noproctitle;
options nodate nonumber;
ods proclabel "overall date issues";
title "overall date issues are in overall date";
proc freq data=tsa.claims_cleaning;
tables date_issues /missing nocum nopercent;
run;
title;

ods graphics on;
ods proclabel "overall claims by year";
title "overall claims by year";
proc freq data=tsa.claims_cleaning;
tables incident_date / nocum nopercent;
format incident_date year4.;
where date_issues ="Fine";
run;
proc sgplot data=tsa.claims_cleaning;
where date_issues = "Fine";
vbar incident_date / stat=freq;
format incident_date year4.;
xaxis label="Incident Year";
yaxis label="Number of Claims";
run;
title;

ods proclabel "&statename claims overview";
title "&StateName claim type claim site and disposition";
proc freq data=tsa.claims_cleaning order=freq;
table claim_type claim_site disposition/ nocum nopercent;
where statename="&StateName" and date_issues = "Fine";
run;
proc sgplot data=tsa.claims_cleaning;
where statename="&StateName" and date_issues = "Fine";
vbar claim_type;
xaxis discreteorder=data label="Claim Type";
yaxis label="Number of Claims";
run;
title;

ods proclabel "&statename close amount statistics";
title "close amount statistics for &StateName";
proc means data=tsa.claims_cleaning mean min max sum maxdec=0;
var close_amount;
where statename="&StateName" and date_issues = "Fine";
run;
proc sgplot data=tsa.claims_cleaning;
where statename="&StateName" and date_issues ="Fine" and close_amount>0;
histogram close_amount;
density close_amount;
xaxis label="Close Amount ($)";
run;
title;
ods pdf close;





