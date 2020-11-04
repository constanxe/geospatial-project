PAGE_TITLE <- "Find schools near you"

fluidPage(theme="simplex",
    # shinythemes::themeSelector(),

    titlePanel(
        windowTitle = PAGE_TITLE,
        title = div(
            img(src = "logo.png", height = 100, width = 100, style = "margin: 10px 10px"),
            PAGE_TITLE
        )
    ),

    sidebarLayout(
        sidebarPanel("",
             selectizeInput("region", "Region:", c("North", "South", "East", "West"),
                            multiple = TRUE, options = list(
                                'plugins' = list('remove_button'),
                                'create' = TRUE,
                                'persist' = FALSE)
             ),
             selectizeInput("jcs", "Junior College(s):", c("W", "I", "P"),
                            multiple = TRUE, options = list(
                                'plugins' = list('remove_button'),
                                'create' = TRUE,
                                'persist' = FALSE)
             ),
            selectInput("analysis", "Analysis:", c("", "Hot & Cold Spot Areas (Gi*)", "Distance (Hansen Accessibility)", "Spatial Accessibility Measure (SAM)")),
            checkboxGroupInput("display", "Display:", c("Show school points", "Show HDB points"))
        ),
        mainPanel(
            navbarPage("Information", collapsible=TRUE,
                tabPanel("Interactive Map", tmapOutput("tmapPlot"), width = "100%", height = "100%"),
                tabPanel("Static Map", plotOutput("mapPlot"), width = "100%", height = "100%"),
                tabPanel("Schools Details", tableOutput("schoolsTable"))
            )
        )
    )

)