# ----------------------------------
#      Curso de Data Mining
# ----------------------------------
# Descripción: Generación de datasets de Spotify integrando charts e información de artistas y canciones. 
# Año: 2021
# 

# Instalar desde el repo
devtools::install_github('charlie86/spotifyr')

library(spotifyr)
library(mongolite)
library(jsonlite)

settings_charts = list(
  region="global",
  period="weekly",
  url="https://spotifycharts.com/regional",
  CHARTS_ON=FALSE,
  ARTIST_ON=TRUE
)


# Registrar la aplicación aquí: https://developer.spotify.com/dashboard/login
# Siguiendo las recomendaciones del creador del paquete R: https://github.com/charlie86/spotifyr
SPOTIFY_CLIENT_ID = ''
SPOTIFY_CLIENT_SECRET = ''

# Retorna la fecha del primer viernes del año
get_first_friday_of_year = function(year){
  d = 0
  friday = FALSE
  f = NA
  while(d<=6 & !friday){
    f = as.Date(paste0(year,"-01-01")) + d
    if(strftime(f,format = "%u") == "5"){
      friday = TRUE
    }else{
      d =  d + 1  
    }
    
  }
  return(f)
}

# Retorna el chart de una fecha
# Ojo! Está pensado para el chart semanal
get_charts_by_date = function(d){
  week_start = d
  week_end = d + 7
  url = paste( settings_charts$url, 
               settings_charts$region,
               settings_charts$period,
               paste(week_start,week_end, sep="--"), "download", sep="/")
  
  charts = read.csv(url, header = T, skip = 1)
  charts$week_start = rep(week_start, nrow(charts))
  charts$week_end = rep(week_end, nrow(charts))
  print(url)
  return(charts)
  }

# Recupera los charts de un año completo
get_charts_by_year = function(y){
  d = get_first_friday_of_year(y)
  NWEEKS=52 
  df_charts = data.frame()
  for(w in 0:NWEEKS){
    d = d + 7
    df_charts = rbind(df_charts, get_charts_by_date(d))
  }
  
  return(df_charts)
}

# ---- Charts ---- 
if(settings_charts$CHARTS_ON){
  # Crea la colección "charts"
  coleccion.charts = mongo(collection = "charts", db = "DMUBA_SPOTIFY")
  
  # Corre para cada año y guarda el charts en mongo y va armando un vector de artistas únicos
  artist = c()
  for(year in 2018:2020){
    db.charts = get_charts_by_year(year)
    
    artist=c(artist, as.character(unique(db.charts[!as.character(db.charts$Artist) %in% artist, ]$Artist)))
    coleccion.charts$insert(db.charts)
  }
  
  # Crea la colección "artist"
  coleccion.artist = mongo(collection = "artist", db = "DMUBA_SPOTIFY")
  coleccion.artist$insert(data.frame(Artist=artist))
}

# Configuración para autenticar en la API de Spotify
Sys.setenv(SPOTIFY_CLIENT_ID = SPOTIFY_CLIENT_ID)
Sys.setenv(SPOTIFY_CLIENT_SECRET = SPOTIFY_CLIENT_SECRET)
access_token <- get_spotify_access_token()

# Crea la colección "artist_audio_features"
coleccion.artist.audio.features = mongo(collection = "artist_audio_features", db = "DMUBA_SPOTIFY")

blk_list = c()
while(settings_charts$ARTIST_ON){
  # Recupera todas las publicaciones del artista en spotify considerando si aparece en: "album","single","appears_on" o "compilation".
  # NOTA: con esa configuración es super lento, quizás combiene solo recuperar singles y album.
  
  groups = c(c("album"))
  #groups = c(c("single"))
  #groups = c(c("appears_on"))
  #groups = c(c("compilation"))
  
  artist = coleccion.artist$distinct("Artist")
  
  for(group in groups){
    print(paste("GRUPO: ", group))
    query = paste0('{"album_type": {"$eq": "',group,'"}}')
    artist_in_mongo = coleccion.artist.audio.features$distinct("artist_name",paste0('{"album_type": "',group,'"}'))
    print(paste("BKL:",blk_list))
    tryCatch(
      { # 
        for(art in artist[!artist %in% artist_in_mongo & !artist %in% blk_list]){
          print(art)
          artist_features = get_artist_audio_features(art, include_groups = group )
          coleccion.artist.audio.features$insert(artist_features)
        }
      },
      error = function(e){ # Renueva el token
        blk_list <<- c(blk_list, art)
        print("Actualiza token...")
        print(e)
        access_token <- get_spotify_access_token()
        # Actualiza lista de artistas ya guardados
        artist_in_mongo = coleccion.artist.audio.features$distinct("artist_name",paste0('{"album_type": "',group,'"}'))
      }
    )
  }
  if(length(artist)==length(artist_in_mongo)){
    settings_charts$ARTIST_ON = FALSE
  }
}
