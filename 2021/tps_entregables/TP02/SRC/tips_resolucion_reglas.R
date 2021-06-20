################################################################
##### Recuperamos todas las letras de canciones en español #####
################################################################

library(mongolite)
conx_feat = mongo(collection = "charts_lookups_features", db = "SPOTIFY_UBA")
df_feat = conx_feat$find(query = '{"album_name": {"$ne": null}}')
conx_lyrics_spa = mongo(collection = "lyrics-spanish", db = "SPOTIFY_UBA")
df_lyrics = conx_lyrics_spa$find('{}')


#########################################################
############### Preprocesamiento Features ###############
#########################################################
df_means_feat = aggregate(
                    cbind(
                      danceability , 
                      acousticness ,
                      energy,
                      duration_ms,
                      liveness , 
                      loudness ,
                      speechiness , 
                      tempo ,
                      valence)
                    ~
                      track_name + artist_name + album_name
                    , 
                    data=df_feat, FUN=function(x) mean(x,na.rm = T))
names(df_feat)

df_means_streams = aggregate(
    streams 
  ~
    track_name + artist_name + album_name
  , 
  data=df_feat, FUN=function(x) mean(x,na.rm = T))

df_best_position = aggregate(
  position 
  ~
    track_name + artist_name + album_name
  , 
  data=df_feat, FUN=min)

# Unión de todos los df
df_feats_ag = merge(x=df_means_feat, 
                    y=df_means_streams,
                    by.x = c("artist_name","track_name", "album_name"), 
                    by.y = c("artist_name","track_name", "album_name")
)

df_feats_ag = merge(x=df_feats_ag, 
                    y=df_best_position,
                    by.x = c("artist_name","track_name", "album_name"), 
                    by.y = c("artist_name","track_name", "album_name")
)


# eliminamos los pasos intermedios
rm(conx_feat, df_best_position, df_means_feat, df_means_streams, conx_lyrics_spa)

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

matriz <- corpus.pro2tdm(corpus.pro, "weightTfIdf", 10000)
dim(matriz)

# ---------------------------------------------------------
# Construcción de variables relacionadas con género 
# musical o algún otro tópico (Ej: romanticas, joda, etc.)
# ---------------------------------------------------------
# Ejemplo: Utiliza vocabulario de reggeton

vocab_reggeton = function(x){
  # Esta función compara si alguna de las palabras presentes 
  # es un término del glosario reggetonero
  x = as.data.frame(t(x))
  reggeton = c("abayalde","garete","arrebata","bellaquear","bellaquiar","bichote","blinblineo ","blin","cangri","dembow","flow","friki","frikitona","glory","gabete","giales","girlas","guaya","juquear","lambo","locotrona","maleanteo","maquinea")
  
  if(sum(names(x[-which(colSums(x)==0)]) %in% reggeton) >0){
    return("VOC_REGGETON=SI")
  }else{
    return("VOC_REGGETON=NO")
  }
}

# Aplico la función vocab_reggeton al df de términos x documentos
tiene_voc_regg = apply(df_tm, 1, vocab_reggeton)
table(tiene_voc_regg)
tiene_voc_regg = as.data.frame(tiene_voc_regg)
# Importante: luego de integrar la variable es necesario quitar los casos negativos ya que 
# solo importa presencia, no ausencia de un ítem.


df_tm = as.data.frame(matriz)
df_ly_feat = merge(x = cbind(df_lyrics[-c(3)], df_tm, tiene_voc_regg), 
                   y = df_feats_ag, 
                   by.x = c("artist_name","track_name"), 
                   by.y = c("artist_name","track_name"))

# Quitar atributos txt con valor 0
filter = !names(df_ly_feat) %in% c("artist_name", "track_name", "album_name", "tiene_voc_regg")
df_ly_feat_ok = df_ly_feat[, filter]
df_ly_feat_ok = df_ly_feat_ok[ ,-which(colSums(df_ly_feat_ok)==0)]

# Agregamos un TID
df_ly_feat_ok$tid = 1:nrow(df_ly_feat_ok)
df_ly_feat$tid = 1:nrow(df_ly_feat_ok)

# Discretizaciones basadas en Quantile
df_ly_feat_ok$cat_posicion = cut(df_ly_feat_ok$position,
                              breaks = c(1, 25, 100,200),#quantile(df_feat$position), 
                              labels = c("Muy Alta","Media", "Baja")) #c("Muy Alta", "Alta","Media", "Baja"))

table(df_ly_feat_ok$cat_posicion)
hist(df_ly_feat_ok$position, breaks = 50)

df_ly_feat_ok$cat_danceability = cut(df_ly_feat_ok$danceability,
                              breaks = c(0.4,0.7,0.8, 1),#quantile(df_feat$danceability), 
                              labels = c("Baja","Media", "Alta"))

summary(df_ly_feat_ok$danceability)
hist(df_ly_feat_ok$danceability, breaks = 10)
table(df_ly_feat_ok$cat_posicion, df_ly_feat_ok$cat_danceability)

df_ly_feat_ok$cat_acousticness = cut(df_ly_feat_ok$acousticness,
                              breaks = c(0,0.25,1),#quantile(df_feat$acousticness), 
                              labels = c("Baja","Alta"))

table(df_ly_feat_ok$cat_posicion, df_ly_feat_ok$cat_acousticness)
hist(df_ly_feat_ok$acousticness, breaks = 10)

names(df_ly_feat_ok)[4240:4255]
# Los features que conservo son los terminos y las categóricas
# features = names(df_ly_feat_ok)[c(1:4241,161,4252:4255)]
features = names(df_ly_feat_ok)[c(1:4240,4252:4255)]
names(df_ly_feat_ok)





# Para los terminos necesito filtrar las frecuencias=0
df_single = reshape2::melt(data = df_ly_feat_ok[,features], id.vars = c("tid") ) 
df_single = df_single[df_single$value!=0,]

df_single_txt = df_single[df_single$value==1,]
df_single_cat = df_single[df_single$value!=1,]

df_single_txt$variable =  paste0("TERM_",df_single_txt$variable)
df_single_cat$variable =  paste0(df_single_cat$variable, "=", as.character(df_single_cat$value))

# Agrego la variable tiene_voc_regg
df_reggeton = reshape2::melt(data = df_ly_feat[,c("tid","tiene_voc_regg")], id.vars = c("tid") ) 
df_reggeton$variable = df_reggeton$value
df_reggeton = df_reggeton[as.character(df_reggeton$variable)=="VOC_REGGETON=SI",]

df_single = rbind(df_single_cat, df_single_txt, df_reggeton)

df_single = na.omit(df_single[,-c(3)])
names(df_single ) = c("TID", "item")


write.table(df_single, file = "transacciones-lyrics-features.txt", row.names = FALSE)

# Fin del preprocesamiento



library(arules)

lyrics_features_trans <- read.transactions("transacciones-lyrics-features.txt", 
                                                   format = "single",
                                                   header = TRUE, 
                                                   sep = " ",
                                                   cols = c("TID","item"),
                                                   quote = '"')

lyrics_features_trans
arules::inspect(head(lyrics_features_trans, 3))

summary(lyrics_features_trans)

reglas <- arules::apriori(lyrics_features_trans, parameter = list(support=0.09, confidence=0.5,minlen=2, target = "rules"))
reglas

arules::inspect(head(sort(reglas, by="lift", decreasing = T), 30))

rules.sub <- arules::subset(reglas, subset =  (lhs %pin% "VOC_"))
rules.sub
arules::inspect(head(sort(rules.sub, by="lift", decreasing = TRUE), 100))
  
rules.sub <- apriori(lyrics_features_trans, 
                       parameter = list(support=0.01, confidence=0.01, target = "rules"), 
                       appearance = list(items = c("cat_posicion=Alta")))


