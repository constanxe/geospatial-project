# R Packages
library("shinydashboard")
library("shiny")
library("shinyWidgets")
library("DT")
library("leaflet")
library("tidyverse")
library("knitr")
library("sp")
library("sf")
library("rgdal")
library("tmap")
library("ggstatsplot")
library("plotly")

PAGE_TITLE <- "Merge'R'Us: JCs Near You"
NOTI_ITEM_STYLE <- "display: inline-block; vertical-align: top;"

NOTIFICATIONS <- dropdownMenu(type = "notifications", badgeStatus="primary", icon=icon("info-circle"),
                              notificationItem(icon=icon("info-circle"), status="primary",
                                               text = tags$div(tags$b("Using the map:"),
                                                               tags$br(),
                                                               
                                                               "Only 1 chosen ", tags$u("Junior College (JC)"),"& ", 
                                                               tags$br(),
                                                               tags$u("analysis type"), " are used at any point.",
                                                               tags$br(), tags$br(),
                                                               
                                                               "To narrow down the list of JCs you", 
                                                               tags$br(),
                                                               "have to choose from, you may", 
                                                               tags$br(),
                                                               "indicate specific ", tags$u("regions"), "you want",
                                                               tags$br(),
                                                               "to focus on. Otherwise, all JCs are",
                                                               tags$br(),
                                                               " listed in the JC dropdown after it.",
                                                               
                                                               style=NOTI_ITEM_STYLE)),
                              notificationItem(icon=icon("info-circle"), status="primary",
                                               text = tags$div(tags$b("Analysis types:"),
                                                               tags$br(),
                                                               
                                                               "The following methods measure",
                                                               tags$br(),
                                                               "the accessibility of the JC to HDB",
                                                               tags$br(),
                                                               "points based on different metrics.",
                                                               tags$br(),
                                                               tags$br(),
                                                               
                                                               tags$u("Isochrone:"), "based on how long it",
                                                               tags$br(),
                                                               "takes to travel from a certain point",
                                                               tags$br(),
                                                               "to the JC. The shorter the duration,",
                                                               tags$br(),
                                                               "the higher the accessibility.",
                                                               tags$br(),
                                                               tags$br(),
                                                               
                                                               tags$u("Hansen Accessibility (Hansen):"),
                                                               tags$br(),
                                                               "potential that a person is willing",
                                                               tags$br(),
                                                               "to travel to the JC based on the",
                                                               tags$br(),
                                                               "distance and duration from the",
                                                               tags$br(),
                                                               "HDB point. The higher the Hansen",
                                                               tags$br(),
                                                               "value, the higher the accessibility.",
                                                               tags$br(),
                                                               tags$br(),
                                                               
                                                               tags$u("Spatial Accessibility Measure (SAM):"), 
                                                               tags$br(),
                                                               "considers population of HDB points",
                                                               tags$br(),
                                                               "& supply of a JC. Accessibility rises",
                                                               tags$br(),
                                                               "with higher population nearby and",
                                                               tags$br(),
                                                               "supply falls with longer distance or",
                                                               tags$br(),
                                                               "time from the HDB point to the JC.",
                                                               tags$br(),
                                                               "The higher the value of SAM, the",
                                                               tags$br(),
                                                               "higher the accessibility.",
                                                               
                                                               style=NOTI_ITEM_STYLE)),
                              notificationItem(icon=icon("info-circle"), status="primary",
                                               text = tags$div(tags$b("Option to display other points:"),
                                                               tags$br(),
                                                               
                                                               "Tick the respective checkboxes to",
                                                               tags$br(),
                                                               
                                                               "show all JC or HDB points as well.",
                                                               tags$br(),
                                                               tags$br(),
                                                               
                                                               tags$u("JC points:"), " clusters showing no. of",
                                                               tags$br(),
                                                               "JCs in that area & other JC points.",
                                                               tags$br(),
                                                               "This allows easier comparison of",
                                                               tags$br(),
                                                               "accessibility. On zoom, some points",
                                                               tags$br(),
                                                               "accounted by a cluster are revealed.",
                                                               tags$br(),
                                                               tags$br(),
                                                               
                                                               tags$u("HDB points:"), "all or the tooltip of",
                                                               tags$br(),
                                                               "a specific one that coincides with a",
                                                               tags$br(),
                                                               "valid postal code that you may input",
                                                               tags$br(),
                                                               "after clicking the relevant checkbox.",
                                                               tags$br(),
                                                               "You may use 'HDB Details' tab to find",
                                                               tags$br(),
                                                               "the postal code for an address.",
                                                               
                                                               style=NOTI_ITEM_STYLE))
)

dashboardPage(title=PAGE_TITLE,
              dashboardHeader(title=div(img(src="logo.png", height = 50, align = "left", style="background-color: white;"), 
                                        p(PAGE_TITLE, style="font-size:13px; font-family: 'Gill Sans MT';")), NOTIFICATIONS),
              dashboardSidebar(
                  conditionalPanel(
                      condition = "input.tabs == 'Accessibility Boxplots' || input.tabs == 'JCs EDA'",
                      selectInput("metric", "Metric:", c("Distance", "Duration"))),
                  conditionalPanel(
                      condition = "input.tabs == 'JCs EDA'",
                      checkboxGroupInput("eda", "Display JC Distribution:", c("Show Overall JC Distribution", "Show Chosen JC Distribution"), c("Show Overall JC Distribution"))),
                  conditionalPanel(
                      condition = "input.tabs == 'Interactive Map' || input.tabs == 'Accessibility Boxplots' || input.tabs == 'JCs Details' || (input.tabs == 'JCs EDA' && input.eda.includes('Show Chosen JC Distribution'))",
                      selectizeInput("region", "Filter Region(s):", unique(jc@data$REGION),
                                     multiple = TRUE, options = list(
                                        "plugins" = list("remove_button"),
                                        "create" = TRUE,
                                        "persist" = FALSE))),
                  conditionalPanel(
                      condition = "input.tabs == 'Interactive Map' || input.tabs == 'Accessibility Boxplots' || (input.tabs == 'JCs EDA' && input.eda.includes('Show Chosen JC Distribution'))",
                      selectInput("jc", "Junior College:", jc@data$SCHOOL)),
                  
                  conditionalPanel(
                      condition = "input.tabs == 'Interactive Map'",
                      selectInput("analysis", "Analysis:", c("Duration (Isochrone)", 
                                                             "Distance (Hansen)", 
                                                             "Duration (Hansen)", 
                                                             "Distance (SAM)",
                                                             "Duration (SAM)")),
                      checkboxGroupInput("schs", "Display JC points:", c("Show all JC points")),
                      checkboxGroupInput("hdbpts", "Display HDB points:", c("Show all HDB points", "Show chosen HDB point")),
                      conditionalPanel(
                          condition = "input.hdbpts.includes('Show chosen HDB point')",
                          searchInput("postal", "Postal Code:", btnSearch = icon("search"))),
                      selectInput("maptype", "Map Theme:", names(providers)))
              ),
              
              dashboardBody(
                  navbarPage("Explore", id="tabs", collapsible=TRUE,
                             tabPanel("Interactive Map", tmapOutput("mapPlot"), width = "100%", height = "100%"),
                             tabPanel("Accessibility Boxplots", 
                                      fluidRow(
                                          box(title="Hansen Boxplot", collapsible = TRUE,
                                              plotOutput("hansenPlot")),
                                          box(title="Hansen p-value Boxplot", collapsible = TRUE,
                                              plotOutput("hansenPvaluePlot")),
                                          box(title="SAM Boxplot", collapsible = TRUE,
                                              plotOutput("samPlot")),
                                          box(title="SAM p-value Boxplot", collapsible = TRUE,
                                              plotOutput("samPvaluePlot"))
                             )),
                             tabPanel("JCs EDA", 
                                      fluidRow(
                                          conditionalPanel(
                                              condition = "input.eda.includes('Show Overall JC Distribution')",
                                              box(width=12,
                                                  plotOutput("overallPlot"))),
                                          conditionalPanel(
                                              condition = "input.eda.includes('Show Chosen JC Distribution')",
                                              box(width=12,
                                                  plotlyOutput("schPlot")))
                             )),
                             tabPanel("JCs Details", DTOutput("jcTable")),
                             tabPanel("HDBs Details", DTOutput("hdbTable")),
                             tabPanel(verbatimTextOutput("temp"), title="")))
)