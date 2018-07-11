# Reproducible analysis and modularizing code

Lesson put together by Naupaka Zimmerman for the 2018 NEON Data Institute.

The goal is to demonstrate a workflow from the start, to think about
what inputs are needs, what outputs are desired, and how to move from
development in a Jupyter notebook to development of a Python script meant to
be operated from the commandline as part of a pipeline-style workflow. It also
serves to introduce learners to the use of git and GitHub during a scientific
coding workflow.

All of the needed files are in the project directory:
`extract_spectra_from_hdf5`

## Steps & Instructor Notes:

Give overview of morning, and emphasize that the goal of the workflow (building on
code learners saw the day before) is to show a conceptual example of a
'more' reproducible workflow. It's worth emphasizing that there is no one
correct way to do this, just some principles to try and follow.

Ask learners to download Atom for editing READMEs and to demonstrate
its git integration.

Also have learners download smaller hdf5 NEON hyperspectral files to work with.
Any NEON hdf5 hyperspectral file will work, but the smaller files help things
process more quickly.

Doi: 10.6084/m9.figshare.6807134
Download all link:   https://ndownloader.figshare.com/articles/6807134/versions/1

Talk though the thought process of defining goals for a coding project,
including think about what variables or inputs are needed, job these
down on whiteboard.

Live coding/demonstrating:

### Setting up a directory, respository, and adding READMEs

Create the following directory structure:

```
project/
  code/
  data/
  output/
    csv/
    figs/
```

Then in gitbash or terminal:

```
git init
git status
```

With Atom, add `README.md` and `data/README.md` files, with appropriate content.
The data directory `README.md` should include an explanation as to why the data
files are not located in the `data` directory, and the doi/URL for the data from
figshare.

The directory should now look like this:

```
project/
  README.md
  code/
  data/
    README.md
  output/
    csv/
    figs/
```

Commit these changes.

```
git add README.md data/README.md
git commit -m "Add README files"
```

### Set up and document conda environment

At terminal, in project directory

```
conda activate py35  # (set up during pre-institute)
conda install h5py gdal pandas IPython

# To export environment file
conda env export > environment.yml

# For other person to use the environment
# conda env create -f <environment-name>.yml
```

Then add and commit that environment file (which contains all of the packages
and versions in the selected conda environment).

```
git add environment.yml
git commit
```

### Hyperspectral analysis in Jupyter notebooks

Run `jupyter notebook` to start a kernel and notebook viewer in the project
folder. Add a new ipynb to the top level.

Start coding, following the ipynb in the `code/instructor_materials` directory
or the html exported version in the `output` directory. Periodically add and
commit.

When finished with notebook, add and commit.

Set up GitHub repo, push to GitHub.

Export ipynb to html, move to output folder, prepend file name with date.
Export ipynb to py, clean and further modify for command-line usage.

The finished version of this script is also in the `code/instructor_materials`
directory.

Demonstrate running command-line script, showing help and verbose/non-verbose
run modes.

```
git add output/
git commit -m "Add in generated output files"
```

Set up new empty repository on GitHub.

Add remote to working repository with `git add remote origin URL-here`.

Push all commits: `git push -u origin master`.

Done!
