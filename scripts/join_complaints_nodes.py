import pandas as pd
import geopandas as gpd
import fiona.crs 
import matplotlib.pyplot as plt
from shapely.geometry import Point

def clean_complaints(df):
    '''
    Takes: complaints df
    Returns: complaints, without 0 lat/lon and uniform case
    '''

    df['latitude'] = pd.to_numeric(df['latitude'])
    df['longitude'] = pd.to_numeric(df['longitude'])
    df = df.loc[df['latitude'] != 0 & df['longitude'] != 0]

    df['complaint_type'] = df['complaint_type'].str.upper()

    return df


def create_node_buffers(nodes, buffer_size = 5000):
    '''
    Takes: a dataframe of nodes, buffer size in meters
    Returns: geodataframe with buffer around each node
    '''

    gs = gpd.GeoSeries(index = nodes.index, crs = fiona.crs.from_epsg(4326), 
                data = [Point(xy) for xy in zip(nodes.lon, nodes.lat)])
    gsb =  gs.buffer(buffer_size)
    gdf = gpd.GeoDataFrame(data = nodes, geometry = gsb)

    return gdf


if __name__ == "__main__":
    
    # read in the complaints dataset
    nodes = pd.read_csv("aot_data/nodes.csv")
    complaints = pd.read_csv("complaint_data/CDPH_Environmental_Complaints.csv")

    buff_nodes = create_node_buffers(nodes, 1)