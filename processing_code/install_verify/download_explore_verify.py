import neonutilities as nu
import os
import rasterio
import pandas as pd
import matplotlib.pyplot as plt

# try to use neonutilities
try:
    bird = nu.load_by_product(dpid="DP1.10003.001", site="WREF",
                              startdate="2019-01", enddate="2019-12",
                              check_size=False, progress=False)
except Exception:
    print("neonutilities could not download data. Check neonutilities installation and internet access.")

# try to read tile with rasterio
try:
    chm = rasterio.open("https://data.neonscience.org/api/v0/data/DP3.30015.001/ARIK/2020-06/NEON_D10_ARIK_DP3_705000_4395000_CHM.tif")
except Exception:
    print("rasterio could not read a raster tile Check rasterio installation.")
