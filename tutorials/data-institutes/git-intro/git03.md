---
syncID: 79a2980fe531424fb457b9c3ca61db6c 
title: "Git 03: Git Clone - Work Locally On Your Computer"
description: "This tutorial teaches you how to clone or copy a
GitHub repository to your local computer."
dateCreated: 2016-05-06
authors:
contributors:
estimatedTime:
packagesLibraries:
topics: data-management
languagesTool: git
dataProduct:
code1:
tutorialSeries: [git-github]
urlTitle: github-git-clone
---

This tutorial covers how to `clone` a github.com repo to your computer so
that you can work locally on files within the repo.

<div id="ds-objectives" markdown="1">
## Learning Objectives
At the end of this activity, you will be able to:

* Be able to use the `git clone` command to create a local version of a GitHub
repository on your computer.

## Additional Resources:

* <a href="http://rogerdudler.github.io/git-guide/files/git_cheat_sheet.pdf" target="_blank"> Diagram of Git Commands </a>
-- this diagram includes more commands than we will cover in this series but
includes all that we use for our standard workflow.
* <a href="https://help.github.com/articles/good-resources-for-learning-git-and-github/" target="_blank"> GitHub Help Learning Git resources.</a>

</div>

## Clone - Copy Repo To Your Computer
In the previous tutorial, we used the github.com interface to fork the central NEON repo.
By forking the NEON repo, we created a copy of it in our github.com account.


<figure>
 <a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/git_fork_emphasis.png">
 <img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/git_fork_emphasis.png" width="70%"></a>
 <figcaption>When you fork a reposiotry on the github.com website, you are creating a
 duplicate copy of it in your github.com account. This is useful as a backup
 of the material. It also allows you to edit the material without modifying
 the original repository.
 Source: National Ecological Observatory Network (NEON)
 </figcaption>
</figure>

Now we will learn how to create a local version of our forked repo on our
laptop, so that we can efficiently add to and edit repo content.

<figure>
 <a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/git_clone.png">
 <img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/git_clone.png" width="70%"></a>
 <figcaption>When you clone a repository to your local computer, you are creating a
 copy of that same repo <strong>locally </strong> on your computer. This
 allows you to edit files on your computer. And, of course, it is also yet another
 backup of the material!
 Source: National Ecological Observatory Network (NEON)
 </figcaption>
</figure>


### Copy Repo URL

Start from the github.com interface:

1. Navigate to the repo that you want to clone (copy) to your computer --
this should be `YOUR-USER-NAME/DI-NEON-participants`.  
2. Click on the **Clone or Download** dropdown button and copy the URL of the repo.

 <figure>
	<a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/Git-ForkScreenshot-clone.png">
	<img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/Git-ForkScreenshot-clone.png"></a>
	<figcaption>The clone or download drop down allows you to copy the URL that
	you will need to clone a repository. Download allows you to download a .zip file
	containing all of the files in the repo.
	Source: National Ecological Observatory Network (NEON).
	</figcaption>
</figure>


Then on your local computer:

1. Your computer should already be setup with Git and a bash shell interface.
If not, please refer to the
<a href="{{ site.baseurl}}/workshop-event/NEON-DI-2017/setup " target="_blank"> Institute setup materials </a>
before continuing.
2. Open bash on your computer and navigate to the local GitHub directory that
you created using the Set-up Materials.

To do this, at the command prompt, type:

    $ cd ~/Documents/GitHub

Note: If you have stored your GitHub directory in a location that is different
- i.e. it is not `/Documents/GitHub`, be sure to adjust the above code to
represent the actual path to the GitHub directory on your computer.

Now use `git clone` to clone, or create a copy of, the entire repo in the
GitHub directory on your computer.


    # clone the forked repo to our computer
    $ git clone https://github.com/neon/DI-NEON-participants.git

<div id="ds-dataTip">
<i class="fa fa-star"></i>**Data Tip:**
Are you a Windows user and are having a hard time copying the URL into shell?
You can copy and paste in the shell environment **after** you
have the feature turned on. Right click on your bash shell window (at the top)
and select "properties". Make sure "quick edit" is checked. You should now be
able to copy and paste within the bash environment.
</div>


The output shows you what is being cloned to your computer.


    Cloning into 'DI-NEON-participants.git'...
    remote: Counting objects: 3808, done.
    remote: Total 3808 (delta 0), reused 0 (delta 0), pack-reused 3808
    Receiving objects: 100% (3808/3808), 2.92 MiB | 2.17 MiB/s, done.
    Resolving deltas: 100% (2185/2185), done.
    Checking connectivity... done.
    $

Note: The output numbers that you see on your computer, representing the total file
size, etc, may differ from the example provided above.

### View the New Repo

Next, let's make sure the repository is created on your
computer in the location where you think it is.

At the command line, type `ls` to list the contents of the current
directory.

    # view directory contents
    $ ls

Next, navigate to your copy of the  data institute repo using `cd` or change
directory:

    # navigate to the NEON participants repository
    $ cd DI-NEON-participants

    # view repository contents
    $ ls

    404.md			_includes		code
    ISSUE_TEMPLATE.md	_layouts		images
    README.md		_posts			index.md
    _config.yml		_site			institute-materials
    _data			assets			org

Alternatively, we can view the local repo `DI-NEON-participants` in a finder (Mac)
or Windows Explorer (Windows) window. Simply open your Documents in a window and
navigate to the new local repo.

Using either method, we can see that the file structure of our cloned repo
exactly mirrors the file structure of our forked GitHub repo.

<div id="ds-dataTip">
<i class="fa fa-star"></i>**Thought Question:**
Is the cloned version of this repo that you just created on your laptop, a
direct copy of the NEON central repo -OR- of your forked version of the NEON
central repo?
</div>


## Summary Workflow -- Create a Local Repo

In the github.com interface:

* Copy URL of the repo you want to work on locally

In shell:

* `git clone URLhere`

Note: that you can copy the URL of your repository directly from GitHub.

****

*Got questions? No problem. Leave your question in the comment box below.
It's likely some of your colleagues have the same question, too! And also
likely someone else knows the answer.*
