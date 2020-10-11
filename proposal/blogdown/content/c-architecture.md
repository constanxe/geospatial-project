---
draft: false
title: System Architecture and Overview
---

![Application System Architecture and Overview](/img/architecture.png)

The main files that drive the Shiny app dashboard are as follows:
- Server.R will do the back-end rendering of the maps and information
- UI.R will showcase the functionality outputs
- Global.R lets us load the relevant libraries for the server and the UI

In between, we use the datasets to perform various forms of analysis. The core functionalities of our application is the accessibility models to see the duration and/or distance and localised geographical statistics that lets us identify the cold spot and hot spot areas. 

Users will be able to interact with our models by filtering the schools they want to look at or their residential area, and we will also provide tooltips to show additional information that may be useful for their decision-making.
