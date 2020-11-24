function(input, output) {
    
    zoomlevel = reactive({
        input$map_zoom
    })
    
    curr_sch_id = reactive({
        which(jc@data$SCHOOL == input$jc[1], arr.ind=TRUE)
    })

    
    iso = reactive({
        schName = jc@data$SCHOOL[[curr_sch_id()]]
        iso = readRDS(file=paste0(dp_j_prefix, schName,'.rds'))
        return(iso)
    })
    
    
    output$jcTable <- renderTable(jc)

    output$mapPlot <- renderPlot({
        sp::plot(mpsz,
                 col="#cceae7",
                 border = NA)
    })

    output$tmapPlot <- renderTmap({
    tm_shape(mpsz) +
                tm_fill() +
                tm_borders(lwd = 0.1,
                        alpha = 1)
    })
    

    
    
    
    
    output$row <- renderPrint({
        schName = jc@data$SCHOOL[[curr_sch_id()]]
        #schName2 = jc@data$SCHOOL[[curr_sch_id()]]
        print(schName);
        #schName2
    })
    
    
    observeEvent(input$analysis, {
        proxy <- leafletProxy("tmapPlot")
        if (input$analysis=='Isochrone'){
            schName = jc@data$SCHOOL[[curr_sch_id()]]
            proxy %>% addMapPane("isolayer", zIndex = 410) %>% setView(lng = 103.8198, lat = 1.3521, zoom = 11) %>%
                addProviderTiles(providers$CartoDB.DarkMatter,
                                 options = providerTileOptions(opacity = 0.8))%>% 
                addPolygons(data =iso(), stroke = TRUE, weight=0.5,
                smoothFactor = 1, color="black", options = pathOptions(pane = "isolayer"),
                fillOpacity = 0.8, fillColor =c('cyan','gold','tomato','red'), group = 'isolayer' )
                
        }else{
            proxy %>% clearGroup('isolayer') 
        }
    })
    
    
    observeEvent(input$display, {
        proxy <- leafletProxy("tmapPlot")
        schName = jc@data$SCHOOL[[curr_sch_id()]]
        if (!is.null(input$display) && input$display =='Show HDB points'){
            proxy %>%  addMapPane("hdblayer", zIndex = 420) %>% 
                addCircleMarkers( lng = hdb@coords[,1], lat = hdb@coords[,2], 
                                  opacity = 1, fillOpacity = 1, fillColor = '#225A88',color = '#000', 
                                  stroke=TRUE, weight = 0.5, radius= 2, options = pathOptions(pane = "hdblayer"),
                                  popup = hdb@data$ADDRESS, label = hdb@data$ADDRESS, 
                                  data = hdb@data$ADDRESS, group = 'hdblayer')
        }
        
        else {
          proxy %>% clearGroup('hdblayer')
        }
        
        
        if (!is.null(input$display) && input$display =='Show school points'){
            proxy %>%  addMapPane("schlayer", zIndex = 420) %>% 
                addMarkers(lng = jc@coords[,1], lat = jc@coords[,2], 
                           popup = jc@data$ADDRESS, options = markerOptions(interactive = TRUE), clusterOptions = markerClusterOptions(),
                           data = jc@data$ADDRESS,
                           group = 'schlayer', icon = schIcon)
        }
        
        else{
            proxy %>% clearGroup('schlayer')
        }
    })
    
    
    
    observeEvent(input$jc, {
        
        if( is.null(zoomlevel())){
            zlevel = 12
        }else{
            zlevel = zoomlevel()
        }
        
        proxy <- leafletProxy("tmapPlot")
        schName = jc@data$SCHOOL[[curr_sch_id()]]
        
        if (input$analysis=='Isochrone'){
            proxy %>% clearGroup('isolayer') %>% addMapPane("isolayer", zIndex = 410) %>% setView(lng = 103.8198, lat = 1.3521, zoom = 11) %>%
                addProviderTiles(providers$CartoDB.DarkMatter,
                                 options = providerTileOptions(opacity = 0.8))%>% 
                addPolygons(data =iso(), stroke = TRUE, weight=0.5,
                            smoothFactor = 1, color="black", options = pathOptions(pane = "isolayer"),
                            fillOpacity = 0.6, fillColor =c('cyan','gold','tomato','red'), group = 'isolayer' )
                
        }
        
        
        proxy %>% clearGroup('targetlayer') %>% addMapPane("targetlayer", zIndex = 430) %>%
            addMarkers(lng = jc@coords[curr_sch_id(),1], lat = jc@coords[curr_sch_id(),2], 
                       popup = schName, options = markerOptions(interactive = TRUE), clusterOptions = markerClusterOptions(), 
                       group = 'targetlayer', icon = schIcon) %>% 
            flyTo(lng = jc@coords[curr_sch_id(),1], lat = jc@coords[curr_sch_id(),2], zlevel)
    })
    

    schIcon <- makeIcon(
        iconUrl = "schIcon.png",
        iconWidth = 20, iconHeight = 30,
        iconAnchorX = 10, iconAnchorY = 30,
    )
    
    
    #for the legend
    observe({
        schName = jc@data$SCHOOL[[curr_sch_id()]]
        proxy <- leafletProxy("tmapPlot")
        proxy %>% clearControls()
        if (input$analysis=='Isochrone'){
            count = iso()@data$blocks
            proxy %>% addLegend(position="topright",colors=rev(c("lightskyblue","greenyellow","gold","orange","tomato")),
                                labels=rev(c('< 90 min', '< 60 min', '< 45 min', '< 30 min', '< 15 min')),
                                opacity = 0.8,
                                title=paste0("Travel time from public transport to ", schName, ' :'))
        }
        
        if(!is.null(input$display) && input$display=='Show HDB points'){
            proxy %>%  addLegend(position="topright",colors=rev(c('navy')),
                                 labels=rev(c("HDB")),
                                 opacity = 0.8)
        }

        
    })
    
    
    
    
    
    
    
    
    
    output$tmapPlot <- renderLeaflet({
        leaflet() %>%
            setView( lng = 103.8198, lat = 1.3521, zoom = 12) %>%
            setMaxBounds( lng1 = 103.4057919091
                          , lat1 = 1.1648902351
                          , lng2 = 104.2321161335
                          , lat2 = 1.601881499) %>%
            htmlwidgets::onRender("
          function(el,x) {
              //$('.leaflet-control-zoom-in').html('<span class=\"typcn typcn-zoom-in\"></span>')
            document.title = 'Merge'R'Us'
          }
      ")
    })
    
    
}
