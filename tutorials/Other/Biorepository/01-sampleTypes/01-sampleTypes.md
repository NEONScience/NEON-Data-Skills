---
syncID:
title: "NEON Biorepository: Understanding NEON Sample Types"
description: "Learn what kinds of samples are collected and stored in the NEON Biorepository and how to explore them using the Sample Type Browser."
dateCreated: 2026-05-05
authors: Chandra Earl
contributors: NEON Biorepository Staff
estimatedTime: 15 minutes
packagesLibraries: 
topics: Biorepository, Samples, Specimens
languagesTool: 
dataProduct: 
code1: 
tutorialSeries: biorepository-series
urlTitle: biorepository-understanding-sample-types
---

In this tutorial, we’ll explore the types of materials archived in the NEON Biorepository and how they are organized. We’ll use the Sample Type Browser and Sample Type Profiles to explore the diversity of archived materials and learn where to find additional information about associated protocols and data products.

<div id="ds-objectives" markdown="1">

## Learning objectives

After completing this tutorial, you will be able to:

* Describe the kinds of materials archived in the NEON Biorepository  
* Understand how sampling and laboratory workflows generate different archived materials  
* Use the Sample Type Browser to explore available sample types  
* Interpret information provided in Sample Type Profiles  
* Identify additional NEON resources related to sample types and associated datasets  

</div>

## Types of samples in the Biorepository

The NEON Biorepository archives physical materials generated through NEON <a href="https://www.neonscience.org/data-collection/observational-sampling" target="_blank">observational sampling</a> at terrestrial and aquatic sites. Because NEON sampling is designed to characterize whole ecosystems, the Biorepository contains many **interconnected sample types** collected from the same location and time periods, including plants, insects, fish, soils, microbes, and environmental materials, unlike traditional natural history collections.

In addition to field-collected samples and preserved specimens, the Biorepository also **archives downstream materials** generated through  laboratory processing and analytical workflows. These include things like tissues, DNA extracts, taxonomic reference slides, and identified bulk organismal samples.

This means that observational protocols produce multiple archived materials from the same collection event. For example, small mammal sampling produces specimens, frozen tissues, pathogen DNA extracts, and mammal DNA extracts, while microbial sampling produces frozen unanalyzed subsamples and analyzed metagenomic DNA extracts. These physical materials are all available through the Biorepository Sample Portal, while associated analytical and observational data are available through the NEON Data Portal.

The table below summarizes the major sample types available in the Biorepository.

<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/other/biorepository/01-sampleTypes/NEONSampleTypesOverview.xlsx" download>NEON Sample Types Quick Overview</a>

## Sample Type Browser

The Sample Type Browser is designed to help researchers understand what kinds of materials are available in the Biorepository. It organizes these materials by taxonomic group, collection workflow, and preservation method.

This can help clarify:

* What kinds of materials are available for a particular taxonomic group
* How materials are preserved or prepared
* Which workflows produce what types of samples

For example, a researcher interested in plant materials may discover that the Biorepository contains not only the typical pressed herbarium specimens, but also frozen leaves, dried canopy foliage, root cores, and litterfall.

The Sample Type Browser is available under **Samples & Specimens > About Samples > Sample Types**, or directly at:

<a href="https://biorepo.neonscience.org/portal/collections/misc/browsecollprofiles.php?utm_source=neon_tutorial&utm_medium=directlink" target="_blank" class="link--button link--arrow">Sample Type Browser</a>

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/sampletypebrowser.jpg">
        <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/sampletypebrowser.jpg" alt="Screenshot of the NEON Biorepository Sample Type Browser">
    </a>
    <figcaption>The NEON Biorepository Sample Type Browser organizes sample types by taxonomic group, collection protocol, and preservation method.</figcaption>
</figure>

Each sample type links to a Sample Type Profile containing additional information about its data, records, and statistics. 

## Sample Type Profiles

Selecting a sample type opens a Sample Type Profile page. These pages provide detailed information about how a material is collected, processed, archived, and connected to associated NEON resources.

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/sampletypeprofile.jpg">
        <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/sampletypeprofile.jpg" alt="Screenshot of the NEON Biorepository Sample Type Profile page for pinned mosquitoes">
    </a>
    <figcaption>A Sample Type Profile page provides detailed information about archived materials.</figcaption>
</figure>

At the top of the page, you’ll find the sample type name along with options to browse all available records for that sample type or launch a search form pre-filtered to that sample type, allowing you to apply additional criteria such as NEON site, collection date, or taxonomy.

Badges linking to <a href="https://www.gbif.org/" target="_blank">GBIF</a> and <a href="https://bionomia.net/" target="_blank">Bionomia</a> display counts associated with the sample type dataset. The GBIF badge links to publications and other research products that use GBIF records from the sample type, while the Bionomia badge links to people associated with the dataset.

The **About** section describes the material represented by the sample type and provides additional information about sampling design, collection methods, and preservation. This section is the best place to get an overview of the protocol associated with the sample type and understand when, where, and how the material may be collected or generated.

Information about downstream analyses and processing workflows, such as subsampling, taxonomic identification, DNA extraction, or pathogen testing, is included to help explain how the sample type relates to other materials generated through the same protocol.

A representative image of the sample type is included to provide an example of what the archived material looks like.

The **Sample Type Statistics** panel summarizes the archived collection associated with the sample type, including record counts, number of taxa represented, linked images, genetic references, and associated publications.

The **Citation** section provides citation text and download options for referencing the sample type in publications.

**Related Sample Types** provides links to sample types from the same protocol or related holdings at external repositories.

The **Linked Data Products and Protocols** section connects the sample type to related NEON data products and protocols. These links can be useful when you need additional information about the analyses, collection methods, or associated NEON datasets.

A **Sample Availability Chart** is included to allow you to see at a glance the distribution of available samples across months, years, site, state and domain.

The **Additional Resources** section provides access to downloadable Darwin Core Archive (DwC-A) files containing all records associated with the sample type, along with dataset metadata and a link to the corresponding dataset published through GBIF.

Finally, the **Contact Information** section lists people associated with the sample type and provides a way to contact the Biorepository with questions about the archived materials or collection workflow.

## Identified Sample Types

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/identificationbanner.jpg">
        <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/identificationbanner.jpg" alt="Screenshot of a notification banner for a sample type with linked identification records">
    </a>
</figure>

Some sample types represent taxonomic identifications rather than distinct physical samples.

For samples containing a single organism, the relationship between the archived material and its identification is usually straightforward. However, a few NEON sample types contain a number of organisms collected together in a single sample. In these cases, taxonomic identification may be performed on all or a subset of the organisms in the sample, and the resulting identifications are published as separate **Identified** sample types.

These sample types provide information about the organisms identified within a collection, but they do not necessarily correspond to individually archived specimens. Instead, they represent the taxonomic results associated with a bulk sample.

The example below shows a bulk sample of ethanol-preserved macroinvertebrates collected from wadeable streams, rivers and lakes. This sample was sent to a taxonomist for identification and counts. Although the individuals were not separated out, we know what taxa are in the parent sample. 

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/identifiedsamples.jpg">
        <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/identifiedsamples.jpg" alt="Multipanel figure showing a Sample Type Summary for a sample with derived identifications, an example of the parent record and examples of the identification records">
    </a>
</figure>

## More Information

### Observation Types

NEON provides summaries of major sampling activities through the <a href="https://www.neonscience.org/data-collection/observation-types" target="_blank">Observation Types</a> pages. These pages organize NEON sampling into broad ecological groups such as plants, fish, mosquitoes, microbes, soils, aquatic macroinvertebrates, and other environmental or organismal systems. 

Each Observation Type page includes links to:

* Related NEON data products  
* Relevant Biorepository sample types  

These pages can be useful starting points when exploring what kinds of data and samples are available for a particular system.

### Data Portal

Samples in the Biorepository are associated with analytical and observational datasets available through the <a href="https://data.neonscience.org/data-products/explore" target="_blank">NEON Data Portal</a>. Related sample types are linked directly from many Data Product pages in the Data Portal, allowing researchers to move between analytical datasets and the archived physical materials associated with those data products. 

<figure>
    <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/dataportal.jpg">
        <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/biorepository/dataportal.jpg" alt="Screenshot of a NEON Data Product Page">
    </a>
    <figcaption>A NEON Data Product Page with the related Biorepository Sample Types marked.</figcaption>
</figure>

### Protocols and Documentation

Sample Type Profiles provide a general overview of how archived materials are generated, but the best way to fully understand how NEON sample types and data products relate to one another is to review the associated protocol documentation. NEON protocols describe how samples move through the full sampling workflow, including field collection, downstream processing, subsampling, analysis, and data generation.

This documentation is especially useful when:

* Understanding relationships among archived materials and associated datasets  
* Understanding where, when, and how frequently samples were collected  
* Evaluating whether materials are appropriate for a particular analytical workflow  
* Interpreting downstream analyses such as sequencing, taxonomic identification, or chemical measurements
* Reviewing protocol revision histories to understand how updates may have affected samples or data

Related protocols are linked directly from both Sample Type Profiles and related NEON Data Product pages. The complete NEON documentation library is available through the <a href="https://data.neonscience.org/documents" target="_blank">NEON Document Library</a>.

## Questions?

If you are unsure which sample types are most appropriate for your research, you are welcome to contact the Biorepository for assistance.

Biorepository staff can help answer questions about:

* Relationships among sample types  
* Preservation and processing workflows  
* What kinds of materials are available for particular organisms, environments, or analytical approaches  
* How archived materials relate to associated NEON datasets
* Potential sample preparation or subsampling options for approved sample use

Contact the NEON Biorepository through the <a href="https://www.neonscience.org/about/contact-neon-biorepository" target="_blank">NEON Biorepository Contact Page</a>.