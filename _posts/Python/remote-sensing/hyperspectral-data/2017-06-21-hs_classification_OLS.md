---
layout: post
title: "Classification of Hyperspectral Data with Ordinary Least Squares in Python"
date: 2017-06-06 
dateCreated: 2017-06-21 
lastModified: 2017-06-21 
estimatedTime: 
packagesLibraries: 
authors: [Paul Gader]
categories: [self-paced-tutorial]
tags: [hyperspectral-remote-sensing, Python, remote-sensing]
mainTag: intro-hsi-py-series
tutorialSeries: [intro-hsi-py-series]
description: "Learn to classify spectral data using the Ordinary Least Squares method." 
image:
  feature: planeBanner.png
  credit:
  creditlink:
permalink: /remote-sensing/classify-ols-python/
code1: Python/hyperspectral-data/Classification_OLS.ipynb
comments: true

---

{% include _toc.html %}

In this tutorial, we will learn to classify spectral data using the 
Ordinary Least Squares method. 


<div id="objectives" markdown="1">

# Objectives
After completing this tutorial, you will be able to:

* Classify spectral remote sensing data using Ordinary Least Squares. 

### Install Python Packages

* **numpy**
* **gdal** 
* **matplotlib** 
* **matplotlib.pyplot** 


### Download Data

 <a href="https://ndownloader.figshare.com/files/8730436" class="btn btn-success">
Download the spectral classification teaching data subset</a>

### Additional Materials

This tutorial was prepared in conjunction with a presentation on spectral classification
that can be downloaded. 

<a href="https://ndownloader.figshare.com/files/8730613" class="btn btn-success">
Download Dr. Paul Gader's Classification 1 PPT</a>

<a href="https://ndownloader.figshare.com/files/8731960" class="btn btn-success">
Download Dr. Paul Gader's Classification 2 PPT</a>

<a href="https://ndownloader.figshare.com/files/8731963" class="btn btn-success">
Download Dr. Paul Gader's Classification 3 PPT</a>

</div>

Classification with Ordinary Least Squares solves the 2-class least squares problem. 


```python
import numpy as np
import matplotlib
import matplotlib.pyplot as mplt
from scipy import linalg
from scipy import io

```

Let's load the data. 


```python
### LOAD DATA ###
### IF LoadClasses IS True, THEN LOAD DATA FROM FILES ###
### OTHERSIE, RANDOMLY GENERATE DATA ###

LoadClasses    = False
TrainOutliers  = False
TestOutliers   = False
NOut           = 20
NSampsClass    = 200
NSamps         = 2*NSampsClass

if LoadClasses:
    
    ### GET FILENAMES %%%
    ### THESE ARE THE OPTIONS ###
    ### LinSepC1, LinSepC2,LinSepC2Outlier (Still Linearly Separable) ###
    ### NonLinSepC1, NonLinSepC2, NonLinSepC22 ###
    
    InFile1          = 'NonLinSepC1.mat'
    InFile2          = 'NonLinSepC22.mat'
    C1Dict           = io.loadmat(InFile1)
    C2Dict           = io.loadmat(InFile2)
    C1               = C1Dict['NonLinSepC1']
    C2               = C2Dict['NonLinSepC22']
    
    if TrainOutliers:
        ### Let's Make Some Noise ###
        Out1        = 2*np.random.rand(NOut,2)-0.5
        Out2        = 2*np.random.rand(NOut,2)-0.5
        C1          = np.concatenate((C1,Out1),axis=0)
        C2          = np.concatenate((C2,Out2),axis=0)
        NSampsClass = NSampsClass+NOut
        NSamps      = 2*NSampsClass
else:
    ### Randomly Generate Some Data
    ### Make a covariance using a diagonal array and rotation matrix
    pi      = 3.141592653589793
    Lambda1 = 0.25
    Lambda2 = 0.05
    DiagMat = np.array([[Lambda1, 0.0],[0.0, Lambda2]])
    RotMat  = np.array([[np.sin(pi/4), np.cos(pi/4)], [-np.cos(pi/4), np.sin(pi/4)]])
    mu1     = np.array([0,0])
    mu2     = np.array([1,1])
    Sigma   = np.dot(np.dot(RotMat.T, DiagMat), RotMat)
    C1      = np.random.multivariate_normal(mu1, Sigma, NSampsClass)
    C2      = np.random.multivariate_normal(mu2, Sigma, NSampsClass)
    print(Sigma)
    print(C1.shape)
    print(C2.shape)

```

Now we can plot the data

```python

### PLOT DATA ###
matplotlib.pyplot.figure(1)
matplotlib.pyplot.plot(C1[:NSampsClass, 0], C1[:NSampsClass, 1], 'bo')
matplotlib.pyplot.plot(C2[:NSampsClass, 0], C2[:NSampsClass, 1], 'ro')
matplotlib.pyplot.show()
```

    [[ 0.15  0.1 ]
     [ 0.1   0.15]]
    (200, 2)
    (200, 2)


![ ]({{ site.baseurl }}/images/py-figs/classification_OLS/output_0_1.png)


```python
### SET UP TARGET OUTPUTS ###
TargetOutputs = np.ones((NSamps,1))
TargetOutputs[NSampsClass:NSamps] = -TargetOutputs[NSampsClass:NSamps]

### PLOT TARGET OUTPUTS ###
matplotlib.pyplot.figure(2)
matplotlib.pyplot.plot(range(NSampsClass),         TargetOutputs[range(NSampsClass)],   'b-')
matplotlib.pyplot.plot(range(NSampsClass, NSamps), TargetOutputs[range(NSampsClass, NSamps)], 'r-')
matplotlib.pyplot.show()
```

![ ]({{ site.baseurl }}/images/py-figs/classification_OLS/output_1_0.png)



```python
### FIND LEAST SQUARES SOLUTION ###
AllSamps     = np.concatenate((C1,C2),axis=0)
AllSampsBias = np.concatenate((AllSamps, np.ones((NSamps,1))), axis=1)
Pseudo       = linalg.pinv2(AllSampsBias)
w            = Pseudo.dot(TargetOutputs)
```


```python
w
```


    array([[-0.60882271],
           [-0.78680753],
           [ 0.72667843]])



```python
### COMPUTE OUTPUTS ON TRAINING DATA ###
y = AllSampsBias.dot(w)

### PLOT OUTPUTS FROM TRAINING DATA ###
matplotlib.pyplot.figure(3)
matplotlib.pyplot.plot(range(NSamps), y, 'm')
matplotlib.pyplot.plot(range(NSamps),np.zeros((NSamps,1)), 'b')
matplotlib.pyplot.plot(range(NSamps), TargetOutputs, 'k')
matplotlib.pyplot.title('TrainingOutputs (Magenta) vs Desired Outputs (Black)')
matplotlib.pyplot.show()
```

![ ]({{ site.baseurl }}/images/py-figs/classification_OLS/output_4_0.png)


```python
### CALCULATE AND PLOT LINEAR DISCRIMINANT ###
Slope     = -w[1]/w[0]
Intercept = -w[2]/w[0]
Domain    = np.linspace(-1.1, 1.1, 60)
Disc      = Slope*Domain+Intercept

matplotlib.pyplot.figure(4)
matplotlib.pyplot.plot(C1[:NSampsClass, 0], C1[:NSampsClass, 1], 'bo')
matplotlib.pyplot.plot(C2[:NSampsClass, 0], C2[:NSampsClass, 1], 'ro')
matplotlib.pyplot.plot(Domain, Disc, 'k-')
matplotlib.pyplot.ylim([-1.1,1.3])
matplotlib.pyplot.title('Ordinary Least Squares')
matplotlib.pyplot.show()
```

![ ]({{ site.baseurl }}/images/py-figs/classification_OLS/output_5_0.png)


```python
RegConst      = 0.1
AllSampsBias  = np.concatenate((AllSamps, np.ones((NSamps,1))), axis=1)
AllSampsBiasT = AllSampsBias.T
XtX           = AllSampsBiasT.dot(AllSampsBias)
AllSampsReg   = XtX + RegConst*np.eye(3)
Pseudo        = linalg.pinv2(AllSampsReg)
wr            = Pseudo.dot(AllSampsBiasT.dot(TargetOutputs))
```


```python
Slope     = -wr[1]/wr[0]
Intercept = -wr[2]/wr[0]
Domain    = np.linspace(-1.1, 1.1, 60)
Disc      = Slope*Domain+Intercept

matplotlib.pyplot.figure(5)
matplotlib.pyplot.plot(C1[:NSampsClass, 0], C1[:NSampsClass, 1], 'bo')
matplotlib.pyplot.plot(C2[:NSampsClass, 0], C2[:NSampsClass, 1], 'ro')
matplotlib.pyplot.plot(Domain, Disc, 'k-')
matplotlib.pyplot.ylim([-1.1,1.3])
matplotlib.pyplot.title('Ridge Regression')
matplotlib.pyplot.show()
```

![ ]({{ site.baseurl }}/images/py-figs/classification_OLS/output_7_0.png)


First, let's save this project with the name: OLSandRidgeRegress2DYourName. 
Take a new project for spectra.


```python
### COMPUTE OUTPUTS ON TRAINING DATA ###
yr = AllSampsBias.dot(wr)

### PLOT OUTPUTS FROM TRAINING DATA ###
matplotlib.pyplot.figure(6)
matplotlib.pyplot.plot(range(NSamps), yr, 'm')
matplotlib.pyplot.plot(range(NSamps),np.zeros((NSamps,1)), 'b')
matplotlib.pyplot.plot(range(NSamps), TargetOutputs, 'k')
matplotlib.pyplot.title('TrainingOutputs (Magenta) vs Desired Outputs (Black)')
matplotlib.pyplot.show()
```

![ ]({{ site.baseurl }}/images/py-figs/classification_OLS/output_9_0.png)




```python
y1 = y[range(NSampsClass)]
y2 = y[range(NSampsClass, NSamps)]
Corr1 = np.sum([y1>0])
Corr2 = np.sum([y2<0])

y1r = yr[range(NSampsClass)]
y2r = yr[range(NSampsClass, NSamps)]
Corr1r = np.sum([y1r>0])
Corr2r = np.sum([y2r<0])
```


```python
print('Result for Ordinary Least Squares')
CorrClassRate=(Corr1+Corr2)/NSamps
print(Corr1 + Corr2, 'Correctly Classified for a ', round(100*CorrClassRate), '% Correct Classification \n')

print('Result for Ridge Regression')
CorrClassRater=(Corr1r+Corr2r)/NSamps
print(Corr1r + Corr2r, 'Correctly Classified for a ', round(100*CorrClassRater), '% Correct Classification \n')
```

    Result for Ordinary Least Squares
    373 Correctly Classified for a  93.0 % Correct Classification 
    
    Result for Ridge Regression
    373 Correctly Classified for a  93.0 % Correct Classification 
    



```python
### Make Confusion Matrices ###
NumClasses = 2;
Cm         = np.zeros((NumClasses,NumClasses))
Cm[(0,0)]  = Corr1/NSampsClass
Cm[(0,1)]  = (NSampsClass-Corr1)/NSampsClass
Cm[(1,0)]  = (NSampsClass-Corr2)/NSampsClass
Cm[(1,1)]  = Corr2/NSampsClass
Cm           = np.round(100*Cm)
print('Confusion Matrix for OLS Regression \n', Cm, '\n')

Cm           = np.zeros((NumClasses,NumClasses))
Cm[(0,0)]    = Corr1r/NSampsClass
Cm[(0,1)]    = (NSampsClass-Corr1r)/NSampsClass
Cm[(1,0)]    = (NSampsClass-Corr2r)/NSampsClass
Cm[(1,1)]    = Corr2r/NSampsClass
Cm           = np.round(100*Cm)
print('Confusion Matrix for Ridge Regression \n', Cm, '\n')
```

    Confusion Matrix for OLS Regression 
     [[ 93.   7.]
     [  6.  94.]] 
    
    Confusion Matrix for Ridge Regression 
     [[ 93.   7.]
     [  6.  94.]] 
    

 <div id="challenge" markdown="1">

## Challenge: Ordinary Least Square 
Run Ordinary Least Squares and Ridge Regression on Spectra and plot the weights.

</div>
