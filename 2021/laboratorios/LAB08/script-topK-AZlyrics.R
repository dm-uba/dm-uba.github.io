# Me conecto a la vista de la db mongo y traigo los datos que necesito
# db.createView("mas_escuchados_2020", "charts", [
#                                     {$match: {week_start: {$regex: "^2020.*"}}},
#                                     {$sort: { Streams: -1 }}
#                                     ])

library(mongolite)
library(stringi)
conx_escuchados = mongo(collection = "mas_escuchados_2020", db = "DMUBA_SPOTIFY")

df_escuchados <- conx_escuchados$find()[, c(2:4)]

# Genero una conexión a una nueva colección denominada lyrics (para las letras)
conx_lyrics = mongo(collection = "lyrics", db = "DMUBA_SPOTIFY")

# Me quedo con la fila de cada canción con más Streams y lo ordeno en forma decreciente
df_escuchados = aggregate(Streams ~ ., data=df_escuchados, FUN=max)
df_escuchados <- df_escuchados[order(df_escuchados$Streams, decreasing = TRUE),]

# Limito a los K más escuchados de 2020
K = 20
df_top_K <- head(df_escuchados, K)
df_top_K$Track_Name = tolower(stri_trans_general(df_top_K$Track_Name, 'latin-ascii'))
df_top_K$Artist = tolower(stri_trans_general(df_top_K$Artist, 'latin-ascii'))

# Cargo el paquete para el scraping e instancio la URL de búsqueda de azlyrics.com
library(rvest)
search_url = "https://search.azlyrics.com/search.php?q="

# Genero el for para recorrer las K canciones para recuperar la letra

K = 1 # Esta instanciación es mientras dure la puesta a punto del script

for (i in 1:K) {
  # Como token de búsqueda uno artista y tema y separo por '+'
  tokens_search = paste(df_top_K$Track_Name[i], df_top_K$Artist[i])
  tokens_search = gsub(" ", "+", tokens_search)
  
  # Uno la url para busqueda con los tokens
  search_url = paste0(search_url, tokens_search)
  
  # Tomo la url de búsqueda y recupero el html
  html_data <- read_html(search_url)
  
  results_search = html_data %>% html_element("table") %>% html_table()
  
  } # Cierro el for
