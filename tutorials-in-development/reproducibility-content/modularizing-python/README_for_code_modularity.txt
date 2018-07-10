Steps:

Create folder structure

RSDI-2018/
data/
├── Biomass
│   ├── NEON_D17_SJER_DP3_256000_4106000_CHM.tif
│   └── training
│       └── SJER_Biomass_Training.csv
├── Day1_Hyperspectral_Intro
│   └── NEON_D02_SERC_DP3_368000_4306000_reflectance.h5
├── Day2_LiDAR_Intro
│   ├── NEON_D02_SERC_DP3_368000_4306000_CHM.tif
│   ├── NEON_D17_TEAK_DP3_316000_4106000_CHM.tif
│   ├── NEON_D17_TEAK_DP3_316000_4106000_aspect.tif
│   └── TEAK_Aspect_Tiles
│       ├── NEON_D17_TEAK_DP3_320000_4100000_aspect.tif
│       ├── NEON_D17_TEAK_DP3_320000_4101000_aspect.tif
│       ├── NEON_D17_TEAK_DP3_321000_4100000_aspect.tif
│       └── NEON_D17_TEAK_DP3_321000_4101000_aspect.tif
├── RGB
│   └── 2017_SERC_2_368000_4306000_image.tif
└── Uncertainty
    ├── CHEQ
    │   ├── CHEQ_Tarp_03_02_refl_bavg.txt
    │   ├── CHEQ_Tarp_48_01_refl_bavg.txt
    │   ├── NEON_D05_CHEQ_DP1_20160912_160540_reflectance.h5
    │   ├── NEON_D05_CHEQ_DP1_20160912_160540_reflectance_w_blur.h5
    │   └── NEON_D05_CHEQ_DP1_20160912_170131_reflectance.h5
    ├── F07A
    │   ├── NEON_D07_F07A_DP1_20160611_160444_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_160846_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_161228_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_161532_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_162007_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_162514_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_162951_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_163424_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_163945_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_164259_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_164809_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_165240_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_165711_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_170118_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_170538_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_170922_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_171403_reflectance_modify.h5
    │   ├── NEON_D07_F07A_DP1_20160611_171852_reflectance_modify.h5
    │   └── NEON_D07_F07A_DP1_20160611_172430_reflectance_modify.h5
    └── PRIN
        ├── 2016_PRIN_1_607000_3696000_DSM.tif
        ├── 2016_PRIN_1_607000_3696000_DTM.tif
        ├── 2016_PRIN_1_607000_3696000_pit_free_CHM.tif
        ├── 2016_PRIN_2_607000_3696000_DSM.tif
        ├── 2016_PRIN_2_607000_3696000_DTM.tif
        └── 2016_PRIN_2_607000_3696000_pit_free_CHM.tif

10 directories, 41 files


project/
  code/
    .gitkeep
  data/
    raw_data_located_outside_project_folder/
    README_raw_data.md
  output/
    .gitkeep

Add ipynb to top level



At terminal, in project directory

conda activate py35
conda install argparse



# Create a conda environment
conda create --name <environment-name> python=<version:2.7/3.5>

# To create a requirements.txt file:
# Gives you list of packages used for the environment
conda list

# Save all the info about packages to your folder
# conda list -e > requirements.txt 

# To export environment file
# activate <environment-name>
conda env export > <environment-name>.yml

# For other person to use the environment
# conda env create -f <environment-name>.yml


python plot_hyperspectral_pixel_spectras_from_hdf5_argparse.py -h
usage: plot_hyperspectral_pixel_spectras_from_hdf5_argparse.py
       [-h] [-v] [-c CSVDIR] [-f FIGDIR] h5input ycoord xcoord

positional arguments:
  h5input               input h5 file
  ycoord                y coord of pixel to plot
  xcoord                x coord of pixel to plot

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         increase output verbosity
  -c CSVDIR, --csvdir CSVDIR
                        csv file output dir
  -f FIGDIR, --figdir FIGDIR
                        fig output dir
                        
                        


python plot_hyperspectral_pixel_spectras_from_hdf5_argparse.py -c csv -f figs ~/Downloads/Files/NEON_D17_SJER_DP1_20180401_185358_reflectance.h5 120 120


