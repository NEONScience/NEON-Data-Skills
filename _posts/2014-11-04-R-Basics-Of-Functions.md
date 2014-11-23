---
layout: post
title: "Activity: Working With Functions"
date:   2014-10-29 20:49:52
authors: Adapted from Software Carpentry Materials by Leah A. Wasser
categories: [Coding and Informatics]
category: coding-and-informatics
tags : [R]
description: "This activity will provide the basics of creating a function in R."
code1: 
image:
  feature: codedFieldJournal.png
  credit: NEON staff working in the field
  creditlink: http://www.neoninc.org
permalink: /Using-R/Working-With-Functions
---
<section id="table-of-contents" class="toc">
  <header>
    <h3 >Contents</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->

# Creating Functions

Sometimes we need to perform a calculation or a set of calculations, multiple times in our code. For example, we might need to convert units from Celcius to Kelvin, across multiple datasets and through time. 
 
We could write out the equation over and over in our code. OR we could chose to build a function that allows us to repeat several operations with a single command. This activity will focus on creating functions in R.

## Objectives

* Define a function that takes parameters (input values).
* Return a value from a function.
* ???Test and debug a function.???
* Set default values for function parameters.
* Explain why we should divide programs into small, single-purpose functions.
* Learn how to define a Function

##Getting Started
Let's start by defining a function `fahr_to_kelvin` that converts temperature values from Fahrenheit to Kelvin:


	fahr_to_kelvin <- function(temp) {
	    kelvin <- ((temp - 32) * (5/9)) + 273.15
	    kelvin
	}

Notice the syntax used to define this function:


> FunctionNameHere <- function(InputVariable-or-variables-here)

The definition begins with the name of your new function, which is followed by the call to make it a `function` and a parenthesized list of parameter names. The parameters are the input values that the function will use to perform any calculations. In this case, the input might be the temperature value that we wish to convert from fahrenheit to kelvin. You can have as many input parameters as you would like (but too many might be bad style). The body, or implementation, is surrounded by curly braces `{ }`. In many languages, the body of the function - the statements that are executed when it runs - must be indented, typically using 4 spaces. 

>HINT: While it is not mandatory to indent your code 4 spaces within a function, it is  strongly recommended as good practice!

When we call the function, the values we pass to it are assigned to those variables so that we can use them inside the function. The last line within the function is what R will evaluate as a returning value. Remember that the last line has to be a command that will print to the screen, and not an object definition, otherwise the function will return nothing - it will work, but will provide no output. For example, let's try running our function. Calling our own function is no different from calling any other function:


	fahr_to_kelvin(32)
	paste('boiling point of water:', fahr_to_kelvin(212))


We've successfully called the function that we defined, and we have access to the value that we returned. However, it the function was redefined as follows


	fahr_to_kelvin <- function(temp) {
	    kelvin <- ((temp - 32) * (5/9)) + 273.15
	}


Now typing


    fahr_to_kelvin(32)


Will return nothing. However try assigning the function to a variable "a".

    a <- fahr_to_kelvin(32)

Now, what happens when you type `a` ?

==============================


## Composing Functions

Now that we've seen how to turn Fahrenheit into Kelvin, it's easy to turn Kelvin into Celsius:

	kelvin_to_celsius <- function(temp) {
	    Celsius <- temp - 273.15
		Celsius
	}
	
	paste('absolute zero in Celsius:', kelvin_to_celsius(0))

What about converting Fahrenheit to Celsius? We could write out the formula, but we don't need to. Instead, we can compose the two functions we have already created:

	fahr_to_celsius <- function(temp) {
		temp_k <- fahr_to_kelvin(temp)
		result <- kelvin_to_celsius(temp_k)
	    result
	}
	
	paste('freezing point of water in Celsius:', fahr_to_celsius(32.0))


This is our first taste of how larger programs are built: we define basic operations, then combine them in ever-large chunks to get the effect we want. 
Real-life functions will usually be larger than the ones shown here—typically half a dozen to a few dozen lines—but they shouldn't ever be much longer than that, or the next person who reads it won't be able to understand what's going on. 


##Let's Build a Function

So now we've learned the basics of building functions in R. Let's create one of our own. The function that we will build, 
