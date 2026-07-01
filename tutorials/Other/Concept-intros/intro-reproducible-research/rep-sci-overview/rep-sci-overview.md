---
syncID: 6e908b9477034bc9b4a23b37c16a2455 
title: "The Importance of Reproducible Science"
description: "This lesson introduces the core principles of reproducible science in ecology and provides practical ways to apply them in research workflows."
dateCreated: 2014-05-06
authors: Megan Jones, Bridget Hass
contributors: Felipe Sanchez
estimatedTime: 1.0 Hour
packagesLibraries:
topics: data-management, reproducible-science
languageTools:
dataProduct: 
code1:
tutorialSeries:
urlTitle: rep-sci-intro

---


> "Reproducibility is a key tenet of the scientific process that dictates the
> reliability and generality of results and methods."
From Powers, S. M., and S. E. Hampton (2019),
<a href="https://doi.org/10.1002/eap.1822" target="_blank">Open science, reproducibility, and transparency in ecology</a> (Abstract)

This lesson introduces the core principles of reproducible science in ecology and provides practical ways to apply them in your own research workflows.

In ecological science, reproducibility is especially important because observations are often context-dependent in space and time, so transparent and computationally reproducible workflows are critical for credible science, management, and policy decisions.

NEON data are especially well suited for reproducible ecological workflows because they are collected using standardized protocols across sites and time, include rich metadata and documentation, and are delivered in formats that make analyses easier to trace, rerun, and compare.

<div id="ds-objectives" markdown="1">

## Learning Objectives
At the end of this activity, you will be able to:

* Summarize the four facets of reproducibility.
* Describe several ways that reproducible workflows can improve your workflow and research.
* Explain several ways you can incorporate reproducible science techniques into
your own research.

</div>

## Getting Started with Reproducible Science

This lesson summarizes key concepts about reproducible science, adapted from the <a href="https://github.com/Reproducible-Science-Curriculum" target="_blank">Reproducible Science Curriculum</a>.

### Why use reproducible methods?

Reproducible methods make science more efficient, more collaborative, and more
trustworthy across the full lifecycle of a project. Some benefits to reproducibility include:

* More efficient, less redundant.
* Allows for continuity in your own work over time.
* Facilitates collaboration, review, and re-use by others.
* Provides stronger transparency and trust in results.

### What research products should be shareable?

To support reproducibility, key research products should be publicly available in
forms that others can find and understand:

* Data
* Code
* Documentation about methods and workflow

### Who needs to understand your workflow?

* Collaborators
* Peer reviewers and journal editors
* The broader scientific community
* The public

## The Four Facets of Reproducibility

Reproducibility is often discussed as one idea, but in practice it has several
connected facets. Improving all four helps make your work more robust and more
useful to others.

1. **Organization**: use clear file structures, informative file names, and
explicit separation of raw, intermediate, and final outputs.
2. **Automation**: prefer scripts over point-and-click steps so analyses can be
rerun, modified, and reviewed efficiently.
3. **Documentation**: record decisions, code purpose, inputs/outputs, and
workflow steps so others (and your future self) can understand the work.
4. **Dissemination**: share data, code, and workflows in accessible repositories
and formats so others can find, evaluate, and build on your results.

<div id="ds-dataTip" markdown="1">

**In practice:** You can be strong in one facet and weak in another, so
reproducibility is usually a work in progress rather than an all-or-nothing
goal. Start with the weakest link in your workflow; for example, sharing code
without data provenance may limit reproducibility even when the analysis itself
is well documented.

</div>

## How Reproducible Workflows Improve Research

Reproducible workflows provide benefits both during a project and after
publication.

* **Fewer errors and faster debugging:** scripted workflows make mistakes easier
to detect and fix.
* **Easier collaboration:** shared conventions (file naming, documentation,
version control) reduce friction across teams.
* **More efficient updates:** when data are revised, automated workflows can
rebuild results quickly.
* **Greater trust and re-use:** transparent methods improve confidence and make
it easier for others to build on your work.
* **Stronger scientific impact:** reproducible outputs are more likely to be
re-analyzed, cited, and used for synthesis.

## Incorporating Reproducible Science Into Your Workflow

You do not need to adopt everything at once. Start with small, high-impact
changes and build over time. 

### Quick Wins (start this week)

* Use descriptive file names and a consistent folder structure.
* Keep raw data read-only; write processed outputs to separate directories.
* Record software versions and package dependencies.
* Add a project `README` with goals, inputs, and run instructions.

### Next Steps (this month)

* Move repeated analyses from point-and-click tools into scripts.
* Use version control (for example, Git) for code and documentation.
* Add lightweight quality checks for expected rows, columns, units, and ranges.
* Archive analysis-ready data and scripts with a persistent identifier (DOI).

### Advanced Practices (ongoing)

* Build end-to-end pipelines that regenerate figures and tables.
* Use computational environments (for example, containers) to
improve run-to-run consistency.
* Add executable reports/notebooks that pair narrative, code, and outputs.
* Include clear licensing, citation, and contribution guidance for re-use.

## Practical Challenges and Tradeoffs

Adopting reproducible methods often requires more setup time at the beginning.
However, this up-front investment usually saves time later by making analyses easier to update, repeat, and explain. Moving towards reproducibility can be approached with a "good-better-best" framework. See the figure below to assess where your work lies on the reproducability spectrum.


<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/Good-better-best_RepSciCur_PengScience.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/dev-aten/graphics/reproducible-science/Good-better-best_RepSciCur_PengScience.jpg"
	alt="The spectrum of reproducibility for published research. From left to right, left being not reproducible and right being the gold standard.">
	</a>
	<figcaption> Reproducibility spectrum for published research.
	Source: Peng, RD Reproducible Research in Computational Science (2011): 1226–1227 via <a href="http://reproducible-science-curriculum.github.io/bosc2015/#/15" target="_blank">Reproducible Science Curriculum</a>
	</figcaption>
</figure>

### How reproducible is your current research?

<a class="link--button link--arrow" href="https://github.com/Reproducible-Science-Curriculum/rr-intro/blob/master/checklist.md" target="_blank"> View Reproducible Science Checklist </a>

<div id="ds-dataTip" markdown="1">

**Thought Questions:** Have a look at the reproducible science check list linked, above and answer the following questions:

* Do you currently apply any of the items in the checklist to your research?
* Are there elements in the list that you are interested in incorporating into your
workflow? If so, which ones?

</div>

## Self-Check Quiz

Use this quick quiz to check your understanding of the learning objectives.

1. Which list matches the four facets from the NEON reproducible science slides?

	A) Computation, Statistics, Visualization, Reporting
	B) Organization, Automation, Documentation, Dissemination
	C) Planning, Coding, Publishing, Archiving
	D) Collection, Cleaning, Modeling, Interpretation

2. Which practice is most aligned with the **Organization** facet?

	A) Using informative file names and a clear directory structure
	B) Writing results directly over raw input data
	C) Keeping steps undocumented but fast
	D) Sharing only a figure in a slide deck

3. Why is scripting preferred over manual steps for many analyses?

	A) It always requires less up-front time
	B) It makes methods harder for collaborators to inspect
	C) It supports efficient reruns and updates over time
	D) It removes the need for version control

4. Which audiences may need access to your research workflow?

	A) Only your principal investigator
	B) Only peer reviewers
	C) Collaborators, peer reviewers/editors, the scientific community, and the public
	D) Only data managers

5. Which option best reflects the **Dissemination** facet?

	A) Publishing ends the workflow; no further sharing is needed
	B) Share data snapshots and workflows in accessible platforms (for example,
	repositories and notebook-sharing tools)
	C) Keep data private unless requested by email
	D) Share code only if journal reviewers ask for it

### Quiz Key

1. B
2. A
3. C
4. C
5. B

## Reflection Prompts

Use these prompts for discussion, journaling, or a short assignment.

* Which of the four facets is currently strongest in your workflow? Which is
weakest?
* Identify one analysis step in your current project that is hard to rerun. What
single change would make it easier to reproduce?
* If a collaborator joined your project tomorrow, what three artifacts (files,
notes, metadata, or scripts) would help them reproduce your results fastest?
* What is one reproducibility practice you can adopt this week and one you can
adopt this month?
* How might improved transparency change trust in your results for a policy,
management, or stakeholder audience?

## Additional Readings and Resources (optional)

### Resources

* Nature magazine's special archive on the
<a href="https://www.nature.com/news/reproducibility-1.17552" target="_blank">Challenges of Irreproducible Science</a>.
* Open-access issue of
<a href="https://onlinelibrary.wiley.com/toc/16000587/2016/39/4" target="_blank">Ecography</a>
focusing on reproducible ecology and software practices.
* Hampton, S. E., et al. (2015). 
<a href="https://doi.org/10.1002/eap.1822" target="_blank">Open science, reproducibility, and transparency in ecology</a>.
Ecological Applications.
* NASA Open Science (TOPS):
<a href="https://science.nasa.gov/open-science/" target="_blank">Open Science at NASA</a>.
* The Turing Way (living handbook):
<a href="https://book.the-turing-way.org/reproducible-research/reproducible-research/" target="_blank">The Turing Way: A handbook for reproducible, ethical, and collaborative data science</a>.

#### Hands-on tutorials and workshops

* NASA Open Science training catalog (includes Open Science 101 and Open
Science Essentials):
<a href="https://science.nasa.gov/open-science/training/" target="_blank">Open Science Training</a>.
* Software Carpentry lesson (R):
<a href="https://swcarpentry.github.io/r-novice-gapminder/" target="_blank">R for Reproducible Scientific Analysis</a>.
* Reproducible Data Science in Python:
<a href="https://valdanchev.github.io/reproducible-data-science-python/intro.html#" target="_blank">Textbook on reproducible workflows in Python</a>.