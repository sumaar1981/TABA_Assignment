#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny)
library(text2vec)
library(tm)
library(tokenizers)
library(wordcloud)
library(slam)
library(stringi)
library(magrittr)
library(tidytext)
library(dplyr)
library(tidyr)
library(stringr)
library(udpipe)
library(textrank)
library(lattice)
library(igraph)
library(ggraph)
library(ggplot2)




shinyUI(
  fluidPage(
    
    titlePanel("NLP using Udpipe"),
    sidebarLayout(
      sidebarPanel(  
        
        fileInput("file1", "Upload data (Text file)"),
                    multiple = FALSE,
                    accept = c("text/csv",
                   "text/comma-separated-values,text/plain", ".csv"),
        fileInput("file2", "Upload udpipe model"),
                  multiple = FALSE,
                  accept = c(".udpipe"),  
        checkboxGroupInput("checkGroup", "XPOS", 
                         c("Adjective (JJ)" = "ADJ", "Noun(NN)" = "NOUN", 
                           "Proper Noun (NNP)" = "PROPN","Adverb (RB)" = "ADV", 
                           "Verb (VB)" = "VERB"), selected = c("ADJ","NOUN","PROPN")),
        sliderInput("freq", "Minimum Frequency in Wordcloud:", min = 0,  max = 100, value = 2),
        
        sliderInput("max",  "Maximum Number of Words in Wordcloud:", min = 1,  max = 300,  value = 50),
        sliderInput("coor",  "Maximum Number of co-occurences:", min = 1,  max = 100,  value = 50),
        sliderInput("skipgram",  "Maximum Number of skipgram words:", min = 1,  max = 10,  value = 4)
        ),
      
     
      mainPanel(
        
        tabsetPanel(type = "tabs",
                    tabPanel("Overview",h4(p("Data input")),
                             p("This app supports input as text file.",align="justify"),
                             p("Please refer to the link below for sample input file."),
                             a(href="https://github.com/sudhir-voleti/sample-data-sets/blob/master/Segmentation%20Discriminant%20and%20targeting%20data/ConneCtorPDASegmentation.csv"
                               ,"Sample data input file"),   
                             br(),br(),
                             p("You also need to provide udpipe model as second input.",align="justify"),
                             h4('How to use this App'),
                             p('To use this app, click on', 
                               span(strong("Upload data (Text file)")),
                               'and upload data file. Also upload the udpipe model(English,Spanish or Hindi etc) as second input depending on text language.
                               Once both the files are uploaded, app will do computations with default inputs and
                               will display Co-occurance Plots and Word cloud in respective tabs.',
                              br(),
                               'Below options are given in left side panel to change inputs as per your requirement.',
                              br(),
                               '- XPOS to choose feature',
                              br(),
                               '- select minimum frequency of word to display in word cloud',
                              br(),
                               '- select maximum number of words to display in word cloud',
                              br(),
                               '- select maximum number of co-occurances  to display in both co-occurances plots',
                              br(),
                               '- select number of skipgrams to consider for co-occurance plot at corpus level. Skipgram 1 will
                                  display words following each other at corpus level'
                               )),
                    
                    tabPanel("Co-occurence plot", 
                             plotOutput("plot"),
                             br(),
                             br(),
                             plotOutput("skipplot")
                             ),
                    tabPanel("Frequency and Word Cloud", 
                             h4("Top 20 Words"),
                             verbatimTextOutput("xpossummary"),
                             br(),
                             h4("Word Cloud"),
                             plotOutput("wordcloud",height = 700, width = 700))
                    
        ) # end of tabsetPanel  
      )# end of main panel
    ) # end of sidebarLayout
  ) # end of fluidPage
) # end of UI


