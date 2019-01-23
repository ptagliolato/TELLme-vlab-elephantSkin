
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

dashboardPagePlus(
  skin = "green-light",
  collapse_sidebar = TRUE,
  dashboardHeaderPlus(
    title = tagList(
      tags$span(class = "logo-lg", "TELLme Erasmus+ Project - Hillshade"),
      tags$img(src = "http://www.get-it.it/assets/img/icon/logo1-ico.png", width = "50px", height = "50px")
    )
    # fixed = FALSE,
    # enable_rightsidebar = TRUE,
    # rightSidebarIcon = "gears",
    # tags$li(class ="dropdown", 
    #         tags$a(
    #           href="http://www.lter-europe.net",
    #           tags$img(src="http://www.get-it.it/assets/img/loghi/eLTERH2020.png"),
    #           style="margin:0;padding-top:2px;padding-bottom:2px;padding-left:10px;padding-right:10px;",
    #           target="_blank"
    #         )
    # ),
    # tags$li(class ="dropdown", 
    #         tags$a(
    #           href="http://www.lteritalia.it",
    #           tags$img(src="http://www.get-it.it/assets/img/loghi/LogoLTERIta.png"),
    #           style="margin:0;padding-top:2px;padding-bottom:2px;padding-left:10px;padding-right:10px;",
    #           target="_blank"
    #         )
    # )
  ),
  dashboardSidebar(
    collapsed = TRUE,
    sidebarMenu(
      menuItem("Elaboration", tabName = "site", icon = icon("map", lib = "font-awesome"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content: map
      tabItem(tabName = "site",
              fluidRow(
                boxPlus(
                  width = 6,
                  title = "Elaboration parameters", 
                  closable = FALSE, 
                  status = "info", 
                  solidHeader = FALSE, 
                  collapsible = TRUE,
                  enable_sidebar = TRUE,
                  sidebar_width = 25,
                  sidebar_start_open = TRUE,
                  sidebar_content = tagList(
                    tags$p("The blue circles identify the amount of datasets shared in the site, the pins identify the LTER sites distributed in the world. By clicking on one of these you can get more information on the site and on the data sets shared by it."),
                    tags$p(tags$b("Press i for collaps this slidebar."))
                  ),
                  #Input: Select a file ----
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
                              value = 45),
                  downloadLink("downloadData", "Download result"),
                  height = "650px", style = "padding-left: 10px;padding-right: 10px;"
                ),
                fluidRow(
                  boxPlus(
                    width = 6,
                    title = "Map Input", 
                    closable = FALSE, 
                    status = "info", 
                    solidHeader = FALSE, 
                    collapsible = TRUE,
                    enable_sidebar = TRUE,
                    sidebar_width = 25,
                    sidebar_start_open = FALSE,
                    sidebar_content = tagList(
                      tags$p("Through this panel it is possible to filter the sites of the LTER network, by selecting one, more information can be displayed regarding the parameters measured in it.")
                    ),
                    plotOutput("mapInput"),
                    style = "padding-left: 10px;padding-right: 10px;"
                  ),
                  boxPlus(
                    width = 6,
                    title = "Map elaborated", 
                    closable = FALSE, 
                    status = "info", 
                    solidHeader = FALSE, 
                    collapsible = TRUE,
                    enable_sidebar = TRUE,
                    sidebar_width = 25,
                    sidebar_start_open = FALSE,
                    sidebar_content = tagList(
                      tags$p("This panel show the the number of the parameter classes and their type collected in the site as squares in a grid.")
                    ),
                    plotOutput("mapImg"),
                    style = "padding-left: 10px;padding-right: 10px;"
                  )
                )
              )
      )
    )
  )
)
