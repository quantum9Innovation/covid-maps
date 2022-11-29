#!/usr/bin/env Rscript
# USAGE: `Rscript fetch.R <countrycode> ...`
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

if (length(args) == 0) {
    stop(
        paste('', 
        'Insufficient arguments provided.',  
        'Please see USAGE:',
        '   `Rscript fetch.R <countrycode> ...`',  
        sep='\n')
    )
} 

for ( arg in args ) {
    if ( !(arg %in% COUNTRIES) ) {
        stop(
            paste('', 
            'Entered country code is not supported yet.',  
            'Available countries are:',
            paste(COUNTRIES, collapse=', '), 
            sep='\n')
        )
    }
}; 'Arguments parsed successfully'


# loop through all countries
setwd('./fetched/')
for ( arg in args ) { 
    # fetch raw data from source
    data <- fread(paste(
        'http://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/estimates-nsum-2022/PlotData/regional_data/', 
        arg, '-latest-estimate.csv',
        sep=''
    ))
    print(paste('All data for', arg, 'has been fetched successfully'))


    # output
    if (!dir.exists(arg)) dir.create(arg)
    write.csv(
        data,
        paste(
            arg, '/',
            arg, '-latest-estimate.csv',
            sep=''
        ),
        quote=FALSE
    )
    print(paste(
        'Process completed; output stored at ./fetched/', 
        arg, '/', 
        arg, '-latest-estimate.csv', 
        sep=''
    ))
}

'Exited with 0; operation successful'
