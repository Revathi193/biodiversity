Biodiversity Shiny app

This is a shiny application that demonstartes the biodiversity data. The main purpose of this application is to view the selected species observations on the map and visualize its timeline.

library(shiny)

library(shinydashboard)

library(leaflet)

library(timevis)

library(dplyr)

library(DT)

library(ggplot2)


\# First clone the repository with git. If you have cloned it into

\# ~/biodiversity, first go to that directory, then use runApp().

setwd("~/app")

runApp()

This application uses the data of two countries Poland and The Netherlands. The input data can be viewed in the Input Data tab.

The default view will be a text output to select country and species.

To view the map, search for the desired species by its Vernacular Name/Scientific name in the search bar.The selected species observations can be viewed on the map and its timeline will be plotted below the map.

The map is built using leaflet library and the timeline plot is generated using timevis library and the Event date in the data.

The application also has another tab to view the stats which contains the total species count in the selected country, the count of the selected species and a bar chart that help to get the kingdom wise count.
