navbarPage("title",

    tabPanel("Plot"),

    sidebarLayout(
        sidebarPanel("Display"),
        mainPanel(
            plotOutput("mapPlot"),
            tmapOutput("tmapPlot")
        )
    )

)
