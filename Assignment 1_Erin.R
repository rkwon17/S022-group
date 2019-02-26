## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#### Assignment 1: s-022  
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#### Set up ####
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# Load libraries
library(magrittr)
library(texreg)   
library(stringr)
library(dplyr)
library(ggplot2)

rm(list = ls())

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#### Item 1 ####
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

#### load in CCES ####
load(url('https://www.dropbox.com/s/hghuiyjec1jggwd/cces2.RData?dl=1'))

names(cces) %<>% tolower()

cces %<>% dplyr::rename(ed_spend = cc16_426_3, party = cc16_360) #gives the two variables more sensible names cces

cces$ed_spend %<>% droplevels() %<>% factor(ordered = FALSE) #drop unusued levels from each factor and convert factors to unordered factors
cces$party %<>% droplevels() %<>% factor(ordered = FALSE)
cces$gender %<>% droplevels() %<>% factor(ordered = FALSE)
cces$educ %<>% droplevels() %<>% factor(ordered = FALSE)
cces$race %<>% droplevels() %<>% factor(ordered = FALSE)
cces$employ %<>% droplevels() %<>% factor(ordered = FALSE)
cces$child18 %<>% droplevels() %<>% factor(ordered = FALSE)

order_vars <- c('party', 'gender', 'educ', 'race', 'employ', 'child18')
for(my_variable in order_vars){
  print(my_variable)
  cces[[my_variable]] %<>% droplevels() %<>% factor(ordered= FALSE)
}

summary(cces$gender)
head(cces$gender)

# create a new variable called ed_spend_num which stores respondent attitudes towards educational spending on a scale of -2 to 2, with -2 indicating a desire to greatly reduce spending and 2 indicating a desire to greatly increase spending.
summary(cces$ed_spend)
cces$ed_spend_num <- 3 - as.numeric(cces$ed_spend)
table(cces$ed_spend_num)

table(cces$faminc)

cces$faminc_num <- as.numeric(cces$faminc) # create a new variable called faminc_num which stores the faminc variable as a number; higher values should indicate higher incomes
cces$faminc_num[cces$faminc_num > 16] <- NA # drop the levels 17 and 18; can you figure out why?

#### load in state data ####

state_dat <- read.csv('c:/users/Erin/Documents/Harvard/S022 Statistical Computing and Data Science/Data/usgs_state_2016.csv', stringsAsFactors = FALSE)
names(state_dat) %<>% tolower()
# read in the usgs_state_2016.csv dataset; make sure to specify stringsAsFactors = FALSE in your read.csv call; make all the names lowercase
state_dat[c(1, 3, 4, 5, 6, 7, 8)] %<>% as.matrix() %<>% str_replace(',', '') %<>% as.numeric() # take columns 1, 3, 4, 5, 6, 7, and 8 of the dataset (the number columns), replace all commas with blanks, and convert the strings to numeric (we need as.matrix because we can't process multiple columns of a dataframe at the same time), then store them back in the original variables

state_dat <- subset(state_dat, !str_detect(state, 'District|Total')) # keep only states where we DON'T find the string District or Total in the state name (do you know why?)
state_dat %<>% arrange(state) # order the states alphabetically from Alabama to Wyoming, and store the sorted dataset over the original one

data('state') # load the state dataset; one of the resources this built-in dataset provides is a set of state abbreviations, 
state_dat$cl_state <- state.abb

# now create a new variable called total_spending in the state dataset which is equal to the sum (use the rowSums function) of all the spending columns.

state_dat$total_spending <- rowSums(state_dat[c(1, 3:8)])

#### merging and collapsing ####
# merge the cces dataframe and the state_dat dataframe
intersect(names(cces), names(state_dat))
cces2 <- right_join(cces, state_dat)

# create a new dataset, collapsed, which stores state mean support for increased educational spending, state mean per-pupil spending, the proportion of people in each state who identify as Democrats, and the proportion of people in each state who identify as Republicans (note, for people who are fmailiar with US states and their political leanings, this results in some implausible results).
coll_dat <- cces2 %>% group_by(state) %>% summarise(mean_ed_spend = mean(ed_spend_num, na.rm = TRUE),
                                                       mean_per_pupil = first(total_spending),
                                                       prop_dem = mean(party == 'Democratic Party', na.rm = TRUE),
                                                       prop_rep = mean(party == 'Republican Party', na.rm = TRUE))

library(tidycensus)
census_dat <- get_acs(geography = "state", variables = c('B05006_001'), geometry = TRUE, output = 'wide', shift_geo = TRUE)

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#### Item 2 ####
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##


#visualization 1: scatter faminc on edu_spend_num, color by party
plot_income_spend <- ggplot(cces2, mapping = aes(x = faminc_num, y = ed_spend_num, color = party)) + geom_smooth(se = FALSE) + ylim(-2, 2) + xlim(0, 16) + guides(fill = guide_legend(nrow = 10))

#visualization 2: scatter per pupil expenditure (total_spending) on mean_edu_spend_num, color by party
plot_spending_opinions <- ggplot(coll_dat, mapping = aes(x = mean_per_pupil, y = mean_ed_spend, color = prop_dem)) + geom_point()

#visualization 3: histogram of spending, color by party leaning
coll_dat_demstates <- subset(coll_dat, prop_dem > prop_rep)
coll_dat_repstates <- subset(coll_dat, prop_rep > prop_dem)

plot_partyspend <- ggplot(coll_dat, mapping = aes(x = mean_per_pupil)) + 
  geom_freqpoly(coll_dat_demstates, mapping = aes(x = mean_per_pupil, color = "blue")) + 
  geom_freqpoly(coll_dat_repstates, mapping = aes(x = mean_per_pupil, color = "red"))

#visualization 4: map of the US, color states by mean edu spend 
census_dat %<>% dplyr::rename(state = NAME)
plot_dat <- left_join(census_dat, coll_dat)
library(ggmap)
plot_map_opinions <- ggplot(plot_dat, aes(fill = mean_ed_spend)) +
  geom_sf() + # add a spatial geom
  coord_sf(crs = 26914)# define the coordinate system (provided by the census)

#arrange them into a grid
library(gridExtra)
grid.arrange(plot_income_spend, plot_spending_opinions, plot_partyspend, plot_map_opinions, ncol = 2)

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#### Item 3 ####
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
cces2$total_spending_10k <- cces2$total_spending/10000

#model 1
model1 <- lm(ed_spend_num ~ total_spending_10k, data = cces2)

#model 2
model2 <- lm(ed_spend_num ~ faminc_num + employ + gender + educ + race + child18, data = cces2)

#model 3
model3 <- lm(ed_spend_num ~ faminc_num + employ + gender + educ + race + child18 + total_spending_10k, data = cces2)

#model 4
model4 <- lm(ed_spend_num ~ faminc_num * party + employ + gender + educ + race + child18 + total_spending_10k, data = cces2)

screenreg(list(model1, model2, model3, model4))
setwd('c:/Users/Erin/Documents/Harvard/S022 Statistical Computing and Data Science/Assignments/')
htmlreg(list(model1, model2, model3, model4), file = 'taxonomy_table.html')


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#### Item 4 ####
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

R <- 10000

#simulation 1
slope_ests_sim1 <- rep(NA, R) # this is where we'll store our slope estimates after we calculate them
sample_sizes_sim1 <- rep(NA, R)
set.seed(exp(1)) # start a new random seed
for(i in 1:R){
  sampled_rows_sim1 <- sample(nrow(cces2), size = 1000) # we'll take a new sample of rows
  sampled_data_sim1 <- cces2[sampled_rows_sim1, c('ed_spend_num', 'total_spending_10k')] # and take a new sample from the cces2
  sample_sizes_sim1[i] <- dim(sampled_data_sim1)[1]
  model_samp_sim1 <- lm(ed_spend_num ~ total_spending_10k, data = sampled_data_sim1) # fit the model again
  slope_ests_sim1[i] <- coef(model_samp_sim1)['total_spending_10k'] # store the estimated slope as the ith slope estimate
  if(i%%100 == 0) print(i) # print i every 100 samples; useful to see how fast the code is running
}

#simulation 2
slope_ests_sim2 <- rep(NA, R)
sample_sizes_sim2 <- rep(NA, R)
set.seed(exp(1))
for(i in 1:R){
  sampled_states_sim2 <- sample(unique(cces2$state), size = 3)
  sampled_data_sim2 <- cces2[cces2$state %in% sampled_states_sim2, c('ed_spend_num', 'total_spending_10k')]
  sample_sizes_sim2[i] <- dim(sampled_data_sim2)[1]
  model_samp_sim2 <- lm(ed_spend_num ~ total_spending_10k, data = sampled_data_sim2)
  slope_ests_sim2[i] <- coef(model_samp_sim2)['total_spending_10k']
  if(i%%100 == 0) print(i)
}

cat("true slope: ", coef(model1)['total_spending_10k'], '\nmean from sim 1: ', mean(slope_ests_sim1), "\nmean from sim 2: ", mean(slope_ests_sim2))
cat("sample size in sim 1: ", mean(sample_sizes_sim1), "\nsample size in sim 2: ", mean(sample_sizes_sim2))
cat("std error in sim 1: ", sd(slope_ests_sim1), "\nstd error in sim 2: ", sd(slope_ests_sim2))


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#### Item 5 ####
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
coll_dat2 <- cces2 %>% group_by(lookupzip) %>% summarise(mean_ed_spend = mean(ed_spend_num, na.rm = TRUE))

census_dat_zc <- get_acs(geography = "zcta", variables = c('B06011_001'), geometry = TRUE, output = 'wide', shift_geo = FALSE)
census_dat_zc %<>% dplyr::rename(lookupzip = GEOID, median_income = B06011_001E)

plot_dat2 <- right_join(census_dat_zc, coll_dat2)

ggplot(plot_dat2, mapping = aes(x = median_income, y = mean_ed_spend)) + geom_point() + geom_smooth()

cces_zc <- right_join(census_dat_zc, cces2)
cces_zc$median_income_10k <- cces_zc$median_income/10000
model5 <- lm(ed_spend_num ~ median_income_10k + I(median_income_10k^2) + faminc_num + employ + gender + educ + race + child18, data = cces_zc)
htmlreg(model5, "taxonomy_table_model5.html")

# census$lookupzip <- str_remove(census$name, "zcta5")

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
#### Challenge Question ####
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##