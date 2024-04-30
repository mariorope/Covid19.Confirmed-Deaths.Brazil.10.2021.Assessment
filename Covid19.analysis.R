knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)

#install.packages('remotes')
#remotes::install_github('liibre/coronabr')

library(coronabr)
library(data.table)
library(dplyr)
library(lubridate)
library(ggplot2)
library(plotly)
library(ggpubr)

data <- get_corona_br(save = FALSE)
head(data)

original_data <- copy(data)

data <- data %>%
  select(date, city, state, estimated_population, new_confirmed, new_deaths)
head(data)

data <- data[is.na(data$city),]
data <- select(data, -city)
head(data)

dim(data)

glimpse(data)

lapply(data, function(x) { sum(is.na(x)) })

data <- data %>%
  mutate(month = month(date)) %>%
  reframe(date, month, state, estimated_population, new_confirmed, new_deaths)

data %>%
  select(date) %>%
  summarise(
    min_date = min(date),
    max_date = max(date)
  )

data <- data[data$date >= date(ymd('2020-03-28')),]

data %>%
  select(state) %>%
  unique()

data %>%
  select(state, estimated_population) %>%
  unique()

data %>%
  filter(new_confirmed<0) %>%
  select(new_confirmed)

data %>% 
  filter(new_deaths<0) %>%
  select(new_deaths)

for (i in 2:length(data$new_confirmed))
  {
    if (data$new_confirmed[i] < 0)
      
    {
      data$new_confirmed[i] <- data$new_confirmed[i]*(-1)
    }
  
    if (data$new_deaths[i] < 0)
      
    {
      data$new_deaths[i] <- data$new_deaths[i]*(-1)
    }
  }

data %>%
  filter(new_confirmed<0) %>%
  select(new_confirmed)

data %>% 
  filter(new_deaths<0) %>%
  select(new_deaths)

data_country_all <- data %>%
  summarise(period = '28/03/2020 to 27/03/2022',
            country = 'Brazil',
            estimated_population = sum(unique(estimated_population)),
            new_confirmed = sum(new_confirmed),
            new_deaths = sum(new_deaths)) %>%
  mutate(prop_confirmed_population = new_confirmed/estimated_population,
         prop_deaths_population = new_deaths/estimated_population,
         deaths_confirmed_rate = new_deaths/new_confirmed)
data_country_all

data_country_week <- data
data_country_week$week <- floor_date(data$date, "week")

data_country_week <- data_country_week %>%
  group_by(week) %>%
  summarise(estimated_population = sum(unique(estimated_population)),
            new_confirmed = sum(new_confirmed),
            new_deaths = sum(new_deaths)) %>%
  mutate(prop_confirmed_population = new_confirmed/estimated_population,
         prop_deaths_population = new_deaths/estimated_population,
         deaths_confirmed_rate = new_deaths/new_confirmed) %>%
ungroup()
head(data_country_week)


colors <- c('Death' = 'red', 'Confirmed' = 'blue', 'Death/Confirmed Rate' = 'black')
x_annotation <- date(ymd_hms('2020-01-01 23:12:13', tz = 'America/New_York'))

ggplot(data=data_country_week) +
  geom_line(mapping = aes(x=week, y=new_confirmed / 10000, color='Confirmed')) +
  geom_line(mapping = aes(x=week, y=new_deaths / 1000, color='Death')) +
  annotate(geom='label', x=x_annotation, y=114, label='BRASIL (total)
  Period: 28/03/2020 to 27/03/2022
  Confirmed Cases: 29,904,964
  Deaths: 659,726', color='black', hjust = 0, fontface='bold', size=4) +
  labs(x = 'Week', color = 'Legend') +
  ggtitle('Evolution of Confirmed and Death Rates in Brazil') +
  scale_y_continuous(
    'Number of New Confirmed Cases (x 10,000)', 
    sec.axis = sec_axis(~ . * 1, name = 'Number of New Deaths (x 1,000)')) +
  scale_color_manual(values = colors) +
  theme(
    plot.title = element_text(size = 14, hjust = 0.5, face = 'bold'),
    axis.title = element_text(size = 11,face = 'bold'),
    axis.text = element_text(size = 10),
    axis.title.y.right = element_text(color = 'red'),
    axis.title.y.left = element_text(color = 'blue'),
    axis.text.y.right = element_text(color = 'red'),
    axis.text.y.left = element_text(color = 'blue'),
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 8, face = 'bold'),
    legend.position = c(0.1, 0.6),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(colour = 'black', fill = '#F5F5F5'),
    panel.border = element_rect(size = 1, fill = NA)
  )

x_annotation <- date(ymd_hms('2021-10-01 23:12:13', tz = 'America/New_York'))

ggplot(data=data_country_week) +
  geom_line(mapping = aes(x=week, y=deaths_confirmed_rate * 100, color='Death/Confirmed Rate')) +
  annotate(geom='label', x=x_annotation, y=6.85, label='BRASIL (total)
Period: 03/2020 to 02/2022
Death/Confirmed Rate: 2.2%', color='black', hjust = 0, fontface='bold', size=4) +
  labs(x = 'Week', y='Death/Confirmed Rate (%)', color = 'Legend') +

  ggtitle('Evlolution of Death/Confirmed Rate in Brazil') +
  scale_color_manual(values = colors) +
  theme(
    plot.title = element_text(size = 14, hjust = 0.5, face = 'bold'),
    axis.title = element_text(size=11,face='bold'),
    axis.text = element_text(size=10),
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 8, face = 'bold'),
    legend.position = c(0.89, 0.688),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(colour = 'black'),
    panel.border = element_rect(size = 1, fill = NA)
  )

data_state <- data %>%
  group_by(state) %>%
  summarise(estimated_population = sum(unique(estimated_population)),
            new_confirmed = sum(new_confirmed),
            new_deaths = sum(new_deaths)) %>%
  mutate(prop_confirmed_population = new_confirmed/estimated_population,
         prop_deaths_population = new_deaths/estimated_population,
         deaths_confirmed_rate = new_deaths/new_confirmed) %>%
ungroup()

state <- c('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')
region <- c('N','NE','N','N','NE','NE','CO','SE','CO','NE','CO','CO','SE','N','NE','S','NE','NE','SE','NE','S','N','N','S','SE','NE','N')
region_state_list <- data.frame(region, state)
counter = 1

data_state$region = 0
for (i in 1:length(data_state$state)){
  for (j in 1:length(region_state_list$region)){
    if (data_state$state[i] == region_state_list$state[j]){
      data_state$region[i] = region_state_list$region[j]
      counter <- counter + 1
    }
  }
}

data_state <- data_state %>%
  reframe(region, state, estimated_population, new_confirmed, new_deaths, prop_confirmed_population, prop_deaths_population, deaths_confirmed_rate)
head(data_state)

gg <- ggplot(data_state) +
  geom_point(aes(x=prop_confirmed_population * 100,
                 y=prop_deaths_population * 100,
                 color=region,
                 size=deaths_confirmed_rate * 100,
                 group=state)) +
  theme_bw() +
  xlab("New Confirmed Case Rate (%)") +
  ylab("New Deaths Rate (%)") +
  ggtitle("Proportion of New Confirmed Case and Deaths Rates per State") +
  labs(color = 'Region') +
  guides(size = FALSE) +
  theme(
    plot.title = element_text(size = 14, hjust = 0.5, face = 'bold'),
    axis.title = element_text(size=11,face='bold'),
    axis.text = element_text(size=10),
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 8, face = 'bold'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(colour = 'black'),
    panel.border = element_rect(size = 1, fill = NA))

ggplotly(gg) %>%
  highlight("plotly_hover")

data_state_week <- data
data_state_week$week <- floor_date(data$date, "week")

data_state_week <- data_state_week %>%
  group_by(state, week) %>%
  summarise(estimated_population = sum(unique(estimated_population)),
            new_confirmed = sum(new_confirmed),
            new_deaths = sum(new_deaths)) %>%
  mutate(prop_confirmed_population = new_confirmed/estimated_population,
         prop_deaths_population = new_deaths/estimated_population,
         deaths_confirmed_rate = new_deaths/new_confirmed) %>%
ungroup()
head(data_state_week)

ggplot(data=data_state_week) +
  geom_line(mapping = aes(x=week, y=new_confirmed, group=state ,color=state)) +
  labs(x = 'Week', y='Number of New Confirmed Cases') +
  ggtitle('Evlolution of New Confirmed Case per State') +

  theme(
    plot.title = element_text(size = 14, hjust = 0.5, face = 'bold'),
    axis.title = element_text(size=11,face='bold'),
    axis.text = element_text(size=10),
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 8, face = 'bold'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(colour = 'black'),
    panel.border = element_rect(size = 1, fill = NA)
  )

data_region_week <- data

counter = 1

data_region_week$region = 0
for (i in 1:length(data_region_week$state)){
  for (j in 1:length(region_state_list$region)){
    if (data_region_week$state[i] == region_state_list$state[j]){
      data_region_week$region[i] = region_state_list$region[j]
      counter <- counter + 1
    }
  }
}

data_region_week$week <- floor_date(data$date, "week")

data_region_week <- data_region_week %>%
  group_by(region, week) %>%
  summarise(estimated_population = sum(unique(estimated_population)),
            new_confirmed = sum(new_confirmed),
            new_deaths = sum(new_deaths)) %>%
  mutate(prop_confirmed_population = new_confirmed/estimated_population,
         prop_deaths_population = new_deaths/estimated_population,
         deaths_confirmed_rate = new_deaths/new_confirmed) %>%
ungroup()

data_region_week <- data_region_week %>%
  reframe(week, region, estimated_population, new_confirmed, new_deaths, prop_confirmed_population, prop_deaths_population, deaths_confirmed_rate)

head(data_region_week)

ggplot(data=data_region_week) +
  geom_line(mapping = aes(x=week, y=prop_confirmed_population * 100, group=region ,color=region)) +
  labs(x = 'Week', y='New Confirmed Cases Rate (%)') +
  ggtitle('Evlolution of New Confirmed Case per Region') +

  theme(
    plot.title = element_text(size = 14, hjust = 0.5, face = 'bold'),
    axis.title = element_text(size=11,face='bold'),
    axis.text = element_text(size=10),
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 8, face = 'bold'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(colour = 'black'),
    panel.border = element_rect(size = 1, fill = NA)
  )

data_region_month <- data

counter = 1

data_region_month$region = 0
for (i in 1:length(data_region_month$state)){
  for (j in 1:length(region_state_list$region)){
    if (data_region_month$state[i] == region_state_list$state[j]){
      data_region_month$region[i] = region_state_list$region[j]
      counter <- counter + 1
    }
  }
}

data_region_month$month <- floor_date(data$date, "month")

data_region_month <- data_region_month %>%
  group_by(region, month) %>%
  summarise(estimated_population = sum(unique(estimated_population)),
            new_confirmed = sum(new_confirmed),
            new_deaths = sum(new_deaths)) %>%
  mutate(prop_confirmed_population = new_confirmed/estimated_population,
         prop_deaths_population = new_deaths/estimated_population,
         deaths_confirmed_rate = new_deaths/new_confirmed) %>%
ungroup()

data_region_month <- data_region_month %>%
  reframe(month, region, estimated_population, new_confirmed, new_deaths, prop_confirmed_population, prop_deaths_population, deaths_confirmed_rate)

head(data_region_month)

ggplot(data=data_region_month) +
  geom_line(mapping = aes(x=month, y=prop_confirmed_population * 100, group=region ,color=region)) +
  labs(x = 'Month', y='New Confirmed Cases Rate (%)') +
  ggtitle('Evlolution of New Confirmed Case per Region per Month') +

  theme(
    plot.title = element_text(size = 14, hjust = 0.5, face = 'bold'),
    axis.title = element_text(size=11,face='bold'),
    axis.text = element_text(size=10),
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 8, face = 'bold'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(colour = 'black'),
    panel.border = element_rect(size = 1, fill = NA)
  )

ggplot(data=data_region_month) +
  geom_line(mapping = aes(x=month, y=prop_deaths_population * 100, group=region ,color=region)) +
  labs(x = 'Month', y='New Deaths Rate (%)') +
  ggtitle('Evlolution of New Deaths per Region per Month') +

  theme(
    plot.title = element_text(size = 14, hjust = 0.5, face = 'bold'),
    axis.title = element_text(size=11,face='bold'),
    axis.text = element_text(size=10),
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 8, face = 'bold'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(colour = 'black'),
    panel.border = element_rect(size = 1, fill = NA)
  )

ggplot(data=data_region_month) +
  geom_line(mapping = aes(x=month, y=deaths_confirmed_rate * 100, group=region ,color=region)) +
  labs(x = 'Month', y='Death/Confirmed Rate (%)') +
  ggtitle('Evlolution of Deaths/Confirmed Rate per Region per Month') +

  theme(
    plot.title = element_text(size = 14, hjust = 0.5, face = 'bold'),
    axis.title = element_text(size=11,face='bold'),
    axis.text = element_text(size=10),
    legend.text = element_text(size = 7),
    legend.title = element_text(size = 8, face = 'bold'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(colour = 'black'),
    panel.border = element_rect(size = 1, fill = NA)
  )

data %>%
  filter(date >= date(ymd('2021-01-01')), date <= date(ymd('2021-12-31'))) %>%
  summarise(total_confirmed = sum(new_confirmed),
            total_death = sum(new_deaths),
            death_rate = sum(new_deaths) / sum(new_confirmed) * 100)
