# MongoDB: Consultas e Interacción con R

En esta guía se explica como crear subconjuntos de datos a partir de consultas de MongoDB para luego accederlos desde R con la idea de que puedan organizar la información y acceder a la misma de manera eficiente.

## Creación de Subconsultas y acceso desde R

Una forma eficiente para trabajar consta de generar nuevas colecciones en MongoDB, que sería el equivalente a crear vistas en un SGBD SQL, y luego acceder a esos datos desde R para no tener que traernos todos los datos y poder trabajar solo con el conjunto que nos interesa.

### Parte I: Creación de consultas en MongoDB

#### Creación de colecciones a partir de agregaciones de datos _aggregate_ y _$out_
Supongamos por un momento que tenemos la necesidad de generar una nueva colección con la cantidad de audios presentes en la colección _artist_audio_features_ agrupados por artista. La consulta sería la siguiente:

```javascript
db.artist_audio_features.aggregate( [
    {$group: { _id: "$artist_name", cantidad_tracks: {$sum: 1} } },
  ] )
```

En el operador _$group_ definimos, en el atributo __id_ cual es el atributo a partir del cual realizamos la agregación y luego creamos el atributo _cantidad_tracks_ con la operación de agregación.

Si quisieramos ordenar el listado, podemos incorporar el operador _$sort_:
```javascript
db.artist_audio_features.aggregate( [
    {$group: { _id: "$artist_name", cantidad_tracks: {$sum: 1} } },
    {$sort:{"cantidad_tracks":-1} }
  ] )
```

En este caso, con el -1 sobre el atributo _cantidad_tracks_, estamos indicando que el orden sea descendente.

Por otro lado, es deseable crear colecciones, o subcolecciones, a partir de estas consultas a modo de _views_ en SQL. Eso lo logramos con el operador _$out_ de la instrucción aggregate:
```javascript
db.artist_audio_features.aggregate( [
    {$group: { _id: "$artist_name", cantidad_tracks: {$sum: 1} } },
    {$sort:{"cantidad_tracks":-1} },
    { $out : "tracks_por_artista" }   
  ] )
```

El operador _$out_ generará una nueva colección denominada __tracks_por_artista__.

#### Creación de vistas en MongoDB a partir del método _createView()_

En aquellos casos que deseáramos crear nuevos subconjuntos de datos que no necesariamente consten de agregaciones (resúmenes, _group by_), también podemos hacerlo en MongoDB.

Supongamos que necesitamos obtener una vista con el nombre del artista, el número de disco, la fecha del álbum, el nombre del track y la duración para aquellos tracks con valor de _energy_ mayor de 0.7. La consulta en MongoDB sería la siguiente:
```javascript
db.getCollection('albums_2021').find({energy: {$gte: 0.7}},
                                     { artist_name: 1, disc_number: 1, album_release_date: 1, track_name: 1, duracion_ms:1  })
```

Ahora bien, si deseamos crear una vista con esta información utilizamos el método _CreateView_ de la siguiente manera:
```javascript
db.createView("energy_07", "albums_2021", [
                                         {$match: {energy: {$gte: 0.7}}},
                                         {$project: { artist_name: 1, disc_number: 1, album_release_date: 1, track_name: 1, duracion_ms:1 }}
                                    ])                                   
```

En la instrucción anterior, definimos -en el orden de aparición- las siguientes cuestiones:
- Nombre de la vista,
- Nombre de la colección consultada,
- _$match_: condiciones que deben cumplir las filas que integrarán la vista,
- _$project_: columnas que incluirá la vista.


### Parte II: Acceder a los datos mediante R

Una vez que contamos con esta colección, podemos consultarla desde R:

1. Levantamos el paquete R que quieran usar para acceder a MongoDB:
```R
# Se puede utilizar mongolite

install.packages("mongolite")

library(mongolite)
```

2. Obtenemos los datos en R desde MongoDB, los que se guardan en un dataframe:
```R
tracks.artista = mongo(collection = "tracks_por_artista", db = "DMUBA_SPOTIFY" )
energy_07 = mongo(db = "DMUBA_SPOTIFY", collection = "energy_07")

df_tracks.artista <- tracks.artista$find()
df_energy_07 = energy_07$find()
```
