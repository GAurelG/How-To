# Installing R and Rstudio:

For ubuntu:

sudo apt intall R-cran-base

voir Rstudio website and tutoriels

## usefull library:

- swirl: interactive tutorial library
- knitr: install.packages('knitr', dependencies = T)
    if error with rgl, sudo apt install r-cran-rgl
- ggplot2: install.packages('ggplot2', dependencies = T)
- dplyr
- plyr

## library management:

- Place a .Renviron file in the /home directory with environment variable
- Place a .Rprofile in ${HOME}/.config/r/ to configure the wd

> .First <- function(){
>     setwd("/home/aurelien/R")
> }

In this function I am setting the working directory.

The .Renviron set the user environment variables (including the 
library path).
