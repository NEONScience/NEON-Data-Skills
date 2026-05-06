---
syncID: 147dae35152d46cebc3e1eb62b77bc7d
title: "Install Git, Bash Shell, R & RStudio"
description: "This page outlines the tools and resources that you will need to complete the Data Institute activities."
dateCreated: 2014-05-06
authors: Materials adapted from Software Carpentry by NEON staff
contributors:
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries:
topics: data-management
languagesTool: git, bash, R
dataProduct:
code1: 
tutorialSeries:
urlTitle: setup-git-bash-rstudio
---


This page outlines the tools and resources that you will need to get started working on the many R-based tutorials that NEON provides.

## Checklist
This checklist includes the tools that need to be set-up on your computer. Detailed directions to accomplish each objective are below. 

* Install Bash shell (or shell of preference) 
* Install Git 
* Install R & RStudio

<h2 id="bash-setup">Bash/Shell Setup</h2>

<h3 id="shell-windows">Install Bash for Windows</h3>
<ol>
<li>Download the Git for Windows <a href="https://git-for-windows.github.io/" target="_blank">installer</a>.</li>
<li>Run the installer and follow the steps below (these may look slightly different depending on Git version number):
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


<h3 id="shell-macosx">Install Bash for Mac OS X</h3>
<p>
The default shell in all versions of Mac OS X is bash, so no
need to install anything.  You access bash from the Terminal
(found in
<code>/Applications/Utilities</code>).  You may want to keep
Terminal in your dock for this workshop.
</p>


<h3 id="shell-linux">Install Bash for Linux</h3>
<p>
The default shell is usually Bash, but if your
machine is set up differently you can run it by opening a
terminal and typing <code>bash</code>.  There is no need to
install anything.
</p>

<p>
</p>

<h2 id="git-setup">Git Setup</h2>

Git is a version control system that lets you track who made changes to what
when and has options for easily updating a shared or public version of your code
on <a href="https://github.com/" target="_blank" >GitHub</a>. You will need a
<a href="https://help.github.com/articles/supported-browsers/" target="_blank">supported</a>
web browser (current versions of Chrome, Firefox or Safari, or Internet Explorer
version 9 or above).
<p>
Git installation instructions borrowed and modified from
<a href="http://software-carpentry.org/" target="_blank"> Software Carpentry</a>.</p>

<h3 id="git-windows">Git for Windows</h3>
Git should be installed on your computer as part of your Bash install.

<h3 id="git-mac">Git on Mac OS X</h3>
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

<h3 id="git-linux">Git on Linux</h3>

If Git is not already available on your machine you can try to
install it via your distro's package manager. For Debian/Ubuntu run
<code>sudo apt-get install git</code> and for Fedora run
<code>sudo yum install git</code>.
<p>
</p>

<h2 id="R-setup"> Setting Up R & RStudio</h2>

<h3 id="R-windows">Windows R/RStudio Setup</h3>

*  Please visit the <a href="https://cran.r-project.org/" target="_blank">CRAN Website</a> to download the latest version of R for windows.
* Run the .exe file that was just downloaded
* Go to the <a href="https://www.rstudio.com/products/rstudio/download/#download" target="_blank">RStudio Download page</a>
* Download the latest version of Rstudio for Windows
* Double click the file to install it


Once R and RStudio are installed, click to open RStudio. If you don't get any error messages you are set.  If there is an error message, you will need to re-install the program. 

<h3 id="R-mac"> Mac R/RStudio Setup</h3>

* Go to <a href="http://cran.r-project.org" target="_blank">CRAN</a> and click on <i>Download
R for (Mac) OS X</i>
* Select the .pkg file for the version of OS X that you have and the file
will download.
* Double click on the file that was downloaded and R will install
* Go to the <a href="https://www.rstudio.com/products/rstudio/download/#download" target="_blank">RStudio Download page</a>
* Download the latest version of Rstudio for Mac
* Once it's downloaded, double click the file to install it

Once R and RStudio are installed, click to open RStudio. If you don't get any error messages you are set.  If there is an error message, you will need to re-install the program. 


<h3 id="R-linux"> Linux R/RStudio Setup</h3>

* R is available through most Linux package managers. 
You can download the binary files for your distribution
        from <a href="http://cran.r-project.org/index.html" target="_blank">CRAN</a>. Or
        you can use your package manager (e.g. for Debian/Ubuntu
        run <code>sudo apt-get install r-base</code> and for Fedora run
        <code>sudo yum install R</code>). 
* To install RStudio, go to the <a href="https://www.rstudio.com/products/rstudio/download/#download" target="_blank">RStudio Download page</a>
* Under <i>Installers</i> select the version for your distribution.
* Once it's downloaded, double click the file to install it

Once R and RStudio are installed, click to open RStudio. If you don't get any error messages you are set.  If there is an error message, you will need to re-install the program. 

<p>
</p>


