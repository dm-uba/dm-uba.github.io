# Se puede utilizar mongolite
install.packages("mongolite")

library(mongolite)

pagina12 = mongo(db = "pagina12", collection = 'noticias_R')

# Podemos insertar desde la sintaxis de un doc JSON
str <- c('{ "titulo" : "Una Noticia", 
            "epigrafe": "Este es el epígrafe",
            "foto": "whiskyyy"}',
         '{ "titulo" : "Segunda Noticia", 
            "epigrafe": "Este es el segundo epígrafe",
            "foto": "sin foto"}')
pagina12$insert(str)

# También podemos insertar desde un data.frame
df = data.frame(titulo='Otra noticia', subtitulo='y tiene un subtitulo')
pagina12$insert(df)

# Consultamos las noticias creadas
pagina12$find(query = '{}', fields = '{}')

# Ahora probamos modificar una noticia
pagina12$update('{"titulo": "Otra noticia"}',
                '{"$set":{"titulo": "NOTICIA MODIFICADA EN DMUBA"}}',
                multiple = TRUE)

# Consultamos el impacto del update
pagina12$find(query = '{}', fields = '{}')

# Cuidado, aquí el delete ~= remove

# Previo a borrar, verificamos la cantidad de documentos
pagina12$count()

# Verificar en la corrida el nuevo oid (en el momento de la ejecución)
pagina12$remove('{"_id":{"$oid":"607e03ccc2740000b100666b"}}', just_one = TRUE)

# Verificamos la cantidad de registros luego del borrado
pagina12$count()

