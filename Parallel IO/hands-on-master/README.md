# Hands-on I/O exercises and reference material

## Array

The presentation will walk you through several interfaces for writing an array
to a file.  We have provided you with some skeleton code which you can build
upon during the lecture.  If you get stuck you can find complete examples in
the `solutions` directory.

## Parallel-NetCDF

You can install Parallel-NetCDF on your laptop easily enough, or it it likely
installed on a machine already.  Consult your site's documentation for
specifics. 
The Parallel-NetCDF projet has a
[Quick Tutorial](http://trac.mcs.anl.gov/projects/parallel-netcdf/wiki/QuickTutorial)
outlining several different ways one can do I/O with Parallel-NetCDF.  We'll
also explore attributes.

### Other Hands-on exercise: comparing I/O approaches
* The
 [QuickTutorial](http://trac.mcs.anl.gov/projects/parallel-netcdf/wiki/QuickTutorial)
 has links to code and some brief discussions about what the
 examples are trying to demonstrate.
* Following the "Real parallel I/O on
 shared files" example, build and run 'pnetcdf-write-standard' to create a
 (tiny) Parallel-NetCDF dataset.
* Look at a Darshan job summary.
* Next, follow the "Non-blocking interface" example to create another (tiny)
 Parallel-NetCDF dataset.
* Compare the Darshan job summary of this approach.  What's different between the two?

### Other Hands-on exercise: using attributes
* Write a simple parallel-netcdf program that puts your name as a global
  attribute on the data set.  You won't need to define any dimensions or
  variables. (If you need to cheat, look at the example C files above).
* What happens if you define different attributes on different processors?
