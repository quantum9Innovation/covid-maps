#!/usr/bin/env Rscript
# USAGE: `Rscript fetch-all.R <countrycode> ...`
# OUTPUT: ./fetched/{countrycode}/{countrycode}-latest-estimate.csv*

# *This output will override results from `fetch.R` and is **not** the latest estimate
# but rather the most recent estimate available for each region; it is named this way
# to keep compatibility with the `map.py` script

# This script fetches the necessary data from 
# https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/estimates-nsum-2022/PlotData/regional_data/{countrycode}-estimate.csv

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
        'https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/estimates-nsum-2022/PlotData/regional_data/', 
        arg, '-estimate.csv',
        sep=''
    ))
    print(paste('All data for', arg, 'has been fetched successfully'))

    # factor by region
    regions <- unique(data$region)
    recents <- data.table()
    for ( regioncode in regions ) {
        row <- tail(data[region==regioncode][!is.na(p_infected)], n=1)
        recents <- rbindlist(list(recents, row))
    }

    # output
    if (!dir.exists(arg)) dir.create(arg)
    write.csv(
        recents,
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
