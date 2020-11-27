function(input, output, session) {

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
        readRDS(file=paste0(prefix, toupper(curr_sch_name()),'.rds')) 
    }
    iso = reactive( read_rds(dp_j_prefix) )
    hansen = reactive( read_rds(dp_h_prefix) )
    sam = reactive( read_rds(dp_s_prefix) )

    
    # conditions for show options
    sch_all_region = reactive({
        is_null(input$region) 
    })
    show_all_sch = reactive({
        !is.null(input$schs) && 
        ('Show all school points' %in% input$schs)
    })
    show_all_hdb = reactive({
        !is.null(input$hdbpts) && 
        ('Show all HDB points' %in% input$hdbpts)
    })
    show_postal = reactive({
        !is.null(input$postal) && 
        ('Show chosen HDB point' %in% input$hdbpts)
    })

    # change map type to what user selected
    observeEvent(input$maptype,{
      proxy <- leafletProxy("mapPlot") %>%
        addMapPane("maptypelayer", zIndex = 410) %>%
        addProviderTiles(input$maptype,
                         options = providerTileOptions(opacity = 0.8))
    })
    

    # save the display into tabs to be called from UI.R

    output$mapPlot <- renderLeaflet({
        leaflet() %>%
          setView(lng = 103.8198, lat = 1.3521, zoom = 11) %>%
          setMaxBounds(lng1 = 103.4057919091, lat1 = 1.1648902351, lng2 = 104.2321161335, lat2 = 1.601881499)
    })
    
    output$jcTable <- renderDT(
        {
            jc_table_data <- jc@data %>% dplyr::select(-X, -Y)
        
            # if regions selected, filter to chosen ones; else taken as all selected
            if (length(input$region) > 0) {
                jc_table_data <- jc_table_data %>% dplyr::filter(REGION %in% input$region)
            }
        
            jc_table_data
        }, options = list(lengthChange = FALSE)
    )

    output$hdbTable <- renderDT({
        hdb@data %>% dplyr::select(POSTAL, ROAD_NAME, ADDRESS)
    })
    
    output$temp <- renderPrint({
        print("")
    })

    # look at the input analysis and add the layer for the selected analysis
    observeEvent(input$analysis, {
        proxy <- leafletProxy("mapPlot")
        if (input$analysis=='Duration (Isochrone)') {
            proxy %>% addMapPane("isolayer", zIndex = 410) %>%
                addPolygons(data =iso(), stroke = TRUE, weight=0.5,
                            smoothFactor = 1, color="black", options = pathOptions(pane = "isolayer"),
                            fillOpacity = 0.8, fillColor =c('cyan','gold','tomato','red'), group = 'isolayer')
        } else {
            proxy %>% clearGroup('isolayer') 
        }
     
        if (input$analysis=='Distance (Hansen)') {
            pal <- colorFactor(
                palette = 'Blues',
                domain = hansen()@data$distanceHansen
            )
            proxy %>% clearGroup('hansendistlayer') %>% addMapPane('hansendistlayer', zIndex = 412) %>%
                addCircles(lng = hansen()@coords[,1], lat = hansen()@coords[,2], radius = sqrt(hansen()@data$distanceHansen)*10, color = pal(hansen()@data$distanceHansen), 
                           stroke = TRUE, fillOpacity = 0.8, label = lapply(hansen()@data[['hansenDistLabel']], htmltools::HTML),
                           group = 'hansendistlayer', options = pathOptions(pane = "hansendistlayer")) 
        } else {
            proxy %>% clearGroup('hansendistlayer')
        }

        if (input$analysis=='Duration (Hansen)') {
            pal <- colorFactor(
                palette = 'Purples',
                domain = hansen()@data$durationHansen
            )
            proxy %>% clearGroup('hansenduralayer') %>% addMapPane('hansenduralayer', zIndex = 412) %>%
                addCircles(lng = hansen()@coords[,1], lat = hansen()@coords[,2], radius = sqrt(hansen()@data$durationHansen)*10, color = pal(hansen()@data$durationHansen), 
                          stroke = TRUE, fillOpacity = 0.8, label = lapply(hansen()@data[['hansenDuraLabel']], htmltools::HTML),
                          group = 'hansenduralayer', options = pathOptions(pane = "hansenduralayer")) 
        } else {
            proxy %>% clearGroup('hansenduralayer')
        }
        
        if (input$analysis=='Distance (SAM)') {
            pal <- colorFactor(
                palette = 'Blues',
                domain = sam()@data$distanceSam
            )
            proxy %>% clearGroup('samdistlayer') %>% addMapPane('samdistlayer', zIndex = 412) %>%
                addCircles(lng = sam()@coords[,1], lat = sam()@coords[,2], radius = sqrt(sam()@data$distanceSam)*10, color = pal(sam()@data$distanceSam), 
                           stroke = TRUE, fillOpacity = 0.8, label = lapply(sam()@data[['samDistLabel']], htmltools::HTML),
                           group = 'samdistlayer', options = pathOptions(pane = "samdistlayer")) 
        } else {
            proxy %>% clearGroup('samdistlayer')
        }
        
        if (input$analysis=='Duration (SAM)') {
            pal <- colorFactor(
                palette = 'Purples',
                domain = sam()@data$durationSam
            )
            proxy %>% clearGroup('samduralayer') %>% addMapPane('samduralayer', zIndex = 412) %>%
                addCircles(lng = sam()@coords[,1], lat = sam()@coords[,2], radius = sqrt(sam()@data$durationSam)*10, color = pal(sam()@data$durationSam), 
                           stroke = TRUE, fillOpacity = 0.8, label = lapply(sam()@data[['samDuraLabel']], htmltools::HTML),
                           group = 'samduralayer', options = pathOptions(pane = "samduralayer")) 
        } else {
            proxy %>% clearGroup('samduralayer')
        }
    })
    
    # update selectinput based on user's region selection input
    observeEvent(input$region, {
        
        if(length(input$region) > 0) {
            updateSelectInput(session, "jc",
                              label = "Junior College",
                              choices = jc@data$SCHOOL[jc@data$REGION %in% input$region])
        }
        else if(sch_all_region()) {
          updateSelectInput(session, "jc",
                            label = "Junior College",
                            choices = jc@data$SCHOOL)
        }
    })
        

    # display all school points if checkbox is ticked
    observeEvent(input$schs, {
        proxy <- leafletProxy("mapPlot")
        
        if (show_all_sch()) {
            proxy %>% addMapPane("schlayer", zIndex = 420) %>% 
                addMarkers(lng = jc@coords[,1], lat = jc@coords[,2], 
                           popup = jc@data$ADDRESS, options = markerOptions(interactive = TRUE), clusterOptions = markerClusterOptions(),
                           data = jc@data$ADDRESS,
                           group = 'schlayer', icon = schIcon)
        } else {
            proxy %>% clearGroup('schlayer')
        }

        if (!show_postal()) {
            proxy %>% clearGroup('hdbptlayer')    
            updateSearchInput(session, "postal", value="")
        }
    })
    
    # display all hdb points if checkbox is ticked
    observeEvent(input$hdbpts, {
        proxy <- leafletProxy("mapPlot")
        
        if (show_all_hdb()) {
            proxy %>%    addMapPane("hdblayer", zIndex = 420) %>% 
                addCircleMarkers(lng = hdb@coords[,1], lat = hdb@coords[,2], 
                                 opacity = 1, fillOpacity = 1, fillColor = '#E4CD05',color = '#000', 
                                 stroke=TRUE, weight = 0.5, radius= 2, options = pathOptions(pane = "hdblayer"),
                                 popup = hdb@data$ADDRESS, label = hdb@data$ADDRESS, 
                                 data = hdb@data$ADDRESS, group = 'hdblayer')
        } else {
            proxy %>% clearGroup('hdblayer')
        }

        if (!show_postal()) {
            proxy %>% clearGroup('hdbptlayer')
            updateSearchInput(session, "postal", value="")
        }
    })
    
    # display hdb popup based on user's searchinput (look at the selected display and add the layer in if checked)
    observeEvent(input$postal, {
      proxy <- leafletProxy("mapPlot")
      
      if (show_postal()) {
        select_hdb <- hdb[hdb@data$POSTAL==input$postal, ]
        proxy %>% addMapPane("hdbptlayer", zIndex = 420) %>% 
          addPopups(lng = select_hdb@coords[,1], lat = select_hdb@coords[,2],
                    popup = select_hdb@data$ADDRESS,
                    options = popupOptions(closeButton = FALSE),
                    data = select_hdb@data$ADDRESS,
                    group = 'hdbptlayer')
      } else {
        proxy %>% clearGroup('hdbptlayer')
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
        
        if (input$analysis=='Duration (Isochrone)') {
            proxy %>% clearGroup('isolayer') %>% addMapPane("isolayer", zIndex = 410) %>%
                addPolygons(data =iso(), stroke = TRUE, weight=0.5,
                            smoothFactor = 1, color="black", options = pathOptions(pane = "isolayer"),
                            fillOpacity = 0.6, fillColor =c('cyan','gold','tomato','red'), group = 'isolayer' )
        }
        
        if (input$analysis=='Distance (Hansen)') {
            pal <- colorFactor(
                palette = 'Blues',
                domain = hansen()@data$distanceHansen
            )
            proxy %>% clearGroup('hansendistlayer') %>% addMapPane('hansendistlayer', zIndex = 412) %>%
                addCircles(lng = hansen()@coords[,1], lat = hansen()@coords[,2], radius = sqrt(hansen()@data$distanceHansen)*10, color = pal(hansen()@data$distanceHansen), 
                           stroke = TRUE, fillOpacity = 0.8, label = lapply(hansen()@data[['hansenDistLabel']], htmltools::HTML),
                           group = 'hansendistlayer', options = pathOptions(pane = "hansendistlayer")) 
        }
        
        if (input$analysis=='Duration (Hansen)') {
            pal <- colorFactor(
                palette = 'Purples',
                domain = hansen()@data$durationHansen
            )
            proxy %>% clearGroup('hansenduralayer') %>% addMapPane('hansenduralayer', zIndex = 412) %>%
                addCircles(lng = hansen()@coords[,1], lat = hansen()@coords[,2], radius = sqrt(hansen()@data$durationHansen)*10, color = pal(hansen()@data$durationHansen), 
                          stroke = TRUE, fillOpacity = 0.8, label = lapply(hansen()@data[['hansenDuraLabel']], htmltools::HTML),
                           group = 'hansenduralayer', options = pathOptions(pane = "hansenduralayer")) 
        }
        
        if (input$analysis=='Distance (SAM)') {
            pal <- colorFactor(
                palette = 'Blues',
                domain = sam()@data$distanceSam
            )
            proxy %>% clearGroup('samdistlayer') %>% addMapPane('samdistlayer', zIndex = 412) %>%
                addCircles(lng = sam()@coords[,1], lat = sam()@coords[,2], radius = sqrt(sam()@data$distanceSam)*10, color = pal(sam()@data$distanceSam), 
                           stroke = TRUE, fillOpacity = 0.8, label = lapply(sam()@data[['samDistLabel']], htmltools::HTML),
                           group = 'samdistlayer', options = pathOptions(pane = "samdistlayer")) 
        }
        
        if (input$analysis=='Duration (SAM)') {
            pal <- colorFactor(
                palette = 'Purples',
                domain = sam()@data$durationSam
            )
            proxy %>% clearGroup('samduralayer') %>% addMapPane('samduralayer', zIndex = 412) %>%
                addCircles(lng = sam()@coords[,1], lat = sam()@coords[,2], radius = sqrt(sam()@data$durationSam)*10, color = pal(sam()@data$durationSam), 
                           stroke = TRUE, fillOpacity = 0.8, label = lapply(sam()@data[['samDuraLabel']], htmltools::HTML),
                           group = 'samduralayer', options = pathOptions(pane = "samduralayer")) 
        }
        
        proxy %>% clearGroup('targetlayer') %>% addMapPane("targetlayer", zIndex = 430) %>%
            addMarkers(lng = jc@coords[curr_sch_id(),1], lat = jc@coords[curr_sch_id(),2], 
                       popup = curr_sch_name(), options = markerOptions(interactive = TRUE), clusterOptions = markerClusterOptions(), 
                       group = 'targetlayer', icon = schIcon) %>% 
            flyTo(lng = jc@coords[curr_sch_id(),1], lat = jc@coords[curr_sch_id(),2], zlevel)
    })
    
    
    # add legends for all analysis and displays
    observe({
        proxy <- leafletProxy("mapPlot")
        proxy %>% clearControls()
        if (input$analysis=='Duration (Isochrone)') {
            count = iso()@data$blocks
            proxy %>% addLegend(position="topright", colors=rev(c("lightskyblue","greenyellow","gold","orange","tomato")),
                                labels=rev(c('< 90 min', '< 60 min', '< 45 min', '< 30 min', '< 15 min')),
                                opacity = 0.8,
                                title=paste0("Travel time from public transport to ", curr_sch_name(), ' :'))
        }
        
        if (input$analysis == 'Distance (Hansen)') {
            vals = hansen()@data$distanceHansen
            colorpal <- colorBin("Blues", vals, reverse = TRUE)
            proxy %>% addLegend(position="topright", pal = colorpal, values = vals,
                                opacity = 0.8, labFormat = labelFormat(transform = function(vals) sort(vals, decreasing = TRUE)),
                                title=paste0("Hansen on DISTANCE from HDBs to ", curr_sch_name(), ' (high to low)'))
        }
        
        if (input$analysis == 'Duration (Hansen)') {
            vals = hansen()@data$durationHansen
            colorpal <- colorBin("Purples", vals, reverse = TRUE)
            proxy %>% addLegend(position="topright", pal = colorpal, values = vals,
                                opacity = 0.8, labFormat = labelFormat(transform = function(vals) sort(vals, decreasing = TRUE)),
                                title=paste0("Hansen on DURATION from HDBs to ", curr_sch_name(), ' (high to low)'))
        }
        
        if (input$analysis == 'Distance (SAM)') {
            vals = sam()@data$distanceSam
            colorpal <- colorBin("Blues", vals, reverse = TRUE)
            proxy %>% addLegend(position="topright", pal = colorpal, values = vals,
                                opacity = 0.8, labFormat = labelFormat(transform = function(vals) sort(vals, decreasing = TRUE)),
                                title=paste0("SAM Accessibility on DISTANCE from HDBs to ", curr_sch_name(), ' (high to low)'))
        }
        
        if (input$analysis == 'Duration (SAM)') {
            vals = sam()@data$durationSam
            colorpal <- colorBin("Purples", vals, reverse = TRUE)
            proxy %>% addLegend(position="topright", pal = colorpal, values = vals,
                                opacity = 0.8, labFormat = labelFormat(transform = function(vals) sort(vals, decreasing = TRUE)),
                                title=paste0("SAM Accessibility on DURATION from HDBs to ", curr_sch_name(), ' (high to low)'))
        }
        
        if (show_all_hdb()) {
            proxy %>% addLegend(position="topright", colors=rev(c('#E4CD05')),
                                labels=rev(c("HDB")),
                                opacity = 0.8)
        } else {
            proxy %>% clearGroup('hdblayer')
        }
        
        if (show_all_sch()) {
            proxy %>% addLegend(position="topright", colors=rev(c('red')),
                                labels=rev(c("school")),
                                opacity = 0.8)
        } else {
            proxy %>% clearGroup('schlayer')
        }
        
        if (!show_postal()) {
            proxy %>% clearGroup('hdbptlayer') 
            updateSearchInput(session, "postal", value="")
        }
    })

}