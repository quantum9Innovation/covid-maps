cd ../src/
echo -e 'Fetching data ...\n'
Rscript fetch.R ES 'Autonomous community' 'Autonomous city'
echo -e '\nMapping regions to administrative regions of Spain ...\n'
Rscript locate.R fetched/ES/ES-latest-estimate.csv located/ES/ES-loc.csv
cp located/ES/ES-loc.csv located/ES/ES-geo.csv
echo -e '\nPreparing data for CARTO ...\n'
Rscript transform.R located/ES/ES-geo.csv
echo -e '\nGenerating map ...\n'
python map.py
echo -e '\nDone! A map should be generated in your CARTO dashboard.'
