---
title: Quantifying The Drivers and Impacts of Natural Disturbance Events – The 2013 Colorado Floods
code1: 
contributors: Donal O'Leary
dataProduct: DP3.30024.001
dateCreated: '2015-05-18'
description: This teaching module demonstrates ways that scientists identify and use
  data that they use to study disturbance events. Further, it encourages students
  to think about why we need to quantify change and different types of data needed
  to quantify the change. The focus is on flooding as a natural disturbance event
  with impacts on the local human populations. Specifically, it focuses on the causes
  and impacts of flooding that occurred in 2013 throughout Colorado with an emphasis
  on Boulder county.
estimatedTime: 4 hours
languagesTool: spreadsheet, R, plotly
packagesLibraries: ggplot2, plotly
syncID: 1ca06930711c4a50bf9cf3b6fd5aec5f
authors: Leah A. Wasser, Megan A. Jones, Donal O'Leary
topics: time-series, meteorology, data-viz
tutorialSeries: disturb-events-co13
urlTitle: tm-disturbance-events-co13flood
---

#### The 2013 Colorado Front Range Flood

<iframe width="640" height="360" src="https://www.youtube.com/embed/IHIckvWhwoo" frameborder="0" allowfullscreen></iframe>
 
## Why was the Flooding so Destructive? 

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/N_St_Vrain_before_and_after_CreditBoulderCo.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/N_St_Vrain_before_and_after_CreditBoulderCo.jpg"></a>
	<figcaption> The St. Vrain River in Boulder County, CO after (left) and before
	(right) the 2013 flooding event.  Source: Boulder County via <a href="http://krcc.org/post/post-flood-planning-boulder-county" target="_blank"> KRCC</a>.
	</figcaption>
</figure>

A major disturbance event like this flood causes significant changes in a 
landscape.  The St. Vrain River in the image above completely shifted its course
of flow in less than 5 days! This brings major changes for aquatic organisms, 
like crayfish, that lived along the old stream bed that is now bare and dry, or 
for, terrestrial organisms, like a field vole, that used to have a burrow under 
what is now the St. Vrain River.  Likewise, the people living in the house that 
is now on the west side of the river instead of the eastern bank have a 
completely different yard and driveway!  

1. Why might this storm have caused so much flooding? 
1. What other weather patterns could have contributed to pronounced flooding? 

## Introduction to Disturbance Events

<div id="ds-dataTip" markdown="1">

**Definition:**  In ecology, a **disturbance event** 
is a temporary change in environmental conditions that causes a pronounced 
change in the ecosystem. Common disturbance events include floods, fires, 
earthquakes, and tsunamis. 

</div>


Within ecology, disturbance events are those events which cause dramatic change
in an ecosystem through a temporary, often rapid, change in environmental
conditions. Although the disturbance events themselves can be of short duration,
the ecological effects last decades, if not longer. 

Common examples of natural ecological disturbances include hurricanes, fires, 
floods, earthquakes and windstorms. 

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/Natural-disturbance.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/Natural-disturbance.png"></a>
	<figcaption> Common natural ecological disturbances.  
	</figcaption>
</figure>

Disturbance events can also be human caused: clear cuts when logging, fires to 
clear forests for cattle grazing or the building of new housing developments 
are all common disturbances. 

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/Anthro-disturbance.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/Anthro-disturbance.png"></a>
	<figcaption> Common human-caused ecological disturbances.  
	</figcaption>
</figure>

Ecological communities are often more resilient to some types of disturbance than
others. Some communities are even dependent on cyclical disturbance events. 
Lodgepole pine (_Pinus_ _contorta_) forests in the Western US are dependent on
frequent stand-replacing fires to release seeds and spur the growth of young 
trees.  

 <figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/Lodgepole_pine_Yellowstone_1998_near_firehole.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/Lodgepole_pine_Yellowstone_1998_near_firehole.jpg"></a>
	<figcaption> Regrowth of Lodgepole Pine (<i>Pinus contorta</i>) after a stand-replacing fire.  
	Source: Jim Peaco, September 1998, Yellowstone Digital Slide Files; 
	<a href="https://commons.wikimedia.org/wiki/File:Lodgepole_pine_Yellowstone_1998_near_firehole.jpg" target="_blank">Wikipedia Commons</a>. 
	</figcaption>
</figure>

However, in discussions of ecological disturbance events we think about events 
that disrupt the status of the ecosystem and change the structure of the
landscape. 

In this lesson we will dig into the causes and disturbances caused during a storm
in September 2013 along the Colorado Front Range. 

## Driver: Climatic & Atmospheric Patterns

### Drought
How do we measure drought? 

<div id="ds-dataTip" markdown="1"> **Definition:** The **Palmer Drought Severity 
Index** is a measure of soil moisture content. It is calculated from soil 
available water content,precipitation and temperature data. The values range 
from **extreme drought** (values <-4.0) through **near normal** (-.49 to .49) 
to **extremely moist** (>4.0).
</div>

Bonus: There are several other commonly used drought indices. The 
<a href="http://drought.unl.edu/Planning/Monitoring/ComparisonofDroughtIndices.aspx" target="_blank"> National Drought Mitigation Center </a> 
provides a comparison of the different indices.  

This interactive plot shows the Palmer Drought Severity Index from 1991 through 
2015 for Colorado. 

<iframe width="800" height="800" frameborder="0" scrolling="no" src="https://plot.ly/~NEONDataSkills/2.embed"></iframe>

Palmer Drought Severity Index for Colorado 1991-2015. Source: National 
Ecological Observatory Network (NEON) based on data from 
<a href="http://www7.ncdc.noaa.gov/CDO/CDODivisionalSelect.jsp" target="_blank"> National Climatic Data Center–NOAA</a>. 

#### Questions
Use the figure above to answer these questions: 

1. In this dataset, what years are **near normal**, **extreme drought**, and 
**extreme wet** on the Palmer Drought Severity Index? 
1. What are the patterns of drought within Colorado that you observe using this 
Palmer Drought Severity Index?
1. What were the drought conditions immediately before the September 2013
floods? 

Over this decade and a half, there have been several cycles of dry and wet 
periods. The 2013 flooding occurred right at the end of a severe drought. 

There is a connection between the dry soils during a drought and the potential 
for flooding. In a severe drought the top layers of the soil dry out. Organic 
matter, spongy and absorbent in moist topsoil, may desiccate and be transported 
by the winds to other areas. Some soil types, like clay, can dry to a 
near-impermeable brick causing water to flow across the top instead of sinking 
into the soils. 

**Optional Data Activity** <a href="https://www.neonscience.org/da-viz-nclimdiv-palmer-drought-data-r" target="_blank">Visualize <b>Palmer Drought Severity Index Data </b> in R to Better Understand the 2013 Colorado Floods</a>.

### Atmospheric Conditions
In early September 2013, a slow moving cold front moved through Colorado
intersecting with a warm, humid front. The clash between the cold and warm
fronts yielded heavy rain and devastating flooding across the Front Range in
Colorado.

<figure>
   <a href="https://en.wikipedia.org/wiki/2013_Colorado_floods#/media/File:North_American_Water_Vapor_Systems.gif">
   <img src="https://upload.wikimedia.org/wikipedia/commons/9/97/North_American_Water_Vapor_Systems.gif"></a>
   <figcaption>This animated loop shows water vapor systems over the western 
   area of North America on September 12th, 2013 as recorded by the GOES-15 and 
   GOES-13 satellites. Source: <a href="http://cimss.ssec.wisc.edu/goes/blog/archives/13876" target="_blank"> Cooperative Institute for Meteorological 
   Satellite Studies (CIMSS), University of Wisconsin – Madison, USA </a>
    </figcaption>
</figure>

The storm that caused the 2013 Colorado flooding was kept in a confined area 
over the Eastern Range of the Rocky Mountains in Colorado by these water vapor 
systems. 

## Driver: Precipitation
How do we measure precipitation? 

<div id="ds-dataTip" markdown="1">
**Definition:** Precipitation is the moisture that
falls from clouds including rain, hail and snow. 
</div>

Precipitation can be measured by different types of gauges; some must be 
manually read and emptied, others automatically record the amount of 
precipitation. If the precipitation is in a frozen form (snow, hail, freezing rain)
the contents of the gauge must be melted to get the water equivalency for 
measurement. Rainfall is generally reported as the total amount of rain 
(millimeters, centimeters, or inches) over a given per period of time. 

Boulder, Colorado lays on the eastern edge of the Rocky Mountains where they meet
the high plains. The average annual precipitation is near 20". However, the 
precipitation comes in many forms -- winter snow, intense summer thunderstorms, 
and intermittent storms throughout the year.

The figure below show the total precipitation each month from 1948 to 2013 for
the National Weather Service's COOP site Boulder 2 (Station ID:050843) that is 
centrally located in Boulder, CO. 

<iframe width="800" height="800" frameborder="0" scrolling="no" src="https://plot.ly/~NEONDataSkills/6.embed"></iframe>

Notice the general pattern of rainfall across the 65 years. 

1. How much rain generally falls within one month?
1. Is there a strong annual or seasonal pattern? (Remember, with 
interactive Plotly plots you can zoom in on the data) 
1. Do any other events over the last 65 years equal the September 2013 event?

Now that we've looked at 65 years of data from Boulder, CO. Let's focus more 
specifically on the September 2013 event. The plot below shows daily 
precipitation between August 15 - October 15, 2013. 

Explore the data and answer the following questions:

1. What dates were the highest precipitation values observed? 
1. What was the total precipitation on these days? 
1. In what units is this value?

<iframe width="800" height="800" frameborder="0" scrolling="no" src="https://plot.ly/~NEONDataSkills/4.embed"></iframe>


**Optional Data Activity:** <a href="https://www.neonscience.org/da-viz-coop-precip-data-R" target="_blank">Visualize <b>Precipitation Data</b> in R to Better Understand the 2013 Colorado Floods</a>.

## Driver: Stream Discharge

The USGS has a distributed network of aquatic sensors located in streams across
the United States. This network monitors a suit of variables that are important
to stream morphology and health. One of the metrics that this sensor network
monitors is **stream discharge**, a metric which quantifies the volume of water
moving down a stream. Discharge is an ideal metric to quantify flow, which
increases significantly during a flood event.

#### How is stream discharge measured? 

> Most USGS streamgages operate by measuring the elevation of the water in the 
> river or stream and then converting the water elevation (called 'stage') to a 
> streamflow ('discharge') by using a curve that relates the elevation to a set 
> of actual discharge measurements. This is done because currently the 
> technology is not available to measure the flow of the water accurately 
> enough directly.  From the
<a href="http://water.usgs.gov/nsip/definition9.html" target="_blank"> USGS National Streamflow Information Program</a>
<figure>
   <a href="http://water.usgs.gov/edu/images/streamflow1-fig2.jpg">
   <img src="http://water.usgs.gov/edu/images/streamflow1-fig2.jpg"></a>
   <figcaption>A typical USGS stream gauge using a stilling well. Source: <a href="http://water.usgs.gov/edu/streamflow1.html" target="_blank"> USGS</a>.  
    </figcaption>
</figure>

#### What was the stream discharge prior to and during the flood events?  

The data for the stream gauge along Boulder Creek 5 miles downstream of downtown 
Boulder is reported in daily averages.  Take a look at the interactive plot 
below to see how patterns of discharge seen in these data?


<iframe width="800" height="800" frameborder="0" scrolling="no" src="https://plot.ly/~NEONDataSkills/8.embed"></iframe>

#### Questions: 


**Optional Data Activity:** <a href="https://www.neonscience.org/da-viz-usgs-stream-discharge-data-R" target="_blank">Visualize <b>Stream Discharge Data</b> in R to Better Understand the 2013 Colorado Floods</a>.

## Impact: Flood

<div id="ds-dataTip" markdown="1">
**Definition:**  A **flood** is anytime water inundates normally dry land. 
</div>

### Return Interval

<figure class="half">
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/500-yr-flood_cropped.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/500-yr-flood_cropped.jpg">
	</a>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/DailyCamera_100-yearFlood_cropped.jpg">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/DailyCamera_100-yearFlood_cropped.jpg">
	</a>
	<figcaption>Return intervals make for shocking headlines but how are they calculated?
	</figcaption>
</figure>  

#### A 1000 year Flood!!!  Understanding Return Periods

When talking about major disturbance events we often hear "It was a 1000-year
flood" or "That was a 100-year storm".  What does this really mean?  
  
<div id="ds-dataTip" markdown="1">
**Definition:** A **return interval** is the likelihood, a statistical 
measurement, of how often an event will occur for a given area. 
</div>

Check out this 
<a href="https://weather.com/news/weather/video/1000-year-flood-explained" target="_blank">video explanation from The Weather Channel </a>
on how return intervals are calculated and what they mean to us.

And it isn't just floods, major hurricanes are forecast to strike New Orleans, 
Louisiana once every 
<a href="http://climatica.org.uk/climate-science-information/return-periods-extreme-events" target="_blank"> 20 years</a>. 
Yet in 2005 New Orleans was pummeled by 4 hurricanes and 1
tropical storm.  Hurricane Cindy in July 2013 caused the worst black out in New
Orleans for 40 years.  Eight weeks later Hurricane Katrina came ashore over New 
Orleans, changed the landscape of the city and became the costliest natural
disaster to date in the United States.  It was frequently called a 100-year
storm. 

If we say the return period is 20 years then how did 4 hurricanes strike New 
Orleans in 1 year?

The return period of extreme events is also referred to as _recurrence_
_interval_. It is an estimate of the likelihood of an extreme event
based on the statistical analysis of data (including flood records, fire
frequency, historical climatic records) that an event of a given magnitude will 
occur in a given year. The probability can be used to assess the risk of these
events for human populations but can also be used by biologists when creating 
habitat management plans or conservation plans for endangered species. The
concept is based on the _magnitude-frequency_ _principle_, where large magnitude
events (such as major hurricanes) are comparatively less frequent than smaller
magnitude incidents (such as rain showers).  (For more information visit  
<a href="http://climatica.org.uk/climate-science-information/return-periods-extreme-events" target="_blank"> Climatica's Return Periods of Extreme Events.</a>)


#### Question
Your friend is thinking about buying a house near Boulder Creek.  The 
house is above the level of seasonal high water but was flooded in the 2013
flood.  He realizes how expensive flood insurance is and says, "Why do I have to
buy this insurance, a flood like that won't happen for another 100 years? 
I won't live here any more."  How would you explain to him that even though the
flood was a 100-year flood he should still buy the flood insurance?  

### Flood Plains 

<div id="ds-dataTip" markdown="1"> 
**Definition:**  A **flood plain** is land adjacent to a waterway, from the 
channel banks to the base of the enclosing valley walls, that experiences 
flooding during periods of high discharge. 
</div>

<figure>
   <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/bigBoulderCreeks760_floodsafety-com.jpg">
   <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/bigBoulderCreeks760_floodsafety-com.jpg"></a>
   <figcaption>Flood plain through the city of Boulder. The LiDAR data used in 
   the lesson is from Four Mile Canyon Creek. Source:<a href="http://floodsafety.com/media/maps/colorado/Boulder/index.htm" target="_blank">floodsafety.com</a>.  
    </figcaption>
</figure>

## Impact: Erosion & Sedimentation

How can we evaluate the impact of a flooding event? 

#### 1. Economic Impacts
We could look at economic damages to homes, businesses, and other 
infrastructure. 
<a href="https://bouldercolorado.gov/flood/flood-maps" target="_blank"> Click here to view the City of Boulder's maps for flood damages.</a> 

#### 2. Before & After Photos
We could view photos from before and after the disturbance event to see where
erosion or sedimentation has occurred. 

<iframe width="640" height="360" src="https://www.youtube.com/embed/bUcWERTM-OA?rel=0&loop=1" frameborder="0" allowfullscreen></iframe>

Images are great for an overall impression of what happened, where soil has 
eroded, and where soil or rocks have been deposited. But it is hard to 
get measurements of change from these 2D images. There are several ways that we can 
measure the apparent erosion and soil deposition.  

#### 3. Field Surveys
Standard surveys can be done to map the three-dimensional position of points allowing
for measurement of distance between points and elevation.  However, this requires
extensive effort by land surveyors to visit each location and collect a large
number of points to precisely map the region. This method can be very time intensive. 

<figure>
   <a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/TotalStation_NEONTechJGallowayD08_PhotoByMichaelPatterson.jpg">
   <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/disturb-events-co13/TotalStation_NEONTechJGallowayD08_PhotoByMichaelPatterson.jpg"></a>
   <figcaption>Survey of a NEON field site done with a total station Source: Michael Patterson</a>.  
    </figcaption>
</figure>

This method is challenging to use over a large spatial scale. 

#### 4. Stereoscopic Images

We could view stereoscopic images, two photos taken from slightly different
perspectives to give the illusion of 3D, one can view, and even measure, 
elevation changes from 2D pictures. 

<figure>
   <a href="https://theoldtopographer.files.wordpress.com/2014/06/sokkisha-13.jpg?w=584&h=444">
   <img src="https://theoldtopographer.files.wordpress.com/2014/06/sokkisha-13.jpg?w=584&h=444"></a>
   <figcaption>A Sokkisha MS-16 stereoscope and the overlapping imaged used to 
   create 3-D visuals from a aerial photo. Source: <a href="https://oldtopographer.net/2014/07/" target="_blank"> Brian Haren</a>.  
    </figcaption>
</figure>

However, this relies on specialized equipment and is challenging to automate. 

#### 5. LiDAR
A newer technology is Light Detection and Ranging (LiDAR or lidar). 

<iframe width="640" height="360" src="https://www.youtube.com/embed/EYbhNSUnIdU" frameborder="0" allowfullscreen></iframe>

Watch this video to see how LiDAR works.  

## Using LiDAR to Measure Change

LiDAR data allows us to create models of the earth's surface. The general term 
for a model of the elevation of an area is a Digital Elevation Model (DEM). DEMs
come in two common types: 

* Digital Terrain Models (DTM): The elevation of the ground (terrain). 
* Digital Surface Models (DSM): The elevation of everything on the surface of the earth,
including trees, buildings, or other structures. Note: some DSMs have been post-processed to remove buildings and other human-made objects. 

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/lidar-derived-products/DSM-DTM.png">
  <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/lidar-derived-products/DSM-DTM.png"></a>
  <figcaption>Digital Terrain Models and Digital Surface Models are two common 
  LiDAR-derived data products. The digital terrain model allows scientists to 
  study changes in terrain (topography) over time.
	</figcaption>
</figure>

### Digital Terrain Models  (DTMs)

<figure class="half">
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/Colorado-floods-data-visualization/NEON-Boulder-Flood-LiDAR-in-R/rfigs/plot-crop-raster-1.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/Colorado-floods-data-visualization/NEON-Boulder-Flood-LiDAR-in-R/rfigs/plot-crop-raster-1.png">
	</a>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/Colorado-floods-data-visualization/NEON-Boulder-Flood-LiDAR-in-R/rfigs/plot-crop-raster-2.png">
	<img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/Colorado-floods-data-visualization/NEON-Boulder-Flood-LiDAR-in-R/rfigs/plot-crop-raster-2.png">
	</a>
</figure>  

Here we have Digital Terrain Model of lower Four-Mile Canyon Creek from before
the 2013 flood event (left) and from after the 2013 flood event (right). We can
see some subtle differences in the elevation, especially along the stream bed, 
however, even on this map it is still challenging to see. 

### Digital Elevation Model of Difference (DoD)

If we have a DEM from before and after an event, we can can create a model that
shows the change that occurred during the event. This new model is called a 
Digital Elevation Model of Difference (DoD). 

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/lidar-derived-products/DoD_DTM.png">
  <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/graphics/lidar-derived-products/DoD_DTM.png"></a>
  <figcaption> A cross-section showing the data represented by a Digital
  Elevation Model of Difference (DoD) created by subtracting one DTM from 
  another. The resultant DoD shows the change that has occurred in a given
  location- here, in orange, the areas where the earth's surface is lower than
  before and, in teal, the areas where the earth's surface is higher than 
  before.
	</figcaption>
</figure>

#### Questions

Here we are using DTMs to create our Digital Elevation Model of Difference (DoD) 
to look at the changes after a flooding event. What types of disturbance events 
or what research question might one want to look at DoDs from Digital Surface 
Models? 

#### Four Mile Canyon Creek DoD

<figure>
	<a href="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/Colorado-floods-data-visualization/NEON-Boulder-Flood-LiDAR-in-R/rfigs/plot-crop-raster-3.png">
  <img src="https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/R/R-skills/Colorado-floods-data-visualization/NEON-Boulder-Flood-LiDAR-in-R/rfigs/plot-crop-raster-3.png"></a>
  <figcaption> Areas in red are those were the elevation is lower after the flood
  and areas in blue are those where the elevation is higher after the flood event.
	</figcaption>
</figure>


**Optional Data Activity:** <a href="https://www.neonscience.org/da-viz-neon-lidar-co13flood-R" target="_blank">Visualize <b>Topography Change</b> using LiDAR-derived Data in R to Better Understand the 2013 Colorado Floods</a>.

## Using Data to Understand Disturbance Events

We've used the data from drought, atmospheric conditions, precipitation, stream flow, 
and the digital elevation models to help us understand what caused the 2013 
Boulder County, Colorado flooding event and where there was change in the stream
bed around Four Mile Canyon Creek at the outskirts of Boulder, Colorado. 

Quantifying the change that we can see from images of the flooding streams or 
post-flood changes to low lying areas allows scientists, city planners, and 
homeowners to make choices about future land use plans.  

### Follow-up Questions

1. What other types of questions could this or similar data be used to answer?
1. What types of disturbance events in your local area could you use data to 
quantify the causes and impact of? 

