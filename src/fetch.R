#!/usr/bin/env Rscript
# USAGE: `Rscript fetch.R <countrycode> <regiontype1> <regiontype2> ...`
# OUTPUT: ./fetched/{countrycode}/{countrycode}-latest-estimate.csv


# This script fetches the necessary data from 
# (1) https://github.com/GCGImdea/coronasurveys/blob/master/data/common-data/regions-tree-population.csv
# (2) https://github.com/GCGImdea/coronasurveys/blob/master/data/common-data/provinces-tree-population.csv
# (3) https://github.com/GCGImdea/coronasurveys/blob/master/data/estimates-provinces/{countrycode}/{countrycode}-latest-estimate.csv
# (4) https://github.com/GCGImdea/coronasurveys/blob/master/data/estimates-regions/{countrycode}/{countrycode}-latest-estimate.csv
#
# and merges the province estimates with the regional estimates for all the 
# parameters in the files provided. Only statistics that are available at the 
# regional and provincial levels are merged. These include:
#
# date                  region                  population 
# p_cases               p_cases_error           p_fatalities 
# p_fatalities_error    p_recentcases           p_recentcases_error 
# p_cases_daily         p_cases_daily_error     p_stillsick 
# p_stillsick_error
#
# If any of these values cannot be obtained for a specific date, its 
# corresponding column will have an 'NA' marker.
#
# This includes:
# (a) a list of all the region codes in the country from (1)
#     => regioncode     population
#
# (b) a list of all the province codes for each region in the country from (2)
#     => regioncode     provincecode        population
#
# (c) a list of required data for each province from (3)
#     => region     p_cases     ...
#
# (d) a list of required data for each region from (4)
#     => region     p_cases     ...


# imports
library(data.table); 'Imports successful'


# argument parsing
args <- commandArgs(trailingOnly=TRUE)

if (length(args) < 2) {
    stop(
        paste('', 
        'Insufficient arguments provided.',  
        'Please see USAGE:',
        '   `Rscript fetch.R <countrycode> <regiontype1> <regiontype2> ...`',  
        sep='\n')
    )
} else if ( !(args[1] %in% c('ES', 'IT', 'FR')) ) {
    stop(
        paste('', 
        'No provincial data exists for this country code.',  
        'Available countries are:',
        '- Spain (ES)', 
        '- Italy (IT)', 
        '- France (FR)',  
        sep='\n')
    )
}

args.countrycode <- args[1]
args.regiontype <- args[2:length(args)]

'Arguments parsed successfully'


# fetch raw data from source
# data source (1)
regions_tree_population <- fread('https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/common-data/regions-tree-population-v2.csv')
# data source (2)
provinces_tree_population <- fread('https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/common-data/provinces-tree-population.csv')
# data source (3)--must only contain essential data
tryCatch(
    expr = {
        estimates_provinces <- fread(
            paste(
            'https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/estimates-provinces/', 
            args.countrycode, '/', args.countrycode, '-latest-estimate.csv',
            sep='')
        )
    }, 
    error = function(e) {
        stop(
            paste('', 
            'Provincial data for the given country could not be fetched at this time.',  
            'Please check <https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/estimates-provinces/>',
            'to see available country specifications.', 
            sep='\n')
        )
    }
)
estimates_provinces <- data.table( 
    p_cases = estimates_provinces$p_cases,
    p_cases_error = estimates_provinces$p_cases_error,
    p_fatalities = estimates_provinces$p_fatalities,
    p_fatalities_error = estimates_provinces$p_fatalities_error,
    p_recentcases = estimates_provinces$p_recentcases,
    p_recentcases_error = estimates_provinces$p_recentcases_error,
    p_cases_daily = estimates_provinces$p_cases_daily,
    p_cases_daily_error = estimates_provinces$p_cases_daily_error,
    p_stillsick = estimates_provinces$p_stillsick,
    p_stillsick_error = estimates_provinces$p_stillsick_error,
    region = estimates_provinces$region
)

# data source (4)
tryCatch(
    expr = {
        estimates_regions <- fread(
            paste(
            'https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/estimates-regions/', 
            args.countrycode, '/', args.countrycode, '-latest-estimate.csv',
            sep='')
        )
    }, 
    error = function(e) {
        stop(
            paste('', 
            'Regional data for the given country could not be fetched at this time.',  
            'Please check <https://raw.githubusercontent.com/GCGImdea/coronasurveys/master/data/estimates-regions/>',
            'to see available country specifications.', 
            sep='\n')
        )
    }
)
estimates_regions <- data.table( 
    p_cases = estimates_regions$p_cases,
    p_cases_error = estimates_regions$p_cases_error,
    p_fatalities = estimates_regions$p_fatalities,
    p_fatalities_error = estimates_regions$p_fatalities_error,
    p_recentcases = estimates_regions$p_recentcases,
    p_recentcases_error = estimates_regions$p_recentcases_error,
    p_cases_daily = estimates_regions$p_cases_daily,
    p_cases_daily_error = estimates_regions$p_cases_daily_error,
    p_stillsick = estimates_regions$p_stillsick,
    p_stillsick_error = estimates_regions$p_stillsick_error,
    region = estimates_regions$region
)

paste('All data for', args.countrycode, 'has been fetched successfully')


# combine data
regions <- data.table(
    regioncode=regions_tree_population[countrycode == args.countrycode & 
                                       regiontype %in% args.regiontype]
                                       $regioncode, 
    population=regions_tree_population[countrycode == args.countrycode & 
                                       regiontype %in% args.regiontype]
                                       $population
)
provinces <- data.table(
    regioncode=provinces_tree_population[countrycode == args.countrycode]$regioncode,
    provincecode=provinces_tree_population[countrycode == args.countrycode]$provincecode, 
    population=provinces_tree_population[countrycode == args.countrycode]$population
)

weighted_average <- data.table()
for (l.region in regions$regioncode) {

    r.population <- as.numeric(regions[regioncode == l.region]$population)
    
    l.data <- data.table(
        p_cases = 0,
        p_cases_error = 0,
        p_fatalities = 0,
        p_fatalities_error = 0,
        p_recentcases = 0,
        p_recentcases_error = 0,
        p_cases_daily = 0,
        p_cases_daily_error = 0,
        p_stillsick = 0,
        p_stillsick_error = 0
    )
    l.populations <- data.table(
        p_cases = 0,
        p_cases_error = 0,
        p_fatalities = 0,
        p_fatalities_error = 0,
        p_recentcases = 0,
        p_recentcases_error = 0,
        p_cases_daily = 0,
        p_cases_daily_error = 0,
        p_stillsick = 0,
        p_stillsick_error = 0
    )

    for (l.i in 1:10) {
        l.item <- estimates_regions[region == l.region][[l.i]]
        if (!is.na(l.item)) {
            l.data[[l.i]] <- r.population * l.item
            l.populations[[l.i]] <- r.population
        }
    } 

    r.provinces <- provinces[regioncode == l.region]
    for (l.province in r.provinces$provincecode) {
        
        p.population <- provinces[provincecode == l.province]$population

        for (l.i in 1:10) {
            l.item <- estimates_provinces[region == l.province][[l.i]]
            if (!is.na(l.item)) {
                l.data[[l.i]] <- l.data[[l.i]] + p.population * l.item
                l.populations[[l.i]] <- l.populations[[l.i]] + p.population
            }
        }
    
    }

    r.weighted_average <- l.data / l.populations
    for (l.i in 1:10) {  # replace `NaN` with `NA`
        l.item <- r.weighted_average[[l.i]]
        if ( is.nan(l.item) ) r.weighted_average[[l.i]] <- NA
    }
    weighted_average <- data.table(
        regioncode = c(weighted_average$regioncode, l.region),
        p_cases = c(weighted_average$p_cases, r.weighted_average$p_cases),
        p_cases_error = c(weighted_average$p_cases_error, r.weighted_average$p_cases_error),
        p_fatalities = c(weighted_average$p_fatalities, r.weighted_average$p_fatalities),
        p_fatalities_error = c(weighted_average$p_fatalities_error, r.weighted_average$p_fatalities_error),
        p_recentcases = c(weighted_average$p_recentcases, r.weighted_average$p_recentcases),
        p_recentcases_error = c(weighted_average$p_recentcases_error, r.weighted_average$p_recentcases_error),
        p_cases_daily = c(weighted_average$p_cases_daily, r.weighted_average$p_cases_daily),
        p_cases_daily_error = c(weighted_average$p_cases_daily_error, r.weighted_average$p_cases_daily_error),
        p_stillsick = c(weighted_average$p_stillsick, r.weighted_average$p_stillsick),
        p_stillsick_error = c(weighted_average$p_stillsick_error, r.weighted_average$p_stillsick_error)
    )

}
paste('Successfully combined all data for ', 
      args.countrycode, '@', 'latest', 
      sep='')


# output
setwd('./fetched/')
if (!dir.exists(args.countrycode)) dir.create(args.countrycode)

write.csv(weighted_average, paste(args.countrycode, 
                                  '/', args.countrycode, 
                                  '-latest-estimate.csv', 
                                  sep=''), 
                            quote=FALSE)
paste('Process completed; output stored at ./fetched/', 
      args.countrycode, '/', 
      args.countrycode, '-latest-estimate.csv', 
      sep='')

'Exited with 0; operation successful'
