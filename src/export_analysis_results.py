"""
This script uses the PostGIS query defined in './src/query_template.sql`
to run the same query four times, once for each of the four HSIP corridor tables.

It then combines the results of all analysis runs to a single output, 
which it then writes to disk in both Shapefile and GeoJSON format.

In future years, you can re-run this analysis by updating the tablenames. To do so:
    - change the corridor tablenames within the 'corridor_tables' list in this script (line 48)
    - change the intersection point tablenames inside the SQL template (lines 17, 32, and 47)
"""

import os
import sqlalchemy
import pandas as pd
import geopandas as gpd
from dotenv import find_dotenv, load_dotenv
import warnings

warnings.filterwarnings("ignore")


def get_gdf(query: str) -> gpd.GeoDataFrame:
    """Get a `geopandas.GeoDataFrame` from a SQL query"""

    engine = sqlalchemy.create_engine(DATABASE_URL)

    gdf = gpd.GeoDataFrame.from_postgis(query, engine, geom_col="geom")

    engine.dispose()

    return gdf


# Load values from the '.env' file
load_dotenv(find_dotenv())
DATABASE_URL = os.getenv("DATABASE_URL")
OUTPUT_FOLDER = os.getenv("OUTPUT_FOLDER")

# Define the output filepath
output_filepath = os.path.join(OUTPUT_FOLDER, "hsip_intersection_analysis")

# Open the SQL template file and read it into memory
with open("./src/query_template.sql", "r") as query_file:
    query_template = query_file.read()

# Define the corridor table names, each of which gets its own analysis
corridor_tables = [
    "hsip_corridor_2019",
    "hsip_hrrr_2019",
    "hsip_pedbikecorridor_2019",
    "hsip_pedcorridor_2019",
]

# Make an empty list to hold the results of each analysis run
results = []

# Iterate over the corridor list, running the same analysis for each one
for tbl in corridor_tables:

    print(f"-> Analyzing: {tbl}")

    # Get a list of the three corridor tables that aren't the basis of this analysis
    other_tables = corridor_tables.copy()
    other_tables.remove(tbl)

    # Update the query by swapping placeholders in the template with specific table names
    query = (
        query_template.replace("ANALYSIS_CORRIDOR_TABLE", tbl)
        .replace("OTHER_CORRIDOR_A", other_tables[0])
        .replace("OTHER_CORRIDOR_B", other_tables[1])
        .replace("OTHER_CORRIDOR_C", other_tables[2])
    )

    # Get the result of the spatial query as a GeoDataFrame
    gdf = get_gdf(query)

    # Add GeoDataFrame to the result list
    results.append(gdf)

# After running each analysis, merge all results together
# into a single GeoDataFrame
merged_gdf = pd.concat(results, ignore_index=True)

# Save the result to file.
# We're doing this to shapefile for convenience, but shapefile column names get truncated
# to 10 characters, which is not ideal.
# We're also saving the exact same data to GeoJSON, which will leave the column names as-is.
print("---------------------------------------")
print("-> Writing results to .shp and .geojson")
merged_gdf.to_file(output_filepath + ".shp", driver="ESRI Shapefile")
merged_gdf.to_file(output_filepath + ".geojson", driver="GeoJSON")
