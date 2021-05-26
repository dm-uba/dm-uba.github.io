Preprocesamiento
========================================================
autosize: true
width: 1200
height: 800

<br />
Tópicos de ingeniería de features
<br />
(atributos textuales)
<br />
<br />
Juan Manuel Fernandez


Contenidos
========================================================

En esta clase vamos a trabajar tips para implementar las siguientes técnicas en R:
- Generación de un corpus de documentos
- Nociones de pre-procesamiento de texto
- Representación mediante matríz de término-documento
- Análisis gráfico de los términos del corpus

Documentos para la demostración
========================================================
Para los ejemplos de esta presentación vamos a utilizar los siguientes "documentos":

```r
doc1 = "El tango es un género musical y una danza característica de la región del Río de la Plata"

doc2 = "El tango revolucionó el baile popular introduciendo una danza sensual con pareja abrazada que propone una profunda relación emocional de cada persona con su propio cuerpo y de los cuerpos de los bailarines entre sí. Refiriéndose a esa relación, Enrique Santos Discépolo, uno de sus máximos poetas, definió al tango como «un pensamiento triste que se baila». 9"

docs = c(doc1, doc2)
```

Generación del corpus de documentos
========================================================
Vamos a utilizar la librería tm (Text Mining Package) de R:
<small>

```r
library(tm)

# Incorporamos los documentos a lo que será nuestro Corpus (encodeado utf8)
# A VectorSource interprets each element of the vector x as a document.
corpus = Corpus(VectorSource(enc2utf8(docs)))

# Recuperamos el primer documento
inspect(corpus[1])
```

```
<<SimpleCorpus>>
Metadata:  corpus specific: 1, document level (indexed): 0
Content:  documents: 1

[1] El tango es un género musical y una danza característica de la región del Río de la Plata
```
</small>

Preprocesamiento (texto a minúsculas)
========================================================
Siempre es aconsejable reducir el espacio de dimensiones, por eso vamos a aplicar algunas transformaciones en el texto. La primera es pasarlo a minúsculas:


```r
# Convertimos el texto a minúsculas
corpus.pro <- tm_map(corpus, content_transformer(tolower))

inspect(corpus.pro[1])
```

```
<<SimpleCorpus>>
Metadata:  corpus specific: 1, document level (indexed): 0
Content:  documents: 1

[1] el tango es un género musical y una danza característica de la región del río de la plata
```

Preprocesamiento (eliminar números)
========================================================
En algunos contextos, puede ser útil remover los números:
<small>

```r
# removemos números
corpus.pro <- tm_map(corpus.pro, removeNumbers)

inspect(corpus.pro[2])
```

```
<<SimpleCorpus>>
Metadata:  corpus specific: 1, document level (indexed): 0
Content:  documents: 1

[1] el tango revolucionó el baile popular introduciendo una danza sensual con pareja abrazada que propone una profunda relación emocional de cada persona con su propio cuerpo y de los cuerpos de los bailarines entre sí. refiriéndose a esa relación, enrique santos discépolo, uno de sus máximos poetas, definió al tango como «un pensamiento triste que se baila». 
```
</small>

Preprocesamiento (eliminar stopwords)
========================================================
Otra etapa ineludible del preprocesamiento de textos es eliminar las palabras vacías:
<small>

```r
# Removemos palabras vacias en español
corpus.pro <- tm_map(corpus.pro, removeWords, stopwords("spanish"))

inspect(corpus.pro[2])
```

```
<<SimpleCorpus>>
Metadata:  corpus specific: 1, document level (indexed): 0
Content:  documents: 1

[1]  tango revolucionó  baile popular introduciendo  danza sensual  pareja abrazada  propone  profunda relación emocional  cada persona   propio cuerpo    cuerpos   bailarines  . refiriéndose   relación, enrique santos discépolo,    máximos poetas, definió  tango  « pensamiento triste   baila». 
```
</small>

Preprocesamiento (eliminar signos de puntuación)
========================================================
También puede ser útil eliminar los signos de puntuación para separar los términos del resto de los símbolos:
<small>

```r
# Removemos puntuaciones
corpus.pro <- tm_map(corpus.pro, removePunctuation)

inspect(corpus.pro[2])
```

```
<<SimpleCorpus>>
Metadata:  corpus specific: 1, document level (indexed): 0
Content:  documents: 1

[1]  tango revolucionó  baile popular introduciendo  danza sensual  pareja abrazada  propone  profunda relación emocional  cada persona   propio cuerpo    cuerpos   bailarines   refiriéndose   relación enrique santos discépolo    máximos poetas definió  tango  « pensamiento triste   baila» 
```
</small>

Preprocesamiento (gsub)
========================================================
Como vemos, nos se han eliminado los símbolos "«»", podemos hacerlo con gsub:
<br />(| actúa como un or)
<small>

```r
# Removemos puntuaciones
corpus.pro <- tm_map(corpus.pro, content_transformer(function(x) gsub(x, pattern = "«|»", replacement = "")))

inspect(corpus.pro[2])
```

```
<<SimpleCorpus>>
Metadata:  corpus specific: 1, document level (indexed): 0
Content:  documents: 1

[1]  tango revolucionó  baile popular introduciendo  danza sensual  pareja abrazada  propone  profunda relación emocional  cada persona   propio cuerpo    cuerpos   bailarines   refiriéndose   relación enrique santos discépolo    máximos poetas definió  tango   pensamiento triste   baila 
```
</small>

Preprocesamiento (eliminar espacios en blanco)
========================================================
Otra cuestión importante, si bien algunos tokenizadores luego lo manejan, es eliminar espacios adicionales:


```r
# Eliminamos espacios
corpus.pro <- tm_map(corpus.pro, stripWhitespace)

inspect(corpus.pro[2])
```

```
<<SimpleCorpus>>
Metadata:  corpus specific: 1, document level (indexed): 0
Content:  documents: 1

[1]  tango revolucionó baile popular introduciendo danza sensual pareja abrazada propone profunda relación emocional cada persona propio cuerpo cuerpos bailarines refiriéndose relación enrique santos discépolo máximos poetas definió tango pensamiento triste baila 
```

Preprocesamiento (eliminar acentos en las palabras)
========================================================
Otra cuestión con la que vamos a tener que lidiar cuando trabajemos con texto en algunos idiomas son los acentos:

```r
library(stringi)
# En tm_map podemos utilizar funciones prop
replaceAcentos <- function(x) {stri_trans_general(x, "Latin-ASCII")}
corpus.pro <- tm_map(corpus.pro, replaceAcentos)
inspect(corpus.pro[1])
```

```
<<SimpleCorpus>>
Metadata:  corpus specific: 1, document level (indexed): 0
Content:  documents: 1

[1]  tango genero musical danza caracteristica region rio plata
```

Matríz Término-Documento
========================================================
Una vez preprocesado el texto, podemos generar la matríz término-documento:

```r
# Pasamos como parámetro la métrica de ponderación de los términos
# weightBin (pesado binario): marca presencia o ausencia
# weightTf (frecuencia del término): apariciones en el doc
dtm <- TermDocumentMatrix(corpus.pro, 
                          control = list(weighting = "weightTf"))

# Resumen de la dtm (document-term matrix)
dtm
```

```
<<TermDocumentMatrix (terms: 35, documents: 2)>>
Non-/sparse entries: 37/33
Sparsity           : 47%
Maximal term length: 14
```

Matríz Término-Documento (++)
========================================================
`dtm`  es un objeto especial de tipo 'term-document matrix'. Ahora vamos a pasar los datos a una matriz, para trabajar de forma más cómoda:

```r
matriz_td <- as.matrix(dtm)
head(matriz_td)
```

```
                Docs
Terms            1 2
  caracteristica 1 0
  danza          1 1
  genero         1 0
  musical        1 0
  plata          1 0
  region         1 0
```

Matríz Término-Documento (+++)
========================================================
Ahora calculamos los términos más utilizados en todo el corpus

```r
# Calculamos la frecuencia de cada término en el corpus
freq_term <- sort(rowSums(matriz_td),decreasing=TRUE)

# Generamos un dataframe con esta sumatoria (de rows)
df_freq <- data.frame(termino = names(freq_term), frecuencia=freq_term)

# Reseteamos el índice (sino era el término "dueño" de la frecuencia)
row.names(df_freq) <- NULL
```

Matríz Término-Documento (++++)
========================================================
Verificamos cuales son los términos más utilizados en todo el corpus y su frecuencia:

```r
N = 8

head(df_freq, N)
```

```
         termino frecuencia
1          tango          3
2          danza          2
3       relacion          2
4 caracteristica          1
5         genero          1
6        musical          1
7          plata          1
8         region          1
```

Análisis gráfico de términos frecuentes
========================================================
Podemos realizar un wordcloud (o nube de palabras) con los términos más importantes:

```r
top20 = head(df_freq, 20)

# Visualización de los resultados
# Nube de Etiquetas
library("wordcloud")
library("RColorBrewer")

par(bg="grey30") # Fijamos el fondo en color gris

wordcloud(df_freq$termino, 
          df_freq$frecuencia,
          min.freq=1,
          col=terrain.colors(length(df_freq$termino), alpha=0.9),
          random.order=FALSE, rot.per=0.3)
```

Análisis gráfico de términos frecuentes (++)
========================================================
Vemos el resultado:
<center>
![plot of chunk unnamed-chunk-15](text_features-figure/unnamed-chunk-15-1.png)
</center>

Ley de Zipf
========================================================
Podemos verificar la ley de Zipf, y lo hago sobre el corpus sin preprocesar:
<center>

```r
dtm_crudo <- TermDocumentMatrix(corpus, control = list(weighting = "weightTf"))
matriz_td <- as.matrix(dtm_crudo)
freq_term <- sort(rowSums(matriz_td),decreasing=TRUE)
df_freq <- data.frame(termino = names(freq_term), frecuencia=freq_term)

hist(df_freq$frecuencia, xlab='Cantidad de términos', ylab='Frecuencia observada', main='Histograma')
```
</center>

Ley de Zipf (++)
========================================================
Aquí vemos el histograma con las frecuencia y cantidad de términos:
<center>
![plot of chunk unnamed-chunk-17](text_features-figure/unnamed-chunk-17-1.png)
</center>

Ley de Zipf (+++)
========================================================
Podemos verificarlo también con un plot de lineas:
<center>
![plot of chunk unnamed-chunk-18](text_features-figure/unnamed-chunk-18-1.png)
</center>
