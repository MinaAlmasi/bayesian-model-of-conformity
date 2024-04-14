# Bayesian Models of Cognition for Social Conformity (Portfolio 3, ACM)
This repository contains the code for the `portfolio 3 assignment` in the course `Advanced Cognitive Modeling` at the Cognitive Science MSc. (F24).

Code was produced jointly by the group members:
* Milena Cholozynska (@milenacholo)
* Daniel Blumenkranz (@daniblu)
* Anton Drasbæk Schiønning (@drasbaek)
* Mina Almasi (@MinaAlmasi)

## Overview 
The repository contains four folders: 
1. `src` - all R scripts 
2. `data` - simulated data and data resulting from fitting models (predictive checks & recovery)
3. `stan` - the simple bayes and weighted bayes coded in Stan (git ignores the C++ compiled version)
4. `plots` - all plots

For the code in `src`, see the seperate [src/README.md](src/README.md).

## Usage 
### Setup
To use the code, ensure that you have `R` and `RScript` installed. All code was developed using `R` version `4.3.2` and was primarily tested on a MacBook. Note that you also need to have Stan properly installed (see [Rstan: Getting Started](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started)).

Furthermore, please install the package `pacman`. Within your `R console`, this can be done as such: 
```
install.packages("pacman")
```

### Run the code 
Code can be run by using `RScript` in your `bash` terminal
```bash
RScript src/simulate.R
```

Note that you cannot run `plot_quality.R` before having run `run_model.R` as the posterior samples are not pushed to Git due to their large size. 
