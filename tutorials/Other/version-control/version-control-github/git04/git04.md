---
syncID: e5c107fbf4a248588d5dbf7fbaffd49f
title: "Git 04: Markdown Files"
description: "This tutorial covers the basics of writing a document using the markdown language."
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
urlTitle: markdown-files
---


This tutorial covers how create and format Markdown files.

<div id="ds-objectives" markdown="1">
## Learning Objectives
At the end of this activity, you will be able to:

* Create a Markdown (.md) file using a text editor.
* Use basic markdown syntax to format a document including: headers, bold and italics.

</div>

## What is the .md Format?

Markdown is a human readable syntax for formatting text documents. Markdown can
be used to produce nicely formatted documents including
pdf's, web pages and more. In fact, this web page that you are reading right now
is generated from a markdown document!

In this tutorial, we will create a markdown file that documents both who you are
and also the project that you might want to work on at the NEON Data Institute.


<a class="link--button link--arrow" href="https://www.neonscience.org/di-rs-capstone" target="_blank">
Read more about the Data Institute Capstone Project</a>

## Markdown Formatting

Markdown is simple plain text, that is styled using symbols, including:

* ` #`: a header element
* `**`: bold text
* `*`: italic text
* ` ` `: code blocks

Let's review some basic markdown syntax.

### Plain Text

Plain text will appear as text in a Markdown document. You can format that
text in different ways.

For example, if we want to highlight a function or some code within a plain text
paragraph, we can use one backtick on each side of the text ( ` ` ), like this:
`Here is some code`. This is the backtick, or grave; not an apostrophe (on most
US keyboards it is on the same key as the tilde).  

To add emphasis to other text you can use **bold** or *italics*.

Have a look at the markdown below:

	  The use of the highlight ( `text` ) will be reserved for denoting code.
    To add emphasis to other text use **bold** or *italics*.

Notice that this sentence uses a code highlight "``", bold and italics.
As a rendered markdown chunk, it looks like this:

The use of the highlight ( `text` ) will be reserve for denoting code when
used in text. To add emphasis to other text use **bold** or *italics*.

### Horizontal Lines (rules)

Create a rule:

	  ***

Below is the rule rendered:

***

## Section Headings

You can create a heading using the pound (#) sign. For the headers to render 
properly there must be a space between the # and the header text. 
Heading one is 1 pound sign, heading two is 2 pound signs, etc as follows:

## Heading two
	## Heading two

### Heading three
	### Heading three

#### Heading four
	#### Heading four


For a more thorough list of markdown syntax, please read this
<a href="https://guides.github.com/features/mastering-markdown/" target="_blank">GitHub Guide on Markdown</a>.

<div id="ds-dataTip" markdown="1">
<i class="fa fa-star"></i> **Data Tip:**
There are many free Markdown editors out there! The
<a href="http://Atom.io" target="_blank">atom.io</a>
editor is a powerful text editor package by GitHub, that also has a Markdown
renderer allowing you to see what your Markdown looks like as you are working.
</div>

<div id="ds-challenge" markdown="1">
## Activity: Create A Markdown Document

Now that you are familiar with the Markdown syntax, use it to create
a brief biography that:

1. Introduces yourself to the other participants.
2. Documents the project that you have in mind for the Data Institute.

### Add Your Bio

First, create a .md file using the text editor of your preference. Name the
file with the naming convention:
 LastName-FirstName.md

 Save the file to the **participants/2017-RemoteSensing/pre-institute2-git** directory in your
 local DI-NEON-participants repo (the copy on your computer).

Add a brief bio using headers, bold and italic formatting as makes sense.
In the bio, please provide basic information including:

* Your Name
* Domain of interest
* One goal for the course

### Add a Capstone Project Description

Next, add a revised Capstone Project idea to the Markdown document using the
heading `## Capstone Project`. Be sure to specify in the document the types of
data that you think you may require to complete your project.

**NOTE:** The Data Institute repository is a public repository visible to anyone
with internet access. If you prefer to not share your bio information publicly,
please submit your Markdown document using a pseudonym for your name. You may also
want to use a pseudonym for your GitHub account. HINT: cartoon character names work well.
Please email us with the pseudonym so that we can connect the submitted document to you.


</div>


****

*Got questions? No problem. Leave your question in the comment box below.
It's likely some of your colleagues have the same question, too! And also
likely someone else knows the answer.*
