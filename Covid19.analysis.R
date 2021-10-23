# title: Exploratory analysis of Covid19 cases and deaths in Brazil, and creation of interactive map
# author: "Mario Peres"
# date: "October 23, 2021"

# Installing package 'coronabr' from github
#remotes::install_github("liibre/coronabr")

# Loading libraries
library(coronabr)
library(data.table)
library(dplyr)
library(lubridate)
library(ggplot2)
library(ggpubr)
library(leaflet)

# Collecting and loading data set on Covid19 from Brasil.io
data <- get_corona_br(save = FALSE)

# Visualizing the data
View(data)

# Selection the variables of interest
data <- data %>%
  select(date, state, city, estimated_population, new_confirmed, new_deaths)

# Checking the number of NA values for each variables
lapply(data, function(x) { sum(is.na(x)) })

# Checking the number of observations in the data set
length(data$city)

# Removing NA values
data <- na.omit(data)

# Visualizing the data
View(data)

# Checking the data types of variables
glimpse(data)

# Rounding the dates down to week
data$week <- floor_date(data$date, "week")

# Finding the sum of new_confirmed and new_deaths per week considering each municipality
data_mun <- data %>%
  group_by(week, state, city) %>%
  mutate(new_confirmed_weekly = sum(new_confirmed),
         new_deaths_weekly = sum(new_deaths))


# Finding the sum of new_confirmed and new_deaths per week considering each state
# Also adjusting the population variables as a few values were smaller, probably
# because some of state population were filled with municipal pop information.
data_state <- data %>%
  select(-c(city, date,)) %>%
  group_by(week, state) %>%
  mutate(new_confirmed_weekly = sum(new_confirmed),
         new_deaths_weekly = sum(new_deaths),
         estimated_population = max(estimated_population),
         new_confirmed = NULL,
         new_deaths = NULL) %>%
  distinct()

# Finding the rate of new_confirmed_weekly and new_deaths_weekly per population considering each municipality
# Also finding the cumulative sum for new_confirmed_weekly and new_deaths_weekly and for the two new variables
data_state <- data_state %>%
  group_by(state) %>%
  mutate(new_confirmed_weekly_rate = round(new_confirmed_weekly / estimated_population * 100, 3),
         new_deaths_weekly_rate = round(new_deaths_weekly / estimated_population * 100, 3),
         new_confirmed_weekly_cum = cumsum(new_confirmed_weekly),
         new_deaths_weekly_cum = cumsum(new_deaths_weekly),
         new_confirmed_weekly_rate_cum = cumsum(new_confirmed_weekly_rate),
         new_deaths_weekly_rate_cum = cumsum(new_deaths_weekly_rate))

# Preparing plot for death rate
plot_death_rate <- data_state %>%
  select(state, new_deaths_weekly_rate_cum) %>%
  group_by(state) %>%
  summarise(total = max(new_deaths_weekly_rate_cum)) %>%
  ggplot() +
  geom_bar(aes(x = state, y = total, fill = state), stat = 'identity') +
  xlab('State') +
  ylab('Death Rate (%)') +
  ggtitle('Death Rate per State')

# Preparing plot for confirmed rates
plot_confirmed_rate <- data_state %>%
  select(state, new_confirmed_weekly_rate_cum) %>%
  group_by(state) %>%
  summarise(total = max(new_confirmed_weekly_rate_cum)) %>%
  ggplot() +
  geom_bar(aes(x = state, y = total, fill = state), stat = 'identity') +
  xlab('State') +
  ylab('Confirmed Rate (%)') +
  ggtitle('Confirmed Rate per State')

# Plotting both plots in the same area
ggarrange(plot_confirmed_rate, plot_death_rate, ncol = 1, nrow = 2)

# Creating a color label
colors <- c("Death" = "red", "Confirmed" = "black")

# Plotting historical new_confirmed_rate and new_deaths_rate per week
data_state %>%
  select(new_confirmed_weekly_rate_cum, new_deaths_weekly_rate_cum, week) %>%
  group_by(week) %>%
  summarise(new_confirmed_weekly_rate_cum_brazil = mean(new_confirmed_weekly_rate_cum, color = 'Confirmed'),
            new_deaths_weekly_rate_cum_brazil = mean(new_deaths_weekly_rate_cum)) %>%
  ggplot() +
  geom_line(mapping = aes(x=week, y=new_deaths_weekly_rate_cum_brazil, color='Death')) +
  geom_line(mapping = aes(x=week, y=new_confirmed_weekly_rate_cum_brazil / 20)) +
  labs(x = 'Weeks', color = 'Legend') +
  ggtitle('Weekly Confirmed and Death Cases in Brazil') +
  scale_y_continuous(
    "Death (%)", 
    sec.axis = sec_axis(~ . * 20, name = "Confirmed (%)")) +
  scale_color_manual(values = colors) +
  theme(
    plot.title = element_text(hjust = 0.5, face = 'bold')
  )


# Collecting and saving data on Covid19 from Johns Hopkins University 
data2 <-get_corona_jhu(save = FALSE)

# Visualizing data
View(data2)

# Selecting variables of interest
data2 <- data2 %>%
  select(last_update, country_region,combined_key, lat, long, confirmed, deaths, case_fatality_ratio)

# Checking the number of NA values in data2
sapply(data2, function(x) {sum(is.na(x))})

# Removing NA values
data2 <- na.omit(data2)

# Visualizing data2
View(data2)

# Checking the data type of variables
glimpse(data2)

# Verifing if there are duplicates in 'combined_key'
length(unique(data2$combined_key)) == length(data2$combined_key)

# Filtering data from Brazil and creating new variable date
data2 <- data2 %>%
  filter(country_region == 'Brazil') %>%
  group_by(last_update, combined_key) %>%
  mutate(date = ymd(paste(year(last_update),'-',month(last_update),'-',day(last_update))))

# Removing variables last_upgrate
data2$last_update = NULL

# Removing variables country_region
data2$country_region = NULL

# Selecting columns in a different order for organization of data2
data2 <- data2 %>%
  select(date, combined_key, confirmed, deaths, case_fatality_ratio, lat, long)

#Visualizing data2
View(data2)

#### Distribution of number of death in Brazil
# Selecting columns for the creation of data for mapping
data2 %>%
  select(combined_key, deaths, lat, long) %>%
  mutate(LatLon = paste(lat, long, sep = ":")) -> formapping

# Checking the formapping data set
head(formapping[,c(1,3:4)]) 

# Preparing data for plotting
num_of_times_to_repeat <- formapping$deaths
long_formapping <- formapping[rep(seq_len(nrow(formapping)),
                                  num_of_times_to_repeat),]

# Plotting an interactive map with deaths data
leaflet(long_formapping) %>% 
  addTiles() %>% 
  addMarkers(clusterOptions = markerClusterOptions())
