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

panels.about_text<- shiny::helpText(
  p("Obtain and process Digital Elevation Model data with gdaldem algorithms and produce 'Elephant Skin' and 'Golden Map' to use as base layers of TELLme Metropolitan Cartography maps."),
  h4("Usage"), 
  div(style="font-size:smaller;",
      p("1. Select the source DEM. You can select the following sources:"),
      p(style="margin-left:0.5em;"," - (file) upload a tiff-image file"),
      p(style="margin-left:0.5em;"," - (from API) select a bounding box (click on the black-square-icon control in the map and draw a rectangle), set the desired resolution, click the button to obtain the DEM from", 
        a("AWS Open Data Terrain Tiles API", 
          href="https://registry.opendata.aws/terrain-tiles/", 
          target="_blank")),
      p("2. Choose the desidered processing (mode) and tune the settings according to your needs. Click 'Compute and plot output map' button."),
      p("3. See the resulting output. When you are satisfied, click the \"Download results\" button to obtain the output raster (geotiff image)" ),
      h4("Credits"), 
      p("Application developed for the TELLme ERASMUS+ project, O4. See source code repository on github",
        a("ptagliolato/TELLme-vlab-elephantSkin",
          href="https://github.com/ptagliolato/TELLme-vlab-elephantSkin", 
          target="_blank")
      ),
      p("Please see citation suggestion at:", 
        a("DOI: 10.5281/zenodo.3741897",
          href="https://doi.org/10.5281/zenodo.3741897",
          target="_blank")
      )
  )
)

panels.troubleshooting_text<-shiny::helpText(p(style="font-size:smaller;",
                                               "If you incur in any issue, please consider the following.",
                                               "Most common problems are due to input dimensions:",
                                               "The bigger the bounding box you select and the higher the requested resolution, the longer the time the application needs to wait the results for.",
                                               "Note also that not all the requests could be handled by the remote service (e.g. too big bounding boxes).",
                                               "If you are using a TELLme Virtual Lab remote deployment, you could also incur in troubles due to a high number of users concurrently connected to the server.",
                                               "Resources are limited, but you or your organization could consider to deploy the application on your own machine (see Credits in the \"About\" tab to obtain the code)."
                                               ))

panels.metadatasuggestion_text<-shiny::helpText(
  h4("How to document lineage metadata of downloaded files"),
  p("- Cite the source DEM file, the gdaldem algorithm you choose (hillshade or slope) and the present application (see credits section).",
    br(),
    "- If you choose the remote service source, please obtain licence information and citation instructions, starting from the documentation at ",
       a("AWS Open Data Terrain Tiles API", 
         href="https://registry.opendata.aws/terrain-tiles/", 
         target="_blank"),
    ". In fact, multiple sources concur to the DEM coverage, so the exact citation of original DEM data depends on the bounding box."
  ),
  p("Example:"),
  p(style="font-size:smaller;","Elaboration of DEM from AWS Open Data Terrain Tiles API (https://registry.opendata.aws/terrain-tiles/).",
    br(),"Source data: DEM from EU-DEM. Produced using Copernicus data and information funded by the European Union - EU-DEM layers.",
    br(),"Elaborated with ", a("gdaldem algorithms", href="https://gdal.org/license.html", target="_blank"),
    br(), "Workflow performed by TELLme Project Virtual Lab tool ElephantSkin (DOI: ", 
    a("10.5281/zenodo.3741898", href="https://doi.org/10.5281/zenodo.3741897", target="_blank"),
    ")"
  )
)
                                                  
                                               
shinydashboardPlus::dashboardPage(  
  skin = "black-light",
  # collapse_sidebar = FALSE,
  # sidebar_fullCollapse = TRUE,
  header = dashboardHeader(
    title = tagList(
      tags$div(class = "logo-lg",
               tags$img(src = "http://tellmehub.get-it.it/static/img/logo1_200px.png", width = "80px", height = "40px"),
               tags$span("TELLme Erasmus+ Project - Elephant Skin (Hillshade) - version 1.1.0")
      )
    ),
    titleWidth = 400
    # fixed = FALSE,
    # enable_rightsidebar = TRUE,
    # rightSidebarIcon = "gears"
  ),
  controlbar = dashboardControlbar(
    skin = "dark",
    width = 350,
    controlbarMenu(
      id = "menu",
      controlbarItem(
        id = "help",
        icon = icon("info"),
        title = "About",
        # active = TRUE,
        panels.about_text
      ),
      controlbarItem(
        id = "troubleshooting",
        icon = icon("fire-extinguisher"),
        title = "Troubleshooting",
        panels.troubleshooting_text
      ),
      controlbarItem(
        id = "metadatasuggestion",
        icon = icon("file-contract"),
        title = "Metadata lineage guidelines",
        panels.metadatasuggestion_text
      ) 
    )
  ),
  sidebar = dashboardSidebar(
    collapsed = FALSE,
    # disable = TRUE,
    width = 0,
    sidebarMenu(
      menuItem("Elaboration", tabName = "site", icon = icon("map", lib = "font-awesome"))
    )
  ),
  
  body = dashboardBody(
    useShinyjs(),
    
    tabItems(
      tabItem(
        tabName = "site",
        fluidRow(
          
          box(# inputs menu
            width = 12,
            #title = "input",
            background = "light-blue",
            # closable = FALSE,
            status = "primary",
            solidHeader = TRUE,
            collapsible = FALSE,
            #enable_sidebar = FALSE,
            #style = "background-color:black; color:white; padding: 0 10px;",
            fluidRow(
              column(
                width = 6, 
                box(
                  title="1. Select Digital Elevation Model input",
                  # closable = FALSE, 
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
                box(
                  title="2. Set Processing chain",
                  # closable = FALSE, 
                  background = "black",
                  width = 12,
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
                box(title="3. Output",
                    # closable = FALSE, 
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
                    disabled(downloadButton("downloadData", "Download result")
                  )
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
