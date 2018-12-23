#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
options(shiny.maxRequestSize = 30*1024^2)

shinyServer(function(input, output) {
 
  textfile <- reactive({
    textfile <- input$file1
    if (is.null(textfile)) {
     return()
    }
    return(readLines(textfile$datapath,encoding = 'UTF-8'))
  })
  
  annotate_data = reactive({
    dataset =  (textfile())
    dataset  =  str_replace_all(dataset, "<.*?>", "") # get rid of html junk
   
    annotate_data <- input$file2
    model = udpipe_load_model(annotate_data$datapath)
    
    # now annotate text dataset using ud_model above
    # system.time({   # ~ depends on corpus size
    x <- udpipe_annotate(model, x = dataset) #%>% as.data.frame() %>% head()
    x <- as.data.frame(x)
    x <- subset(x,select=-c(sentence))
    return(x)
  })
  
  output$plot = renderPlot({
    x=annotate_data()
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    data_cooc <- cooccurrence(x = subset(x, upos %in% c(input$checkGroup)),
                              term = "lemma",
                              group = c("doc_id", "paragraph_id", "sentence_id"))
    
    wordnetwork <- head(data_cooc, input$coor)
    wordnetwork <- igraph::graph_from_data_frame(wordnetwork) # needs edgelist in first 2 colms.
    
    ggraph(wordnetwork, layout = "fr") + 
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
      geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
      theme_graph(base_family = "Arial Narrow") +  
      labs(title = "Cooccurrences at Sentence Level")
    
  })
  
  output$skipplot = renderPlot({
    x=annotate_data()
    windowsFonts(devanew=windowsFont("Devanagari new normal"))
    data_cooc_skip <- cooccurrence(x$lemma, 
                                   relevant = x$upos %in% c(input$checkGroup),
                                   skipgram = input$skipgram)
                               

    wordnetwork <- head(data_cooc_skip, input$coor)
    wordnetwork <- igraph::graph_from_data_frame(wordnetwork) # needs edgelist in first 2 colms.
    
    ggraph(wordnetwork, layout = "fr") + 
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
      geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
      theme_graph(base_family = "Arial Narrow") +  
      labs(title = "Cooccurrences within skipgram words distance")
    
  })
  output$xpossummary = renderPrint({
    x=annotate_data()
    all_nouns = x %>% subset(., upos %in% c(input$checkGroup))
    top_nouns = txt_freq(all_nouns$lemma)
    # txt_freq() calcs noun freqs in desc order
    head(top_nouns, 20)
    
  })
    output$wordcloud = renderPlot({
    x=annotate_data()
    all_nouns = x %>% subset(., upos %in% c(input$checkGroup))
    top_nouns = txt_freq(all_nouns$lemma)
    wordcloud(words = top_nouns$key, 
              freq = top_nouns$freq, 
              min.freq = input$freq, 
              max.words = input$max,
              random.order = FALSE, 
              colors = brewer.pal(6, "Dark2"))
    
    })
 
  

})
