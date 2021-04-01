---
syncID: 1497c1da6ed64a7591e56ff1f2fce18d
title: "Classification of Hyperspectral Data with Support Vector Machine (SVM) Using SciKit in Python"
description: "Learn to classify spectral data using the Support Vector Machine (SVM) method." 
dateCreated: 2017-06-19 
authors: Paul Gader
contributors: Donal O'Leary
estimatedTime: 1 hour
packagesLibraries: numpy, gdal, matplotlib, matplotlib.pyplot
topics: hyperspectral-remote-sensing, HDF5, remote-sensing
languagesTool: python
dataProduct: NEON.DP1.30006, NEON.DP3.30006, NEON.DP1.30008
code1: Python/remote-sensing/hyperspectral-data/Classification_Scikit_SVM.ipynb
tutorialSeries: intro-hsi-py-series
urlTitle: classification-scikit-svm-python
---

In this tutorial, we will learn to classify spectral data using the Support 
Vector Machine (SVM) method. 


<div id="ds-objectives" markdown="1">

### Objectives
After completing this tutorial, you will be able to:

* Classify spectral remote sensing data using Support Vector Machine (SVM). 

### Install Python Packages

* **numpy**
* **gdal** 
* **matplotlib** 
* **matplotlib.pyplot** 


### Download Data

 <a href="https://ndownloader.figshare.com/files/8730436">
Download the spectral classification teaching data subset</a>

<a href="https://ndownloader.figshare.com/files/8730436" class="link--button link--arrow">
Download Dataset</a>

### Additional Materials

This tutorial was prepared in conjunction with a presentation on spectral classification
that can be downloaded. 

<a href="https://ndownloader.figshare.com/files/8730613">
Download Dr. Paul Gader's Classification 1 PPT</a>

<a href="https://ndownloader.figshare.com/files/8731960">
Download Dr. Paul Gader's Classification 2 PPT</a>

<a href="https://ndownloader.figshare.com/files/8731963">
Download Dr. Paul Gader's Classification 3 PPT</a>

</div>


```python
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from scipy import linalg
from scipy import io
```


```python
from sklearn import linear_model as lmd
```

Note that you will need to update these filepaths according to your local machine.


```python
InFile1          = '/Users/olearyd/Git/data/RSDI2017-Data-SpecClass/LinSepC1.mat'
InFile2          = '/Users/olearyd/Git/data/RSDI2017-Data-SpecClass/LinSepC2.mat'
C1Dict           = io.loadmat(InFile1)
C2Dict           = io.loadmat(InFile2)
C1               = C1Dict['LinSepC1']
C2               = C2Dict['LinSepC2']
NSampsClass    = 200
NSamps         = 2*NSampsClass
```


```python
### Set Target Outputs ###
TargetOutputs                     =  np.ones((NSamps,1))
TargetOutputs[NSampsClass:NSamps] = -TargetOutputs[NSampsClass:NSamps]
```


```python
AllSamps     = np.concatenate((C1,C2),axis=0)
```


```python
AllSamps.shape
```




    (400, 2)




```python
#import sklearn
#sklearn.__version__
```


```python
LinMod = lmd.LinearRegression.fit?
```


```python
LinMod = lmd.LinearRegression.fit
```


```python
LinMod = lmd.LinearRegression.fit
```


```python
LinMod = lmd.LinearRegression.fit
```


```python
LinMod = lmd.LinearRegression.fit
```


```python
M = lmd.LinearRegression()
```


```python
print(M)
```

    LinearRegression()



```python
LinMod = lmd.LinearRegression.fit(M, AllSamps, TargetOutputs, sample_weight=None)
```


```python
R = lmd.LinearRegression.score(LinMod, AllSamps, TargetOutputs, sample_weight=None)
```


```python
print(R)
```

    0.9112691769822485



```python
LinMod
```




    LinearRegression()




```python
w = LinMod.coef_
w
```




    array([[0.81592447, 0.94178188]])




```python
w0 = LinMod.intercept_
w0
```




    array([-0.01663028])




```python
### Question:  How would we compute the outputs of the regression model?
```

## Kernels

Now well use support vector models (SVM) for classification. 


```python
from sklearn.svm import SVC
```


```python
### SVC wants a 1d array, not a column vector
Targets = np.ravel(TargetOutputs)
```


```python
InitSVM = SVC()
InitSVM
```




    SVC()




```python
TrainedSVM = InitSVM.fit(AllSamps, Targets)
```


```python
y = TrainedSVM.predict(AllSamps)
```


```python
plt.figure(1)
plt.plot(y)
plt.show()
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/hyperspectral-classification/Classification_Scikit_SVM_py/Classification_Scikit_SVM_py_files/Classification_Scikit_SVM_py_30_0.png)



```python
d = TrainedSVM.decision_function(AllSamps)
```


```python
plt.figure(1)
plt.plot(d)
plt.show()
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/hyperspectral-classification/Classification_Scikit_SVM_py/Classification_Scikit_SVM_py_files/Classification_Scikit_SVM_py_32_0.png)


## Include Outliers


We can also try it with outliers.

Let's start by looking at some spectra.



```python
### Look at some Pine and Oak spectra from
### NEON Site D03 Ordway-Swisher Biological Station
### at UF
### Pinus palustris
### Quercus virginiana
InFile1 = '/Users/olearyd/Git/data/RSDI2017-Data-SpecClass/Pines.mat'
InFile2 = '/Users/olearyd/Git/data/RSDI2017-Data-SpecClass/Oaks.mat'
C1Dict  = io.loadmat(InFile1)
C2Dict  = io.loadmat(InFile2)
Pines   = C1Dict['Pines']
Oaks    = C2Dict['Oaks']
```


```python
WvFile  = '/Users/olearyd/Git/data/RSDI2017-Data-SpecClass/NEONWvsNBB.mat'
WvDict  = io.loadmat(WvFile)
Wv      = WvDict['NEONWvsNBB']
```


```python
Pines.shape
```




    (809, 346)




```python
Oaks.shape
```




    (1731, 346)




```python
NBands=Wv.shape[0]
print(NBands)
```

    346


Notice that these training sets are unbalanced.


```python
NTrainSampsClass = 600
NTestSampsClass  = 200
Targets          = np.ones((1200,1))
Targets[range(600)] = -Targets[range(600)]
Targets             = np.ravel(Targets)
print(Targets.shape)
```

    (1200,)



```python
plt.figure(111)
plt.plot(Targets)
plt.show()
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/hyperspectral-classification/Classification_Scikit_SVM_py/Classification_Scikit_SVM_py_files/Classification_Scikit_SVM_py_41_0.png)



```python
TrainPines = Pines[0:600,:]
TrainOaks  = Oaks[0:600,:]
#TrainSet   = np.concatenate?
```


```python
TrainSet   = np.concatenate((TrainPines, TrainOaks), axis=0)
print(TrainSet.shape)
```

    (1200, 346)



```python
plt.figure(3)
### Plot Pine Training Spectra ###
plt.subplot(121)
plt.plot(Wv, TrainPines.T)
plt.ylim((0.0,0.8))
plt.xlim((Wv[1], Wv[NBands-1]))
### Plot Oak Training Spectra ###
plt.subplot(122)
plt.plot(Wv, TrainOaks.T)
plt.ylim((0.0,0.8))
plt.xlim((Wv[1], Wv[NBands-1]))
plt.show()
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/hyperspectral-classification/Classification_Scikit_SVM_py/Classification_Scikit_SVM_py_files/Classification_Scikit_SVM_py_44_0.png)



```python
InitSVM= SVC()
```


```python
TrainedSVM=InitSVM.fit(TrainSet, Targets)
```


```python
d = TrainedSVM.decision_function(TrainSet)
print(d)
```

    [-0.26050536 -0.45009774 -0.4508219  ...  1.70930028  1.79781222
      1.66711708]



```python
plt.figure(4)
plt.plot(d)
plt.show()
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/hyperspectral-classification/Classification_Scikit_SVM_py/Classification_Scikit_SVM_py_files/Classification_Scikit_SVM_py_48_0.png)


Does this seem to be too good to be true?


```python
TestPines = Pines[600:800,:]
TestOaks  = Oaks[600:800,:]
```


```python
TestSet = np.concatenate((TestPines, TestOaks), axis=0)
print(TestSet.shape)
```

    (400, 346)



```python
dtest = TrainedSVM.decision_function(TestSet)
```


```python
plt.figure(5)
plt.plot(dtest)
plt.show()
```


![png](https://raw.githubusercontent.com/NEONScience/NEON-Data-Skills/main/tutorials/Python/Hyperspectral/hyperspectral-classification/Classification_Scikit_SVM_py/Classification_Scikit_SVM_py_files/Classification_Scikit_SVM_py_53_0.png)


Yeah, too good to be true...What can we do?

## Error Analysis

Error analysis can be used to identify characteristics of errors. 

You could try different Magic Numbers using Cross Validation, etc.  Stay tuned
for a tutorial on this topic. 
