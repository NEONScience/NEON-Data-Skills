
## Instructions for writing NEON Data Skills tutorials

NEON Data Skills tutorials are automatically synced from the [NEON Data Skills](https://github.com/NEONScience/NEON-Data-Skills) GitHub repository 
to the [Learning Hub](https://www.neonscience.org/resources/learning-hub/tutorials) on the NEON website. 
Adding a new tutorial to the repo also adds it to the website.

### Workflow Overview

The process of creating a tutorial looks like this:

1. Write your code and commentary in an R markdown (.Rmd) file.
2. Add the yaml header to enable website syncing.
3. Knit to a markdown (.md) file.
4. Submit a pull request (PR) to the NEON-Data-Skills repo to add the files to the tutorials folder.

Discuss your plan with Data Skills staff in advance. We can help you with steps 2 and 3, 
in which case you only need to submit a PR with your Rmd file. But we need to 
know in advance that this is your plan!

### Writing the tutorial (technical)

The sync process works on markdown files (.md), so technically you could develop 
your tutorial using any process that can produce a .md file. In practice, we 
highly recommend starting by writing an R markdown (.Rmd) document, for a couple 
of reasons:

* You need to make sure the code in your tutorial runs successfully. Knitting an Rmd file will check this.
* R markdown includes many options for adjusting the visibility and appearance of both code and outputs, using [chunk options](https://yihui.org/knitr/options/). 

Because of the chunk options, Rmd is often preferable even if your code is in Python. 
It will give you much more flexibility than a Jupyter notebook, in terms of things 
like hiding progress bars, silently setting a customized working directory while showing the 
user code to set their own working directory, etc.

If you are interested in writing a tutorial with code in both R and Python so users can 
follow along in their language of choice, see instructions [here](https://github.com/NEONScience/NEON-Data-Skills/blob/main/tutorials-in-development/tabbed_tutorial_instructions.md) and 
an example of what this looks like on the website [here](https://www.neonscience.org/resources/learning-hub/tutorials/download-explore-neon-data). 
We don't recommend trying this for your first tutorial, start with a single language.

### Writing the tutorial (syntactical)

Use the tutorial [style guide](https://github.com/NEONScience/NEON-Data-Skills/blob/main/tutorials-in-development/0_templates_style_guide/NDS-style-guide.md). This is important for 
things like headers (don't use level 1 headers), links (don't use standard 
markdown links, follow the instructions in the style guide so links open in a 
new tab), etc.

Level 2 headers create the index that appears in the lefthand sidebar, so 
choose these thoughtfully.

### Writing the tutorial (pedagogical)

Check out existing tutorials on the website to get a sense of how they're 
structured. In general:

* Start with a paragraph or two explaining what the tutorial is about. It's 
helpful to give users an idea of where the tutorial is going, even if it's just, 
"we're going to download a little bit of data and demo how to plot it." That way  
they know what the goal is.
* Avoid using a lot of code comments. The joy of markdown is you can talk about 
what you're doing in the text, and just do it in the code. If you find yourself 
writing a lot of code comments, it's a sign you need more text.
* Break up code. Avoid long, dense code chunks - they're hard to follow. In most 
NEON tutorials, we don't explain every single line of code, but your code chunks 
should be short enough that the text can explain what's happening in each one 
in a sentence or two.
* If you need to break the above rule, say so. For example, if your tutorial 
includes writing a function or a for loop to do a data transformation, but the 
data transformation isn't the focus of the tutorial, you can explain that in the 
text. Tell users what the function does, and that they don't need to worry about 
the details. But you should generally avoid doing this - do it no more than once 
in one tutorial.
* It's nice to finish with a little bit of commentary, to give a feeling of 
conclusion. Often this is a good place to point people to where they can go for 
more information or more advanced analyses. It can also be a good place to 
discuss the broader picture - did your tutorial focus on a specific ecosystem 
type, and users might find different results in other systems? Are there 
important limitations to the type of analysis you outlined? Help the user think 
bigger.

### yaml header

The yaml header is explained in section 5 of [this document](https://github.com/NEONScience/NEON-Data-Skills/blob/main/tutorials-in-development/Tutorial_Instructions.pdf). 
It contains the metadata for website syncing and tags for categorization. If you 
are unsure of how to fill it out, contact Data Skills staff and we can help you 
out or do it for you.

### Knitting the tutorial

Once the tutorial is ready to go, we recommend using the "Knit" button in 
RStudio to make sure all the code runs and knits successfully, and the results 
look good. But this is for review purposes only, it's not the document you'll 
push to the repo!

To generate the files to push to the repo, use [this code](https://github.com/NEONScience/NEON-Data-Skills/blob/main/processing_code/01knit-RMD-2-MD_NDSRepo.R) 
to knit from an .Rmd file and [this code](https://github.com/NEONScience/NEON-Data-Skills/blob/main/processing_code/02process-ipynb-2-MD_NDSRepo.R) to knit from a Jupyter notebook.
The only lines you should need to change are near the top, where you put in the 
file path to the tutorial you want to knit. Put in the correct file path and 
then run the full script.

One of the outputs will be a .md file. Open it in a markdown reader and give it 
a review - did all the code run successfully? Did it produce the expected 
outputs? Note that if this is a new tutorial, the figures won't appear in the 
markdown. That's fine, just confirm that the figure files are present in the PR.

If everything knit correctly, submit your PR to the NEON-Data-Skills repo. If 
you have trouble with the knitting process, contact Data Skills staff and we can 
check it out for you.

### Publishing

Once the PR is merged, the tutorial will sync to the website, but initially it 
will be unpublished. Anyone with website permissions can approve and publish it; 
once this is done, do a final review of the tutorial as it appears on the 
website.

