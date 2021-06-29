# ---------------------------------------
#   Curso Data Mining (UBA)
#   Ejemplo de Local Sensitive Hashing
#   Clase del 29 de Junio 2021
# ---------------------------------------
library(mongolite)
library(jsonlite)
library(textreuse)
library(tm)
library(stringr)
library(stringi)
library(dplyr)
library(tidyverse)
library(textcat)

# ----------------------------------------------------------------
#   Creacion del archivo random_lyrics_lsh.csv
#   No hace falta ejecutar la siguiente sección (comentada)
# ----------------------------------------------------------------

# Las letras se descargan a MongoDB ejecutando el siguiente script
# download_lyrics_random.R
# https://github.com/dm-uba/dm-uba.github.io/blob/master/2021/laboratorios/LAB11/download-lyrics-random.R

# Recuperamos la colección desde mongodb
#conx_lyrics_random = mongo(collection = "lyrics_lsh", db = "SPOTIFY_UBA")
#df_text = conx_lyrics_random$find('{}')


# Vamos a usar la librería textcat para quedarnos con las letras en inglés
#textcat("This is a sentence.")

# Filtramos las que el idioma es inglés
#df_text = df_text[textcat(df_text$lyrics)=="english",]

# eliminamos las conexión dado que no la vamos a usar
#rm(conx_lyrics_random)


# ----------------------------------------------------------------
#                     Limpieza de los textos
# ----------------------------------------------------------------

# Elimino todo lo que aparece antes del primer [] por formato en GENIUS site
#df_text$lyrics <- sub('^.+?\\[.*?\\]',"", df_text$lyrics)

# Elimino las aclaraciones en las canciones, por ejemplo:
# [Verso 1: Luis Fonsi & Daddy Yankee]
#df_text$lyrics <- gsub('\\[.*?\\]', '', df_text$lyrics)

# Elimino todo lo que aparece luego de 'More on Genius'
#df_text$lyrics <- gsub("More on Genius.*","", df_text$lyrics)


# Se quitan caracteres no alfanuméricos
#df_text$lyrics <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", df_text$lyrics)

# Se quitan acentos
#df_text$lyrics = stri_trans_general(df_text$lyrics, "Latin-ASCII")

# Se pasa a minusculas
#df_text$lyrics = tolower(df_text$lyrics)

# Se quita puntuacion
#df_text$lyrics = removePunctuation(df_text$lyrics)

# Se quitan números
#df_text$lyrics = removeNumbers(df_text$lyrics)

# se quitan espacios extras
#df_text$lyrics =  stripWhitespace(df_text$lyrics)

# se quitan espacios al principio y final de la cadena
#df_text$lyrics = str_trim(df_text$lyrics)
#df_text$lyrics <- gsub("https[a-z0-9]+", "", df_text$lyrics)

# Se eliminan duplicados en base al mismo nombre
#df_text = df_text[!duplicated(df_text[c(2)]),]

# Se eliminan registros que no tienen lyrics
#df_text = df_text[!(is.na(df_text$lyrics) | df_text$lyrics==""), ]

########## df_text se exporta como random_lyrics_lsh.csv  #################

# ---------------------- LABORATORIO -------------------------- #

#file = "RUTA AL ARCHIVO"
#df_text <- read.csv(file)

# a) Hay duplicados en base al track_name?
df_text[duplicated(df_text$track_name),]

# b) Nueva variable con largo del texto
df_text$lyrics_len <- nchar(df_text$lyrics)

# c) Observemos los datos ordenados por track_name y cantidad de caracteres
View(df_text[c(2,4)][with(df_text, order(track_name, lyrics_len)),])

# d) Compare similitud de jaccard para 6 temas elegidos aleatoriamente
library(textreuse)
subset = TextReuseCorpus(text = df_text[c("1741","389","849","1783"),]$lyrics,                          tokenizer = tokenize_ngrams,n = 5)

comparaciones = pairwise_compare(subset, jaccard_similarity)

# ----------------------------------------------------------------
#           Configuración de la función minhash
#           n = 200 Número de permutaciones π (pi) 
# ----------------------------------------------------------------
minhash <- minhash_generator(n = 200, seed = 318)

# Generación del corpus 
corpus <- TextReuseCorpus(text = df_text$lyrics, 
                          tokenizer = tokenize_ngrams, 
                          n = 3, # Tamaño del shingling con 3 palabras
                          minhash_func = minhash, # Función minhash definida previamente 
                          keep_tokens = TRUE,
                          progress = TRUE)

# Matriz M de 200 permutaciones filas x 1124 documentos
# Algunos documentos no fueron procesados (poca cantidad de palabras)
corpus

# Los documentos salteados contenian pocas palabras
warnings()

# Acceder a un documento
corpus[["doc-1"]]

# Solo el contenido
corpus[["doc-1"]]$content

# Acceder a los tokens de un documento
head(tokens(corpus[["doc-1"]]),5)

# Acceder a los hashes de un documento
head(hashes(corpus[["doc-1"]]),5)

# Hay un hash por n-gram tokens
length(tokens(corpus[["doc-1"]]))
length(hashes(corpus[["doc-1"]]))

# Podriamos acceder a las firmas o minhashes
head(minhashes(corpus[["doc-1"]]))

# Por cada documento generamos π (pi) permutaciones
length(minhashes(corpus[["doc-1"]]))

# c) Si s = 0.7, b = 20, r = 200/20:
print(1 - (1 - 0.7 ** 10) ** 20) 

# c.1) Utilizando 40 bandas
# Si s = 0.7, b = 40, r = 200/40:
print(1 - (1 - 0.7 ** 5) ** 40) 

# Se generan los buckets
buckets <- lsh(corpus, bands = 40, progress = FALSE)

# Generación de pares candidatos
candidatos <- lsh_candidates(buckets)

# Se realiza las comparaciones *solo* de los pares candidatos
resultados = lsh_compare(candidatos, corpus, jaccard_similarity, progress = FALSE)

# Documentos duplicados (Idénticos)
iguales = resultados[resultados$score ==1,]
head(iguales)

# Observamos algunos registros iguales
View(df_text[c(1003,958), c(1,2,3)])



library(dplyr)
# Documentos parecidos
parecidos = filter(resultados, (resultados$score < 1 & resultados$score > 0.6 ))
parecidos

##### Solución Alternativa ###

# Eliminar registros duplicados en base a cantidad de caracteres en lyrics
# y primer palabra de track name

# Guardamos primer palabra de cada track name en nueva columna
df_text$first_word <- gsub("([A-Za-z]+).*", "\\1", df_text$track_name)

# Eliminamos duplicados
df_text2 = df_text[!duplicated(df_text[c(4,5)]), ]

# Generamos nuevo corpus
corpus2 <- TextReuseCorpus(text = df_text2$lyrics, 
                          tokenizer = tokenize_ngrams, 
                          n = 3, # Tamaño del shingling con 3 palabras
                          minhash_func = minhash, # Función minhash definida previamente 
                          keep_tokens = TRUE,
                          progress = TRUE)


# Se generan los buckets
buckets2 <- lsh(corpus2, bands = 40, progress = FALSE)

# Generación de pares candidatos
candidatos2 <- lsh_candidates(buckets2)

# Se realiza las comparaciones *solo* de los pares candidatos
resultados2 = lsh_compare(candidatos2, corpus2, jaccard_similarity, progress = FALSE)

# Documentos con 100% de similitud
# Misma letra pero distintos track_names
View(df_text2[c(278,710), c(1,2,3,4)])
