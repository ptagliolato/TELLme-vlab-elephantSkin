
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

choices <- list("hillshade" = "hillshade",
                #"slope" = "slope",
                "aspect" = "aspect",
                #"color-relief"= "color-relief",
                #"TRI"="TRI",
                "TPI"="TPI"
                #"roughness"="roughness"
)

dashboardPagePlus(
  
  skin = "black-light",
  collapse_sidebar = TRUE,
  dashboardHeaderPlus(
    title = tagList(
      
      tags$span(class = "logo-lg", "TELLme Erasmus+ Project - Elephant Skin (Hillshade)"),
      #tags$img(src = "http://www.get-it.it/assets/img/icon/logo1-ico.png", width = "50px", height = "50px"),
      tags$img(src = "http://tellmehub.get-it.it/static/img/logo1_200px.png", width = "80px", height = "40px")
    ),
    titleWidth = 400
    # fixed = FALSE,
    ,enable_rightsidebar = TRUE,
     rightSidebarIcon = "gears"
  ),
  rightsidebar=rightSidebar(
    
    selectInput("mode", "choose mode",choices = choices),
    sliderInput("z","Vertical exaggeration",min = 1,max = 50,value = 1),
    sliderInput("az","Azimuth of the light",min = 1,max = 360,value = 315),
    sliderInput("alt","Altitude of the light",min = 0,max = 90,value = 45)
  ),
  sidebar=dashboardSidebar(
    collapsed = TRUE,
    disable = FALSE,
    width = 200,
    sidebarMenu(
      menuItem("Elaboration", tabName = "site", icon = icon("map", lib = "font-awesome")),
      menuItem("Map", tabName = "map", icon = icon("map", lib = "font-awesome"))
    )
  ),
  
  body=dashboardBody(
    useShinyjs(),
    tabItems(
      tabItem(
        tabName = "site",
        
        # fluidRow(
        #   boxPlus(# processing parameters
        #     width = 12, # bootstrap grid system (12 columns total)
        #     title = "Elaboration parameters", 
        #     closable = FALSE, status = "info", solidHeader = FALSE, collapsible = TRUE,
        #     enable_sidebar = TRUE,sidebar_width = 25,sidebar_start_open = FALSE,
        #     sidebar_content = tagList(
        #       tags$p("Upload a Digital Elevation Model (DEM) raster file (.tif), then tune the parameters to adjust the 'Elephant Skin' (Hillshade) map according to your needs"),
        #       #tags$p("Default par"),
        #       tags$p(tags$b("Press i to collapse this slidebar."))
        #     ),
        #     style = "padding-left: 10px;padding-right: 10px;"
        #     #--- contents ---
        #     # ,fileInput("file1", "Choose Digital Elevation Model File (raster image)",
        #     #           multiple = FALSE, accept = c("*/*","*,*",".*"),width="30%"),
        #     # selectInput("mode", "choose mode",choices = choices, width="30%"),
        #     # sliderInput("z","Vertical exaggeration",min = 1,max = 50,value = 1),
        #     # sliderInput("az","Azimuth of the light",min = 1,max = 360,value = 315),
        #     # sliderInput("alt","Altitude of the light",min = 0,max = 90,value = 45)
        #   )),
        
        fluidRow(
          boxPlus(width = 12,collapsible = TRUE,
                  title="commands",
                  box(width=4, 
                         fileInput("file1", "Choose Digital Elevation Model File (raster image)",
                                            multiple = FALSE, accept = c("*/*","*,*",".*"))),
                  box(width=4, 
                         disabled(actionButton("doPlotMap","-> Compute and plot output map ->", style="margin-bottom:15px;display:block;margin:26px 0 15px 0;"))),
                  box(width=4,
                      disabled(downloadButton("downloadData", "Download result")))
          )
        ),
        fluidRow(
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
              # --- contents ---
              
              plotOutput("mapImg")
            )
            
        )#end fluidRow
      )#end tabItem
    )#end tabItems
  )#end dashboardBody
)
