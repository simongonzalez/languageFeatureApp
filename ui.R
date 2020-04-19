library(countrycode)
library(data.table)
library(DiagrammeR)
library(DT)
library(echarts4r.assets)
library(echarts4r.maps)
library(echarts4r.suite)
library(echarts4r)
library(edgebundleR)
library(formattable)
library(geojsonsf)
library(gridExtra)
library(grImport)
library(highcharter)
library(htmltidy)
library(igraph)
library(jsonify)
library(leaflet)
library(lubridate)
library(mapdeck)
library(networkD3)
library(plotly)
library(RColorBrewer)
library(RCurl)
library(readr)
library(reshape2)
library(sf)
library(shiny)
library(shinyalert)
library(shinyBS)
library(shinydashboard)
library(shinyjqui)
library(shinyWidgets)
library(sigmajs)
library(sigmaNet)
library(sortable)
library(stopwords)
library(streamgraph)
library(tidyverse)
library(varhandle)
library(viridis)
library(visNetwork)
library(XML)
library(zoo)

shinyUI(fluidPage(theme = "_bootswatch.scss",
                  tabsetPanel(id = "tabsPanel", 
                              tabPanel("HOME",
                                       tags$hr(),
                                       tags$h5(HTML("This app is a minimalistic yet practical interface which helps the visualision of features from the PHOIBLE project and the World Atlas of Language Structures (WALS).<br/><br/>The app has two visualisation components. The first one is a world map which shows the feature distribution of languages. A bar chart is combined with the map to help observe feature counts. The second componet is the network visualisation. It helps observe relationships between languages based on multiple features.<br/><br/>All the information from the projects as well as the data where it was taken from can be found in the following website links:")),
                                       tags$hr(),
                                       tags$a(href="https://phoible.org/", "PHOIBLE Link"),
                                       tags$hr(),
                                       tags$a(href="https://wals.info/", "WALS Link"),
                                       tags$hr(),
                                       tags$h4("App information"),
                                       tags$h5("Developer: Simon Gonzalez"),
                                       tags$h5("Email: simon.gonzalez@anu.edu.au"),
                                       tags$h5("Institution: The Australian National University"),
                                       tags$hr(),
                                       tags$h4("Acknowledgements"),
                                       tags$h5("Special thanks to Steve Moran for comments on the content and references to source data.")
                                       
                              ),
                              tabPanel("Parameters",
                                       fluidRow(
                                         column(4, uiOutput('selAr')),
                                         column(4, uiOutput('selParam')),
                                         column(4, selectInput('themes', 'Plot Theme', choices = unlist(strsplit('default dark vintage westeros essos wonderland walden chalk infographic macarons roma shine purple-passion halloween', ' ' ))))
                                       ),
                                       radioButtons('sizeby', 'Language Size', choices = c('Same Size', 'Inventory Size', 'Consonants Size', 'Vowels Size'), 
                                                    inline = T), 
                                       
                                       fluidRow(
                                         column(4, checkboxInput('includeUnclassified', 'Include Unclassified Languages', TRUE)),
                                         column(4, checkboxInput('inDifferentPlot', 'As separate plots', FALSE))
                                       ),
                                       echarts4rOutput("selPlot"),
                                       highchartOutput("selBarPlot")
                              ),
                              tabPanel("Network Visualisation",
                                       tags$h5('This section allows to plot one or multiple features in a network. Please select variables in the field section.'),
                                       uiOutput('selNet'),
                                       sigmaNetOutput('selplotnetwork')
                                       
                              ))
))
