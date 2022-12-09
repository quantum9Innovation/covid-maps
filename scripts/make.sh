#!/usr/bin/env bash
cd src/
echo -e 'Fetching data ...\n'
Rscript fetch.R DE CL US
echo -e '\nGenerating map ...\n'
python map.py all
echo -e '\nDone! A map should be generated in an open browser window.'
