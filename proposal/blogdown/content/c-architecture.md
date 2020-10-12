---
draft: false
title: Application System Architecture & Overview
---

![Application System Architecture and Overview](/img/architecture-overview.png)

The main files driving the Shiny app dashboard that the user interacts with are as follows:
- UI.R is supported by the server for rendering information, and will showcase the functionality outputs on the maps. Users can further interact with the models by filtering the schools they want to look at, and there will be point markings, tooltips and legends provided to show additional information that may be useful.
- Server.R will do the back-end work, generating the information from the models. The core functionalities of our application is the accessibility models to see the duration and/or distance and localised geographical statistics that lets us identify the cold spot and hot spot areas.
- Global.R lets us load the relevant libraries and datasets for the server and the UI, which allow us to perform various forms of analysis.
