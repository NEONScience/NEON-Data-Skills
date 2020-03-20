## ----function-farKelv---------------------------------------------------------------------
fahr_to_kelvin <- function(temp) {
	kelvin <- ((temp - 32) * (5/9)) + 273.15
	kelvin
	}



## ----function-format, eval=FALSE----------------------------------------------------------
## 
## FunctionNameHere <- function(Input-variable-here){
## 	what-to-do-here
## 	what-to-return-here
## 	}
## 


## ----call-function------------------------------------------------------------------------
# call function for F=32 degrees
fahr_to_kelvin(32)

# We could use `paste()` to create a sentence with the answer
paste('The boiling point of water (212 Fahrenheit) is', fahr_to_kelvin(212),'degrees Kelvin.')



## ----funct-test---------------------------------------------------------------------------
fahr_to_kelvin_test <- function(temp) {
	kelvin <- ((temp - 32) * (5/9)) + 273.15
	}



## ----funct-test-2-------------------------------------------------------------------------

fahr_to_kelvin_test(32)



## ----funct-test-3-------------------------------------------------------------------------
# assign to a
a <- fahr_to_kelvin_test(32)

# value of a
a


## ----challenge-code-kelv-to-cels, include=TRUE, results="hide", echo=FALSE----------------

kelvin_to_celsius <- function(temp) {
	Celsius <- temp - 273.15
	Celsius
	}
	
paste('absolute zero (0 Kelvin) in Celsius:', kelvin_to_celsius(0))
	


## ----compound-function--------------------------------------------------------------------

# use two functions (F->K & K->C) to create a new one (F->C)
fahr_to_celsius <- function(temp) {
	temp_k <- fahr_to_kelvin(temp)
	temp_c <- kelvin_to_celsius(temp_k)
	temp_c
	}
	
paste('freezing point of water (32 Fahrenheit) in Celsius:', fahr_to_celsius(32.0))


