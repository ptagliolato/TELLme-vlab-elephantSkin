
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
# cf. https://www.gdal.org/gdaldem.html
library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("TELLme Erasmus+ Project - Hillshade"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      # Input: Select a file ----
      fileInput("file1", "Choose First File",
                multiple = FALSE,
                accept = c("*/*",
                           "*,*",
                           ".*")),
      
      selectInput("mode", "choose mode", 
                  choices = list("hillshade" = "hillshade", 
                                 "slope" = "slope",
                                 "aspect" = "aspect",
                                 "color-relief"= "color-relief",
                                 "TRI"="TRI",
                                 "TPI"="TPI",
                                 "roughness"="roughness")),
      
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
                  value = 45)
      ,downloadLink("downloadData", "Download result")
      ),
    

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("mapInput"),
      plotOutput("mapImg")
    )
  )
))
