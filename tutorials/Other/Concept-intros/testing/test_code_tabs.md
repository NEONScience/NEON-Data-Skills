---
syncID: 8ab4445008fd408fab9992c5c8751505
title: "Test reticulate tabs"
description: Test for tabbed tutorials with R and Python code. Do not publish this tutorial.
dateCreated: '2024-04-25'
dataProducts: 
authors: Claire K. Lunch
contributors: 
estimatedTime: 0 hours
packagesLibraries: neonUtilities, neonutilities
topics: data-management, rep-sci
languageTool: R, Python
code1: https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Other/Concept-intros/testing/test_code_tabs.R
tutorialSeries:
urlTitle: test-code-tabs
---




<!--html_preserve-->


<div id="load-neonutilities-or-neonutilities-package" class="section level2 tabset">
<h2 class="tabset">Load neonUtilities or neonutilities package</h2>
<div id="r" class="section level3">
<h3>R</h3>
<pre class="r"><code>library(neonUtilities)</code></pre>
</div>
<div id="python" class="section level3">
<h3>Python</h3>
<pre class="python"><code>import neonutilities as nu</code></pre>
</div>
</div>
<div id="get-a-citation" class="section level2 tabset">
<h2 class="tabset">Get a citation</h2>
<div id="r-1" class="section level3">
<h3>R</h3>
<pre class="r"><code>getCitation(dpID=&#39;DP1.20093.001&#39;, release=&#39;RELEASE-2024&#39;)</code></pre>
<pre><code>## [1] &quot;@misc{https://doi.org/10.48443/fdfd-d514,\n  doi = {10.48443/FDFD-D514},\n  url = {https://data.neonscience.org/data-products/DP1.20093.001/RELEASE-2024},\n  author = {{National Ecological Observatory Network (NEON)}},\n  keywords = {chemistry, water quality, anions, cations, alkalinity, nutrients, surface water, nitrogen (N), carbon (C), total carbon (TC), acid neutralizing capacity (ANC), analytes, grab samples, chemical properties, swc, phosphorus (P)},\n  language = {en},\n  title = {Chemical properties of surface water (DP1.20093.001)},\n  publisher = {National Ecological Observatory Network (NEON)},\n  year = {2024},\n  copyright = {Creative Commons Zero v1.0 Universal}\n}\n&quot;</code></pre>
</div>
<div id="python-1" class="section level3">
<h3>Python</h3>
<pre class="python"><code>nu.get_citation(dpID=&#39;DP1.20093.001&#39;, release=&#39;RELEASE-2024&#39;)</code></pre>
<pre><code>## &#39;@misc{https://doi.org/10.48443/fdfd-d514,\n  doi = {10.48443/FDFD-D514},\n  url = {https://data.neonscience.org/data-products/DP1.20093.001/RELEASE-2024},\n  author = {{National Ecological Observatory Network (NEON)}},\n  keywords = {chemistry, water quality, anions, cations, alkalinity, nutrients, surface water, nitrogen (N), carbon (C), total carbon (TC), acid neutralizing capacity (ANC), analytes, grab samples, chemical properties, swc, phosphorus (P)},\n  language = {en},\n  title = {Chemical properties of surface water (DP1.20093.001)},\n  publisher = {National Ecological Observatory Network (NEON)},\n  year = {2024},\n  copyright = {Creative Commons Zero v1.0 Universal}\n}\n&#39;</code></pre>
</div>
</div><!--/html_preserve-->

