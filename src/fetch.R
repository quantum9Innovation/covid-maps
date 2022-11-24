#!/usr/bin/env Rscript
# USAGE: `Rscript fetch.R <countrycode>`
# OUTPUT: ./fetched/{countrycode}/{countrycode}-latest-estimate.csv

# This script fetches the necessary data from 
# http://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/estimates-nsum-2022/PlotData/regional_data/{countrycode}-latest-estimate.csv

# imports
library(data.table); 'Imports successful'


# argument parsing
args <- commandArgs(trailingOnly=TRUE)
COUNTRIES <- c(
    'CL', 'DE', 'ES', 
    'FR', 'GB', 'GR', 
    'IT', 'JP', 'PT', 
    'US', 'ZA'
)

if (length(args) != 1) {
    stop(
        paste('', 
        'Insufficient arguments provided.',  
        'Please see USAGE:',
        '   `Rscript fetch.R <countrycode>`',  
        sep='\n')
    )
} else if ( !(args[1] %in% COUNTRIES) ) {
    stop(
        paste('', 
        'Entered country code is not supported yet.',  
        'Available countries are:',
        paste(COUNTRIES, collapse=', '), 
        sep='\n')
    )
}

args.countrycode <- args[1]; 'Arguments parsed successfully'


# fetch raw data from source
data <- fread(paste(
    'http://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/estimates-nsum-2022/PlotData/regional_data/', 
    args.countrycode, '-latest-estimate.csv',
    sep=''
))
paste('All data for', args.countrycode, 'has been fetched successfully')


# output
setwd('./fetched/')
if (!dir.exists(args.countrycode)) dir.create(args.countrycode)
write.csv(
    data,
    paste(
        args.countrycode, '/',
        args.countrycode, '-latest-estimate.csv',
        sep=''
    ),
    quote=FALSE
)
paste(
    'Process completed; output stored at ./fetched/', 
    args.countrycode, '/', 
    args.countrycode, '-latest-estimate.csv', 
    sep=''
)

'Exited with 0; operation successful'
