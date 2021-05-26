install.packages("rvest")
install.packages("geniusr")
install.packages("tidytext")

library(rvest)
library(mongolite)
library(stringi)


songs = mongo(collection = "charts_sin_duplicados", db = "SPOTIFY_UBA")
lyrics = mongo(collection = "lyrics", db = "SPOTIFY_UBA")
data.feat = songs$find(query = '{}' ,fields = '{"_id":0, "Track_Name": 1,"Artist":1}')
data.feat = na.omit(data.feat)

clear_name = function(txt){
  
  nclear = str_extract_all(string = txt, pattern = "\\(.*?\\)")
  nclear = str_trim(stri_replace_all_fixed(txt, nclear[[1]], ""))
  return(nclear)

  }


for(i in 1:nrow(data.feat)){
#for(i in 1:10){
  print(data.feat[i,])
  
  track = data.feat[i,]$Track_Name
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
  artist = str_to_lower(str_replace_all(data.feat[i,]$Artist, " ","-"))
  
  
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
          artist_name=c(data.feat[i,]$Artist),
          track_name=c(data.feat[i,]$Track_Name),
          lyrics=c(txt))
        
        lyrics$insert(data)  
      }
    },
    error = function(e){ # Renueva el token
      print("Error..")
    }
  )
}










