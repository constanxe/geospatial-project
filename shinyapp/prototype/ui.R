PAGE_TITLE <- "Junior Colleges near you"

dashboardPage(title=PAGE_TITLE,
    dashboardHeader(title=div(img(src="logo.png", height = 50, align = "left", style="background-color: white;"), 
                              p(PAGE_TITLE, style="font-size:13px; font-family: 'Gill Sans MT';"))),
    
    dashboardSidebar(
        selectizeInput("region", "Region(s):", c("North", "South", "East", "West"),
                    multiple = TRUE, options = list(
                        'plugins' = list('remove_button'),
                        'create' = TRUE,
                        'persist' = FALSE)
        ),
        selectInput("jc", "Junior College:", jc@data$SCHOOL),
        selectInput("analysis", "Analysis:", c("Duration (Isochrone)", 
                                               "Distance & Duration (Hansen Accessibility)", 
                                               "Distance & Duration (Spatial Accessibility Measure)")),
        checkboxGroupInput("display", "Display:", c("Show school points", "Show HDB points"))
    ),
    
    dashboardBody(
        navbarPage("Information", collapsible=TRUE,
            tabPanel("Interactive Map", tmapOutput("mapPlot"), width = "100%", height = "100%"),
            tabPanel("JC Details", DTOutput("jcTable"))
        )
    )

)

