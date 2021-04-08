---
syncID: 1d30df8e044b4c9e9098ac47310a0380
title: "Git 02: GitHub.com - Repos & Forks"
description: "This tutorial teaches you how to fork, or copy, an existing GitHub repository."
dateCreated: 2016-05-06
authors: Megan A. Jones
contributors: Felipe Sanchez
estimatedTime: 30 minutes
packagesLibraries:
topics: data-management, rep-sci
languagesTool: git
dataProduct:
code1:
tutorialSeries: [git-github]
urlTitle: github-forks-repos
---


In this tutorial, we will fork, or create a copy in your github.com account,
an existing GitHub repository. We will also explore the github.com interface.

<div id="ds-objectives" markdown="1">
## Learning Objectives
At the end of this activity, you will be able to:

* Create a GitHub account.
* Know how to navigate to and between GitHub repositories.
* Create your own fork, or copy, a GitHub repository.
* Explain the relationship between your forked repository and the master
repository it was created from.

****

#### Additional Resources


* <a href="http://rogerdudler.github.io/git-guide/files/git_cheat_sheet.pdf" target="_blank"> Diagram of Git Commands </a>
-- this diagram includes more commands than we will
learn in this series but includes all that we use for our standard workflow.
* <a href="https://help.github.com/articles/good-resources-for-learning-git-and-github/" target="_blank"> GitHub Help Learning Git resources </a>

</div>

## Create An Account
If you do not already have a GitHub account, go to <a href="http://github.com" target="_blank" >GitHub </a> and sign up for
your free account. Pick a username that you like! This username is what your
colleagues will see as you work with them in GitHub and Git.

Take a minute to setup your account. If you want to make your account more
recognizable, be sure to add a profile picture to your account!

If you already have a GitHub account, simply sign in.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** Are you a student? Sign up for the
<a href="https://education.github.com/pack" target="_blank" >Student Developer Pack</a>
and get the Git Personal account free (with unlimited private repos and other
discounts/options; normally $7/month).
</div>

## Navigate GitHub

### Repositories, AKA Repos

Let's first discuss the repository or "repo". (The cool kids say repo, so we will
jump on the git cool kid bandwagon) and use "repo" from here on in. According to
<a href="https://help.github.com/articles/github-glossary/" target="_blank"> the GitHub glossary</a>:

> A repository is the most basic element of GitHub. They're easiest to imagine
as a project's folder. A repository contains all of the project files (including
documentation), and stores each file's revision history. Repositories can have
multiple collaborators and can be either public or private.

In the Data Institute, we will share our work in the
<a href="https://github.com/NEONScience/DI-NEON-participants" target="_blank">DI-NEON-participants repo.</a>

### Find an Existing Repo

The first thing that you'll need to do is find the DI-NEON-participants repo.
You can find repos in two ways:

1. Type  “**DI-NEON-participants**”  in the github.com search bar to find the repository.
2. Use the repository URL if you have it - like so:
<a href="https://github.com/NEONScience/DI-NEON-participants" target="_blank"> https://github.com/NEONScience/DI-NEON-participants</a>.

### Navigation of a Repo Page

Once you have found the Data Institute participants repo, take 5 minutes
to explore it.


#### Git Repo Names
First, get to know the repository naming convention. Repository names all take
the format:

**OrganizationName**/**RepositoryName**

So the full name of our repository is:

 **NEONScience/DI-NEON-participants**

#### Header Tabs

At the top of the page you'll notice a series of tabs. Please focus
on the following 3 for now:

* **Code:** Click here to view structure & contents of the repo.
* **Issues:** Submit discussion topics, or problems that you are having with
the content in the repo, here.
* **Pull Requests:** Submit changes to the repo for review /
acceptance. We will explore pull requests more in the <a href="https://www.neonscience.org/github-pull-requests" target="_blank">
Git 06 tutorial.</a>

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/Git-MasterScreenshot-tabs.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/Git-MasterScreenshot-tabs.png"
	alt="Screenshot of the NEON Data Institute central repository on github.com highlighting the search bar, and six tabs below the repository name including: Code, Issues, Pull Request, Pulse, Graphics, and Settings.">
	</a>
	<figcaption> Screenshot of the NEON Data Institute central repository (note, 
	there has been a slight change in the repo name).
	The github.com search bar is at the top of the page. Notice there are 6
	"tabs" below the repo name including: Code, Issues, Pull Request, Pulse,
	Graphics and Settings. NOTE: Because you are not an administrator for this
	repo, you will not see the "Settings" tab in your browser.
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>



#### Other Text Links

A bit further down the page, you'll notice a few other links:

* **commits:** a commit is a saved and documented change to the content
or structure of the repo. The commit history contains all changes that
have been made to that repo. We will discuss commits more in
<a href="https://www.neonscience.org/github-git-add" target="_blank"> Git 05: Git Add Changes -- Commits </a>.

## Fork a Repository

Next, let's discuss the concept of a fork on the github.com site. A fork is a
copy of the repo that you create in **your account**. You can fork any repo at
any time by clicking the fork button in the upper right hand corner on github.com.

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/GitHubGuides_Bootcamp-Fork.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/GitHubGuides_Bootcamp-Fork.png" width="70%"
	alt="Graphic showing the fork button as it appears on the upper right hand corner of the github website.">
	</a>
	<figcaption> Click on the "Fork" button to fork any repo. Source:
<a href="https://guides.github.com/activities/forking/" target="_blank">GitHub Guides</a>.  
	</figcaption>
</figure>

<figure>
 <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/git_fork_emphasis.png">
 <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/git_fork_emphasis.png" width="70%"
 alt="Graphic showing a fork of the central repository, which creates an exact copy of the repository in our own github account.">
 </a>
 <figcaption>When we fork a repo in github.com, we are telling Git to create an
 exact copy of the repo that we're forking in our own github.com account.
 Once the repo is in our own account, we can edit it as we now own that fork.
 Note that a fork is just a copy of the repo on github.com.
 Source: National Ecological Observatory Network (NEON) 
 </figcaption>
</figure>



 <div id="ds-challenge" markdown="1">
## Activity: Fork the NEON Data Institute Participants Repo

Create your own fork of the DI-NEON-participants now.
</div>


<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:** You can change the name of a forked
repo and it will still be connected to the central repo from which it was forked.
For now, leave it the same.
</div>

## Check Out Your Data Institute Fork

Now, check out your new fork. Its name should be:

 **YOUR-USER-NAME/DI-NEON-participants**.

It can get confusing sometimes moving between a central repo:

* https://github.com/NEONScience/DI-NEON-participants

and your forked repo:

* https://github.com/YOUR-USER-NAME/DI-NEON-participants

A good way to figure out which repo you are viewing is to look at the name of the
repo. Does it contain your username? Or your colleagues'? Or NEON's?

## Your Fork vs the Central Repo

Your fork is *an exact copy*, or completely in sync with, the NEON central repo.
You could confirm this by comparing your fork to the NEON central repository using
the **pull request** option. We will learn about pull requests in
<a href="https://www.neonscience.org/github-pull-requests" target="_blank"> Git06: Sync GitHub Repos with Pull Requests.</a>
For now, take our word for it.

The fork will remain in sync with the NEON central repo until:

1. You begin to make changes to your forked copy of the repo.
2. The central repository is changed or updated by a collaborator.

If you make changes to your forked repo, the changes will not be added to the
NEON central repo until you sync your fork with the NEON central repo.

## Summary Workflow -- Fork a GitHub Repository

On the github.com website:

* Navigate to desired repo that you want to fork.
* Click Fork button.

****

*Have questions? No problem. Leave your question in the comment box below.
It's likely some of your colleagues have the same question, too! And also
likely someone else knows the answer.*
