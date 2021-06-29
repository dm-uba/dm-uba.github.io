# install.packages("rvest")
# install.packages("geniusr")
# install.packages("tidytext")

library(rvest)
library(mongolite)
library(stringi)
library(stringr)

# Modificando el codigo que vimos en el labo de Text Mining
# Vamos a seleccionar aleatoriamente 6000 canciones de la coleccion Features
# Y luego vamos a descargar sus lyrics

songs = mongo(collection = "features_tp", db = "SPOTIFY_UBA")
lyrics_lsh = mongo(collection = "lyrics_lsh", db = "SPOTIFY_UBA")

# Seleccionamos 6000 documentos aleatoriamente
data.feat = songs$aggregate('[ { "$sample": { "size": 6000 } },
   {"$project": {"_id":0, "track_name": 1,"artist_name":1}}]')
data.feat = na.omit(data.feat)

# Creamos una funcion para limpiar track names,
# ya que luego los usaremos en la URL de descarga de lyrics
clear_name = function(txt){
  
  nclear = str_extract_all(string = txt, pattern = "\\(.*?\\)")
  nclear = str_trim(stri_replace_all_fixed(txt, nclear[[1]], ""))
  return(nclear)

  }


for(i in 1:nrow(data.feat)){
#for(i in 1:10){
  print(data.feat[i,])
  
  track = data.feat[i,]$track_name
  if(str_detect(track,"\\(")){
    track = clear_name(track)
  }
  
  if(str_detect(track,"\\;")){
    track = substr(track, 1, unlist(gregexpr(text = track,pattern = ";"))-1 )
  }
  
  if(str_detect(track,"\\-")){
    track = substr(track, 1, unlist(gregexpr(text = track,pattern = "-"))-2 )
  }
  
  track  = str_to_lower(str_replace_all(track, " ","-"))
  artist = str_to_lower(str_replace_all(data.feat[i,]$artist_name, " ","-"))
  
  
  url  = paste0("https://genius.com/", artist, "-", track, "-lyrics")
  print(url)  
  
  tryCatch(
    { 
      simple <- read_html(url)
      
      txt = simple %>%
        html_nodes(xpath = "//*[@class='song_body-lyrics']") %>%
        html_text()
      
      if(length(txt) != 0){
        data = data.frame(
          artist_name=c(data.feat[i,]$artist_name),
          track_name=c(data.feat[i,]$track_name),
          lyrics=c(txt))
        
        lyrics$insert(data)  
      }
    },
    error = function(e){ # Renueva el token
      print("Error..")
    }
  )
}










