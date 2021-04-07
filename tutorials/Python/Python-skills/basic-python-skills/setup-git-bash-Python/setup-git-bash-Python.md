---
syncID: f98c089c370d441c9af10d1ad9f0f9fd
title: "Install Git, Bash Shell, Python"
description: "This page outlines the tools and resources that you will need to
 complete the Data Institute activities."
dateCreated: 2017-04-10
dateUpdated: 2020-04-20
authors: Materials adapted from Data Carpentry by NEON staff
contributors: 
estimatedTime: 
packagesLibraries: 
topics: data-management 
languagesTool: Git, Bash, Python
dataProduct: 
code1: 
tutorialSeries: 
urlTitle: setup-git-bash-python
---


This page outlines the tools and resources that you will need to install Git, Bash and Python applications onto your computer as the first step  of our Python skills tutorial series.

## Checklist
Detailed directions to accomplish each objective are below. 

* Install Bash shell (or shell of preference) 
* Install Git 
* Install Python 3.x


<h3 id="bash-setup">Bash/Shell Setup</h3>

<h4 id="shell-windows">Install Bash for Windows</h4>
<ol>
<li>Download the Git for Windows <a href="https://git-for-windows.github.io/" target="_blank">installer</a>.</li>
<li>Run the installer and follow the steps bellow:
  <ol>
	<!-- Git 2.6.1 Setup -->
	<!-- Welcome to the Git Setup Wizard -->
	<li>Welcome to the Git Setup Wizard: Click on "Next".</li>
	<!-- Information -->
	<li>Information: Click on "Next".</li>
	<!-- Select Destination Location -->
	<li>Select Destination Location: Click on "Next".</li>
	<!-- Select Components -->
	<li>Select Components: Click on "Next".</li>
	<!-- Select Start Menu Folder -->
	<li>Select Start Menu Folder: Click on "Next".</li>
	<!-- Adjusting your PATH environment -->
	<li>Adjusting your PATH environment: 
	  <strong>
		Select "Use Git from the Windows Command Prompt" and click on "Next".
	  </strong>
		If you forgot to do this programs that you need for the event will not work properly.
		If this happens rerun the installer and select the appropriate option.
	</li>
	<!-- Configuring the line ending conversions -->
	<li>
	  Configuring the line ending conversions: Click on "Next".
	  <strong>
		Keep "Checkout Windows-style, commit Unix-style line endings" selected.
	  </strong>
	</li>
	<!-- Configuring the terminal emulator to use with Git Bash -->
	<li> Configuring the terminal emulator to use with Git Bash:
	  <strong>
		 Select "Use Windows' default console window" and click on "Next".
	  </strong>
	</li>
	<!-- Configuring experimental performance tweaks -->
	<li>Configuring experimental performance tweaks: Click on "Next".</li>
	<!-- Installing -->
	<!-- Completing the Git Setup Wizard -->
	<li>Completing the Git Setup Wizard: Click on "Finish".</li>
  </ol>
</li>
</ol>
<p>This will provide you with both Git and Bash in the Git Bash program.</p>


<h4 id="shell-macosx">Install Bash for Mac OS X</h4>
<p>
The default shell in all versions of Mac OS X is bash, so no
need to install anything.  You access bash from the Terminal
(found in
<code>/Applications/Utilities</code>).  You may want to keep
Terminal in your dock for this workshop.
</p>


<h4 id="shell-linux">Install Bash for Linux</h4>
<p>
The default shell is usually Bash, but if your
machine is set up differently you can run it by opening a
terminal and typing <code>bash</code>.  There is no need to
install anything.
</p>

<p>
</p>

<h3 id="git-setup">Git Setup</h3>

Git is a version control system that lets you track who made changes to what
when and has options for easily updating a shared or public version of your code
on <a href="https://github.com/" target="_blank" >GitHub</a>. You will need a
<a href="https://help.github.com/articles/supported-browsers/" target="_blank">supported</a>
web browser (current versions of Chrome, Firefox or Safari, or Internet Explorer
version 9 or above).
<p>
Git installation instructions borrowed and modified from
<a href="http://software-carpentry.org/" target="_blank"> Software Carpentry</a>.</p>

<h4 id="git-windows">Git for Windows</h4>
Git should be installed on your computer as part of your Bash install.

<h4 id="git-mac">Git on Mac OS X</h4>
<a href="https://www.youtube.com/watch?v=9LQhwETCdwY" target="_blank">Video Tutorial</a>
<p>

Install Git on Macs by downloading and running the most recent installer for
"mavericks" if you are using OS X 10.9 and higher -or- if using an
earlier OS X, choose the most recent "snow leopard" installer, from
<a href="http://sourceforge.net/projects/git-osx-installer/files/"  target="_blank">this list</a>.
After installing Git, there will not be anything in your
<code>/Applications</code> folder, as Git is a command line program. </p>


<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:**
If you are running Mac OSX El Capitan, you might encounter errors when trying to
use git. Make sure you update XCODE.
<a href="http://stackoverflow.com/questions/32893412/command-line-tools-not-working-os-x-el-capitan" target="_blank">
  Read more - a Stack Overflow Issue.</a>
</div>

<h4 id="git-linux">Git on Linux</h4>

If Git is not already available on your machine you can try to
install it via your distro's package manager. For Debian/Ubuntu run
<code>sudo apt-get install git</code> and for Fedora run
<code>sudo yum install git</code>.
<p>
</p>


<h3 id="Python-setup"> Setting Up Python </h3>

<a href="http://python.org" target="_blank">Python</a> is a popular language for
scientific computing and data science, as well as being a great for 
general-purpose programming. Installing all of the scientific packages 
individually can be a bit difficult, so we recommend using an all-in-one 
installer, like Anaconda.

Regardless of how you choose to install it, **please make sure your environment 
is set up with Python version 3.7 (at the time of writing, the `gdal` package did not work 
with the newest Python version 3.6). Python 2.x is quite different from Python 3.x
so you do need to install 3.x and set up with the 3.7 environment. 

We will teach using Python in the 
<a href="http://jupyter.org" target="_blank">Jupyter Notebook environment</a>, 
a programming environment that runs in a web browser. For this to work you will 
need a reasonably up-to-date browser. The current versions of the Chrome, Safari 
and Firefox browsers are all 
<a href="http://ipython.org/ipython-doc/2/install/install.html#browser-compatibility" target="_blank">supported</a>
(some older browsers, including Internet Explorer version 9 and below, are not).
You can choose to not use notebooks in the course, however, we do 
recommend you download and install the library so that you can explore this tool.


<h4 id="Python-windows"> Windows </h4>

Download and install 
<a href="https://www.anaconda.com/products/individual" target="_blank" >Anaconda</a>.
Download the default Python 3 installer (3.7). Use all of the defaults for 
installation *except* make sure to check **Make Anaconda the default Python**.


<h4 id="Python-mac">Mac OS X </h4>

Download and install 
<a href="https://www.anaconda.com/products/individual" target="_blank">Anaconda</a>.
Download the Python 3.x installer, choosing either the graphical installer or the 
command-line installer (3.7). For the graphical installer, use all of the defaults for 
installation. For the command-line installer open Terminal, navigate to the
directory with the download then enter: 

`bash Anaconda3-2020.11-MacOSX-x86_64.sh` (or whatever you file name is)

<h4 id="Python-linux">Linux </h4>
Download and install 
<a href="https://www.anaconda.com/products/individual" target="_blank">Anaconda</a>.
Download the installer that matches your operating system and save it in your 
home folder. Download the default Python 3 installer.

Open a terminal window and navigate to your downloads folder. Type 

`bash Anaconda3-2020.11-Linux-ppc64le.sh`

and then press tab. The name of the file you just downloaded should appear.

Press enter. You will follow the text-only prompts.  When there is a colon at 
the bottom of the screen press the down arrow to move down through the text. 
Type `yes` and press enter to approve the license. Press enter to 
approve the default location for the files. Type `yes` and press 
enter to prepend Anaconda to your `PATH` (this makes the Anaconda 
distribution the default Python).

<h2 id="package-install"> Install Python packages</h2>

We need to install several packages to the Python environment to be able to work
with the remote sensing data

* gdal 
* h5py

If you are new to working with command line you may wish to complete the next
setup instructions which provides and intro to command line (bash) prior to 
completing these package installation instructions. 

<h4 id="package-windows">Windows</h4>

Create a new Python 3.7 environment by opening Windows Command Prompt and typing 

`conda create –n py37 python=3.7 anaconda`

When prompted, activate the py37 environment in Command Prompt by typing 

`activate py37`

You should see (py37) at the beginning of the command line. You can also test 
that you are using the correct version by typing `python --version`.

Install Python package(s): 

* gdal: `conda install gdal`
* h5py: `conda install h5py`

Note: You may need to only install gdal as the others may be included in the 
default. 

<h4 id="package-mac">Mac OS X</h4>

Create a new Python 3.7 environment by opening Terminal and typing 

`conda create –n py37 python=3.7 anaconda`

This may take a minute or two. 

When prompted, activate the py37 environment in Command Prompt by typing 

`source activate py37`

You should see (py37) at the beginning of the command line. You can also test 
that you are using the correct version by typing `python --version`.

Install Python package(s): 

* gdal: `conda install gdal`
* h5py: `conda install h5py`


<h4 id="package-linux">Linux</h4>
Open default terminal application
(on Ubuntu that will be <em>gnome-terminal</em>).

Launch Python. 

Install Python package(s): 

* gdal: `conda install gdal`
* h5py: `conda install h5py`

<h2 id="jupyter-notebook">Set up Jupyter Notebook Environment</h2>

In your terminal application, navigate to the directory (`cd`) that where you
want the Jupyter Notebooks to be saved (or where they already exist). 

Open Jupyter Notebook with 

`jupyter notebook`

Once the notebook is open, check which version of Python you are in by using the 
prompts

    # check what version of Python you are using.
    import sys
    sys.version

You should now be able to work in the notebook. 

The `gdal` package that occasionally has problems with some versions of Python. 
Therefore test out loading it using 

`import gdal`.  

<h3 id="additional-resources"> Additional Resources</h3>

* <a href="https://sites.google.com/site/pythonbootcamp/preparation" target="_blank"> Setting up the Python Environment section from the Python Bootcamp</a>
* <a href="https://conda.io/docs/using/envs.html" target="_blank"> Conda Help: setting up an environment</a>
* <a href="https://ipython.readthedocs.io/en/latest/install/kernel_install.html" target="_blank"> iPython documentation: Kernals </a>

<p>
</p>


