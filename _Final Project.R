rm(list = ls())
setwd('c:/users/juggl_000/Desktop/R Scripts') # set directory 

library(magrittr)
library(texreg)

library(tidycensus)
library(ggplot2)
library(stringr)

# a list of all the ACS 2015 variables is stored here. https://api.census.gov/data/2015/acs/acs5/subject/variables.html
vars <- data.frame(load_variables(2016, 'acs5')) # downloads a list of all variables from the 2016 ACS
head(vars) # there are a LOT of options

test_vec <- c('banana', 'app le', 'apple and banana', 'mangosteen') # a list of fruits
str_detect(test_vec, 'banana') # what does this do? searches a vector and says which one has the term in it
test_vec[str_detect(test_vec, 'banana')] # pulls out the items that it found banana in 

race_vars <- vars[str_detect(vars$concept, 'RACE'), ] # what is the following code designed to do?
white_race_vars <- race_vars[str_detect(race_vars$concept, 'HISPANIC'), ]
head(white_race_vars)

census_dat <- get_acs(geography = "county", variables = c('B03002_001',
                                                          'B03002_002',
                                                          'B03002_003',
                                                          'B03002_004',
                                                          'B03002_005',
                                                          'B03002_006',
                                                          'B03002_007',
                                                          'B03002_008',
                                                          'B03002_009',
                                                          'B03002_010',
                                                          'B03002_011',
                                                          'B03002_012',
                                                          'B03002_013',
                                                          'B03002_014',
                                                          'B03002_015',
                                                          'B03002_016',
                                                          'B03002_017',
                                                          'B03002_018',
                                                          'B03002_019',
                                                          'B03002_020',
                                                          'B03002_021'), geometry = FALSE, output = 'wide', shift_geo = FALSE, summary_var = 'S0101_C01_001') # can you make sense of what this code is doing? Either look at the head of census_dat or the help file for get_acs. Feel free to download other variables, just make sure you get the one about the proportion of people who are residents
head(census_dat) # which variable do you think we're going to use to link with the cces data?

census_dat %<>% dplyr::rename('countyfips' = 'GEOID', 'county' = 'NAME', 'foreign_total' = 'B05006_001E', 'recent_total' = 'B05007_002E',
                              'population' = 'summary_est')