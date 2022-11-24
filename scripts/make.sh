#!/usr/bin/env bash
cd src/
echo -e 'Fetching data ...\n'
Rscript fetch.R US
echo -e '\nLocating regions ...\n'
Rscript locate.R fetched/US/US-latest-estimate.csv
echo -e '\nGenerating map ...\n'
python map.py
echo -e '\nDone! A map should be generated in an open browser window.'
