---
syncID: 01a3327fae774337ace59ced0f6fd86f
title: "Git 07: Updating Your Repo by Setting Up a Remote"
description: "This tutorial covers how to set up a repository to update your local repo with any any changes from the central repo."
dateCreated: 2017-06-20
authors: Megan A. Jones
contributors: Felipe Sanchez
estimatedTime: 30 minutes
packagesLibraries:
topics: data-management, rep-sci
languagesTool: git
dataProduct: 
code1:
tutorialSeries: [git-github]
urlTitle: git-setup-remote

---


This tutorial covers how to set up a Central Repo as a remote to your local repo 
in order to update your local fork with updates. You want to do this every time
before starting new edits in your local repo.  

<div id="ds-objectives" markdown="1">

## Learning Objectives
At the end of this activity, you will be able to:

* Explain why it is important to update a local repo before beginning edits.
* Update your local repository from a remote (upstream) central repo. 

## Additional Resources

* <a href="http://rogerdudler.github.io/git-guide/files/git_cheat_sheet.pdf" target="_blank"> Diagram of Git Commands: </a>
this diagram includes more commands than we will learn in this series.
* <a href="https://help.github.com/articles/good-resources-for-learning-git-and-github/" target="_blank"> GitHub Help Learning Git resources </a>

</div>

We now have done the following:

1. We've **forked** (made an individual copy of) the `NEONScience/DI-NEON-participants` repo to
our github.com account.
2. We've **cloned** the forked repo - making a copy of it on our local computers.
3. We've added files and content to our local copy of the repo and **committed**
 the changes.
4. We've **pushed** those changes back up to our forked repo on github.com.
5. We've completed a *Pull Request* to update the central repository with our 
changes.  

Once you're all setup to work on your project, you won't need to repeat the fork 
and clone steps. But you do want to update your local repository with any changes 
other's may have added to the central repository. How do we do this? 

We will do this by directly pulling the updates from the central repo to our
local repo by setting up the local repo as a "remote". A "remote" repo is any 
repo which is not the repo that you are currently working in. 

<figure class="half">
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/git-fork-clone-flow.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/git-fork-clone-flow.png" width="70%"
	alt="Graphic showing the entire workflow after you have forked and cloned the repository. You will fork and clone the repository only once.">
	</a>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/pre-institute-content/pre-institute2-git/git-fork-loop.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/pre-institute-content/pre-institute2-git/git-fork-loop.png" width="70%"
	alt="Graphic showing the entire workflow once a repository has been established. Subsequent updates to the forked repository from the central repository will be made by setting it up as a remote and pulling from it using the git pull command.">
	</a>
	<figcaption>LEFT: You will fork and clone a repo only <strong> once </strong>. RIGHT: After that,
	you will update your fork from the central repository by setting
	it up as a remote and pulling from it with <code> git pull </code>.
 	Source: National Ecological Observatory Network (NEON)
 </figcaption>
</figure>

## Update, then Work

Once you've established working in your repo, you should follow these steps
when starting to work each time in the repo:

1. Update your local repo from the central repo (`git pull upstream master`).
1. Make edits, save, `git add`, and `git commit` all in your local repo.
1. Push changes from local repo to your fork on github.com (`git push origin master`)
1. Update the central repo from your fork (`Pull Request`)
1. Repeat. 

Notice that we've already learned how to do steps 2-4, now we are completing 
the circle by learning to update our local repo directly with any changes from 
the central repo. 

The order of steps above is important as it ensures that you incorporate any
changes that have been made to the NEON central repository into your forked & local
repos prior to adding changes to the central repo. If you do not sync in this order,
you are at greater risk of creating a **merge conflict**.


### What's A Merge Conflict?

A merge conflict
occurs when two users edit the same part of a file at the same time. Git cannot
decide which edit was first and which was last, and therefore which edit should
be in the most current copy. Hence the conflict.

<figure>
	<a href="https://developer.atlassian.com/blog/2015/01/a-better-pull-request/merge-conflict.png">
	<img src="https://developer.atlassian.com/blog/2015/01/a-better-pull-request/merge-conflict.png"
	alt="Graphic showing how merge conflicts may occur when updates are made. Merge conflicts occur when the same part of a script or document has been changed simultaneously and Git can't determine which change should be applied.">
	</a>
	<figcaption> Merge conflicts occur when the same part of a script or
	document has been changed simultaneously and Git can’t determine which change should be
	applied. Source: Atlassian
	</figcaption>
</figure>


## Set up Upstream Remote 

We want to directly update our local repo with any changes made in the central 
repo prior to starting our next edits or additions. To do this we need to set 
up the central repository as an upstream remote for our repo.  

#### Step 1: Get Central Repository URL

First, we need the URL of the central repository. Navigate to the central 
repository in GitHub **NEONScience/DI-NEON-participants**. Select the
green **Clone or Download** button (just like we did when we cloned the repo) to 
copy the URL of the repo. 

#### Step 2: Add the Remote

Second, we need to connect the upstream remote -- the central repository to 
our local repo. 

Make sure you are still in you local repository in bash

First, navigate to the desired directory.

    $ cd ~/Documents/GitHub/DI-NEON-participants

 and then type: 

    $ git remote add upstream https://github.com/NEONScience/DI-NEON-participants.git

Here you are identifying that is is a git command with `git` and then that you 
are adding an upstream remote with the given URL.  



#### Step 3: Update Local Repo


Use `git pull` to sync your local repo with the forked GitHub.com repo.

Second, update local repo using `git pull` with the added directions of 
`upstream` indicating the central repository and `master` specifying which 
branch you are pulling down (remember, branches are a great tool to look into 
once you're comfortable with Git and GitHub, but we aren't going to focus on 
them. Just use `master`). 

    $ git pull upstream master

    remote: Counting objects: 25, done.
    remote: Compressing objects: 100% (15/15), done.
    remote: Total 25 (delta 16), reused 19 (delta 10), pack-reused 0
    Unpacking objects: 100% (25/25), done.
    From https://github.com/NEONScience/DI-NEON-participants
        74d9b7b..463e6f0  master   -> origin/master
    Auto-merging _posts/institute-materials/example.md


**Understand the output:** The output will change with every update, several
things to look for in the output:

* `remote: …`: tells you how many items have changed.
* `From https:URL`: which remote repository is data being pulled from. We set up 
the central repository as the remote but it can be lots of other repos too. 
* Section with + and - : this visually shows you which documents are updated
and the types of edits (additions/deletions) that were made.

Now that you've synced your local repo, let's check the status of the repo.

    $ git status


#### Step 4: Complete the Cycle

Now you are set up with the additions, you will need to add and commit those changes.
Once you've done that, you can push the changes back up to your fork on
github.com.

    $ git push origin master

Now your commits are added to your forked repo on github.com and you're ready 
to repeat the loop with a Pull Request.  


## Workflow Summary

### Syncing Central Repo with Local Repo 

Setting It Up (only do this the initial time)

* Find & copy Central Repo URL
* `git remote add upstream https://github.com/NEONScience/DI-NEON-participants.git`

After Initial Set Up 

* Update your Local Repo & Push Changes
  + `git pull upstream master` - pull down any changes and sync the local repo with the central repo
  + make changes, `git add` and `git commit` 
  + `git push origin master` - push your changes up to your fork
  + Repeat



  ****

  *Have questions? No problem. Leave your question in the comment box below.
  It's likely some of your colleagues have the same question, too! And also
  likely someone else knows the answer.*
