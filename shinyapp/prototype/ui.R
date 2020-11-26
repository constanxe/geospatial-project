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
        selectizeInput("region", "Region(s):", c("North", "North-East", "East", "West", "Central"),
                    multiple = TRUE, options = list(
                        'plugins' = list('remove_button'),
                        'create' = TRUE,
                        'persist' = FALSE)
        ),
        selectInput("jc", "Junior College:", rapportools::tocamel(tolower(jc@data$SCHOOL), upper=TRUE, sep=" ")),
        selectInput("analysis", "Analysis:", c("Duration (Isochrone)", 
                                               "Distance (Hansen)", 
                                               "Duration (Hansen)", 
                                               "Distance (SAM)",
                                               "Duration (SAM)")),
        searchInput("postal", "Postal Code:"),
        checkboxGroupInput("display", "Display:", c("Show school points", "Show HDB points"))
    ),
    
    dashboardBody(
        navbarPage("Information", collapsible=TRUE,
            tabPanel("Interactive Map", tmapOutput("mapPlot"), width = "100%", height = "100%"),
            tabPanel("JC Details", DTOutput("jcTable")),
            tabPanel(verbatimTextOutput('temp'), title="temp")
        )
    )

)

