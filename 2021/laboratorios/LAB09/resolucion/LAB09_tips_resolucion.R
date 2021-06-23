################################################################
##### Recuperamos todas las letras de canciones en español #####
################################################################

library(mongolite)
conx_lyrics_spa = mongo(collection = "lyrics_spanish", db = "DMUBA_SPOTIFY")
df_lyrics = conx_lyrics_spa$find('{}')

# eliminamos las conexión dado que no la vamos a usar
rm(conx_lyrics_spa)

#####################################################
############### Generación del corpus ###############
#####################################################

df2corpus.pro <-function(data, pro.genius=TRUE, pro.symbols=TRUE, 
                         pro.stopwords=TRUE, idioma_stopwords = "spanish",
                         pro.min=TRUE, pro.num=TRUE, pro.accents=TRUE,
                         pro.spaces=TRUE, pro.stemm=TRUE) {
  
  library(tm)
  library(stringi)
  library(stringr)
  library(SnowballC) # para Stemming
  
  corpus = Corpus(VectorSource(enc2utf8(data)))
  
  if(pro.genius){
    # Elimino todo lo que aparece antes del primer []
    corpus.pro <- tm_map(corpus, content_transformer(
      function(x) sub('^.+?\\[.*?\\]',"", x)))
    
    # Elimino las aclaraciones en las canciones, por ejemplo:
    # [Verso 1: Luis Fonsi & Daddy Yankee]
    corpus.pro <- tm_map(corpus.pro, content_transformer(
      function(x) gsub('\\[.*?\\]', '', x)))

    # Elimino todo lo que aparece luego de 'More on Genius'
    corpus.pro <- tm_map(corpus.pro, content_transformer(function(x) gsub("More on Genius.*","", x)))
    }
  
  if(pro.min){
    # Convertimos el texto a minúsculas
    corpus.pro <- tm_map(corpus.pro, content_transformer(tolower))
    }

  if(pro.stopwords){
    # Removemos palabras vacias en español
    corpus.pro <- tm_map(corpus.pro, removeWords, stopwords(idioma_stopwords))
  }

  if(pro.num){
    # removemos números
    corpus.pro <- tm_map(corpus.pro, removeNumbers)
  }
  
  if(pro.symbols){
    # Removemos puntuaciones
    corpus.pro <- tm_map(corpus.pro, removePunctuation)

    # Removemos todo lo que no es alfanumérico
    corpus.pro <- tm_map(corpus.pro, content_transformer(function(x) str_replace_all(x, "[[:punct:]]", " ")))

    # Removemos puntuaciones
    corpus.pro <- tm_map(corpus.pro, removePunctuation)
    }

  if(pro.accents){
    replaceAcentos <- function(x) {stri_trans_general(x, "Latin-ASCII")}
    corpus.pro <- tm_map(corpus.pro, replaceAcentos)
  }
  
  if(pro.spaces){
    # Se eliminan los espacios adicionales
    corpus.pro <- tm_map(corpus.pro, stripWhitespace)
  }

    if(pro.stemm){
    # Se eliminan los espacios adicionales
    corpus.pro <- tm_map(corpus.pro, stemDocument, language="spanish")
  }
  
  return(corpus.pro)
}

#####################################################
###########Pre-procesamiento del corpus #############
#####################################################

# Corremos la función (operaciones del LAB08)
corpus.pro = df2corpus.pro(df_lyrics$lyrics, pro.stemm = FALSE)

# Recuperamos la letra de la primera canción
# Carlos Vives (Robarte un beso)
inspect(corpus.pro[1])
df_lyrics[1,]

####################################################################
####### Generación de la Matríz Término-Documento del corpus #######
####################################################################

corpus.pro2tdm <- function(corpus, ponderacion, n_terms) {

  # Genero la matriz TD y la transformo en una matriz
  dtm <- TermDocumentMatrix(corpus.pro, control = list(weighting = ponderacion))
  matriz_td <- as.matrix(dtm)

  # Me quedo con los n_terms más frecuentes
  terminos_frecuentes = head(sort(rowSums(matriz_td), decreasing = T), n_terms)
  
  # Me quedo con la matriz transpuesta de los n_terms más frecuentes
  # Cada fila es un tema, cada columna un término
  matriz_mf = t(matriz_td[sort(names(terminos_frecuentes)),])

  # Paso a binaria la matriz (está o no está el término)
  matriz_mf[matriz_mf > 0] <- 1
  
  return(matriz_mf)
}

matriz <- corpus.pro2tdm(corpus.pro, "weightTfIdf", 150000)
View(matriz)

lyrics_transactions <- transactions(matriz)
lyrics_transactions
arules::inspect(head(lyrics_transactions, 3))

summary(lyrics_transactions)

reglas <- apriori(lyrics_transactions, parameter = list(support=0.1, confidence=0.5, target = "rules"))
reglas

arules::inspect(head(sort(reglas, by="lift", decreasing = TRUE), 30))

rules.sub <- subset(reglas, subset = rhs %in% "amor")
arules::inspect(head(sort(rules.sub, by="lift", decreasing = TRUE), 30))
