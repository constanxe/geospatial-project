function(input, output) {
    output$schoolsTable <- renderTable(data_sch)

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
}
