---
syncID: 7a3d01f3a2a84e6092774e2d21e13a16
title: "Using an API Token when Accessing NEON Data"
description: "Get an API token tied to your NEON user account, and use it for faster download speeds when accessing NEON data via the neonUtilities package."
dateCreated: 2020-05-04
authors: [Claire K. Lunch, Megan A. Jones, Donal O'Leary]
contributors:
estimatedTime: 20 minutes
packagesLibraries: neonUtilities
topics: data-management, rep-sci
languageTool: R
code1: R/api-token/api-token.R
tutorialSeries:
urlTitle: api-token

---

NEON data can be downloaded from either the NEON Data Portal or the NEON API. 
When downloading from the Data Portal, you can create a user account. Read 
about the benefits of an account on the <a href="https://www.neonscience.org/data/about-data/data-portal-user-accounts" target="_blank">User Account page</a>.

Using a token is optional! You can download data without a token, and 
without a user account. Using a token when downloading data via the API links 
your downloads to your user account, as well as enabling faster download 
speeds. As NEON Data Portal development continues, additional benefits will 
be added to accounts and tokens, such as allowing you to access your own 
download history, and to be notified of updates to data products you've 
downloaded.

For now, in addition to faster downloads, using a token helps NEON to track 
data downloads. Using **anonymized** user information, we can then calculate 
data access statistics, such as which data products are downloaded most 
frequently, which data products are downloaded in groups by the same users, 
and how many users in total are downloading data. This information helps NEON 
to evaluate the growth and reach of the observatory, and to advocate for 
training activities, workshops, and software development.

Tokens can be used whenever you use the NEON API. In this tutorial, we'll 
focus on using tokens with the neonUtilities R package.

<div id="ds-objectives" markdown="1">

## Objectives
After completing this activity, you will be able to:

 * Create a NEON API token 
 * Use your token when downloading data with neonUtilities 

## Things You’ll Need To Complete This Tutorial
You will need the most current version of R and, preferably, `RStudio` loaded
on your computer to complete this tutorial.

### Install R Packages

* **neonUtilities:** `install.packages("neonUtilities")`

## Additional Resources

* NEON <a href="http://data.neonscience.org" target="_blank"> Data Portal </a>
* <a href="https://github.com/NEONScience" target="_blank">NEONScience GitHub Organization</a>
* <a href="https://www.neonscience.org/neonDataStackR" target="_blank">neonUtilities tutorial</a>

</div>

If you've never downloaded NEON data using the neonUtilities package before, 
we recommend starting with the <a href="https://www.neonscience.org/download-explore-neon-data" target="_blank">Download and Explore tutorial</a> before proceeding with this tutorial.

In the next sections, we'll get an API token from the NEON Data Portal, and 
then use it in neonUtilities when downloading data.

## Get a NEON API Token 

The first step is create a NEON user account, if you don't have one. 
Follow the instructions on the <a href="https://www.neonscience.org/data/about-data/data-portal-user-accounts" target="_blank">Data Portal User Accounts</a> page.

Once you have an account, you can create an API token for yourself. At 
the bottom of the My Account page, you should see this bar: 

<figure>
	<a href="{{ site.baseurl }}/images/NEON-api-token/get-api-token-button.png">
	<img src="{{ site.baseurl }}/images/NEON-api-token/get-api-token-button.png"></a>
	<figcaption>Screenshot of account page button to Get API Token. 
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>

Click the 'GET API TOKEN' button. After a moment, you should see this:

<figure>
	<a href="{{ site.baseurl }}/images/NEON-api-token/api-token-view.png">
	<img src="{{ site.baseurl }}/images/NEON-api-token/api-token-view.png"></a>
	<figcaption>Screenshot of account page with API token created. 
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>

Click on the Copy button to copy your API token to the clipboard:

<figure>
	<a href="{{ site.baseurl }}/images/NEON-api-token/api-token-copy-button.png">
	<img src="{{ site.baseurl }}/images/NEON-api-token/api-token-copy-button.png"></a>
	<figcaption>Screenshot of account page with API token created. 
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>

## Use API token in neonUtilities 

In a moment, we'll walk through saving your token somewhere secure but 
accessible to your code. But first let's try out using the token the easy 
way.

First, we need to load the `neonUtilities` package:


    # install neonUtilities - can skip if already installed
    install.packages("neonUtilities")
    
    # load neonUtilities
    library(neonUtilities)

Now we'll use the `loadByProduct()` function to download data. Your 
API token is entered as the optional `token` input parameter. For 
this example, we'll download Plant foliar traits (DP1.10026.001).


    foliar <- loadByProduct(dpID="DP1.10026.001", site="all", 
                            package="expanded", check.size=F,
                            token="PASTE YOUR TOKEN HERE")

You should now have data saved in the `foliar` object; the API 
silently used your token. If you've downloaded data without a 
token before, you may notice this is faster!

This format applies to all `neonUtilities` functions that involve 
downloading data or otherwise accessing the API; you can use the 
`token` input with all of them. For example, when downloading 
remote sensing data:


    chm <- byTileAOP(dpID="DP3.30015.001", site="WREF", 
                     year=2017, check.size=F,
                     easting=c(571000,578000), 
                     northing=c(5079000,5080000), 
                     savepath="/data",
                     token="PASTE YOUR TOKEN HERE")

## Token management for open code

Your API token is unique to your account, so don't share it!

If you're writing code that will be available publicly, such as in a GitHub 
repository, you'll need to save your token locally, and pull it into your 
code with an alias. There are a few ways to do this. Here, we'll simply 
assign the token to a variable name.


    NEON_TOKEN <- "PASTE YOUR TOKEN HERE"
    
    foliar <- loadByProduct(dpID="DP1.10026.001", site="all", 
                            package="expanded", check.size=F,
                            token=NEON_TOKEN)

Of course, when you close your R session, the `NEON_TOKEN` variable will 
be cleared, so you'd have to re-create the variable in every session. We'll 
show two options for doing this smoothly:

* Option 1: Save the token in a local file, and `source()` that file at the 
start of every script. This is fairly simple but requires a line of code in 
every script.

* Option 2: Add the token to a `.Renviron` file to create an environment 
variable that gets loaded when you open RStudio. This is a little harder 
to set up initially, and you must be using RStudio for it to work, but 
once it's done, it's done globally, and it will work in every script you 
run.

### Option 1: Save token in a local file

Open a new, empty R script. Put a single line of code in the script:


    NEON_TOKEN <- "PASTE YOUR TOKEN HERE"

Save this file in a logical place on your machine, somewhere that won't be 
visible publicly. Let's call it `neon_token_source.R`, and let's say you've 
saved it to the `/data` folder on your machine. Then, at the start of every 
script where you're going to use the NEON API, you would run this line of 
code:


    source("/data/neon_token_source.R")

Then you'll be able to use `token=NEON_TOKEN` when you run `neonUtilities` 
functions, and you can share your code without accidentally sharing your 
token.

### Option 2: Save token to the RStudio environment

To create a persistent environment variable, we use a `.Renviron` file. 
Before creating a file, check which directory RStudio is using as your home 
directory:


    # For Windows:
    Sys.getenv("R_USER")
    
    # For Mac/Linux:
    Sys.getenv("HOME")

Check the home directory to see if you already have a `.Renviron` file, **using 
the file browse pane in RStudio**. Files that begin with `.` are hidden by 
default, but RStudio recognizes files that begin with `.R` and displays them.

<figure>
	<a href="{{ site.baseurl }}/images/NEON-api-token/R-environ-file-browse.png">
	<img src="{{ site.baseurl }}/images/NEON-api-token/R-environ-file-browse.png"></a>
	<figcaption>Screenshot of file browse pane with .Renviron file. 
	</figcaption>
</figure>

If you already have a `.Renviron` file, open it and follow the instructions 
below to add to it. If you don't have one, create one using File -> New File 
-> Text File in the RStudio menus.

Add one line to the text file. In this option, there are no quotes around the 
token value.


    NEON_TOKEN=PASTE YOUR TOKEN HERE

Save the file as `.Renviron`, in the RStudio home directory identified above. 
Re-start RStudio to load the environment.

Once your token is assigned to an environment variable, use the function 
`Sys.getenv()` to access it. For example, in `loadByProduct()`:


    foliar <- loadByProduct(dpID="DP1.10026.001", site="all", 
                            package="expanded", check.size=F,
                            token=Sys.getenv("NEON_TOKEN"))


