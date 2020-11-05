PAGE_TITLE <- "Junior Colleges near you"

dashboardPage(title=PAGE_TITLE,
    dashboardHeader(title=div(img(src="logo.png", height = 50, align = "left", style="background-color: white;"), 
                              p(PAGE_TITLE, style="font-size:13px; font-family: 'Gill Sans MT';"))),
    
    dashboardSidebar(
         selectizeInput("region", "Region", c("North", "South", "East", "West"),
                        multiple = TRUE, options = list(
                            'plugins' = list('remove_button'),
                            'create' = TRUE,
                            'persist' = FALSE)
         ),
         selectizeInput("jc", "Junior College(s):", c("W", "I", "P"),
                        multiple = TRUE, options = list(
                            'plugins' = list('remove_button'),
                            'create' = TRUE,
                            'persist' = FALSE)
         ),
        selectInput("analysis", "Analysis:", c("", "Hot & Cold Spot Areas (Gi*)", "Distance (Hansen Accessibility)", "Spatial Accessibility Measure (SAM)")),
        checkboxGroupInput("display", "Display:", c("Show school points", "Show HDB points"))
    ),
    
    dashboardBody(
        navbarPage("Information", collapsible=TRUE,
            tabPanel("Interactive Map", tmapOutput("tmapPlot"), width = "100%", height = "100%"),
            tabPanel("Static Map", plotOutput("mapPlot"), width = "100%", height = "100%"),
            tabPanel("JC Details", tableOutput("jcTable"))
        )
    )

)