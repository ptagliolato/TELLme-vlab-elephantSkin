#
# TELLme Erasmus Plus Project
# 
# Shiny app for dtm -> hillshade and slope maps
# expected data: https://www.asf.alaska.edu/sar-data/palsar/terrain-corrected-rtc/
# alos-palsar DTM high res products (geoTIFF) (DEM INT16 GeoTIFF 12.5m)
# see also: https://www.asf.alaska.edu/asf-tutorials/dem-information/
# obtain data from web interface: https://vertex.daac.asf.alaska.edu/
# filtering on dataset alos-palsar
#
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
# cf. https://www.gdal.org/gdaldem.html
library(shiny)
# devtools::install_github("RinteRface/shinydashboardPlus", force = TRUE)
library(shinydashboardPlus)
library(shinydashboard)
#devtools::install_github('andrewsali/shinycssloaders')
library(shinycssloaders)
#install.packages("shinyjs")
library(shinyjs)
library(leaflet)
library(mapview)

choices <- list("elephant skin (hillshade)" = "hillshade",
                "golden map (slope)" = "slope"
                #,"aspect" = "aspect",
                #"color-relief"= "color-relief",
                #"TRI"="TRI",
                #"TPI"="TPI"
                #"roughness"="roughness"
)

dashboardPagePlus(
  skin = "black-light",
  collapse_sidebar = FALSE,
  sidebar_fullCollapse=TRUE,
  dashboardHeaderPlus(
    title = tagList(
      tags$div(class = "logo-lg",
               tags$img(src = "http://tellmehub.get-it.it/static/img/logo1_200px.png", width = "80px", height = "40px"),
               tags$span("TELLme Erasmus+ Project - Elephant Skin (Hillshade)")
      )
    ),
    titleWidth = 400
    # fixed = FALSE,
    ,enable_rightsidebar = TRUE,
    rightSidebarIcon = "gears"
  ),
  rightsidebar=rightSidebar(
    #fileInput("file1", "Choose Digital Elevation Model File (raster image)",
    #                      multiple = FALSE, accept = c("*/*","*,*",".*")),
    #            selectInput("mode", "choose mode",choices = choices),
    sliderInput("z","Vertical exaggeration",min = 1,max = 50,value = 1),
    sliderInput("az","Azimuth of the light",min = 1,max = 360,value = 315),
    sliderInput("alt","Altitude of the light",min = 0,max = 90,value = 45)
    
  ),
  sidebar=dashboardSidebar(
    collapsed = FALSE,
    disable = FALSE,
    width = 0,
    sidebarMenu(
      menuItem("Elaboration", tabName = "site", icon = icon("map", lib = "font-awesome"))
      #menuItem("Map", tabName = "map", icon = icon("map", lib = "font-awesome"))
      # ,
      # dropdownBlock(
      #   fileInput("file1", "Choose Digital Elevation Model File (raster image)",
      #             multiple = FALSE, accept = c("*/*","*,*",".*")),
      #   selectInput("mode", "choose mode",choices = choices),
      #   sliderInput("z","Vertical exaggeration",min = 1,max = 50,value = 1),
      #   sliderInput("az","Azimuth of the light",min = 1,max = 360,value = 315),
      #   sliderInput("alt","Altitude of the light",min = 0,max = 90,value = 45),
      #   id="ss",icon = icon("map", lib = "font-awesome"),title="inputs"
      # )
    )
  ),
  
  body=dashboardBody(
    useShinyjs(),
    
    tabItems(
      tabItem(
        tabName = "site",
        fluidRow(
          
          boxPlus(# inputs menu
            width=12,
            #title="input",
            background = "light-blue",
            closable=FALSE,status = "primary", solidHeader = FALSE, collapsible = FALSE,
            #enable_sidebar = FALSE,
            #style = "background-color:black; color:white; padding: 0 10px;",
            fluidRow(
              column(
                width=6,
                fileInput("file1", "Choose Digital Elevation Model File (raster image)",
                          multiple = FALSE, accept = c("*/*","*,*",".*"))
              ),
              column(
                width=6,
                selectInput("mode", "choose mode",choices = choices)
              )
            ),
            fluidRow(
              column(
                offset=6,
                width=3,
                style="text-align:left;",
                disabled(actionButton("doPlotMap","Compute and plot output map",icon("cog")))
              ),
              column(
                width=3,
                style="text-align:right;",
                disabled(downloadButton("downloadData", "Download result"))
              )
            )
          ),
          
          boxPlus(# input raster plot
            width = 6,
            title = "Input Map", 
            closable = FALSE, status = "info", solidHeader = FALSE, collapsible = TRUE,
            enable_sidebar = TRUE,sidebar_width = 25,sidebar_start_open = FALSE,
            sidebar_content = tagList(
              tags$p("Original raster file")
            ),
            style = "padding: 0 10px;",
            # --- contents ---
            plotOutput("mapInput")
          ),
          
          boxPlus(# output raster plot
            width = 6,
            title = "Elaborated map", 
            closable = FALSE, status = "info", solidHeader = FALSE, collapsible = TRUE,
            enable_sidebar = TRUE,sidebar_width = 25,sidebar_start_open = FALSE,
            sidebar_content = tagList(
              tags$p("Elaborated map")
            ),
            style = "padding: 0 10px;",
            plotOutput("mapImg")
          ),
          
          boxPlus(
            width=12,
            leafletOutput("mapleaflet")
          )
          
        )#end fluidRow
      )#end tabItem
    )#end tabItems
  )#end dashboardBody
)#end dashboardPagePlus
