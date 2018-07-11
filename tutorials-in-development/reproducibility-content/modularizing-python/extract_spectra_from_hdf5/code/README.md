Naupaka Zimmerman
July 10, 2018
nzimmerman@usfca.edu

This code folder contains two subdirectories, `in-class` and `instructor_materials`.

The `in-class` folder contains an example notebook that was live-coded in class at the 2018 NEON Data Institute.

The `intructor_materials` folder contains two files, which go from less generalized to more generalized. The idea is to go from developing code to accomplish a task using a Jupyter notebook, taking care to try and abstract input as possible and hard code as little as possible so that the code is later reusable for other inputs. The end goal of the exercise is to export the notebook file to a `.py` file, and adjust it to take commandline parameters via flags passed in and parsed with the `argparse` package.

The first script, and the one that is to be live-coded in class, is `plot_hyperspectral_pixel_spectras_from_hdf5.ipynb`. An html version of this is in the output folder of the parent directory: `output/plot_hyperspectral_pixel_spectras_from_hdf5.html`.

The python script `plot_hyperspectral_pixel_spectras_from_hdf5_argparse.py` has been modified to run from the command line (instead of interactively), and to take both the hdf5 file and the desired pixel as inputs, and to output three figures and a csv file with the spectra for that pixel. There is additional help available in the comment at the top of the script file and when run on the command line with the `-h` or `--help` options.

Example output files from the python script are included in the output directory.
