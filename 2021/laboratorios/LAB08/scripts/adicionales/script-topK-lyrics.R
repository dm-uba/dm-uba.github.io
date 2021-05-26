# Me conecto a la vista de la db mongo y traigo los datos que necesito
# db.createView("mas_escuchados_2020", "charts", [
#                                     {$match: {week_start: {$regex: "^2020.*"}}},
#                                     {$sort: { Streams: -1 }}
#                                     ])

library(mongolite)
library(stringi)
conx_escuchados = mongo(collection = "mas_escuchados_2020", db = "DMUBA_SPOTIFY")

df_escuchados <- conx_escuchados$find()[, c(2:5)]

# Genero una conexión a una nueva colección denominada lyrics (para las letras)
conx_lyrics = mongo(collection = "lyrics", db = "DMUBA_SPOTIFY")

# Me quedo con la fila de cada canción con más Streams  y lo ordeno en forma decreciente
df_escuchados = aggregate(Streams ~ ., data=df_escuchados, FUN=max)
df_escuchados <- df_escuchados[order(df_escuchados$Streams, decreasing = TRUE),]

# Limito a los K más escuchados
K = 20
df_top_K <- head(df_escuchados, K)
df_top_K$Track_Name = tolower(stri_trans_general(df_top_K$Track_Name, 'latin-ascii'))
df_top_K$Artist = tolower(stri_trans_general(df_top_K$Artist, 'latin-ascii'))

# Quito los warnings que aparecen con geniusr
options(warn=-1)

# Se genera función para retornar los temas
library(geniusr)
get_lyric = function(artista, tema){
  letra = NULL
  tryCatch(
    { 
      letra = get_lyrics_search(artist_name = artista,
                                song_title = tema)
    },
    error = function(e) e)
  return(letra)
}

# Se recorren los temas, se descargan las letras y se guardan en MongoDB
ok=0
for(i in 1:nrow(df_top_K)){
  item = df_top_K[i,]
  item$lyric = ''
  msj = paste("Art:", item$Artist, " Tema:", item$Track_Name, " Resultado:")
  
  # Se hace el llamado a la función que busca la canción
  letra = get_lyric(item$Artist, item$Track_Name)

  # Si falló la llamada se insiste 3 veces
  intentos = 1
  while((is.null(letra) || nrow(letra) == 0) & intentos <= 3){
    
    # Se genera una pausa aleatoria para la nueva petición
    time = sample(1:5, 1)
    cat('Se esperan',time,'segundos...\n')
    Sys.sleep(time)
    
    # Se vuelve a solicitar el tema
    letra = get_lyric( item$artist_name, item$track_name)
    intentos = intentos + 1
  }
  
  # Se verifica si la llamada tuvo éxito
  if(!is.null(letra)) {
    
    # Y si se encontró la canción
    if (nrow(letra)>0) {
      
      # Se pasan todas las líneas a un único campo string
      for (line in letra$line) item$lyric = paste(item$lyric, line, '\n')
      conx_lyrics$insert(item)
      
      msj = paste(msj, "OK")
      
      ok=ok+1
    
    } else msj = paste(msj, "No encontrado.") # Si nrow() es vacío
  
  } else msj = paste(msj, "Error.")           # Si letra es nulo
  
  # Se imprime el mensaje con el resultado para la canción
  print(msj)
}

cat('Se encontraron ', ok, 'de las ', K, ' letras buscadas.')

# Se cierran las conexiones
rm(conx_escuchados)
rm(conx_lyrics)
