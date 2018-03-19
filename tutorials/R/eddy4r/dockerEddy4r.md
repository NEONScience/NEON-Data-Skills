---
syncID: 63993d7274f84e51a1047e1fea9aece1
title: "Install & Set Up Docker For Use With eddy4R"
description: "This tutorial provides the basic steps for setting up and using Docker to work with the eddy4R R package in a Docker container."
dateCreated: 2018-03-06
authors: Megan A. Jones
contributors: 
estimatedTime: 
packagesLibraries: 
topics: data management
languagesTool: R, Docker
dataProduct: 
code1: 
tutorialSeries: eddy4r
urlTitle: set-up-docker
---

This tutorial provides the basics on how to set up Docker on one's local computer
and then connect to an eddy4R Docker container in order to use the eddy4R R package. 
There are no specific skills needed for this tutorial, however, you will need to
know how to access the command line tool for your operating system 
(basic instructions given). 

<div id="ds-objectives" markdown="1">

## Learning Objectives
After completing this tutorial, you will be able to:

  * Access Docker on your local computer.
  * Access the eddy4R package in a RStudio Docker environment.
  
## Things You’ll Need To Complete This Tutorial
You will need internet access and an up to date browser.

## Sources

The directions on how to install docker are heavily borrowed from the author's 
of CyVerse's Container Camp's 
<a href="https://cyverse-container-camp-workshop-2018.readthedocs-hosted.com/en/latest/docker/dockerintro.html" target="_blank"> Intro to Docker</a> and we thank them for providing the information. 

The directions for how to access eddy4R comes from Metzger, S., D. Durden, C. Sturtevant, H. Luo, N. Pingintha-durden, and T. Sachs (2017). eddy4R 0.2.0: a DevOps model for community-extensible processing and analysis of eddy-covariance data based on R, Git, Docker, and HDF5. Geoscientific Model Development 10:3189–3206. doi: 
<a href="https://www.geosci-model-dev.net/10/3189/2017/" target="_blank">10.5194/gmd-10-3189-2017</a>. 

</div>


## Why Docker? 
[MJ: This section still needs to be completed.]

"Getting all the tooling setup on your computer can be a daunting task, but not with Docker." 

In the tutorial below, we give the very barest of information to get Docker set
up for use with the NEON R package eddy4R. For more information on using Docker, 
consider reading through the content from CyVerse's Container Camp's 
<a href="https://cyverse-container-camp-workshop-2018.readthedocs-hosted.com/en/latest/docker/dockerintro.html" target="_blank"> Intro to Docker</a>. 


## Install Docker

To work with the eddy4R–Docker image, you first need to sign up for an 
account at <a href="https://hub.docker.com/" target="_blank">DockerHub</a>. 

Once logged in, getting Docker up and running on your favorite operating system 
(Mac/Windows/Linux) is very easy. The "getting started" guide on Docker has 
detailed instructions for setting up Docker. Unless you plan on being a very
active user and devoloper in Docker, we recommend starting with the stable channel 
(not edge channel) as you may encounter fewer problems.  

* <a href="https://docs.docker.com/docker-for-mac/install/" target="_blank">Mac </a>
* <a href="https://docs.docker.com/docker-for-windows/install/" target="_blank">Windows </a>
* <a href="https://docs.docker.com/install/linux/docker-ce/ubuntu/" target="_blank">Linux</a>

If you're using Docker for Windows make sure you have 
<a href="https://docs.docker.com/docker-for-windows/#shared-drives" target="_blank">shared your drive</a>. 

If you're using an older version of Windows or MacOS, you may need to use 
<a href="https://docs.docker.com/machine/overview/" target="_blank">Docker Machine</a> 
instead. 

## Test Docker installation

Once you are done installing Docker, test your Docker installation by running 
the following command to make sure you are using version 1.13 or higher. 

You will need to open an open shell window (Linux; Mac=Terminal) or 


    
    docker --version

    ## Docker version 17.12.0-ce, build c97c6d6

When run, you will see which version of docker you currently are running (note,
your output may be different than the output here).

Note: If run without ``--version`` you should see a whole bunch of lines showing the different options available with ``docker``. Alternatively you can test your installation by running the following:


    
    docker run hello-world

    ## Unable to find image 'hello-world:latest' locally
    ## latest: Pulling from library/hello-world
    ## 03f4658f8b78: Pull complete
    ## a3ed95caeb02: Pull complete
    ## Digest: sha256:8be990ef2aeb16dbcb9271ddfe2610fa6658d13f6dfb8bc72074cc1ca36966a7
    ## Status: Downloaded newer image for hello-world:latest
    ## 
    ## Hello from Docker!
    ## This message shows that your installation appears to be working correctly.
    ## 
    ## To generate this message, Docker took the following steps:
    ##  1. The Docker client contacted the Docker daemon.
    ##  2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    ##     (amd64)
    ##  3. The Docker daemon created a new container from that image which runs the
    ##     executable that produces the output you are currently reading.
    ##  4. The Docker daemon streamed that output to the Docker client, which sent it
    ##     to your terminal.
    ## 
    ## To try something more ambitious, you can run an Ubuntu container with:
    ##  $ docker run -it ubuntu bash
    ## 
    ## Share images, automate workflows, and more with a free Docker ID:
    ##  https://cloud.docker.com/
    ## 
    ## For more examples and ideas, visit:
    ##  https://docs.docker.com/engine/userguide/


Notice that the first line, states that the image can't be found locally. If you 
were to run the `hello-world` prompt again, it would already be local and you'd
see the message start at "Hello from Docker!".  

If either of these steps work, you are ready to go on to access the eddy4R R 
package in Docker. If these steps have not worked, following the installation 
instructions a second time. 

## Access eddy4R

Download of the eddy4R–Docker image and subsequent creation of a local container 
can be performed by two simple commands in an open shell (Linux; Mac = Termnal) 
or the Docker Quickstart Terminal (Windows). 

The first command `docker login` will prompt you for your DockerHub ID and password. 
The second command `docker run -d -p 8787:8787 stefanmet/eddy4r:0.2.0` will 
download the latest eddy4R–Docker image and start a Docker container that 
utilizes port 8787 for establishing a graphical interface via web browser.  

* `docker run`: docker will preform some process on an isolated container 
* `-d`: the container will start in a detached mode, which means the container 
run in the background and will print the container ID
* `-p`: publish a container to a specified port (which follows)
* `8787:8787`: specify which port you want to use. This default one is great if 
you are runnin locally on a . If you are running many containers or on a shared network, 
you may need to specify a different port.
* `stefanmet/eddy4r:0.2.0`: finally, which container do you want to run. 

Now try it.

    docker login 
    
    docker run -d -p 8787:8787 stefanmet/eddy4r:0.2.0

This last command will run a specified release version (`eddy4r:0.2.0`) of the 
Docker image. Alternatively you can use `eddy4r:latest` to get the most up-to-date 
development image. 

[MJ:what does this mean] If data are not directed from/to cloud hosting , a 
physical file system location on the host computer (local/dir) can be mounted 
to a file system location inside the Docker container (docker/dir). This is 
achieved with the Docker run option -v local/dir:docker/dir. 


## Access RStudio session

Now you can access the interactive RStudio session for using eddy4r by using any
web browser and going to `http://host-ip-address:8787` where `host-ip-address` 
is the internal IP address of the Docker host. For example, if you host ip address 
is 10.100.90.169 then you should type `http://10.100.90.169:8787` into your browser. 

[MJ: my notes have `http://10.100.90.169:8787/auth-sign-in` difference?]

The IP address of the Docker host is determined slighlty differently depending 
on your Operating System. 

***
#### Windows
Type `docker-machine ip default` into cmd.exe window. The output will be your 
local IP address for the docker machine. 

#### Mac

Type `ifconfig | grep "inet " | grep -v 127.0.0.1` into your Terminal window. 
The output will be one or more local IP addresses for the docker machine. Use 
the numbers after the first `inet` output. 

#### Linux
Type `localhost` in a shell session and the local IP will be the output.

***

Once in the web browser you can log into this instance of the RStudio session 
with both the username and password as **rstudio**. Once complete you are now in 
a RStudio user interface with eddy4R installed and ready to use. 

Additional information about the use of RStudio and eddy4R packages in Docker 
containers can be found on the 
<a href="https://github.com/rocker-org/rocker/wiki/Using-the-RStudio-image" target="_blank">rocker-org/rocker website</a> 
and the <a href="" target="_blank">eddy4RWiki pages</a> 
[MJ:where is this wiki?, I can't find it]. 

## Using eddy4R

To learn to use the eddy4R package for turbulence flow, please visit [add link 
once ready]. 
