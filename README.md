# NJ-HSIP-analysis

Analysis of data from the New Jersey Highway Safety Improvement Program (HSIP)

## Setup

Create the Python environment with:

```
conda env create -f environment.yml
```

Create a file named `.env` at the root of this project and add the following entries:

    - `DATABASE_URL` is a connection string to DVRPC's GIS database
    - `OUTPUT_FOLDER` is a folder path to wherever you want to save the output shapefile and geojson

For example:

```
DATABASE_URL=postgresql://username:password@host:port/database
OUTPUT_FOLDER=U:\FY2022\Transportation\HSIP
```

## Run the analysis

To run this analysis, begin by activating the Python environment with:

```
conda activate nj_hsip
```

You can then run the analysis script with:

```
python .\src\export_analysis_results.py
```

This will save a shapefile and geojson to the `OUTPUT_FOLDER` with the results of the analysis.
