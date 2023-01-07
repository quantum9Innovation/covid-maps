#!/usr/bin/env bash
cd src/
echo -e 'This script will load all historical data, which can take some time'
echo -e 'For only the latest estimates, use `scripts/make-latest.sh`.\n'
echo -e 'Fetching all data ...\n'
Rscript fetch-all.R CL DE ES FR GB GR IT JP PT US ZA
echo -e '\nGenerating map ...\n'
python map.py all
echo -e '\nDone! A map should be generated in an open browser window.'
