---
layout: post
title: "Document Code with Jupyter Notebooks"
description: "This tutorial cover how to use Jupyter Notebooks to document code."
date: 2017-06-10
dateCreated: 2017-06-10
lastModified: 2017-06-10
estimatedTime:
packagesLibraries:
authors: Megan A. Jones
categories:
tags:
mainTag: JupPy
tutorialSeries: JupPy
code1:
image:
 feature: data-institute-rs.png
 credit:
 creditlink:
permalink: /workshop-event/NEON-DI-2016/rmd-assignment
comments: true
---


There are lots of available resources for learning to use Jupyter Notebooks with 
Python. Instead of duplicating efforts, this tutorial is a directed guide to 
materials created by others so that you become a proficient user of Jupyter Notebooks. 

## Setting up Jupyter Notebooks

You can set up your notebook in several ways. Here we present the Anaconda Python
distribution method so as to follow the 
<a href="{{ site.baseurl }}/setup/setup-git-bash-Python " target="_blank">Data Institute set up instructions</a>. 

### Browser
First, make sure you have an updated browser on which to run the app. Both Mozilla
Firefox and Google Chrome work well.  

### Installation 
Data Institute participants should have already installed Jupyter Notebooks 
through the Anaconda installation during the 
<a href="{{ site.baseurl }}/setup/setup-git-bash-Python " target="_blank">Data Institute set up instructions</a>.

If you install Python using `pip` you can install the Jupyter package with the 
following code. 

<pre><code> 
# Python2
pip install jupyter
# Python 3
pip3 install jupyter
</code></pre>


## Using Jupyter Notebooks

## Launching the Application 

To launch the application either launch it from the Anaconda Navigator or by 
typing `jupyter notebook` into your terminal or command window. 

<pre><code> 
# Launch Jupyter
jupyter notebook
</code></pre>

More information can be found in the **Read the Docs** 
<a href="https://jupyter-notebook-beginner-guide.readthedocs.io/en/latest/execute.html" target="_blank"> Running the Jupyter Notebook</a>. 

## Navigating the Jupyter Python Interface

*The following information is adapted from Griffin Chure's <a href="http://bi1.caltech.edu/code/t0b_jupyter_notebooks.html" target="_blank"> Tutorial 0b: Using Jupyter Notebooks</a>*

If everything launched correctly, you should be able to see a screen which looks 
something like this.  Note that the home directory will be whatever directory you
have navigated to in your terminal before launching Jupyter Notebooks.  

 <figure>
	<a href="{ { site.baseurl }}/images/pre-institute-content/pre-institute3-jupPy/startingNotebook_GriffinChure.png">
	<img src="{ { site.baseurl }}/images/pre-institute-content/pre-institute3-jupPy/startingNotebook_GriffinChure.png">"></a>
	<figcaption> Upon opening the application, you should see a screen similar to this one. 
	Source: Griffin Chure's <a href="http://bi1.caltech.edu/code/t0b_jupyter_notebooks.html" target="_blank"> Tutorial 0b: Using Jupyter Notebooks</a>
	</figcaption>
</figure>

To start a new Python notebook, click on the right-hand side of the application 
window and select `New` (the expanded menu is shown in the screen shot above). 
This will give you several options for new notebook kernels depending on what
is installed on your computer. In the above screenshot, there are two available 
Python kernels and one Matlab kernel. When starting a notebook, you should choose 
`Python 3` if it are available or `conda(root)` . 

Once you start a new notebook, you will be brought to the following screen.

 <figure>
	<a href="{ { site.baseurl }}/images/pre-institute-content/pre-institute3-jupPy/toolbars_GriffinChure.png">
	<img src="{ { site.baseurl }}/images/pre-institute-content/pre-institute3-jupPy/toolbars_GriffinChure.png">"></a>
	<figcaption> Upon opening a new Python notebook, you should see a screen similar to this one. 
	Source: Griffin Chure's <a href="http://bi1.caltech.edu/code/t0b_jupyter_notebooks.html" target="_blank"> Tutorial 0b: Using Jupyter Notebooks</a>
	</figcaption>
</figure>

Welcome to your first look at a Jupyter notebook! 

There are many available buttons for you to click. The three most important 
components of the notebook are highlighted in colored boxes. 

* In **blue** is the **name** of the notebook. By clicking this, you can rename 
the notebook. 
* In **red** is the **cell formatting assignment**. By default, it is registered 
as code, but it can also be set to markdown as described later.
* In **purple**, is the **code cell**. In this cell, you can type an execute 
Python code as well as text that will be formatted in a nicely readable format.

## Writing & running code

*The following information is adapted from Griffin Chure's <a href="http://bi1.caltech.edu/code/t0b_jupyter_notebooks.html" target="_blank"> Tutorial 0b: Using Jupyter Notebooks</a>*

All code you write in the notebook will be in the code cell. You can write 
single lines, to entire loops, to complete functions. As an example, we can 
write and evaluate a print statement in a code cell, as is shown below. 

To exectue the code, we can simply hit `Shift + Enter` while our cursor is in the 
code cell.

	 # This is a comment and is not read by Python
	 print('Hello! This is the print function. Python will print this line below')

	 Hello! This is the print function. Python will print this line below

We can also write a for loop as an example of executing multiple lines of code at once.

	 # Write a basic for loop.
	 for i in range(5):
    # Multiply the value of i by two and assign it to a variable. 
    temp_variable = 2 * i

    # Print the value of the temp variable.
    print(temp_variable)

	 0
	 2
	 4
	 6
	 8


There are two other useful keyboard shortcuts for running code:

* `Alt + Enter` runs the current cell and inserts a new one below
* `Ctrl + Enter` run the current cell and enters command mode.

For more keyboard shortcuts, check out weidadeyue's 
<a href="https://www.cheatography.com/weidadeyue/cheat-sheets/jupyter-notebook/" target="_blank">Shortcut cheatsheet</a>. 

<i class="fa fa-star"></i> **Data Tip:**  Code cells can be executed in any 
order. This means that you can overwrite your current variables by running 
things out of order. When coding in notebooks, be cautions of the order in 
which you run cells.
{: .notice}


If you would like more details on running code in Jupyter Notebooks, please go through the 
following short tutorial by 
<a href="https://nbviewer.jupyter.org/github/jupyter/notebook/blob/master/docs/source/examples/Notebook/Running%20Code.ipynb" target="_blank"> Running Code </a> 
by contributors to the Jupyter project. This tutorial touches on start and stopping 
the kernel and using multiple kernels (e.g., Python and R) in one notebook. 

## Writing Text

*The following information is adapted from Griffin Chure's <a href="http://bi1.caltech.edu/code/t0b_jupyter_notebooks.html" target="_blank"> Tutorial 0b: Using Jupyter Notebooks</a>*

Arguably the most useful component of the Jupyter notebook is the ability to 
interweave code and explanatory text into a single, coherent document. Through
out the Data Institute (and one's everyday workflow), we encourage all code and 
plots should be accompanied with explanatory text. 

Each cell in a notebook can exist either as a code cell or as text-formatting 
cell called a markdown cell. Markdown is a mark-up language that very easily 
converts to other typesetting formats such as HTML and PDF. 

Whenever you make a new cell, it's default assignment will be a code cell. 
This means when you want to write text, you will need to specifically change it 
to a markdown cell. You can do this by clicking on the drop-down menu that reads code' 
(highlighted in red in the second figure of this page) and selecting 'Markdown'. 
You can then type in the code cell and all Python syntax highlighting will be 
removed. 

**Resources for Learning Markdown**

* Review the <a href="{{ site.baseurl }}/reproducible-research/git04" target="_blank"> Pre-Institute Week 2 materials on the basics of Markdown files</a>
* Adam Pritchard's <a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet" target="_blank"> Markdown Cheatsheet </a>

## Saving, quitting, and going home

*The following information is adapted from Griffin Chure's <a href="http://bi1.caltech.edu/code/t0b_jupyter_notebooks.html" target="_blank"> Tutorial 0b: Using Jupyter Notebooks</a>*

Jupyter notebooks are set up to autosave your work every 15 or so minutes. 
However, you should not rely on the autosave feature! Save your work frequently 
by clicking on the floppy disk icon located in the upper left-hand corner of the 
toolbar.

To navigate back to the root of your Jupyter notebook server, you can click on 
the Jupyter logo at any time.

To quit your Jupyter notebook, you can simply close the browser window and the 
Jupyter notebook server running in your terminal. 

## Converting to HTML and PDF

In addition to sharing notebooks in the.ipynb format, it may useful to convert 
these notebooks to highly-portable formats such as HTML and PDF.

To convert, you can either use the dropdown menu option 

File -> download as -> ... 

or via the command line by using the following lines:

	 jupyter nbconvert --to pdf notebook_name.ipynb 

Where "notebook_name.ipynb" matches the name of the notebook you want to convert. Prior to 
converting the notebook you must be in the same working directory as your notebooks.

If you prefer to convert to a different format, like html, you simply change the 
file type. Read more on what formats you can convert to and more about the 
<a href="https://github.com/jupyter/nbconvert" target="_blank"> nbconvert package </a>. 


## Additional Resources

### Using Jupyter Notebooks

* Jupyter Documentation on <a href="https://jupyter.readthedocs.io/en/latest/index.html" target="_blank"> ReadTheDocs </a>
* Griffin Chure's multi-part course on 
<a href="http://bi1.caltech.edu/code/t0a_setting_up_python.html" target="_blank"> Using Jupyter Notebooks for Scientific Computing </a>. 
Much of the material above is adapted from 
<a href="http://bi1.caltech.edu/code/t0b_jupyter_notebooks.html" target="_blank"> Tutorial 0b: Using Jupyter Notebooks </a>. 
* Jupyter Project's <a href="https://nbviewer.jupyter.org/github/jupyter/notebook/blob/master/docs/source/examples/Notebook/Running%20Code.ipynb" target="_blank"> Running Code </a> 
* 


### Using Python 
* Software Carpentry's <href="http://swcarpentry.github.io/python-novice-inflammation/" target="_blank"> Programming with Python workshop </a>
* Data Carpentry's <href="http://www.datacarpentry.org/python-ecology-lesson/" target="_blank"> Python for Ecologists workshop </a>
* Many, many others that a simple web search will bring up...