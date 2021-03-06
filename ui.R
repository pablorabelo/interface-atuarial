library(shiny)
library(shinydashboard)


dashboardPage(
    dashboardHeader(title = "Calculadora Atuarial",
                    tags$li(class="dropdown",tags$a(href="https://ligadecienciasatuariais.github.io/portalhalley/", icon("newspaper-o"), "", target="_blank", style='color:#100033; font-weight: bold;')),
                    tags$li(class="dropdown",tags$a(href="https://github.com/walefmachado/interface-atuarial/", icon("github"), "", target="_blank", style='color:#100033; font-weight: bold;'))#,
                    #tags$li(class="dropdown",tags$a(href="https://ligadecienciasatuariais.github.io/portalhalley/quem-somos.html", icon("github"), "Quem somos", target="_blank"))
    ), #Cabeçalho
    dashboardSidebar( #Menu Lateral

        #Inputs condicionados às abas que se encontram no corpo do código
        conditionalPanel(condition = "input.abaselecionada==1",
                         selectInput("seg", "Selecione o seguro:",choices = c("Seguro Temporário" = 1 ,"Seguro Vitalício" = 2) ,multiple = F)),

        conditionalPanel(condition = "input.abaselecionada==2",
                         selectInput("anu", "Selecione o Produto:",choices = c("Anuidade Temporária" = 1, "Anuidade Vitalícia"=2) ,multiple = F),
                         conditionalPanel(condition = "!input.diferido",
                                          checkboxInput(inputId = "df", label = "Antecipado?", value=T))),

        conditionalPanel(condition = "input.abaselecionada==3",
                         selectInput("dot", "Selecione o Produto:",choices = c("Dotal Puro" = 1, "Dotal Misto" = 2) ,multiple = F)),

        conditionalPanel(condition = "(!((input.seg == 2 && input.abaselecionada== 1) || (input.abaselecionada==2 && input.anu == 2)))", numericInput("n", "Cobertura", min = 0, max = (nrow(dados)-1), value = 1, step = 1)),
        checkboxInput(inputId = "diferido", label = "Diferido"),
        conditionalPanel(condition = "input.diferido",
                         numericInput("m", "Período de diferimento (m)", min = 0, max = (nrow(dados)-1), value = 1, step = 1)),
        #Inputs gerais, aparecem em todos os produtos
        selectInput("tab", "Selecione a tábua de vida", choices = c("AT 49M" = "AT.49_MALE", "AT 49F" = "AT.49_FEMALE", "IBGE 2006" = "IBGE_2006",
                                                                    "IBGE 2007" = "IBGE_2007", "IBGE 2008" = "IBGE_2008", "IBGE 2009" = "IBGE_2009",
                                                                    "AT 83F" = "AT.83_FEMALE_IAM", "AT 83M" = "AT.83_MALE_IAM"  ,"AT 2000M" = "AT.2000_MALE",
                                                                    "AT 2000F" = "AT.2000_FEMALE")),
        # Se a tábua at2000 for selecionada então o individuo pode escolher o sexo do participante.
        # conditionalPanel(condition = "input.tab == 3",
        #                  selectInput("sex", "Sexo:",choices = c("Masculino" = 1 ,"Feminino" = 2), multiple = F)),

        numericInput("idade", "Idade", min = 0, max = (nrow(dados)-1), value = 0, step = 1),
        numericInput("ben", "Beneficio ($)", min = 0, max = Inf, value = 1),
        numericInput("tx", "Taxa de juros", min = 0, max = 1, value = 0.06, step = 0.001 ),
        # radioButtons(inputId = "premio", label = "Prêmio", choices= c("Puro Único"=1, "Nivelado pela duração do produto"=2, "Nivelado Personalizado"=3)),
        # conditionalPanel(condition = "input.premio==3",
        #                  numericInput("npremio", "Periodo de pagamento", min = 0, max = (nrow(dados)-1), value = 1, step = 1)),
        conditionalPanel(condition = "input.abaselecionada==666", # \m/
                         checkboxInput(inputId = "fecha", label = "fecha"))#,
        #tags$img(src="github.png",width=150, align="middle")


    ),
    
    dashboardBody( #Corpo da página
        #Abas usadas para organizar a página por produtos e chamar a saída respectiva para o mesmo

        tags$head(tags$link(rel = "stylesheet",
                       type = "text/css",
                       href = "styles.css")),
        #tags$style(type="text/css",".shiny-output-error { visibility: hidden; }",".shiny-output-error:before { visibility: hidden; }"),

        fluidRow(
          tabsetPanel(type = "tab",
                      tabPanel("Seguro de Vida", icon=icon("user"),
                               box(
                                   title = "Relatório", status = "primary", #solidHeader = TRUE,
                                   collapsible = TRUE,
                                   verbatimTextOutput("segs")),value = 1
                               ),
                      tabPanel("Anuidade", icon=icon("cubes"),
                               box(
                                   title = "Relatório", status = "primary", #solidHeader = TRUE,
                                   collapsible = TRUE,
                                   #verbatimTextOutput("teste"),
                                   verbatimTextOutput("anuids")), value = 2
                               ),
                      tabPanel("Seguro Dotal", icon=icon("user-o"),
                               box(
                                   title = "Relatório", status = "primary", #solidHeader = TRUE,
                                   collapsible = TRUE,
                                   verbatimTextOutput("dots")), value = 3
                               ),
                      id = "abaselecionada"),
          
          # box(
          #   title = "Tábuas de Vida", status = "primary", #solidHeader = TRUE,
          #   collapsible = TRUE,
          #   plotlyOutput("plot"),
          #   verbatimTextOutput("event") #Saída
          #   #box(plotlyOutput("plot")),
          # ),
          conditionalPanel(condition = "input.abaselecionada==1",
                           box(
                             title = "Prêmio por idade para o seguro de vida vitalício", status = "primary", #solidHeader = TRUE,
                             collapsible = TRUE,
                             plotlyOutput("plot2")
                           )),
          conditionalPanel(condition = "input.abaselecionada==2",
                           box(
                             title = "Prêmio por idade para anuidade vitalícia", status = "primary", #solidHeader = TRUE,
                             collapsible = TRUE,
                             plotlyOutput("plot4")
                           )),
          conditionalPanel(condition = "input.abaselecionada==3",
                           box(
                             title = "Comparativo entre valores presentes atuariais e financeiros", status = "primary", #solidHeader = TRUE,
                             collapsible = TRUE,
                             plotlyOutput("plot3")
                           ))

        ),

        fluidRow(
         
          box(
            radioButtons(inputId = "premio", label = "Prêmio", choices= c("Puro Único"=1, "Nivelado pela duração do produto"=2, "Nivelado Personalizado"=3)),
            conditionalPanel(condition = "input.premio==3",
                             numericInput("npremio", "Periodo de pagamento", min = 0, max = (nrow(dados)-1), value = 1, step = 1))#,
            # conditionalPanel(condition = "input.premio!=1",
            #                  numericInput("frac", "Fracionamento do prêmio:", min = 1, max = 12*(nrow(dados)-1), value = 1, step = 1))#,
            
            # radioButtons(inputId = "carrega", label = "Opções de carregamento", choices= c("Nulo"=1, "Valor único"=2, "Valor periódico"=3)),
            # conditionalPanel(condition = "input.carrega!=1",
            #                  numericInput("charge", "$", min = 0, value = 1))
          ),
          box(
            
            title = "Fórmula de cálculo", status = "primary", collapsible = TRUE,
            conditionalPanel(condition = "input.abaselecionada==1 && input.seg==1",
                             uiOutput("not_seg_temp")),
            conditionalPanel(condition = "input.abaselecionada==1 && input.seg==2",
                             uiOutput("not_seg_vit")),
            conditionalPanel(condition = "input.abaselecionada==2 && input.anu==1",
                             conditionalPanel(condition = "input.df",
                                              uiOutput("anu_tempA")),
                             conditionalPanel(condition = "!input.df",
                                              uiOutput("anu_tempP"))
            ),
            conditionalPanel(condition = "input.abaselecionada==2 && input.anu==2",
                             conditionalPanel(condition = "input.df",
                                              uiOutput("anu_vitA")),
                             conditionalPanel(condition = "!input.df",
                                              uiOutput("anu_vitP"))
            ),
            conditionalPanel(condition = "input.abaselecionada==3 && input.dot==1",
                             uiOutput("not_seg_dot_p")),
            conditionalPanel(condition = "input.abaselecionada==3 && input.dot==2",
                             uiOutput("not_seg_dot_m")),
            "x = Idade do segurado", br(),
            "n = Período", br(),
            "m = Período de diferimento"
        )
      ),
      fluidRow(
        column(width=4),
        tags$a( href = "http://unifal-mg.edu.br/portal/",
                tags$img(src="UNIFAL-MG.png",width=150, align="middle")),
        tags$a( href = "http://unifal-mg.edu.br/lar/",
            tags$img(src="LAR.png",width=150, align="middle", style='margin-left:20px;')),
        tags$a( href = "https://lcaunifal.wordpress.com/",
            tags$img(src="LCA.png",width=150, align="middle"))#,
        # tags$a( href = "https://github.com/walefmachado/interface-atuarial/",
        #     tags$img(src="github.png",width=100, align="right"))
        
      )
        
        #,
        # box(
        #   radioButtons(inputId = "premio", label = "Prêmio", choices= c("Puro Único"=1, "Nivelado pela duração do produto"=2, "Nivelado Personalizado"=3)),
        #     conditionalPanel(condition = "input.premio==3",
        #                      numericInput("npremio", "Periodo de pagamento", min = 0, max = (nrow(dados)-1), value = 1, step = 1))
        # )
        
        #plotlyOutput("plot"), #Saída do gráfico definida pelo UI
    )
)
