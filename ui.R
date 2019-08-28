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
library(raster)

choices <- list("elephant skin (hillshade)" = "hillshade",
                "golden map (slope)" = "slope"
                #,"aspect" = "aspect",
                #"color-relief"= "color-relief",
                #"TRI"="TRI",
                #"TPI"="TPI"
                #"roughness"="roughness"
)

{
  countries <- raster::getData('ISO3')
  countries <- countries[order(countries$NAME),]
  countries_choice<-countries[,1]
  names(countries_choice)<-countries[,2]
}

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
    
    # sliderInput("z","Vertical exaggeration",min = 1,max = 50,value = 1),
    # sliderInput("az","Azimuth of the light",min = 1,max = 360,value = 315),
    # sliderInput("alt","Altitude of the light",min = 0,max = 90,value = 45)
    
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
                boxPlus(title="1. Select Digital Elevation Model input",
                        closable = FALSE, 
                        background = "black",
                        width=12,
                        tabsetPanel(
                          tabPanel("from API", 
                                   p("Select the bounding box, adjust the resolution and invoke remote API to obtain the Digital Elevation Model"),
                                   bbxSelectorUI("bbxSelectorId","Bounding Box", height="20em"),
                                   sliderInput("zlevel","DEM zoom level Resolution (1-14)", min=1, max=14, value=5),
                                   p("(Please note that too large bounding boxes and too high resolution levels may lead to unexpected issues. Try lower values if necessary.)"),
                                   disabled(actionButton("getRasterFromAPI", "Obtain DEM for selected bounding box"))
                          ),
                          tabPanel("from file", 
                                   p("Select a Digital Elevation Model from your computer"),
                                   fileInput("file1", "Choose Digital Elevation Model File (raster image)",
                                             multiple = FALSE, accept = c("*/*","*,*",".*"))
                                   
                          )
                        ),
                        hr(),
                        h4("Current Input image:"),
                        div(style="border:1px solid white; border-radius:0.2em; margin-bottom:0.3em; padding: 0.2em;",
                        plotOutput("mapInput", height="20em")
                        )
                )
              ),
              column(
                width=6,
                boxPlus(title="2. Set Processing chain",
                        closable = FALSE, 
                        background = "black",
                        width=12,
                        selectInput("mode", "choose mode",choices = choices),
                        
                        conditionalPanel("input.mode=='hillshade'",
                                         div(style="border:1px solid white; border-radius:0.2em; margin-bottom:0.3em; padding: 0.2em",
                                         sliderInput("z","Vertical exaggeration",min = 1,max = 50,value = 1),
                                         sliderInput("az","Azimuth of the light",min = 1,max = 360,value = 315),
                                         sliderInput("alt","Altitude of the light",min = 0,max = 90,value = 45)           
                                          #p("Advanced settings for elephant skin (hillshade) mode are available in the settings panel (click the gear icon in the top right part of the page to expand")
                                         )),
                        disabled(actionButton("doPlotMap","Compute and plot output map",icon("cog")))
                
                ),
                boxPlus(title="3. Output",
                        closable = FALSE, 
                        background = "black",
                        width=12,
                        tabsetPanel(
                          tabPanel(title="Map view",
                            leafletOutput("mapleaflet")
                          ),
                          tabPanel(title="Image view",
                                   plotOutput("mapImg")      
                          )
                        ),
                        disabled(downloadButton("downloadData", "Download result"))
                )
              )
            ),
            fluidRow(
              column(
                offset=6,
                width=3,
                style="text-align:left;"#,
                #disabled(actionButton("doPlotMap","Compute and plot output map",icon("cog")))
              ),
              column(
                width=3,
                style="text-align:right;"#,
                #disabled(downloadButton("downloadData", "Download result"))
              )
            )
          ),
          div()
          # boxPlus(# input raster plot
          #   width = 6,
          #   title = "Input Map", 
          #   closable = FALSE, status = "info", solidHeader = FALSE, collapsible = TRUE,
          #   collapsed = TRUE,
          #   enable_sidebar = TRUE,sidebar_width = 25,sidebar_start_open = FALSE,
          #   sidebar_content = tagList(
          #     tags$p("Original raster file")
          #   ),
          #   style = "padding: 0 10px;",
          #   # --- contents ---
          #   plotOutput("mapInput_1")
          # ),
          # 
          # boxPlus(# output raster plot
          #   width = 6,
          #   title = "Elaborated map", 
          #   closable = FALSE, status = "info", solidHeader = FALSE, collapsible = TRUE,
          #   enable_sidebar = TRUE,sidebar_width = 25,sidebar_start_open = FALSE,
          #   sidebar_content = tagList(
          #     tags$p("Elaborated map")
          #   ),
          #   style = "padding: 0 10px;",
          #   plotOutput("mapImg_1")
          # )
          #,
          # boxPlus(
          #   width=12,
          #   leafletOutput("mapleaflet")
          # )
          
        )#end fluidRow
      )#end tabItem
    )#end tabItems
  )#end dashboardBody
)#end dashboardPagePlus
