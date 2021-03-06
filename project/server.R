library(shiny)
source("data_processing.R")
themes <- sort(unique(data$theme))

shinyServer(
  function(input, output) {
    output$setid <- renderText({input$setid})
    
    output$address <- renderText({
        input$goButtonAdd
        isolate(paste("http://brickset.com/sets/", 
                input$setid, sep=""))
        
    })
    
#     getPage<-function(url) {
#         return(tags$iframe(src = url, 
#                            style="width:100%;",  
#                            frameborder="0", id="iframe", 
#                            height = "500px"))
#     }
    
    openPage <- function(url) {
        return(tags$a(href=url, "Click here!", target="_blank"))
    }
    
    output$inc <- renderUI({ 
        input$goButtonDirect
        isolate(openPage(paste("http://brickset.com/sets/", 
                               input$setid, sep="")))
        ## Can't open iframe below 
        # Got This request has been blocked; 
        # the content must be served over HTTPS error msg
        # Mixed Content: The page at 'https://xiaodan.shinyapps.io/LegoDatasetVisualization/' 
        # was loaded over HTTPS, but requested an insecure resource 'http://brickset.com/sets/'. 
        # This request has been blocked; the content must be served over HTTPS.
        #isolate(getPage(paste("//brickset.com/sets/", 
        #                       input$setid, sep="")))  
    })
    
    values <- reactiveValues()
    values$themes <- themes
  
    output$themesControl <- renderUI({
        checkboxGroupInput('themes', 'LEGO Themes:', 
                           themes, selected = values$themes)
    })
    
    observe({
        if(input$selectAll == 0) return()
        values$themes <- themes
    })
    
    observe({
        if(input$clearAll == 0) return()
        values$themes <- c() # empty list
    })

    dataTable <- reactive({
        groupByTheme(data, input$timeline[1], 
                     input$timeline[2], input$pieces[1],
                     input$pieces[2], input$themes)
    })

    dataTableByYear <- reactive({
        groupByYearAgg(data, input$timeline[1], 
                    input$timeline[2], input$pieces[1],
                    input$pieces[2], input$themes)
    })

    dataTableByPiece <- reactive({
        groupByYearPiece(data, input$timeline[1], 
                       input$timeline[2], input$pieces[1],
                       input$pieces[2], input$themes)
    })

    dataTableByPieceAvg <- reactive({
        groupByPieceAvg(data, input$timeline[1], 
                        input$timeline[2], input$pieces[1],
                        input$pieces[2], input$themes)
    })

    dataTableByPieceThemeAvg <- reactive({
        groupByPieceThemeAvg(data, input$timeline[1], 
                             input$timeline[2], input$pieces[1],
                             input$pieces[2], input$themes)
    })
    
    output$dTable <- renderDataTable({
        dataTable()
    } #, options = list(bFilter = FALSE, iDisplayLength = 50)
    )
    
    output$themesByYear <- renderChart({
        plotThemesCountByYear(dataTableByYear())
    })

    output$piecesByYear <- renderChart({
        plotPiecesByYear(dataTableByPiece())
    })

    output$piecesByYearAvg <- renderChart({
        plotPiecesByYearAvg(dataTableByPieceAvg())
    })

    output$piecesByThemeAvg <- renderChart({
        plotPiecesByThemeAvg(dataTableByPieceThemeAvg())
    })
    
  } # end of function(input, output)
)