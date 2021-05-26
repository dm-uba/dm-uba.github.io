# Recuperamos todas las letras de canciones en español
library(mongolite)
conx_lyrics_spa = mongo(collection = "lyrics_spanish", db = "DMUBA_SPOTIFY")
df_lyrics = conx_lyrics_spa$find('{}')

# eliminamos las conexión dado que no la vamos a usar
rm(conx_lyrics_spa)

library(tm)
corpus = Corpus(VectorSource(enc2utf8(df_lyrics$lyrics)))

# Recuperamos la letra de la primera canción
inspect(corpus[1])

# Convertimos el texto a minúsculas
corpus.pro <- tm_map(corpus, content_transformer(tolower))

# removemos números
corpus.pro <- tm_map(corpus.pro, removeNumbers)

# Removemos palabras vacias en español
corpus.pro <- tm_map(corpus.pro, removeWords, stopwords("spanish"))

# Removemos puntuaciones
corpus.pro <- tm_map(corpus.pro, removePunctuation)

# Removemos puntuaciones
corpus.pro <- tm_map(corpus.pro, content_transformer(function(x) gsub(x, pattern = "«|»", replacement = "")))

# Eliminamos espacios
corpus.pro <- tm_map(corpus.pro, stripWhitespace)

# En tm_map podemos utilizar funciones prop
library(stringi)
replaceAcentos <- function(x) {stri_trans_general(x, "Latin-ASCII")}
corpus.pro <- tm_map(corpus.pro, replaceAcentos)

# Recuperamos el primer tweet
inspect(corpus.pro[1])

dtm <- TermDocumentMatrix(corpus.pro, 
                          control = list(weighting = "weightTf"))

# Resumen de la dtm (document-term matrix)
dtm

matriz_td <- as.matrix(dtm)
View(matriz_td)

# Calculamos la frecuencia de cada término en el corpus
freq_term <- sort(rowSums(matriz_td),decreasing=TRUE)

# Generamos un dataframe con esta sumatoria (de rows)
df_freq <- data.frame(termino = names(freq_term), frecuencia=freq_term)

# Reseteamos el índice (sino era el término "dueño" de la frecuencia)
row.names(df_freq) <- NULL

#######################################################
###################### WORDCLOUD ######################

topK = head(df_freq, 100)

# Visualización de los resultados
# Nube de Etiquetas
library("wordcloud")
library("RColorBrewer")

par(bg="grey30") # Fijamos el fondo en color gris

wordcloud(topK$termino, 
          topK$frecuencia,
          min.freq=1,
          col=terrain.colors(length(topK$termino), alpha=0.9),
          random.order=FALSE, rot.per=0.3)

par(bg="white") # Fijamos el fondo en color gris
dtm_crudo <- TermDocumentMatrix(corpus, control = list(weighting = "weightTf"))
matriz_td <- as.matrix(dtm_crudo)
freq_term <- sort(rowSums(matriz_td),decreasing=TRUE)
df_freq <- data.frame(termino = names(freq_term), frecuencia=freq_term)

hist(df_freq$frecuencia, xlab='Cantidad de términos', ylab='Frecuencia observada', main='Histograma')

plot(df_freq$frecuencia[1:150], type='l', xlab='Cantidad de términos', ylab='Frecuencia observada', main='Plot con frequencias')
