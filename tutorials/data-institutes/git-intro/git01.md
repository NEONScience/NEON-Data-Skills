---
syncID: d447575df18a45618504010a416da4ed
title: "Git 01: Intro to Git Version Control"
description: "This tutorial introduces the importance of version control in scientific workflows."
dateCreated: 2016-05-06
authors:
contributors:
estimatedTime:
packagesLibraries:
topics: data-analysis
subtopics:
languagesTool: git
dataProduct:
code1:
tutorialSeries: [git-github]
---

In this page, you will be introduced to the importance of version control in
scientific workflows.  

<div id="objectives" markdown="1">
# Learning Objectives
At the end of this activity, you will be able to:

* Explain what version control is and how it can be used.
* Explain why version control is important.
* Discuss the basics of how the Git version control system works.
* Discuss how GitHub can be used as a collaboration tool.

</div>

The text and graphics in the first three sections were borrowed, with some
modifications, from
<a href="http://swcarpentry.github.io/git-novice/" target="_blank"> Software Carpentry's Version Control with Git lessons</a>.

## What is Version Control?

A version control system maintains a record of changes to code and other content.
It also allows us to revert changes to a previous point in time.


<figure>
	<a href="http://www.phdcomics.com/comics/archive/phd101212s.gif">
	<img src="http://www.phdcomics.com/comics/archive/phd101212s.gif"></a>
	<figcaption> Many of us have used the "append a date" to a file name version
 of version control at some point in our lives.  Source: "Piled Higher and
Deeper" by Jorge Cham <a href="http://www.phdcomics.com" target="_blank"> www.phdcomics.com</a>
	</figcaption>
</figure>

## Types of Version control

There are many forms of version control. Some not as good:

* Save a document with a new date (we’ve all done it, but it isn’t efficient)
* Google Docs "history" function (not bad for some documents, but limited in scope).

Some better:

* Mercurial
* Subversion
* Git - which we’ll be learning much more about in this series.


<i class="fa fa-star"></i> **Thought Question:** Do you currently implement
any form of version control in your work?
{: .notice .thought}

<div class="notice" markdown="1">
## More Resources:

* <a href="https://en.wikipedia.org/wiki/List_of_version_control_software" target="_blank">
Visit the version control Wikipedia list of version control platforms.</a>
* <a href="https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control" target="_blank"> Read the Git documentation explaining the progression of version control systems.</a>
</div>

## Why Version Control is Important

Version control facilitates two important aspects of many scientific workflows:

1. The ability to save and review or revert to previous versions.
2. The ability to collaborate on a single project.

This means that you don’t have to worry about a collaborator (or your future self)
overwriting something important. It also allows two people working on the same
document to efficiently combine ideas and changes.

<div class="notice thought" markdown="1">
<i class="fa fa-star"></i> **Thought Questions:** Think of a specific time when
you weren’t using version control that it would have been useful.

* Why would version control have been helpful to your project & work flow?  
* What were the consequences of not having a version control system in place?
</div>

## How Version Control Systems Works

### Simple Version Control Model

A version control system keeps track of what has changed in one or more files
over time. The way this tracking occurs, is slightly different between various
version control tools including `git`, `mercurial` and `svn`. However the
principle is the same.

Version control systems begin with a base version of a document. They then
save the committed changes that you make. You can think of version control
as a tape: if you rewind the tape and start at the base document, then you can
play back each change and end up with your latest version.

 <figure>
	<a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/SWC_Git_play-changes.svg">
	<img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/SWC_Git_play-changes.svg"></a>
	<figcaption> A version control system saves changes to a document, sequentially
  as you add and commit them to the system.
	Source: <a href="http://swcarpentry.github.io/git-novice/01-basics.html" target="_blank"> Software Carpentry </a>
	</figcaption>
</figure>

Once you think of changes as separate from the document itself, you can then
think about “playing back” different sets of changes onto the base document.
You can then retrieve, or revert to, different versions of the document.

The benefit of version control when you are in a collaborative environment is that
two users can make independent changes to the same document.

 <figure>
	<a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/SWC_Git_versions.svg">
	<img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/SWC_Git_versions.svg"></a>
	<figcaption> Different versions of the same document can be saved within a
  version control system.
	Source: <a href="http://swcarpentry.github.io/git-novice/01-basics.html" target="_blank"> Software Carpentry </a>
	</figcaption>
</figure>

If there aren’t conflicts between the users changes (a conflict is an area
where both users modified the same part of the same document in different
ways) you can review two sets of changes on the same base document.

 <figure>
	<a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/SWC_Git_merge.svg">
	<img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/SWC_Git_merge.svg"></a>
	<figcaption>Two sets of changes to the same base document can be reviewed
	together, within a version control system <strong> if </strong> there are no conflicts (areas
	where both users <strong> modified the same part of the same document in different ways</strong>).
	Changes submitted by both users can then be merged together.
	Source: <a href="http://swcarpentry.github.io/git-novice/01-basics.html" target="_blank"> Software Carpentry </a>
	</figcaption>
</figure>

A version control system is a tool that keeps track of these changes for us.
Each version of a file can be viewed and reverted to at any time. That way if you
add something that you end up not liking or delete something that you need, you
can simply go back to a previous version.

### Git & GitHub - A Distributed Version Control Model

GitHub uses a distributed version control model. This means that there can be
many copies (or forks in GitHub world) of the repository.

<figure>
 <a href="https://git-scm.com/book/en/v2/book/01-introduction/images/distributed.png">
 <img src="https://git-scm.com/book/en/v2/book/01-introduction/images/distributed.png" width="70%"></a>
 <figcaption>One advantage of a distributed version control system is that there
 are many copies of the repository. Thus, if any server or computer dies, any of
  the client repositories can be copied and used to restore the data! Every clone
  (or fork) is a full backup of all the data.
 Source: <a href="https://git-scm.com/book/en/v2/book/01-introduction/images/distributed.png" target="_blank"> Pro Git by Scott Chacon & Ben Straub </a>
 </figcaption>
</figure>

Have a look at the graphic below. Notice that in the example, there is a "central"
version of our repository. Joe, Sue and Eve are all working together to update
the central repository. Because they are using a distributed system, each user (Joe,
Sue and Eve) has their own copy of the repository and can contribute to the central
copy of the repository at any time.

<figure>
 <a href="http://betterexplained.com/wp-content/uploads/version_control/distributed/distributed_example.png">
 <img src="http://betterexplained.com/wp-content/uploads/version_control/distributed/distributed_example.png"></a>
 <figcaption>Distributed version control models allow many users to
contribute to the same central document.
 Source: <a href="http://betterexplained.com/wp-content/uploads/version_control/distributed/distributed_example.png" target="_blank"> Better Explained </a>
 </figcaption>
</figure>

### Create A Working Copy of a Git Repo - Fork

There are many different Git and GitHub workflows. In the NEON Data Institute,
we will use a distributed workflow with a **Central Repository**. This allows
us all (all of the Institute participants) to work independently. We can then
contribute our changes to update the Central (NEON) Repository. Our collaborative workflow goes
like this:

1. NEON "owns" the <a href="https://github.com/NEON-WorkWithData/DI-NEON-participants" target="_blank">Central Repository.</a>
2. You will create a copy of this repository (known as a **fork**) in your own GitHub account.
3. You will then `clone` (copy) the repository to your local computer. You
will do your work locally on your laptop.
4. When you are ready to submit your changes to the NEON repository, you will:
   * Sync your local copy of the repository with NEON's central
repository so you have the most up to date version, and then,
   * Push the changes you made to your local copy (or fork) of the repository to
NEON's main repository.

Each participant in the institute will be contributing to the NEON central
repository using the same workflow! Pretty cool stuff.

 <figure>
	<a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/git-fork-clone-flow.png">
	<img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute2-git/git-fork-clone-flow.png" width="70%"></a>
	<figcaption>The NEON central repository is the final working version of our
	project. You can <strong>fork</strong> or create a copy of this repository
	into your github.com account. You can then copy or <code>clone</code> your
	fork, to your local computer where you can make edits. When you are done
	working, you can push or transfer those edits back to your local fork. When
	you are read to update the NEON central repository, you submit a pull
	request. We will walk through the steps of this workflow over the
	next few lessons.
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>


Let's get some terms straight before we go any further.

* **Central repository** - the central repository is what all participants will
add to. It is the "final working version" of the project.
* **Your forked repository** - is a "personal” working copy of the
central repository stored in your GitHub account. This is called a fork.
When you are happy with your work, you update your repo from the central repo,
then you can update your changes to the central NEON repository.
* **Your local repository** - this is a local version of your fork on your
own computer. You will most often do all of your work locally on your computer.

<i class="fa fa-star"></i> **Data Tip:** Other Workflows -- There are many other
git workflows.
<a href="https://ru.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow" target="_blank">Read more about other workflows</a>.
This resource mentions Bitbucket, another web-based hosting service like GitHub.
{: .notice}

## Additional Resources:
Further documentation for and how-to-use direction for Git, is provided by the
<a href="https://git-scm.com/doc " target="_blank" >Git Pro version 2 book by Scott Chacon and Ben Straub </a>,
available in print or online. If you enjoy learning from videos, the site hosts
several.
