#!/usr/bin/env python
# coding: utf-8

# ---
# syncID: 1497c1da6ed64a7591e56ff1f2fce18d
# title: "Classification of Hyperspectral Data with Support Vector Machine (SVM) Using SciKit in Python"
# description: "Learn to classify spectral data using the Support Vector Machine (SVM) method." 
# dateCreated: 2017-06-19 
# authors: Paul Gader
# contributors: Donal O'Leary
# estimatedTime: 
# packagesLibraries: numpy, gdal, matplotlib, matplotlib.pyplot
# topics: hyperspectral-remote-sensing, HDF5, remote-sensing
# languagesTool: python
# dataProduct: NEON.DP1.30006, NEON.DP3.30006, NEON.DP1.30008
# code1: Python/remote-sensing/hyperspectral-data/Classification_Scikit_SVM.ipynb
# tutorialSeries: intro-hsi-py-series
# urlTitle: classification-scikit-svm-python
# ---

# In this tutorial, we will learn to classify spectral data using the Support 
# Vector Machine (SVM) method. 
# 
# 
# <div id="ds-objectives" markdown="1">
# 
# ### Objectives
# After completing this tutorial, you will be able to:
# 
# * Classify spectral remote sensing data using Support Vector Machine (SVM). 
# 
# ### Install Python Packages
# 
# * **numpy**
# * **gdal** 
# * **matplotlib** 
# * **matplotlib.pyplot** 
# 
# 
# ### Download Data
# 
#  <a href="https://ndownloader.figshare.com/files/8730436">
# Download the spectral classification teaching data subset</a>
# 
# <a href="https://ndownloader.figshare.com/files/8730436" class="link--button link--arrow">
# Download Dataset</a>
# 
# ### Additional Materials
# 
# This tutorial was prepared in conjunction with a presentation on spectral classification
# that can be downloaded. 
# 
# <a href="https://ndownloader.figshare.com/files/8730613">
# Download Dr. Paul Gader's Classification 1 PPT</a>
# 
# <a href="https://ndownloader.figshare.com/files/8731960">
# Download Dr. Paul Gader's Classification 2 PPT</a>
# 
# <a href="https://ndownloader.figshare.com/files/8731963">
# Download Dr. Paul Gader's Classification 3 PPT</a>
# 
# </div>

# In[1]:


import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from scipy import linalg
from scipy import io


# In[2]:


from sklearn import linear_model as lmd


# Note that you will need to update these filepaths according to your local machine.

# In[3]:


InFile1          = '/Users/olearyd/Git/data/RSDI2017-Data-SpecClass/LinSepC1.mat'
InFile2          = '/Users/olearyd/Git/data/RSDI2017-Data-SpecClass/LinSepC2.mat'
C1Dict           = io.loadmat(InFile1)
C2Dict           = io.loadmat(InFile2)
C1               = C1Dict['LinSepC1']
C2               = C2Dict['LinSepC2']
NSampsClass    = 200
NSamps         = 2*NSampsClass


# In[4]:


### Set Target Outputs ###
TargetOutputs                     =  np.ones((NSamps,1))
TargetOutputs[NSampsClass:NSamps] = -TargetOutputs[NSampsClass:NSamps]


# In[5]:


AllSamps     = np.concatenate((C1,C2),axis=0)


# In[6]:


AllSamps.shape


# In[7]:


#import sklearn
#sklearn.__version__


# In[8]:


get_ipython().set_next_input('LinMod = lmd.LinearRegression.fit');get_ipython().run_line_magic('pinfo', 'lmd.LinearRegression.fit')


# In[9]:


LinMod = lmd.LinearRegression.fit


# In[10]:


LinMod = lmd.LinearRegression.fit


# In[11]:


LinMod = lmd.LinearRegression.fit


# In[12]:


LinMod = lmd.LinearRegression.fit


# In[13]:


M = lmd.LinearRegression()


# In[14]:


print(M)


# In[15]:


LinMod = lmd.LinearRegression.fit(M, AllSamps, TargetOutputs, sample_weight=None)


# In[16]:


R = lmd.LinearRegression.score(LinMod, AllSamps, TargetOutputs, sample_weight=None)


# In[17]:


print(R)


# In[18]:


LinMod


# In[19]:


w = LinMod.coef_
w


# In[20]:


w0 = LinMod.intercept_
w0


# In[21]:


### Question:  How would we compute the outputs of the regression model?


# ## Kernels
# 
# Now well use support vector models (SVM) for classification. 

# In[22]:


from sklearn.svm import SVC


# In[23]:


### SVC wants a 1d array, not a column vector
Targets = np.ravel(TargetOutputs)


# In[24]:


InitSVM = SVC()
InitSVM


# In[25]:


TrainedSVM = InitSVM.fit(AllSamps, Targets)


# In[26]:


y = TrainedSVM.predict(AllSamps)


# In[27]:


plt.figure(1)
plt.plot(y)
plt.show()


# In[28]:


d = TrainedSVM.decision_function(AllSamps)


# In[29]:


plt.figure(1)
plt.plot(d)
plt.show()


# ## Include Outliers
# 
# 
# We can also try it with outliers.
# 
# Let's start by looking at some spectra.
# 

# In[30]:


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


# In[31]:


WvFile  = '/Users/olearyd/Git/data/RSDI2017-Data-SpecClass/NEONWvsNBB.mat'
WvDict  = io.loadmat(WvFile)
Wv      = WvDict['NEONWvsNBB']


# In[32]:


Pines.shape


# In[33]:


Oaks.shape


# In[34]:


NBands=Wv.shape[0]
print(NBands)


# Notice that these training sets are unbalanced.

# In[35]:


NTrainSampsClass = 600
NTestSampsClass  = 200
Targets          = np.ones((1200,1))
Targets[range(600)] = -Targets[range(600)]
Targets             = np.ravel(Targets)
print(Targets.shape)


# In[36]:


plt.figure(111)
plt.plot(Targets)
plt.show()


# In[37]:


TrainPines = Pines[0:600,:]
TrainOaks  = Oaks[0:600,:]
#TrainSet   = np.concatenate?


# In[38]:


TrainSet   = np.concatenate((TrainPines, TrainOaks), axis=0)
print(TrainSet.shape)


# In[39]:


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


# In[40]:


InitSVM= SVC()


# In[41]:


TrainedSVM=InitSVM.fit(TrainSet, Targets)


# In[42]:


d = TrainedSVM.decision_function(TrainSet)
print(d)


# In[43]:


plt.figure(4)
plt.plot(d)
plt.show()


# Does this seem to be too good to be true?

# In[44]:


TestPines = Pines[600:800,:]
TestOaks  = Oaks[600:800,:]


# In[45]:


TestSet = np.concatenate((TestPines, TestOaks), axis=0)
print(TestSet.shape)


# In[46]:


dtest = TrainedSVM.decision_function(TestSet)


# In[47]:


plt.figure(5)
plt.plot(dtest)
plt.show()


# Yeah, too good to be true...What can we do?
# 
# ## Error Analysis
# 
# Error analysis can be used to identify characteristics of errors. 
# 
# You could try different Magic Numbers using Cross Validation, etc.  Stay tuned
# for a tutorial on this topic. 
