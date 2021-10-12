# CARTOframes

CARTOframes for GCGImdea/Coronasurveys

---

## Quick start

To build the application, follow the steps below:

1. Clone the repository:\
   `git clone https://github.com/quantum9innovation/CARTOframes`
2. Install the dependencies:\
   `pip install -r requirements.txt`
3. Create a file creds/creds.json and populate it with:

   ```json
   {
     "username": "your_username",
     "api_key": "********"
   }
   ```

4. Run the build script:\
   `cd scripts; ./make.sh`

Once run, the script will periodically print a summary of what it is doing. After it finishes, a map will be generated using the CARTO API.

## Application Details

When you run the build script, it systematically calls a number of scripts in the [`src/`](./src/) directory. The procedure that it follows is:

1. [`fetch.R`](./src/fetch.R): fetches the latest data for Spain from CoronaSurveys common data
2. [`locate.R`](./src/locate.R): decodes region abbreviations and maps them to their corresponding administrative regions, also adds a `country` column for CARTO
3. [`transform.R`](./src/transform.R): transforms the spellings of various names in the file so that CARTO can recognize them

The outputs of each of the respective scripts is stored at:

1. [`fetch.R`](./src/fetch.R): [src/fetched/ES/ES-latest-estimate.csv](./src/fetched/ES/ES-latest-estimate.csv)
2. [`locate.R`](./src/locate.R): [src/located/ES/ES-loc.csv](./src/located/ES/ES-loc.csv)
3. [`transform.R`](./src/transform.R): [src/located/ES/ES-geo.csv](./src/located/ES/ES-geo.csv)

The final output, ES-geo.csv, is used by the [`map.py`](./src/map.py) script to generate the map using the CARTOframes package.
