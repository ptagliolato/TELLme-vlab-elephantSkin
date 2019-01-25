
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

dashboardPagePlus(
  
  skin = "black-light",
  collapse_sidebar = TRUE,
  dashboardHeaderPlus(
    title = tagList(
      tags$span(class = "logo-lg", "TELLme Erasmus+ Project - Elephant Skin (Hillshade)"),
      #tags$img(src = "http://www.get-it.it/assets/img/icon/logo1-ico.png", width = "50px", height = "50px")
      tags$img(src = "http://tellmehub.get-it.it/static/img/logo1_200px.png", width = "100px", height = "50px")
    )
    # fixed = FALSE,
    # ,enable_rightsidebar = TRUE
    # rightSidebarIcon = "gears",
  ),
  
  dashboardSidebar(
    collapsed = TRUE,
    disable = FALSE,
    width = 2,
    sidebarMenu(
      menuItem("Elaboration", tabName = "site", icon = icon("map", lib = "font-awesome"))
    )
  ),
  
  dashboardBody(
    useShinyjs(),
    tabItems(
      # First tab content: input parameters
      tabItem(tabName = "site",
              fluidRow(
                boxPlus(
                  width = 4, # bootstrap grid system (12 columns total)
                  title = "Elaboration parameters", 
                  closable = FALSE, 
                  status = "info", 
                  solidHeader = FALSE, 
                  collapsible = TRUE,
                  enable_sidebar = TRUE,
                  sidebar_width = 25,
                  sidebar_start_open = FALSE,
                  sidebar_content = tagList(
                    tags$p("Upload a Digital Elevation Model (DEM) raster file (.tif), then tune the parameters to adjust the 'Elephant Skin' (Hillshade) map according to your needs"),
                    #tags$p("Default par"),
                    tags$p(tags$b("Press i to collapse this slidebar."))
                  ),
                  #Input: Select a file ----
                  fileInput("file1", "Choose Digital Elevation Model File (raster image)",
                            multiple = FALSE,
                            accept = c("*/*",
                                       "*,*",
                                       ".*")),
                  selectInput("mode", "choose mode",
                              choices = list("hillshade" = "hillshade",
                                             #"slope" = "slope",
                                             "aspect" = "aspect",
                                             #"color-relief"= "color-relief",
                                             #"TRI"="TRI",
                                             "TPI"="TPI"
                                             #"roughness"="roughness"
                                             )),
                  sliderInput("z",
                              "Vertical exaggeration",
                              min = 1,
                              max = 50,
                              value = 1),
                  sliderInput("az",
                              "Azimuth of the light",
                              min = 1,
                              max = 360,
                              value = 315),
                  sliderInput("alt",
                              "Altitude of the light",
                              min = 0,
                              max = 90,
                              value = 45),
                  #uiOutput("path"),
                  height = "650px", 
                  style = "padding-left: 10px;padding-right: 10px;"
                ),
                #fluidRow(
                  # display input raster
                  boxPlus(
                    #
                    # actual map
                    #
                    plotOutput("mapInput"),
                    #
                    # boxPlus rendering configuration
                    #
                    width = 4,
                    title = "Input Map", 
                    closable = FALSE, 
                    status = "info", 
                    solidHeader = FALSE, 
                    collapsible = TRUE,
                    enable_sidebar = TRUE,
                    sidebar_width = 25,
                    sidebar_start_open = FALSE,
                    sidebar_content = tagList(
                      tags$p("Original raster file")
                    ),
                    style = "padding-left: 10px;padding-right: 10px;"
                  ),
                  # display output map
                  boxPlus(
                    disabled(actionButton("doPlotMap","Compute and plot output map")),
                    disabled(downloadButton("downloadData", "Download result")),
                    #
                    # actual map
                    #
                    plotOutput("mapImg"),
                    #
                    # boxPlus rendering configuration
                    #
                    width = 4,
                    title = "Elaborated map", 
                    closable = FALSE, 
                    status = "info", 
                    solidHeader = FALSE, 
                    collapsible = TRUE,
                    # sidebar with info
                    enable_sidebar = TRUE,
                    sidebar_width = 25,
                    sidebar_start_open = FALSE,
                    sidebar_content = tagList(
                      tags$p("Elaborated map")
                    ),
                    style = "padding-left: 10px;padding-right: 10px;"
                  )
                #)
              )
      )
    )
  )
)
