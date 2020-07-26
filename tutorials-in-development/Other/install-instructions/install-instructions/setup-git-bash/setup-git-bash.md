---
title: "Install Bash/Shell and Git"
contributors: Garrett M. Williams
dataProduct:
  code1: null
  tutorialSeries: null
  urlTitle: setup-git-bash
dateCreated: '2020-05-08'
description: This page outlines the tools and resources that you will need to work
  on collaborative data projects.
estimatedTime: 0.5 - 1.0 hours
languagesTool: git
packagesLibraries:
  topics: data-management
syncID: 
authors: Materials adapted from Software Carpentry by NEON staff
---

## Install Bash/Shell

### Install Bash for Windows

1. Download the Git for Windows <a href="https://git-for-windows.github.io/">installer</a>.
1. Run the installer and follow the steps bellow: 

[//]: # (ISSUE: The steps for options are outdated)

   1. Welcome to the Git Setup Wizard: Click on "Next".
   1. Information: Click on "Next".
   1. Select Destination Location: Click on "Next".
   1. Select Components: Click on "Next".
   1. Select Start Menu Folder: Click on "Next".
   1. Adjusting your PATH environment: **Select "Use Git from the Windows 
   Command Prompt" and click on "Next".** If you forgot to do this programs 
   that you need for the event will not work properly. If this happens 
   rerun the installer and select the appropriate option.
   1. Configuring the line ending conversions: Click on "Next". **Keep 
   "Checkout Windows-style, commit Unix-style line endings" selected.**
   1. Configuring the terminal emulator to use with Git Bash: **Select "Use 
   Windows' default console window" and click on "Next".**
   1. Configuring experimental performance tweaks: Click on "Next".
   1. Completing the Git Setup Wizard: Click on "Finish".
   
This will provide you with both Git and Bash in the Git Bash program.

### Install Bash for Mac OS X

[//]: (ISSUE zsh is the default, not bash, bash is still installed on macOS, but is an old version due to Apple not supporting GPLv3 liscences, and may need to be updated)

The default shell in all versions of Mac OS X is bash, so no need to 
install anything. You access bash from the Terminal (found in 
`/Applications/Utilities`). You may want to keep Terminal in your dock 
for this workshop.

### Install Bash for Linux

The default shell is usually Bash, but if your machine is set up differently you can run it by opening a terminal and typing bash. There is no need to install anything.

## Git Setup

Git is a version control system that lets you track who made changes to what when 
and has options for easily updating a shared or public version of your code on 
<a href="https://github.com/">GitHub</a>. You will need a <a href="https://help.github.com/en/github/getting-started-with-github/supported-browsers">supported</a> web browser (current versions of Chrome, Firefox, Safari, or Microsoft Edge). 

Git installation instructions borrowed and modified from Software 
Carpentry.

### Git for Windows

Git should be installed on your computer as part of your Bash install.

### Git on Mac OS X

[//]: (ISSUE: outdated, need instructions for macOS)

<a href="https://www.youtube.com/watch?v=9LQhwETCdwY">Video Tutorial</a>

Install Git on Macs by downloading and running the most recent installer 
for "mavericks" if you are using OS X 10.9 and higher -or- if using an 
earlier OS X, choose the most recent "snow leopard" installer, from 
<a href="http://sourceforge.net/projects/git-osx-installer/files/">this list</a>. After installing Git, there will not be anything in your 
`/Applications` folder, as Git is a command line program.

**Data Tip:** If you are running Mac OSX El Capitan, you might encounter 
errors when trying to use git. Make sure you update XCODE. <a href="http://stackoverflow.com/questions/32893412/command-line-tools-not-working-os-x-el-capitan">Read more - a Stack Overflow Issue</a>.

### Git on Linux

If Git is not already available on your machine you can try to install it 
via your distro's package manager. For Debian/Ubuntu run `sudo apt-get install git` 
and for Fedora run `sudo yum install git`. 
