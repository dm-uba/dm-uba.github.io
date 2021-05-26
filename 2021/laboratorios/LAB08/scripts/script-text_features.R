# Chequeo si está instalada la librería que voy a utilizar
librerias_instaladas<-rownames(installed.packages())

if (!("tm" %in% librerias_instaladas)) {
  install.packages("tm", dependencies = TRUE)
}

if (!("RColorBrewer" %in% librerias_instaladas)) {
  install.packages("RColorBrewer", dependencies = TRUE)
}

if (!("wordcloud" %in% librerias_instaladas)) {
  install.packages("wordcloud", dependencies = TRUE)
}

if (!("proxy" %in% librerias_instaladas)) {
  install.packages("proxy", dependencies = TRUE)
}

library(tm)

df_Corpus = Corpus(VectorSource(enc2utf8(tweets_corpus_df$text)))

# Recuperamos el primer tweet
inspect(dfCorpus[1])

# Convertimos el texto a minúsculas
corpus.pro <- tm_map(dfCorpus, content_transformer(tolower))

# removemos números
corpus.pro <- tm_map(corpus.pro, removeNumbers)

# Removemos palabras vacias en español
corpus.pro <- tm_map(corpus.pro, removeWords, stopwords("spanish"))

# Removemos puntuaciones
corpus.pro <- tm_map(corpus.pro, removePunctuation)

# Eliminamos espacios
corpus.pro <- tm_map(corpus.pro, stripWhitespace)

# Recuperamos el primer tweet
inspect(corpus.pro[1])

dtm <- TermDocumentMatrix(corpus.pro)

# Resumen de la dtm
dtm

# Miramos cuales son los términos más frecuentes

m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(term = names(v),frec=v)
head(d, 50)

top50 = head(d, 50)

# Visualización de los resultados
# Nube de Etiquetas
library("wordcloud")
library("RColorBrewer")

par(bg="grey30") # Fijamos el fondo en color gris

wordcloud(d$term, 
          d$frec, 
          col=terrain.colors(length(d$term), alpha=0.9),
          random.order=FALSE, rot.per=0.3)

# Escalado multidimensional
# Vamos a filtrar los 50 términos más frecuentes para realizar un escalado 
# multidimensional y analizar qué términos están más cerca en los datos originales.

library(proxy)
N=50

# Distancia del coseno
top50.dtm = dtm[as.character(top50$term)[1:N],]
cosine_dist_mat <- as.matrix(dist(as.matrix(top50.dtm), method = "cosine"))

fit <- cmdscale(cosine_dist_mat, eig=TRUE, k=2) # k es el número de dim

x <- fit$points[,1]
y <- fit$points[,2]


par(bg="white")
plot(x, y, xlab="Coordinate 1", ylab="Coordinate 2", main="Escalado Multidimensional - Top 100 términos", type="n")
text(x, y, labels = rownames(fit$points), cex=.7, col = c("#e41a1c","#377eb8","#4daf4a","#984ea3")[as.factor(floor(log(top100$frec)))]) 
