#Assignment 1
#-------Authors----------------
#Rachel Kwon, Erin Mahoney, Kevin Nazario

#calling packages
library(magrittr) 
library(texreg)
library(stringr)
library(dplyr)
library(ggplot2)

#clear workspace
rm(list = ls())

#### step 1: cleaning and merging ####
# this step asks you to read in two datasets and clean them up, and merge them. We're providing a little code to get you started.

#### step 1: the cces ####
# you are NOT required to follow these steps. However, if you want the script to run as written (without any modifications on your part), you'll need to. To begin, read in the cces dataset using the load() function and call it cces. Set all of the variable names to be lowercase.
load(url('https://www.dropbox.com/s/gd4nkwsk5qkoi8l/CCES16_Common_OUTPUT_Feb2018_VV.RData?dl=1'))
cces <- x
rm('x')

names(cces) %<>% tolower()

cces %<>% dplyr::rename(ed_spend = cc16_426_3, party = cc16_360) # you can look these variables up in the cces dataset. They're named in a way which is unhelpful. This code 1) takes the cces, passes it to the rename function, which gives the two variables more sensible names, and then passes it back to cces

cces$ed_spend %<>% droplevels() %<>% factor(ordered = FALSE) # for later parts of this assignment, it will be nice to 1) drop unusued levels from each factor and 2) convert factors to unordered factors. This code accomplished this for ed_spend; read it as saying "take the ed_spend variable from cces, drop unused levels, and convert it into an unordered factor, storing the result in the ed_spend variable". Now do the same for the party, gender, educ, race, employ, and child18 variables

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

cces$ed_spend_num <- factor(cces$ed_spend, levels = c('Greatly increase', 'Slightly increase', 'Maintain', 
                                                      'Slightly decrease', 'Greatly decrease'),
                            labels = 2:-2)
cces$ed_spend_num %<>% as.character() %<>% as.numeric()
table(cces$ed_spend, cces$ed_spend_num)

table(cces$faminc)

cces$faminc_num <- as.numeric(cces$faminc) # create a new variable called faminc_num which stores the faminc variable as a number; higher values should indicate higher incomes
cces$faminc_num[cces$faminc_num > 16] <- NA # drop the levels 17 and 18; can you figure out why?

#### step 1: the state dataset ####
state_dat <- read.csv('usgs_state_2016.csv', stringsAsFactors = FALSE)
# read in the usgs_state_2016.csv dataset; make sure to specify stringsAsFactors = FALSE in your read.csv call; make all the names lowercase
state_dat[c(1, 3, 4, 5, 6, 7, 8)] %<>% as.matrix() %<>% str_replace(',', '') %<>% as.numeric() # take columns 1, 3, 4, 5, 6, 7, and 8 of the dataset (the number columns), replace all commas with blanks, and convert the strings to numeric (we need as.matrix because we can't process multiple columns of a dataframe at the same time), then store them back in the original variables

state_dat <- subset(state_dat, !str_detect(state, 'District|Total')) # keep only states where we DON'T find the string District or Total in the state name (do you know why?)
state_dat %<>% arrange(state) # order the states alphabetically from Alabama to Wyoming, and store the sorted dataset over the original one

data('state') # load the state dataset; one of the resources this built-in dataset provides is a set of state abbreviations, 
state_dat$cl_state <- state.abb

# now create a new variable called total_spending in the state dataset which is equal to the sum (use the rowSums function) of all the spending columns.

state_dat$total_spending <- rowSums(state_dat[c(1, 3:8)])

#### step 1: merging ####
# merge the cces dataframe and the state_dat dataframe. Make sure you know what you'll be merging on
intersect(names(cces), names(state_dat))

cces2 <- right_join(cces, state_dat)

#### step 1: collapsing ####
# create a new dataset, collapsed, which stores state mean support for increased educational spending, state mean per-pupil spending, the proportion of people in each state who identify as Democrats, and the proportion of people in each state who identify as Republicans (note, for people who are fmailiar with US states and their political leanings, this results in some implausible results).
coll_dat <- cces2 %>% group_by(cl_state) %>% summarise(mean_ed_spend = mean(ed_spend_num, na.rm = TRUE),
                                                       mean_per_pupil = first(total_spending),
                                                       prop_dem = mean(party == 'Democratic Party', na.rm = TRUE),
                                                       prop_rep = mean(party == 'Republican Party', na.rm = TRUE))

library(tidycensus)
get_acs(geography = "county", variables = c('B05006_001'), geometry = TRUE, output = 'wide', shift_geo = TRUE)

#------------------assignment 1 coding starts here -----------------------------------------------------
#produce a figure that shows the association between family income and support for increased educational spending
#relabel party levels
cces2$party_num <- factor(cces2$party, levels = c('No Party, Independent, Decline to state', 'Democratic Party', 'Republican Party', 'Other'),
                            labels = 1:4)
summary(cces2$party_num)
#create new directory for figures

library(hexbin)
#can we use cces2 instead of cces
ggplot(cces2, mapping = aes(x = faminc_num, y = ed_spend_num)) + geom_point() + geom_smooth(method ='lm')
#these don't look right - let's make sure these are right 2: greatly increase ed spending -2 greatly decrease ed spending
#plot for no party/decline/independent
p1 <- ggplot(subset(cces2, party_num == 1), aes(x = faminc_num, y = ed_spend_num)) + 
  geom_smooth(col = "#E7B800", lty = 2)
#democractic party
p2 <- ggplot(subset(cces2, party_num == 2), aes(x = faminc_num, y = ed_spend_num)) +
  geom_smooth(col = "dodgerblue", lty = 2)
#republican party
p3 <- ggplot(subset(cces2, party_num == 3), aes(x = faminc_num, y = ed_spend_num)) +
  geom_smooth(col = "firebrick1", lty = 2)
#other
p4 <- ggplot(subset(cces2, party_num == 4), aes(x = faminc_num, y = ed_spend_num)) + 
  geom_smooth(col = "forestgreen", lty = 2)
library(gridExtra)
dir.create('s022figures',showWarnings = FALSE)
png('s022figures/a1_f1.png')
figure <- grid.arrange(p1, p2, p3, p4,nrow = 2)
dev.off() #close the connection for the file

#next, using the state-level dataset you created, show the association between state per-pupil expenditures and state mean support for educational spending. There are lots of ways to do this, so pick one that seems good to you. Find a way to incorporate state political leanings (whether there are more Democrats or Republicans in the state). 
#make sure this is right/and accurate in how we added political leanings
png('s022figures/a1_f2.png')
ggplot(coll_dat, mapping = aes(x = mean_per_pupil, y = mean_ed_spend,color=prop_dem)) + geom_point() + geom_smooth()
dev.off()
#Show how educational spending varies between Republican-leaning states and Democratic-leaning states.
p5<- ggplot(coll_dat, mapping = aes(x = mean_ed_spend, y = prop_dem)) + geom_point() + geom_smooth()
p6<- ggplot(coll_dat, mapping = aes(x = mean_ed_spend, y = prop_rep)) + geom_point() + geom_smooth(col='red')
grid.arrange(p5,p6,nrow=1)

ggplot(coll_dat, mapping = aes(x = mean_ed_spend, y = prop_rep)) + geom_point() + geom_smooth(col='red')

#Create a map of the US, where states are colored according to the mean level of support for educational spending that their residents express. You could alternately do this at the county- or zipcode-level.
library(ggmap)
library(viridis)
library(tidycensus)
#not sure why this isn't working
ggplot(coll_dat, aes(fill = mean_ed_spend)) +
  geom_sf() + # add a spatial geom
  coord_sf(crs = 26914) + # define the coordinate system (provided by the census)
  scale_fill_viridis(option = "A") # this is the color palette; options go from A through E

#regression models - step 3
#regress for support of ed spending on total spending
mod <- lm(total_spending ~ ed_spend_num,cces2)
#regress with other predictors
mod2 <- lm(total_spending ~ faminc_num + employ + gender + educ + race + child18,cces2)
#added ed spending back into model
mod3 <- lm(total_spending ~ed_spend + faminc_num + employ + gender + educ + race + child18,cces2)
#introduce interaction between family income and party
mod4 <- lm(total_spending ~ed_spend + faminc_num + employ + gender + educ + race + child18 + faminc_num:party,cces2)
#taxonomy table
htmlreg(list(mod,mod2,mod3,mod4), file =
          's022figures/regression_table.html')
#step4
#stimulation 1
#set seed - figure out how to do
# simulation 2
# step 1: randomly sample 3 states
# this code creates a vector containing 3 randomly selected states
sampled_states <- sample(unique(cces$state), size = 3)  
# step 2: select all individuals from those 3 states
# this code creates a new dataframe keeping only people from those 
sampled_data <- cces[cces$cl_state %in% sampled_states] 
