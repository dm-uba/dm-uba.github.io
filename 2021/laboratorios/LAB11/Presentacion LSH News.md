Documentos Similares
========================================================
autosize: true
width: 1200
height: 800



Locality Sensitive Hashing
<br />
<br />
Santiago Banchero
<br />
Juan Manuel Fernández
<br />
Eloísa Piccoli

<br />
Minería de Datos - UBA


Contenidos
========================================================
- Limpieza básica de documentos
- Cálculo de distancia de Jaccard
- Implementación Locality Sensitive Hashing
  + Exploración del objeto Corpus
  + Identificación de candidatos
  + Cálculo de score de similitud
- Identificación de documentos parecidos y similares

Utilizaremos un conjunto de noticias publicados en Kaggle --> <br/>
https://www.kaggle.com/clmentbisaillon/fake-and-real-news-dataset
<br/>
(También en GitHub de la materia)

Cargamos el dataframe
========================================================




```r
library(knitr)
nrow(df_text)
```

```
[1] 21417
```

```r
kable(head(df_text,1))
```



|title                                                            |text                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |subject      |date              |
|:----------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------|:-----------------|
|As U.S. budget fight looms, Republicans flip their fiscal script |WASHINGTON (Reuters) - The head of a conservative Republican faction in the U.S. Congress, who voted this month for a huge expansion of the national debt to pay for tax cuts, called himself a â€œfiscal conservativeâ€ on Sunday and urged budget restraint in 2018. In keeping with a sharp pivot under way among Republicans, U.S. Representative Mark Meadows, speaking on CBSâ€™ â€œFace the Nation,â€ drew a hard line on federal spending, which lawmakers are bracing to do battle over in January. When they return from the holidays on Wednesday, lawmakers will begin trying to pass a federal budget in a fight likely to be linked to other issues, such as immigration policy, even as the November congressional election campaigns approach in which Republicans will seek to keep control of Congress. President Donald Trump and his Republicans want a big budget increase in military spending, while Democrats also want proportional increases for non-defense â€œdiscretionaryâ€ spending on programs that support education, scientific research, infrastructure, public health and environmental protection. â€œThe (Trump) administration has already been willing to say: â€˜Weâ€™re going to increase non-defense discretionary spending ... by about 7 percent,â€™â€ Meadows, chairman of the small but influential House Freedom Caucus, said on the program. â€œNow, Democrats are saying thatâ€™s not enough, we need to give the government a pay raise of 10 to 11 percent. For a fiscal conservative, I donâ€™t see where the rationale is. ... Eventually you run out of other peopleâ€™s money,â€ he said. Meadows was among Republicans who voted in late December for their partyâ€™s debt-financed tax overhaul, which is expected to balloon the federal budget deficit and add about $1.5 trillion over 10 years to the $20 trillion national debt. â€œItâ€™s interesting to hear Mark talk about fiscal responsibility,â€ Democratic U.S. Representative Joseph Crowley said on CBS. Crowley said the Republican tax bill would require the  United States to borrow $1.5 trillion, to be paid off by future generations, to finance tax cuts for corporations and the rich. â€œThis is one of the least ... fiscally responsible bills weâ€™ve ever seen passed in the history of the House of Representatives. I think weâ€™re going to be paying for this for many, many years to come,â€ Crowley said. Republicans insist the tax package, the biggest U.S. tax overhaul in more than 30 years,  will boost the economy and job growth. House Speaker Paul Ryan, who also supported the tax bill, recently went further than Meadows, making clear in a radio interview that welfare or â€œentitlement reform,â€ as the party often calls it, would be a top Republican priority in 2018. In Republican parlance, â€œentitlementâ€ programs mean food stamps, housing assistance, Medicare and Medicaid health insurance for the elderly, poor and disabled, as well as other programs created by Washington to assist the needy. Democrats seized on Ryanâ€™s early December remarks, saying they showed Republicans would try to pay for their tax overhaul by seeking spending cuts for social programs. But the goals of House Republicans may have to take a back seat to the Senate, where the votes of some Democrats will be needed to approve a budget and prevent a government shutdown. Democrats will use their leverage in the Senate, which Republicans narrowly control, to defend both discretionary non-defense programs and social spending, while tackling the issue of the â€œDreamers,â€ people brought illegally to the country as children. Trump in September put a March 2018 expiration date on the Deferred Action for Childhood Arrivals, or DACA, program, which protects the young immigrants from deportation and provides them with work permits. The president has said in recent Twitter messages he wants funding for his proposed Mexican border wall and other immigration law changes in exchange for agreeing to help the Dreamers. Representative Debbie Dingell told CBS she did not favor linking that issue to other policy objectives, such as wall funding. â€œWe need to do DACA clean,â€ she said.  On Wednesday, Trump aides will meet with congressional leaders to discuss those issues. That will be followed by a weekend of strategy sessions for Trump and Republican leaders on Jan. 6 and 7, the White House said. Trump was also scheduled to meet on Sunday with Florida Republican Governor Rick Scott, who wants more emergency aid. The House has passed an $81 billion aid package after hurricanes in Florida, Texas and Puerto Rico, and wildfires in California. The package far exceeded the $44 billion requested by the Trump administration. The Senate has not yet voted on the aid. |politicsNews |December 31, 2017 |


Limpieza de documentos
========================================================


```r
# Nos quedamos con 3000 documentos elegidos aleatoriamente
# Pueden existir repetidos ya que seleccionamos por título
set.seed(321)
elegidos <- sample(unique(df_text$title), 3000)
df_text <- subset(df_text, title %in% elegidos)

library(tm)
# Se quitan caracteres no alfanuméricos
df_text$text <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", df_text$text)

# Se pasa a minúsculas
df_text$text = tolower(df_text$text)

# se quitan espacios extras
df_text$text =  stripWhitespace(df_text$text)

library(stringi)
# Se quitan acentos
df_text$text = stri_trans_general(df_text$text, "Latin-ASCII")
```
Similitud Jaccard entre pares
========================================================

```r
library(textreuse)

subset = TextReuseCorpus(text =         df_text[c(150,152,1597,1598,2433,2453),]$text,                          tokenizer = tokenize_ngrams,n = 5)
 
comparaciones = pairwise_compare(subset, jaccard_similarity)
```

```r
comparaciones
```

```
      doc-1 doc-2 doc-3 doc-4 doc-5    doc-6
doc-1    NA     1     0     0     0 0.000000
doc-2    NA    NA     0     0     0 0.000000
doc-3    NA    NA    NA     1     0 0.000000
doc-4    NA    NA    NA    NA     0 0.000000
doc-5    NA    NA    NA    NA    NA 0.939759
doc-6    NA    NA    NA    NA    NA       NA
```

Similitud Jaccard entre pares (+)
========================================================


```r
head(strwrap(subset[["doc-1"]]$content),2)
```

```
[1] "washington reuters - president donald trump on thursday tapped fed"   
[2] "governor jerome powell to become head of the us central bank breaking"
```


```r
head(strwrap(subset[["doc-2"]]$content),2)
```

```
[1] "washington reuters - president donald trump on thursday tapped fed"   
[2] "governor jerome powell to become head of the us central bank breaking"
```

Número combinatorio 6/2 = choose(6,2) = 15 comparaciones
</br> 
Ahora quién podrá ayudarnos? Locality Sensitive Hashing :)



Configuramos la función MinHash y creamos el corpus
========================================================

```r
minhash <- minhash_generator(n = 100, seed = 12)

corpus <- TextReuseCorpus(text = df_text$text, 
                          tokenizer = tokenize_ngrams, 
                          n = 5, # Shingling con 5 palabras
                          minhash_func = minhash, 
                          keep_tokens = TRUE) 

# Matriz M de π (100 permutaciones) filas x 3.095 documentos
# El objeto corpus contiene los tokens, los hashes, y los minhashes
corpus
```

```
TextReuseCorpus
Number of documents: 3095 
hash_func : hash_string 
minhash_func : minhash 
tokenizer : tokenize_ngrams 
```

Exploramos el objeto
========================================================

```r
# Los documentos fueron numerados
head(names(corpus))
```

```
[1] "doc-1" "doc-2" "doc-3" "doc-4" "doc-5" "doc-6"
```

```r
# Acceder al contenido un documento
corpus[["doc-1"]]$content
```

```
the following statementsa were posted to the verified twitter accounts of us president donald trump realdonaldtrump and potus the opinions expressed are his owna reuters has not edited the statements or confirmed their accuracy realdonaldtrump - together we are making america great again bitly/2lnpkaq 1814 est - in the east it could be the coldest new yearas eve on record perhaps we could use a little bit of that good old global warming that our country but not other countries was going to pay trillions of dollars to protect against bundle up 1901 est -- source link bitly/2jbh4lu bitly/2jpexyr 
```


Exploramos el objeto (+)
========================================================

```r
# Acceder a los tokens de un documento
head(tokens(corpus[["doc-1"]]),5)
```

```
[1] "the following statementsa were posted"
[2] "following statementsa were posted to" 
[3] "statementsa were posted to the"       
[4] "were posted to the verified"          
[5] "posted to the verified twitter"       
```

```r
# Acceder a los hashes de un documento
head(hashes(corpus[["doc-1"]]),5)
```

```
[1]  1429311630  1747942757  1984816445  1123365726 -1181171736
```
Exploramos el objeto (++)
========================================================

Genero un hash por n-gram tokens

```r
length(tokens(corpus[["doc-1"]]))
```

```
[1] 95
```


```r
length(hashes(corpus[["doc-1"]]))
```

```
[1] 95
```


Exploramos el objeto (+++)
========================================================

```r
# Podriamos acceder a las firmas o minhashes
head(minhashes(corpus[["doc-1"]]))
```

```
[1] -2134971303 -2140939379 -2141211777 -2124812613 -2092233601 -2040545567
```

```r
# Por cada documento generamos π (pi) permutaciones
length(minhashes(corpus[["doc-1"]]))
```

```
[1] 100
```

Locality Sensitive Hashing
========================================================

Particionamos la matriz de Signatures en **b** Bandas con **r** Filas cada una.
</br>
Para 2 documentos con una similitud de Jaccard de **s** , la probabilidad de que la función MinHash coincida en todas las filas en al menos 1 banda para esos documentos es:

<img src="Formula.png"; style="max-width:320px;float:center;">




```r
# Si s = 0.8, b = 20, r = 100/20:
print(1 - (1 - 0.8 ** 5) ** 20) 
```

```
[1] 0.9996439
```


```r
# Utilizando la librería
print(lsh_probability(h = 100, b = 20, s = 0.80)) 
```

```
[1] 0.9996439
```
Locality Sensitive Hashing (+)
========================================================

Cuanto más disímiles los documentos menos probabilidad de enviarlos al mismo bucket:


```r
print(1 - (1 - 0.6 ** 5) ** 20) 
```

```
[1] 0.8019025
```

```r
print(1 - (1 - 0.4 ** 5) ** 20) 
```

```
[1] 0.1860496
```

```r
print(1 - (1 - 0.2 ** 5) ** 20) 
```

```
[1] 0.006380581
```

Locality Sensitive Hashing (++)
========================================================

A menor cantidad de bandas menor es la Pb de identificar los documentos como pares candidatos:


```r
# Si s = 0.8, b = 10, r = 100/10:
print(1 - (1 - 0.8 ** 10) ** 10) 
```

```
[1] 0.67886
```


```r
# Si s = 0.8, b = 5, r = 100/5:
print(1 - (1 - 0.8 ** 20) ** 5) 
```

```
[1] 0.05633208
```

Locality Sensitive Hashing (+++)
========================================================
Nos quedamos con los parámetros b = 20 y r = 5:


```r
# Se generan los buckets
buckets <- lsh(corpus, bands = 20, progress = FALSE)
```

```r
# Generación de pares candidatos
candidatos <- lsh_candidates(buckets)

# Se realiza las comparaciones *solo* de los pares candidatos
resultados = lsh_compare(candidatos, corpus, jaccard_similarity, progress = FALSE)
```


Documentos Idénticos 
========================================================


```r
# Documentos duplicados (Idénticos)
iguales = resultados[resultados$score ==1,]
head(iguales)
```

```
# A tibble: 6 x 3
  a        b        score
  <chr>    <chr>    <dbl>
1 doc-150  doc-152      1
2 doc-1547 doc-1548     1
3 doc-1597 doc-1598     1
4 doc-1640 doc-1641     1
5 doc-1643 doc-1662     1
6 doc-1644 doc-1663     1
```

Documentos Parecidos 
========================================================

```r
library(dplyr)
# Documentos parecidos
parecidos = filter(resultados, (resultados$score < 1 & resultados$score > 0.8 ))
parecidos
```

```
# A tibble: 5 x 3
  a        b        score
  <chr>    <chr>    <dbl>
1 doc-119  doc-2200 0.84 
2 doc-129  doc-2223 0.941
3 doc-1392 doc-1394 0.900
4 doc-146  doc-2275 0.913
5 doc-2433 doc-2453 0.940
```

Documentos Parecidos (+)
========================================================

```r
substr(df_text[c(119, 2200),]$text, 400, 600)
```

```
[1] "atement issued by chinaas ministry of foreign affairs on thursday china agreed to further lower market entry barriers to its banking insurance and securities industries and will gradually reduce vehicl"
[2] "atement issued by china s ministry of foreign affairs on thursday china agreed to further lower market entry barriers to its banking insurance and securities industries and will gradually reduce vehicl"
```
