data {
    int<lower=0> N;
    array[N] int Choice;
    array[N] real <lower = 0, upper = 1> FirstRating; 
    array[N] real <lower = 0, upper = 1> GroupRating;
}

parameters {
   /* ... declarations ... */
}

model {
    abc
}