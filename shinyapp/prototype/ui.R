PAGE_TITLE <- "Junior Colleges near you"
NOTI_ITEM_STYLE <- "display: inline-block; vertical-align: middle;"


notifications <- dropdownMenu(type = "notifications", badgeStatus="primary", icon=icon("info-circle"),
                              notificationItem(icon=icon("info-circle"), status="primary",
                                               text = tags$div("Choosing the region allows you",
                                                               tags$br(),
                                                               "to narrow down your search for",
                                                               style=NOTI_ITEM_STYLE)
                              ),
                              notificationItem(icon=icon("info-circle"), status="primary",
                                               text = tags$div("Isochrone",
                                                               tags$br(),
                                                               "",
                                                               style=NOTI_ITEM_STYLE)
                              ),
                              notificationItem(icon=icon("info-circle"), status="primary",
                                               text = tags$div("Hansen Accessibility",
                                                               tags$br(),
                                                               "",
                                                               style=NOTI_ITEM_STYLE)
                              ),
                              notificationItem(icon=icon("info-circle"), status="primary",
                                               text = tags$div("Spatial Accessibility Measure (SAM)",
                                                               tags$br(),
                                                               "",
                                                               style=NOTI_ITEM_STYLE)
                              )
)


dashboardPage(title=PAGE_TITLE,
    dashboardHeader(title=div(img(src="logo.png", height = 50, align = "left", style="background-color: white;"), 
                              p(PAGE_TITLE, style="font-size:13px; font-family: 'Gill Sans MT';")),
                    notifications),
    
    dashboardSidebar(
        conditionalPanel(
            condition = "input.tabs == 'Interactive Map' || input.tabs == 'JCs in Region(s) Details'",
            selectizeInput("region", "Region(s):", unique(jc@data$REGION),
                        multiple = TRUE, options = list(
                            'plugins' = list('remove_button'),
                            'create' = TRUE,
                            'persist' = FALSE))
        ),
        conditionalPanel(
            condition = "input.tabs == 'Interactive Map'",
            selectInput("jc", "Junior College:", jc@data$SCHOOL),
            selectInput("analysis", "Analysis:", c("Duration (Isochrone)", 
                                                   "Distance (Hansen)", 
                                                   "Duration (Hansen)", 
                                                   "Distance (SAM)",
                                                   "Duration (SAM)")),
            checkboxGroupInput("schs", "Display school points:", c("Show all school points")),
            checkboxGroupInput("hdbpts", "Display HDB points:", choices=c("Show all HDB points", "Show chosen HDB point")),
            conditionalPanel(
                condition = "input.hdbpts.includes('Show chosen HDB point')",
                searchInput("postal", "Postal Code:", btnSearch = icon("search"))))
    ),
    
    dashboardBody(
        navbarPage("Information", id="tabs", collapsible=TRUE,
            tabPanel("Interactive Map", tmapOutput("mapPlot"), width = "100%", height = "100%"),
            tabPanel("JCs in Region(s) Details", DTOutput("jcTable")),
            tabPanel("HDBs Details", DTOutput("hdbTable")),
            tabPanel(verbatimTextOutput('temp'), title="temp")
        )
    )

)