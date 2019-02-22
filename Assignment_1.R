#Assignment 1
#-------Authors----------------
#Rachel Kwon, Erin Mahoney, Kevin Nazario

#We’re going to work with the CCES dataset. We’ll also be adding data I found which reports how muche each state #spent on education per student in 2016. We’ll be trying to see if there’s an association between how much #states spend on education and much residents of those states want to increase educational spending.

#Follow the script for step one which helps you do some simple data preparation which will make your life easier later on.

#Step 2
#We’re going to visualize some associations.

#First, using cces, produce a figure showing how family income is associated with support for increased #educational spending. Make sure that your figure shows this association separately for people of different #political parties.

#Next, using the state-level dataset you created, show the association between state per-pupil expenditures and state mean support for educational spending. There are lots of ways to do this, so pick one that seems good to you. Find a way to incorporate state political leanings (whether there are more Democrats or Republicans in the state).

#Show how educational spending varies between Republican-leaning states and Democratic-leaning states.

#Create a map of the US, where states are colored according to the mean level of support for educational spending that their residents express. You could alternately do this at the county- or zipcode-level.

#Group these plots into a single 2x2 grid (see the grid.arrange() function in the week 2 script). Write a brief explanation of what we learn from each plot.

#Step 3
#using the cces dataframe, fit a series of models.

#First, regress support for educational spending (ed_spend_num) on mean state spending alone (total_spending).

#Next, regress on family income (the numeric version, faminc_num), employment status (employ), gender (gender), educational attainment (educ), race (race), and whether or not the respondent has a child under the age of 18 (child18); these seem like variables which might predict support for increased spending.

#Next, add total spending back into the model.

#Finally, allow family income to interact with party. Create a taxonomy table showing these four models.

#Look across the models and try to say 1) how state per pupil expenditures are associated with support for increased spending, and 2) how family income is associated withsupport for increased spending. Remember, we want you to consider all available data. Note: if coefficients are too small to be read from the table, you can fix things by either rescaling the predictor or by finding a way to tell your software to display more digits.

#Step 4
#Using the techniques we developed in class, run two different simulations. Take 10,000 random samples, first by randomly sampling 1,000 individuals from the data, then by randomly sampling all individuals from three randomly selected states. You can accomplish this second goal by running

# simulation 2
# step 1: randomly sample 3 states
# this code creates a vector containing 3 randomly selected states
#  sampled_states <- sample(unique(cces$state), size = 3)  
# step 2: select all individuals from those 3 states
# this code creates a new dataframe keeping only people from those 
# sampled_data <- cces[cces$cl_state %in% sampled_states] 
#In each simulation, fit a model regressing support for increased educational spending on total state spending. Do not include any other controls. Simulations can often be easier to understand when they’re designed to be simple. Looking across the simulations, determine which method tends to give larger samples, and which method has a smaller standard error. Try to make sense of the results, and explain what model violations are present in the second approach. Use some sort of a visual display to explain your findings.

#If you want everyone in the group to get identical results, be sure to set the same random seed before the simulation starts.

#Step 5
#Use the census dataset to determine whether support for increased educational spending is associaetd with the median income of a respondent’s zip code. The census geometry for zipcodes is zcta, the cces variable is lookupzip, and the census median income variable is  B06011_001. Create a plot showing how zipcode-level mean support for increased educational spending is associated with zipcode median income. Use this plot to determine the functional form you intend to use for the association.

#Then fit a model regressing support for increased educational spending on median income, controlling for family income, employment status, gender, educational attainment, race, and whether or not the respondent has a child under the age of 18.

#Present your plot and fitted model, and in a short paragraph explain how you used the plot, ways in which you think your model is successful and ways you think it may be lacking, and what you learn about how median income predicts support for increased educational spending controlling for the other variables in the model. As a part of your response, you may want to discuss which sorts of communities are most and least likely to support increased educational spending. Note: you may find your interpretations are easier if you first rescale median income to be in thousands- or tens-of-thousands of dollars.

#-----------------------------------------------------------------------------------
#Challenge question
#Please note: challenge questions are never graded, are never factored into your final score, and are only intended for you to satisfy your own interest in a question. We will provide solutions for people who are interested.

#Consider the same model as you did in step 4. The 95% confidence intervals for the slope coefficient ought to contain the true slope (for the model fit to the full cces data) 95% of the time. In your simulations, how frequently did each approach to sampling result in a sample for which the 95% confidence interval contained the true slope. Can you explain your result?

