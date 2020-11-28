function(input, output, session) {

    # JC school point markers
    schIcon <- makeIcon(
      iconUrl = "schIcon.png",
      iconWidth = 20, iconHeight = 30,
      iconAnchorX = 10, iconAnchorY = 30,
    )
  
    # zoom setting on map
    zoom_level = reactive({
        input$map_zoom
    })
    
    # look at current school selected
    curr_sch_id = reactive({
        which(jc@data$SCHOOL == input$jc, arr.ind=TRUE) 
    })
    curr_sch_name = reactive({
        jc@data$SCHOOL[[curr_sch_id()]]
    })

    # read the rds file of the school selected for the specified analysis type
    read_rds <- function(prefix) { 
        readRDS(file=paste0(prefix, toupper(curr_sch_name()),".rds")) 
    }
    iso = reactive( read_rds(dp_j_prefix) )
    hansen = reactive( read_rds(dp_h_prefix) )
    sam = reactive( read_rds(dp_s_prefix) )

    
    # conditions for show options
    show_all_sch = reactive({
        !is.null(input$schs) && 
        ("Show all JC points" %in% input$schs)
    })
    show_all_hdb = reactive({
        !is.null(input$hdbpts) && 
        ("Show all HDB points" %in% input$hdbpts)
    })
    show_postal = reactive({
        !is.null(input$postal) && 
        ("Show chosen HDB point" %in% input$hdbpts)
    })
    
    #get hansen mpsz
    
    get_hansen_mpsz <- function() { 
      acc_Hansen <- tbl_df(hansen())
      hdb_hansen<- left_join(hdb, acc_Hansen, by=c("ADDRESS"="address"))
      
      hansen_sf <- st_as_sf(hdb_hansen, crs=3414, coords=c('X', 'Y'), sf_column_name="geometry")
      hansen_svy21 <- st_transform(hansen_sf, 3414)
      
      return(st_join(hansen_svy21, mpsz, join = st_intersects))
    }
     
    
      
      #get sam mpsz
   get_sam_mpsz <- function() { 
      acc_sam <- tbl_df(sam())
      hdb_sam<- left_join(hdb, acc_sam, by=c("ADDRESS"="address"))
      
      sam_sf <- st_as_sf(hdb_sam, crs=3414, coords=c('X', 'Y'), sf_column_name="geometry")
      sam_svy21 <- st_transform(sam_sf, 3414)
      return(st_join(sam_svy21, mpsz, join = st_intersects))
      
    }
     

    # change map type to what user selected
    observeEvent(input$maptype,{
      proxy <- leafletProxy("mapPlot") %>%
        addMapPane("maptypelayer", zIndex = 410) %>%
        addProviderTiles(input$maptype, options = providerTileOptions(opacity = 0.8))
    })
    

    # save the display into tabs to be called from UI.R

    output$mapPlot <- renderLeaflet({
        leaflet() %>%
          setView(lng = 103.8198, lat = 1.3521, zoom = 11) %>%
          setMaxBounds(lng1 = 103.4057919091, lat1 = 1.1648902351, lng2 = 104.2321161335, lat2 = 1.601881499)
    })
    
    output$jcTable <- renderDT(
        {
            jc_table_data <- jc@data %>% dplyr::select(-LONGITUDE, -LATITUDE)
        
            # if regions selected, filter to chosen ones; else taken as all selected
            if (length(input$region) > 0) {
                jc_table_data <- jc_table_data %>% dplyr::filter(REGION %in% input$region)
            }
        
            jc_table_data
        }, options = list(lengthChange = FALSE)
    )

    output$hdbTable <- renderDT({
        hdb %>% dplyr::select(POSTAL, ROAD_NAME, ADDRESS)
    })
    

    output$temp <- renderPrint({
      print("")
    })
    
    observeEvent(input$metric,{
      if (input$metric == "distance"){
        hansen_mpsz<-get_hansen_mpsz()
        sam_mpsz<-get_sam_mpsz()
        
        output$hansenPlot <- renderPlot({
          ggplot(data=hansen_mpsz, 
                 aes(y =distanceHansen, 
                     x= REGION_N)) +
            geom_boxplot() +
            geom_point(stat="summary", 
                       fun.y="mean", 
                       colour ="red", 
                       size=4)
        })
        #Hansen distance plot (p-value)
        output$hansenPvaluePlot <- renderPlot({
          hansen_mpsz$log_distanceHansen <- log(hansen_mpsz$distanceHansen)
          ggbetweenstats(data = hansen_mpsz,
                         x = REGION_N,
                         y = log_distanceHansen,
                         pairwise.comparisons = TRUE,
                         p.adjust.method = "fdr",
                         title = "Hansen's accessibility (distance) values by HDB location and by Region",
                         caption = "Hansen's values"
          )
        })
        
        #sam distance plot
        output$samPlot <- renderPlot({
          ggplot(data=sam_mpsz, 
                 aes(y =distanceSam, 
                     x= REGION_N)) +
            geom_boxplot() +
            geom_point(stat="summary", 
                       fun.y="mean", 
                       colour ="red", 
                       size=4)
        })
        #sam distance plot (p-value)
        output$samPvaluePlot <- renderPlot({
          sam_mpsz$log_distanceSam <- log(sam_mpsz$distanceSam)
          ggbetweenstats(data = sam_mpsz,
                         x = REGION_N,
                         y = log_distanceSam,
                         pairwise.comparisons = TRUE,
                         p.adjust.method = "fdr",
                         title = "Sam's accessibility (distance) values by HDB location and by Region",
                         caption = "Sam's values"
          )
        })
        
      }else{
        hansen_mpsz<-get_hansen_mpsz()
        sam_mpsz<-get_sam_mpsz()
        #Hansen duration plot
        output$hansenPlot <- renderPlot({
          ggplot(data=hansen_mpsz, 
                 aes(y =durationHansen, 
                     x= REGION_N)) +
            geom_boxplot() +
            geom_point(stat="summary", 
                       fun.y="mean", 
                       colour ="red", 
                       size=4)
        })
        #Hansen duration plot (p-value)
        output$hansenPvaluePlot <- renderPlot({
          hansen_mpsz$log_durationHansen <- log(hansen_mpsz$durationHansen)
          ggbetweenstats(data = hansen_mpsz,
                         x = REGION_N,
                         y = log_durationHansen,
                         pairwise.comparisons = TRUE,
                         p.adjust.method = "fdr",
                         title = "Hansen's accessibility (duration) values by HDB location and by Region",
                         caption = "Hansen's values"
          )
          
        })
        #sam duration plot
        output$samPlot <- renderPlot({
          ggplot(data=sam_mpsz, 
                 aes(y =durationSam, 
                     x= REGION_N)) +
            geom_boxplot() +
            geom_point(stat="summary", 
                       fun.y="mean", 
                       colour ="red", 
                       size=4)
          
        })
        
        #sam duration plot (p-value)
        output$samPvaluePlot <- renderPlot({
          sam_mpsz$log_durationSam <- log(sam_mpsz$durationSam)
          ggbetweenstats(data = sam_mpsz,
                         x = REGION_N,
                         y = log_durationSam,
                         pairwise.comparisons = TRUE,
                         p.adjust.method = "fdr",
                         title = "Sam's accessibility (duration) values by HDB location and by Region",
                         caption = "Sam's values"
          )
          
        })
      }
    })

    # update selectinput based on user"s region selection input
    observeEvent(input$region, {
        if (length(input$region) > 0) {
            updateSelectInput(session, "jc", "Junior College", jc@data$SCHOOL[jc@data$REGION %in% input$region])
        } else {
            updateSelectInput(session, "jc", "Junior College", jc@data$SCHOOL)
        }
    })
    
    # display all school points if checkbox is ticked
    observeEvent(input$schs, {
        proxy <- leafletProxy("mapPlot")
        
        if (show_all_sch()) {
            proxy %>% addMapPane("schlayer", zIndex = 420) %>% 
                addMarkers(lng = jc@data$LONGITUDE, lat = jc@data$LATITUDE, 
                           data = jc@data$ADDRESS, popup = jc@data$ADDRESS, icon = schIcon, group = "schlayer", 
                           options = markerOptions(interactive = TRUE), clusterOptions = markerClusterOptions())
        } else {
            proxy %>% clearGroup("schlayer")
        }

        if (!show_postal()) {
            proxy %>% clearGroup("hdbptlayer")    
            updateSearchInput(session, "postal", value="")
        }
    })
    
    # display all hdb points if checkbox is ticked
    observeEvent(input$hdbpts, {
        proxy <- leafletProxy("mapPlot")
        
        if (show_all_hdb()) {
            proxy %>% addMapPane("hdblayer", zIndex = 420) %>% 
                addCircleMarkers(lng = hdb$LONGITUDE, lat = hdb$LATITUDE, 
                                 opacity = 0.5, fillOpacity = 0.5, fillColor = "#E4CD05", color = "#000", weight = 0.5, radius= 2,
                                 data = hdb$ADDRESS, popup = hdb$ADDRESS, label = hdb$ADDRESS, group = "hdblayer", 
                                 options = pathOptions(pane = "hdblayer"))
        } else {
            proxy %>% clearGroup("hdblayer")
        }

        if (!show_postal()) {
            proxy %>% clearGroup("hdbptlayer")
            updateSearchInput(session, "postal", value="")
        }
    })
    
    # display hdb popup based on user"s searchinput (look at the selected display and add the layer in if checked)
    observeEvent(input$postal, {
      proxy <- leafletProxy("mapPlot")
      
      if (show_postal()) {
        select_hdb <- hdb[hdb$POSTAL==input$postal, ]
        proxy %>% addMapPane("hdbptlayer", zIndex = 420) %>% 
          addPopups(lng = select_hdb$LONGITUDE, lat = select_hdb$LATITUDE,
                    data = select_hdb$ADDRESS, popup = select_hdb$ADDRESS,
                    group = "hdbptlayer", 
                    options = popupOptions(closeButton = FALSE))
      } else {
        proxy %>% clearGroup("hdbptlayer")
      }
    })
    

    # look at the input analysis and add the layer for the selected analysis
    observeEvent(input$analysis, {
        proxy <- leafletProxy("mapPlot")

        if (input$analysis=="Duration (Isochrone)") {
            layer <- "isolayer"

            proxy %>% addMapPane(layer, zIndex = 410) %>%
                addPolygons(fillOpacity = 0.8, fillColor =c("cyan","gold","tomato","red"), color="black", weight=0.5, 
                            data =iso(), group = layer, 
                            options = pathOptions(pane = layer))
        } else {
            proxy %>% clearGroup("isolayer") 
        }
     
        if (input$analysis=="Distance (Hansen)") {
            assessibility_measures_analysis_map(proxy, hansen(), "hansendistlayer", "distanceHansen", "hansenDistLabel", "Blues")
        } else {
            proxy %>% clearGroup("hansendistlayer")
        }

        if (input$analysis=="Duration (Hansen)") {
            assessibility_measures_analysis_map(proxy, hansen(), "hansenduralayer", "durationHansen", "hansenDuraLabel", "Purples")
        } else {
            proxy %>% clearGroup("hansenduralayer")
        }
        
        if (input$analysis=="Distance (SAM)") {
            assessibility_measures_analysis_map(proxy, sam(), "samdistlayer", "distanceSam", "samDistLabel", "Blues")
        } else {
            proxy %>% clearGroup("samdistlayer")
        }
        
        if (input$analysis=="Duration (SAM)") {
            assessibility_measures_analysis_map(proxy, sam(), "samduralayer", "durationSam", "samDuraLabel", "Purples")
        } else {
            proxy %>% clearGroup("samduralayer")
        }
    })

    # look at the selected jc and the various selected items and add the layers in
    observeEvent(input$jc, {
        
        if (is.null(zoom_level())) {
            zlevel = 11
        } else {
            zlevel = zoom_level()
        }
        
        proxy <- leafletProxy("mapPlot")
        
        if (input$analysis=="Duration (Isochrone)") {
            proxy %>% clearGroup("isolayer") %>% addMapPane("isolayer", zIndex = 410) %>%
                addPolygons(fillOpacity = 0.6, fillColor =c("cyan","gold","tomato","red"), color="black", weight=0.5, 
                            data =iso(), group = "isolayer", 
                            options = pathOptions(pane = "isolayer"))
        }

        if (input$analysis=="Distance (Hansen)") {
            assessibility_measures_analysis_map(proxy, hansen(), "hansendistlayer", "distanceHansen", "hansenDistLabel", "Blues")
        }
        if (input$analysis=="Duration (Hansen)") {
            assessibility_measures_analysis_map(proxy, hansen(), "hansenduralayer", "durationHansen", "hansenDuraLabel", "Purples")
        }
        if (input$analysis=="Distance (SAM)") {
            assessibility_measures_analysis_map(proxy, sam(), "samdistlayer", "distanceSam", "samDistLabel", "Blues")
        }
        if (input$analysis=="Duration (SAM)") {
            assessibility_measures_analysis_map(proxy, sam(), "samduralayer", "durationSam", "samDuraLabel", "Purples")
        }

        proxy %>% clearGroup("targetlayer") %>% addMapPane("targetlayer", zIndex = 430) %>%
            addMarkers(lng = jc@data$LONGITUDE[curr_sch_id()], lat = jc@data$LATITUDE[curr_sch_id()], 
                       popup = curr_sch_name(), icon = schIcon, group = "targetlayer", 
                       options = markerOptions(interactive = TRUE), clusterOptions = markerClusterOptions()) %>% 
            flyTo(lng = jc@data$LONGITUDE[curr_sch_id()], lat = jc@data$LATITUDE[curr_sch_id()], zlevel)
    })
    
    # function for the above
    assessibility_measures_analysis_map <- function(proxy, rds, layer, column, lab, color) {
        domain <- rds@data[[column]]
        pal <- colorFactor(color, domain)
        proxy %>% addMapPane(layer, zIndex = 412) %>%
            addCircles(lng = rds@coords[,1], lat = rds@coords[,2], 
                        fillOpacity = 0.8, label = lapply(rds@data[[lab]], htmltools::HTML), color = pal(domain), 
                        group = layer, radius = sqrt(domain)*10, 
                        options = pathOptions(pane = layer)) 
    }

    # function for the below
    assessibility_measures_analysis_legend <- function(proxy, rds, column, lab, color) {
        domain <- rds@data[[column]]
        colorpal <- colorBin(color, domain, reverse = TRUE)
        proxy %>% addLegend(title=paste0(lab, curr_sch_name()), position="topright", pal = colorpal, values = domain, 
                            labFormat=labelFormat(transform = function(domain) sort(domain, decreasing = TRUE)), opacity = 0.8)
    }

    # add legends for all analysis and displays
    observe({
        proxy <- leafletProxy("mapPlot")
        proxy %>% clearControls()

        if (input$analysis=="Duration (Isochrone)") {
            count = iso()@data$blocks
            proxy %>% addLegend(title=paste0("Duration from ", curr_sch_name()), position="topright", colors=rev(c("lightskyblue","greenyellow","gold","orange","tomato")),
                                labels=rev(c("< 90 min", "< 60 min", "< 45 min", "< 30 min", "< 15 min")), opacity = 0.8)
        }
        
        if (input$analysis == "Distance (Hansen)") {
            assessibility_measures_analysis_legend(proxy, hansen(), "distanceHansen", "Distance using Hansen from ", "Blues")
        }
        if (input$analysis == "Duration (Hansen)") {
            assessibility_measures_analysis_legend(proxy, hansen(), "durationHansen", "Duration using Hansen from ", "Purples")
        }
        if (input$analysis == "Distance (SAM)") {
            assessibility_measures_analysis_legend(proxy, sam(), "distanceSam", "Distance using SAM from ", "Blues")
        }
        if (input$analysis == "Duration (SAM)") {
            assessibility_measures_analysis_legend(proxy, hansen(), "durationSam", "Duration using SAM from ", "Purples")
        }
        
        if (show_all_hdb()) {
            proxy %>% addLegend(position="topright", colors=rev(c("#E4CD05")), 
                                labels=rev(c("HDB")), opacity = 0.8)
        } else {
            proxy %>% clearGroup("hdblayer")
        }
        
        if (show_all_sch()) {
            proxy %>% addLegend(position="topright", colors=rev(c("black")), 
                                labels=rev(c("school")), opacity = 0.8)
        } else {
            proxy %>% clearGroup("schlayer")
        }
        
        if (!show_postal()) {
            proxy %>% clearGroup("hdbptlayer") 
            updateSearchInput(session, "postal", value="")
        }
    })

}