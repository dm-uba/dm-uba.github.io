# PS C:\Program Files\MongoDB\Tools\100\bin> .\mongoimport.exe -h localhost -d DMUBA_SPOTIFY -c lyrics --file=C:\Users\unlu\Documents\GitHub\dm-uba\2021\laboratorios\LAB08\data\lyrics-dm.json

# Vamos a usar la librería textcat para quedarnos con las letras en español
library("textcat")
textcat("Esta es una frase en español.")

# Recuperamos todas las letras de canciones
library(mongolite)
conx_lyrics = mongo(collection = "lyrics", db = "DMUBA_SPOTIFY")
lyrics =conx_lyrics$find('{}')

# Filtramos las que el idioma es español y las guardamos en una nueva colección
spa_lyrics = lyrics[textcat(lyrics$lyrics)=="spanish",]
conx_lyrics_spa = mongo(collection = "lyrics_spanish", db = "DMUBA_SPOTIFY")
conx_lyrics_spa$insert(spa_lyrics)

# eliminamos las conexiones
rm(conx_lyrics_spa)
rm(conx_lyrics)