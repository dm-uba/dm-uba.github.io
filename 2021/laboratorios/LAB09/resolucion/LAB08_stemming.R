# Documentación:
# https://cran.r-project.org/web/packages/SnowballC/SnowballC.pdf

library(SnowballC)

getStemLanguages()

words = c("ganar", "gana", "ganador", "ganadores")
wordStem(words, language = "spanish")

words2 = c("efectúa", "efectuaba", "efectuada", "efectuadas", "efectuado", "efectúan",
           "efectuar", "efectuará", "efectuarán", "efectuaría", "efectuaron", "efectuarse",
           "efectúen", "efectuo", "efectúo", "efectuó")

length(unique(words2))

unique(wordStem(words2, language = "spanish"))


library(tm)
# https://www.rdocumentation.org/packages/tm/versions/0.7-8/topics/stemDocument
# stemDocument
# The argument language is passed over to wordStem as the name of the Snowball stemmer.
# Así se realiza stemming:
# corpus.pro <- tm_map(corpus.pro, stemDocument, language="spanish")

library(mongolite)
conx_lyrics_spa = mongo(collection = "lyrics_spanish", db = "DMUBA_SPOTIFY")
df_lyrics = conx_lyrics_spa$find('{}')

# Corremos la función (operaciones del LAB08)
corpus.pro = df2corpus.pro(df_lyrics$lyrics, pro.stemm = TRUE)

inspect(corpus.pro[1])
