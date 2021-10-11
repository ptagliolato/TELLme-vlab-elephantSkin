library(shiny)
#library(osmdata)
library(sf)
library(sp)
library(leaflet)
library(leaflet.extras)


bbxSelectorUI <- function(id, label = "select bounding box", height=400) {
  ns <- NS(id)
  
  tagList(
    leafletOutput(ns("mapleaflet"), height=height)
    #,
    # column(width = 3, style = "text-align:left", disabled(textInput(
    #   ns("bbxN"), "NW-lat"
    # ))),
    # column(width = 3, style = "text-align:left", disabled(textInput(
    #   ns("bbxW"), "NW-lon"
    # ))),
    # column(width = 3, style = "text-align:left", disabled(textInput(
    #   ns("bbxS"), "SE-lat"
    # ))),
    # column(width = 3, style = "text-align:left", disabled(textInput(
    #   ns("bbxE"), "SE-lon"
    # ))),
    # column(width = 12, div(style = "visibility:hidden", textOutput(ns(
    #   "bbx"
    # ))))
  )
  
}

bbxSelector <- function(input, output, session, reactiveToClearTheMap) {
  
  
  output$mapleaflet <- renderLeaflet({
    leaflet() %>% addTiles(group="OpenStreetMap") %>%
      addProviderTiles(providers$CartoDB.Positron, group="CartoDB") %>%
      setView(0, 0, 1) %>%  addSearchOSM() %>%
      addDrawToolbar(
        targetGroup = "draw",
        polylineOptions = FALSE,
        markerOptions = FALSE,
        circleOptions = FALSE,
        circleMarkerOptions = FALSE,
        polygonOptions = FALSE,
        rectangleOptions = drawRectangleOptions(shapeOptions = drawShapeOptions(
          fillOpacity = 0,
          color = 'white',
          weight = 3
        )),
        singleFeature = TRUE
      )%>%
      addLayersControl(baseGroups=c("OpenStreetMap","CartoDB"))
    
  })
  
  # RV reactive values. It contains the slots "layers" (list of downloaded layers - sp objects)
  # and a boolean flag "layersPresent" indicating if layers are already present in the layers list slot.
  RV <-
    reactiveValues(layers = list(),
                   layersPresent = FALSE,
                   queries = list())
  
  
  # # download button is enabled according to RV$layersPresent boolean value
  # observe({
  #   if (RV$layersPresent) {
  #     enable("downloadShapeFiles")
  #   }
  #   else{
  #     disable("downloadShapeFiles")
  #   }
  # })
  
  # BOUNDING BOX
  {
    # BBX reactive values. It contains "N" "S" "E" "W" slots.
    BBX <- reactiveValues(N = NULL,
                          S = NULL,
                          E = NULL,
                          W = NULL)
    
    # bbx reactive. It returns the concatenation (array) of BBX slots.
    # [the following is lazy and cached. It is reactive: it is notified when its dependencies change]
    bbx <- reactive({
      # it is the same to explicitly return the value:
      # return(c(BBX$W, BBX$S, BBX$E, BBX$N))
      # or to simply end the expression with:
      c(BBX$W, BBX$S, BBX$E, BBX$N)
    })
    
    bbx_df<-reactive({
      xmin=as.numeric(BBX$W)
      xmax=as.numeric(BBX$E)
      ymin=as.numeric(BBX$S)
      ymax=as.numeric(BBX$N)
      return(data.frame(x=c(xmin,xmax),y=c(ymin,ymax)))
    })
    
    crs_string<-reactive({
      bbox_dfl<-bbx_df()
      st_crs(st_sfc(st_point(as.numeric(bbox_dfl[1,])), st_point(as.numeric(bbox_dfl[2,])), crs=4326))$proj4string
    })
    
    
    # concatenation of bbx with "_" separator
    bbx_concat <- reactive({
      paste(bbx(), sep = "_", collapse = "_")
    })
    
    # # print bounding box bbx (reactive) in label
    # output$bbx <- renderText({
    #   bbx()
    # })
    
    # intercept new bounding box drawn by the user and store it in BBX reactive values
    # (note: its within the pattern: observer->no return value, but side effects)
    observeEvent(input$mapleaflet_draw_new_feature, {
      shape <- input$mapleaflet_draw_new_feature
      
      polygon_coordinates <- shape$geometry$coordinates
      
      feature_type <- shape$properties$feature_type
      if (feature_type == "rectangle") {
        NW = polygon_coordinates[[1]][[2]]
        SE = polygon_coordinates[[1]][[4]]
        
        BBX$N <- paste(NW[[2]])
        BBX$W <- paste(NW[[1]])
        BBX$S <- paste(SE[[2]])
        BBX$E <- paste(SE[[1]])
      }
    })
    
    # # print bbx components in TextInput elements
    # # (also here there is an antipattern, maybe?
    # # It would be more appropriate to use html output elements instead of input.. wouldn't it?)
    # # TODO (?): let the user change the bbx through these inputs. The issue here is to synchronize the leaflet map bbx visualization.
    # observe({
    #   updateTextInput(session, "bbxN", value = BBX$N)
    #   updateTextInput(session, "bbxW", value = BBX$W)
    #   updateTextInput(session, "bbxS", value = BBX$S)
    #   updateTextInput(session, "bbxE", value = BBX$E)
    # })
    
    
  }
  
  proxymap<-reactive({leafletProxy("mapleaflet")})
  
  # RESET LAYERS
  # reset the layers (in the map and in the RV layers slot) when bbx() changes 
  {
    clearTheMap<-function(){
      cat("bbxSelector - ClearTheMap\n")
      proxy <- proxymap()#leafletProxy("mapleaflet")
      clearShapes(proxy)
      clearImages(proxy)
      RV$layers = list()
      RV$layersPresent = FALSE
      proxy %>% addLayersControl(baseGroups=c("OpenStreetMap","CartoDB"))
      #%>% leaflet::removeLayersControl()
    }
    
    observeEvent(bbx(), {
      clearTheMap()
    })
    
    # ...any other observeEvent=>reset layers needed? 
    #  is there any way to reset layers even from the including app?
    observeEvent(reactiveToClearTheMap(),{
      req(proxymap())
      cat("bbxSelector: triggered reactiveToClearTheMap")
      clearTheMap()
    }, ignoreInit = TRUE)
    
  }
  
  
  return(list("bbx"=bbx,
              "proxymap"=proxymap, 
              "bbx_df"=bbx_df, 
              "crs_string"=crs_string))
  
  # NOTE: When invoking the module, accessing the return values
  # must be done like:
  # bbxSelector1$bbx()
  # bbxSelector1$proxymap()
  # i.e. access the list element as reactive, NOT the list as a reactive!!
  
}
