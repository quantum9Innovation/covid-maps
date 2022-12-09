# COVID Maps

COVID-19 choropleth maps for GCGImdea/Coronasurveys

---

## Quick start

To build the application, follow the steps below:

1. Clone the repository:\
   `git clone https://github.com/quantum9innovation/covid-maps`
2. Install the dependencies
   1. R dependencies: `install.packages('data.table')`
   2. Python dependencies: `pip install plotly pandas`
3. Run the build script:\
   `scripts/make.sh`

## Application Details

When you run the build script, it systematically calls a number of scripts in the [`src/`](./src/) directory. The procedure that it follows is:

1. [`fetch.R`](./src/fetch.R): fetches the latest data and saves it locally
2. [`map.py`](./src/map.py): generates Plotly map
