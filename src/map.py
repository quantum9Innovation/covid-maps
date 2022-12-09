#!/usr/bin/env python3
# USAGE: `python map.R <countrycode>`
# OUTPUT: Plotly map

# Use `python map.py all` to generate a map for all countries
# This script processes all .csv files generated by `fetch.R` and
# all .geojson mapping files to create the Plotly map
# displaying the relevant data.

# imports
import sys
import json
from plotly import graph_objects as go
import pandas as pd

# get arguments
if len(sys.argv) != 2:
    print('USAGE: `python map.py <countrycode>`')
    sys.exit()
countrycode = sys.argv[1]
country_lower = countrycode.lower()

# validate arguments
COUNTRIES = ['CL', 'DE', 'ES', 'FR', 'GB', 'US']
if countrycode not in COUNTRIES and countrycode != 'all':
    print(
        'ERROR: Invalid country code. '
        + 'Please use one of the following:\n',
        COUNTRIES
    )
    sys.exit()

# get data
if countrycode != 'all':
    data = pd.read_csv(
        f'./fetched/{countrycode}/{countrycode}-latest-estimate.csv'
    )
    with open(f'./maps/{country_lower}.geojson', 'r') as f:
        map = json.load(f)
else:
    data = pd.DataFrame()
    map = dict(
        type='FeatureCollection',
        features=[]
    )
    for countrycode in COUNTRIES:
        df = pd.read_csv(
            f'./fetched/{countrycode}/{countrycode}-latest-estimate.csv'
        )
        data = pd.concat([data, df])
        with open(f'./maps/{countrycode.lower()}.geojson', 'r') as f:
            country_map = json.load(f)
            map['features'] += country_map['features']

# graph
fig = go.Figure(go.Choroplethmapbox(
    geojson=map,
    locations=data.region,
    z=data.p_infected,
    zmin=0, zmax=1,
    colorscale=[
        [0, '#adffc2'],
        [0.5, '#ff9382'],
        [1, '#c90061']
    ],
    marker_line_width=0,
    marker_opacity=0.75,
))
fig.update_layout(
    mapbox_style='open-street-map',
    mapbox_zoom=2,
    mapbox_center={'lat': 35, 'lon': -40},
)
fig.update_layout(
    margin={ 'r': 0, 't': 0, 'l': 0, 'b': 0 }
)
fig.show()
