# 02-functions Instructor notes

### How to write functions in R?

When demonstrating how to write the function to convert the temperature, go
slowly and demonstrate how to do it in steps in RStudio. For instance, start by
taking one of the numeric examples, replace the number by the variable `temp`,
explain that `temp` doesn't exist in the global environment, and that we will be
creating it by enclosing it into a function:
1. `(temp - 32) * 5/9`
1. ```
    function(temp) {
		(temp - 32) * 5/9
		}
	```
1.

### After flashing the first function for temperature conversion:

- Demonstrate default values: show how convert_fahr() doesn't work.
- Change function to have default value for the temperature (e.g., `temp = 0`
and `to = "celcius"`, and show how now `convert_fahr()` works.
- Use this to expand on using `match.arg` coming up.

### After refactoring of the functions, before weight conversion challenge

- Demonstrate scoping:
    -  Show that there is no variable `to`, `temp` or `res` in the global
    environment.
    - Then assign a value to the variable `to` or `res` and show that it
    doesn't affect the behavior of the function.
