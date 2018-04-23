---
title: "Taxon API Endpoint"
author: "Claire Lunch"
date: "4/19/2018"
output: pdf_document
---


## Taxonomy

NEON maintains accepted taxonomies for many of the taxonomic identification 
data we collect. NEON taxonomies are available for query via the API; they 
are also provided via an interactive user interface, the <a href="http://data.neonscience.org/static/taxon.html" target="_blank">Taxon Viewer</a>.

NEON taxonomy data provides the reference information for how NEON 
validates taxa; an identification must appear in the taxonomy lists 
in order to be accepted into the NEON database. Additions to the lists 
are reviewed regularly. The taxonomy lists also provide the author 
of the scientific name, and the reference text used.

The taxonomy endpoint of the API works a little bit differently from the 
other endpoints. In the "Anatomy of an API Call" section above, each 
endpoint has a single type of target - a data product number, a named 
location name, etc. For taxonomic data, there are multiple query 
options, and some of them can be used in combination.
For example, a query for taxa in the Pineaceae family:

<span style="color:#A2A4A3">http://data.neonscience.org/api/v0/taxonomy</span><span style="color:#A00606;font-weight:bold">/?family=Pinaceae</span>

The available types of queries are listed in the <a href="http://data.neonscience.org/data-api#!/taxonomy/Get_taxonomy" target="_blank">taxonomy section</a> 
of the API web page. Briefly, they are:

* taxonTypeCode: Which of the taxonomies maintained by NEON are you 
looking for? BIRD, FISH, PLANT, etc. Cannot be used in combination 
with the taxonomic rank queries.
* The major taxonomic ranks from genus through kingdom
* scientificname: Genus + species
* offset: Skip this number of items in the list. Defaults to 50.
* limit: Result set will be truncated at this length. Defaults to 50.

NEON has plans to modify the settings for offset and limit, such that 
offset will default to 0 and limit will default to $\infty$   ∞   , but in 
the meantime users will want to set these manually. They are set to 
non-default values in the examples below.

For the first example, let's query for the loon family, in the bird 
taxonomy. Note that query parameters are case-sensitive.


```r
loon.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?family=Gaviidae&offset=0&limit=500")
```

Parse the results into a list:


```r
loon.list <- fromJSON(content(loon.req, as="text"))
```

And look at the $data element of the results, which contains:

* The full taxonomy of each taxon
* The short taxon code used by NEON (taxonID/acceptedTaxonID)
* The author of the scientific name (scientificNameAuthorship)
* The vernacular name, if applicable
* The reference text used (nameAccordingToID)

The terms used for each field are matched to Darwin Core (dwc) and 
the Global Biodiversity Information Facility (gbif) terms, where 
possible, and the matches are indicated in the column headers.


```r
loon.list$data
```

```
##   taxonTypeCode taxonID acceptedTaxonID dwc:scientificName
## 1          BIRD    YBLO            YBLO      Gavia adamsii
## 2          BIRD    RTLO            RTLO     Gavia stellata
## 3          BIRD    PALO            PALO     Gavia pacifica
## 4          BIRD    COLO            COLO        Gavia immer
## 5          BIRD    ARLO            ARLO      Gavia arctica
##   dwc:scientificNameAuthorship dwc:taxonRank dwc:vernacularName
## 1                 (G. R. Gray)       species Yellow-billed Loon
## 2                (Pontoppidan)       species  Red-throated Loon
## 3                   (Lawrence)       species       Pacific Loon
## 4                   (Brunnich)       species        Common Loon
## 5                   (Linnaeus)       species        Arctic Loon
##      dwc:nameAccordingToID dwc:kingdom dwc:phylum dwc:class   dwc:order
## 1 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
## 2 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
## 3 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
## 4 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
## 5 doi: 10.1642/AUK-15-73.1    Animalia   Chordata      Aves Gaviiformes
##   dwc:family dwc:genus gbif:subspecies gbif:variety
## 1   Gaviidae     Gavia              NA           NA
## 2   Gaviidae     Gavia              NA           NA
## 3   Gaviidae     Gavia              NA           NA
## 4   Gaviidae     Gavia              NA           NA
## 5   Gaviidae     Gavia              NA           NA
```

To get the entire list for a particular taxonomic type, use the 
taxonTypeCode query. Be cautious with this query, the PLANT taxonomic 
list has several hundred thousand entries.

For an example, let's look up the small mammal taxonomic list, which 
is one of the shorter ones, and then display only the first 20 taxa:


```r
mam.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?taxonTypeCode=SMALL_MAMMAL&offset=0&limit=500")
mam.list <- fromJSON(content(mam.req, as="text"))
mam.list$data[1:20,]
```

```
##    taxonTypeCode taxonID acceptedTaxonID               dwc:scientificName
## 1   SMALL_MAMMAL    AMHA            AMHA        Ammospermophilus harrisii
## 2   SMALL_MAMMAL    AMIN            AMIN       Ammospermophilus interpres
## 3   SMALL_MAMMAL    AMLE            AMLE        Ammospermophilus leucurus
## 4   SMALL_MAMMAL    AMLT            AMLT Ammospermophilus leucurus tersus
## 5   SMALL_MAMMAL    AMNE            AMNE         Ammospermophilus nelsoni
## 6   SMALL_MAMMAL    AMSP            AMSP             Ammospermophilus sp.
## 7   SMALL_MAMMAL    APRN            APRN            Aplodontia rufa nigra
## 8   SMALL_MAMMAL    APRU            APRU                  Aplodontia rufa
## 9   SMALL_MAMMAL    ARAL            ARAL                Arborimus albipes
## 10  SMALL_MAMMAL    ARLO            ARLO            Arborimus longicaudus
## 11  SMALL_MAMMAL    ARPO            ARPO                   Arborimus pomo
## 12  SMALL_MAMMAL    ARSP            ARSP                    Arborimus sp.
## 13  SMALL_MAMMAL    BATA            BATA                  Baiomys taylori
## 14  SMALL_MAMMAL    BLBR            BLBR               Blarina brevicauda
## 15  SMALL_MAMMAL    BLCA            BLCA             Blarina carolinensis
## 16  SMALL_MAMMAL    BLHY            BLHY                Blarina hylophaga
## 17  SMALL_MAMMAL    BLSP            BLSP                      Blarina sp.
## 18  SMALL_MAMMAL    BRID            BRID           Brachylagus idahoensis
## 19  SMALL_MAMMAL    CHBA            CHBA              Chaetodipus baileyi
## 20  SMALL_MAMMAL    CHCA            CHCA         Chaetodipus californicus
##    dwc:scientificNameAuthorship dwc:taxonRank
## 1           Audubon and Bachman       species
## 2                       Merriam       species
## 3                       Merriam       species
## 4                       Goldman    subspecies
## 5                       Merriam       species
## 6                          <NA>         genus
## 7                        Taylor    subspecies
## 8                    Rafinesque       species
## 9                       Merriam       species
## 10                         True       species
## 11           Johnson and George       species
## 12                         <NA>         genus
## 13                       Thomas       species
## 14                          Say       species
## 15                      Bachman       species
## 16                       Elliot       species
## 17                         <NA>         genus
## 18                      Merriam       species
## 19                      Merriam       species
## 20                      Merriam       species
##               dwc:vernacularName dwc:nameAccordingToID dwc:kingdom
## 1      Harriss Antelope Squirrel  isbn: 978 0801882210    Animalia
## 2        Texas Antelope Squirrel  isbn: 978 0801882210    Animalia
## 3  Whitetailed Antelope Squirrel  isbn: 978 0801882210    Animalia
## 4                           <NA>  isbn: 978 0801882210    Animalia
## 5      Nelsons Antelope Squirrel  isbn: 978 0801882210    Animalia
## 6                           <NA>  isbn: 978 0801882210    Animalia
## 7                           <NA>  isbn: 978 0801882210    Animalia
## 8                       Sewellel  isbn: 978 0801882210    Animalia
## 9               Whitefooted Vole  isbn: 978 0801882210    Animalia
## 10                 Red Tree Vole  isbn: 978 0801882210    Animalia
## 11              Sonoma Tree Vole  isbn: 978 0801882210    Animalia
## 12                          <NA>  isbn: 978 0801882210    Animalia
## 13          Northern Pygmy Mouse  isbn: 978 0801882210    Animalia
## 14    Northern Shorttailed Shrew  isbn: 978 0801882210    Animalia
## 15    Southern Shorttailed Shrew  isbn: 978 0801882210    Animalia
## 16     Elliots Shorttailed Shrew  isbn: 978 0801882210    Animalia
## 17                          <NA>  isbn: 978 0801882210    Animalia
## 18                  Pygmy Rabbit  isbn: 978 0801882210    Animalia
## 19          Baileys Pocket Mouse  isbn: 978 0801882210    Animalia
## 20       California Pocket Mouse  isbn: 978 0801882210    Animalia
##    dwc:phylum dwc:class    dwc:order    dwc:family        dwc:genus
## 1    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
## 2    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
## 3    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
## 4    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
## 5    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
## 6    Chordata  Mammalia     Rodentia     Sciuridae Ammospermophilus
## 7    Chordata  Mammalia     Rodentia Aplodontiidae       Aplodontia
## 8    Chordata  Mammalia     Rodentia Aplodontiidae       Aplodontia
## 9    Chordata  Mammalia     Rodentia    Cricetidae        Arborimus
## 10   Chordata  Mammalia     Rodentia    Cricetidae        Arborimus
## 11   Chordata  Mammalia     Rodentia    Cricetidae        Arborimus
## 12   Chordata  Mammalia     Rodentia    Cricetidae        Arborimus
## 13   Chordata  Mammalia     Rodentia    Cricetidae          Baiomys
## 14   Chordata  Mammalia Soricomorpha     Soricidae          Blarina
## 15   Chordata  Mammalia Soricomorpha     Soricidae          Blarina
## 16   Chordata  Mammalia Soricomorpha     Soricidae          Blarina
## 17   Chordata  Mammalia Soricomorpha     Soricidae          Blarina
## 18   Chordata  Mammalia   Lagomorpha     Leporidae      Brachylagus
## 19   Chordata  Mammalia     Rodentia  Heteromyidae      Chaetodipus
## 20   Chordata  Mammalia     Rodentia  Heteromyidae      Chaetodipus
##    gbif:subspecies gbif:variety
## 1               NA           NA
## 2               NA           NA
## 3               NA           NA
## 4               NA           NA
## 5               NA           NA
## 6               NA           NA
## 7               NA           NA
## 8               NA           NA
## 9               NA           NA
## 10              NA           NA
## 11              NA           NA
## 12              NA           NA
## 13              NA           NA
## 14              NA           NA
## 15              NA           NA
## 16              NA           NA
## 17              NA           NA
## 18              NA           NA
## 19              NA           NA
## 20              NA           NA
```


