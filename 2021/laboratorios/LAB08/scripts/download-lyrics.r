install.packages("geniusr")
install.packages("tidytext")

library(geniusr)
library(dplyr)
library(tidytext)
library(mongolite)
library(stringr)


songs = mongo(collection = "charts_lookups_features", db = "SPOTIFY_UBA")
lyrics = mongo(collection = "lyrics", db = "SPOTIFY_UBA")
data.feat = songs$find(query = '{}' ,fields = '{"_id":0, "position": 1,"artist_name":1,"track_name":1}')
data.feat = na.omit(data.feat)

get_lyric = function(artista, tema){
  letra = NULL
  tryCatch(
    { 
      letra = get_lyrics_search(artist_name = item$artist_name,
                                song_title = item$track_name)
    },
    error = function(e){ # Renueva el token
      print("Error..")
    }
  )
  return(letra)
}

for(i in 1:nrow(data.feat)){
  item = data.feat[i,]  
  print(paste("Art:", item$artist_name, " Tema:", item$track_name))
  
  letra = get_lyric( item$artist_name, item$track_name)
  
  intentos = 1
  while((is.null(letra) | length(nrow(letra)) == 0) & intentos <= 3){
    letra = get_lyric( item$artist_name, item$track_name)
    intentos = intentos + 1
  }
  if((!is.null(letra) & length(nrow(letra)) > 0)) lyrics$insert(letra)
}

