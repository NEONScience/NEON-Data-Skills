---
syncID: c31429a97db04e868c75bb6866b2a039
title: "Setup GitHub Working Directory - Quick Intro to Bash"
description: "This page reviews how to check that github is installed on your computer. It also provides a quick overview of Bash shell. Finally we will setup a working GitHub directory."
dateCreated: 2014-05-06
authors: Materials adapted from Software Carpentry by NEON staff
contributors:
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries:
topics: data-management
subtopics: 
languagesTool: git, bash
dataProduct:
code1: 
tutorialSeries:
---

## Checklist
Once you have Git, Bash, R, and RStudio installed, you are ready to configure 
Git. 

On this page you will:

*  Create a directory for all future GitHub repositories created on your computer

To ensure Git is properly installed and to create a working directory for GitHub, 
you will need to know a bit of shell. Please find a crash course below.

## Crash Course in Shell 

The Unix shell has been around longer than most of its users have been alive. 
It has survived so long because it’s a power tool that allows people to do 
complex things with just a few keystrokes. More importantly, it helps them 
combine existing programs in new ways and automate repetitive tasks so they 
aren’t typing the same things over and over again. Use of the shell is 
fundamental to using a wide range of other powerful tools and computing 
resources (including “high-performance computing” supercomputers). 

This section is an abbreviated form of 
<a href="http://swcarpentry.github.io/shell-novice/" target="_blank">Software Carpentry’s The Unix Shell for Novice’s</a> 
workshop lesson series. Content and wording (including all the above) is heavily
copied and credit is due to those creators 
(<a href=" https://github.com/swcarpentry/shell-novice/blob/gh-pages/AUTHORS" target="_blank">full author list</a>).

Our goal with shell is to:

* Set up the directory where we will store all of the GitHub repositories 
during the Institute, 
* Make sure Git is installed correctly, and 
* Gain comfort using bash so that we can use it to work with Git in Week 2. 

## Accessing Shell 
How one accesses the shell depends on the operating system being used. 

* OS X: The bash program is called Terminal. You can search for it in Spotlight. 
* Windows: Git Bash came with your download of Git for Windows. Search Git Bash. 
* Linux: Default is usually bash, if not, type `bash` in the terminal.

## Bash Commands 

```bash
$ 
```

The dollar sign is a **prompt**, which shows us that the shell is waiting for 
input; your shell may use a different character as a prompt and may add 
information before the prompt. 

When typing commands, either from these tutorials or from other sources, do not 
type the prompt (`$`), only the commands that follow it.
In these tutorials, subsequent lines that follow a prompt and do not start with 
`$` are the output of the command. 

### listing contents - ls
Next, let's find out where we are by running a command called `pwd` -- print 
working directory. At any moment, our **current working directory** is our 
current default directory. I.e., the directory that the computer assumes we 
want to run commands in unless we explicitly specify something else. Here, the 
computer's response is `/Users/neon`, which is NEON’s **home directory**:

```bash
$ pwd

/Users/neon
```

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip:** Home Directory Variation - The home 
directory path will look different on different operating systems. On Linux it 
may look like `/home/neon`, and on Windows it will be similar to
 `C:\Documents and Settings\neon` or `C:\Users\neon`. 
(It may look slightly different for different versions of Windows.) 
In future examples, we've used Mac output as the default, Linux and Windows 
output may differ slightly, but should be generally similar. 
</div>

If you are not, by default, in your home directory, you get there by typing: 

```bash

$ cd ~

```

Now let's learn the command that will let us see the contents of our own 
file system. We can see what's in our home directory by running `ls` --listing.

```bash
$ ls

Applications   Documents   Library   Music   Public
Desktop        Downloads   Movies    Pictures
```

(Again, your results may be slightly different depending on your operating 
system and how you have customized your filesystem.)

`ls` prints the names of the files and directories in the current directory in
alphabetical order, arranged neatly into columns.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip:** What is a directory? That is a folder! Read this section on
<a href="http://neondataskills.org/R/Set-Working-Directory#directory-vs-folder" target="_blank"> Directory & Folder </a>
if you find the wording confusing.
</div> 

### Change directory -- cd
Now we want to move into our Documents directory where we will create a 
directory to host our GitHub repository (to be created in Week 2). The command 
to change locations is `cd` followed by a directory name if it is a 
sub-directory in our current working directory or a file path if not.
`cd` stands for "change directory", which is a bit misleading: the command 
doesn't change the directory, it changes the shell's idea of what directory we 
are in.

To move to the Documents directory, we can use the following series of commands 
to get there: 

```bash
$ cd Documents
```

These commands will move us from our home directory into our Documents 
directory. `cd` doesn't print anything, but if we run `pwd` after it, we can 
see that we are now in `/Users/neon/Documents`.

If we run `ls` now, it lists the contents of `/Users/neon/Documents`, because 
that's where we now are:

```bash
$ pwd

/Users/neon/Documents
```
```bash
$ ls


data/  elements/  animals.txt  planets.txt  sunspot.txt
```

To use `cd`, you need to be familiar with paths, if not, read the section on 
<a href="http://neondataskills.org/R/Set-Working-Directory#full-base-and-relative-paths" target="_blank"> Full, Base, and Relative Paths </a>.

### Make a directory -- mkdir
Now we can create a new directory called `GitHub` that will contain our GitHub 
repositories when we create them later. 
We can use the command `mkdir NAME`-- “make directory”

```bash
$ mkdir GitHub
```
There is not output. 

Since `GitHub` is a relative path (i.e., doesn't have a leading slash), the 
new directory is created in the current working directory:

```bash
$ ls

data/  elements/  GitHub/  animals.txt  planets.txt  sunspot.txt
```

<i class="fa fa-star"></i>**Data Tip:** This material is a much abbreviated form of the 
<a href="http://swcarpentry.github.io/shell-novice/" target="_blank"> Software Carpentry Unix Shell for Novices</a>
workhop. Want a better understanding of shell? Check out the full series!
</div>

## Is Git Installed Correctly? 

All of the above commands are bash commands, not Git specific commands. We 
still need to check to make sure git installed correctly. One of the easiest 
ways is to check to see which version of git we have installed. 

Git commands start with `git`. 
We can use `git --version` to see which version of Git is installed

```bash
$ git --version

git version 2.5.4 (Apple Git-61)
```

If you get a git version number, then Git is installed! 

If you get an error, Git isn’t installed correctly. Reinstall and repeat. 

 
## Setup Git Global Configurations
Now that we know Git is correctly installed, we can get it set up to work with. 

The text below is modified slightly from 
<a href="http://swcarpentry.github.io/git-novice/02-setup.html" target="_blank"> Software Carpentry's Setting up Git lesson</a>. 

When we use Git on a new computer for the first time, we need to configure a 
few things. Below are a few examples of configurations we will set as we get 
started with Git:

* our name and email address,
* to colorize our output,
* what our preferred text editor is,
* and that we want to use these settings globally (i.e. for every project)

On a command line, Git commands are written as `git verb`, where `verb` is what
we actually want to do. 

Set up you own git with the folowing command, using your own information instead
of NEON's. 

```bash
$ git config --global user.name "NEON Science"
$ git config --global user.email "neon@BattelleEcology.org"
$ git config --global color.ui "auto"
```

Then set up your favorite text editor following this table:

| Editor       | Configuration command              |
|:-------------------|:-------------------------------------------------|
| nano        | `$ git config --global core.editor "nano -w"`  |
| Text Wrangler   | `$ git config --global core.editor "edit -w"`  |
| Sublime Text (Mac) | `$ git config --global core.editor "subl -n -w"` |
| Sublime Text (Win, 32-bit install) | `$ git config --global core.editor "'c:/program files (x86)/sublime text 3/sublime_text.exe' -w"` |
| Sublime Text (Win, 64-bit install) | `$ git config --global core.editor "'c:/program files/sublime text 3/sublime_text.exe' -w"` |
| Notepad++ (Win)  | `$ git config --global core.editor "'c:/program files (x86)/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"`|
| Kate (Linux)    | `$ git config --global core.editor "kate"`    |
| Gedit (Linux)   | `$ git config --global core.editor "gedit -s -w"`  |
| emacs       | `$ git config --global core.editor "emacs"`  |
| vim        | `$ git config --global core.editor "vim"`  |

The four commands we just ran above only need to be run once: 
the flag `--global` tells Git to use the settings for every project in your user
 account on this computer.

You can check your settings at any time:

```bash
$ git config --list
```

You can change your configuration as many times as you want; just use the
same commands to choose another editor or update your email address.

Now that Git is set up, you will be ready to start the Week 2 materials to learn 
about version control and how Git & GitHub work. 

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i>**Data Tip:** 
<a href="https://desktop.github.com/" target="_blank"> GitDesktop </a>
is a GUI (one of many) for 
using GitHub that is free and available for both Mac and Windows operating 
systems. In NEON Data Skills workshops & Data Institutes will only teach how to 
use Git through command line, and not support use of GitDesktop 
(or any other GUI), however, you are welcome to check it out and use it if you 
would like to. 
</div>
