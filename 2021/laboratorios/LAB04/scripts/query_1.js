 /**  -------- Query 1  ----------------
Colección: artist_audio_features
Generamos una colección con album_type = "single"
y agrupando por artist_name calcula la media de algunos 
features. 
Guarda el resultado del query en una nueva colección llamada: singles_features_avg
**/
db.artist_audio_features.aggregate([
    {$match: {album_type: "single"}},
    {$group: {_id: "$artist_name", 
              f_danceability: {$avg: "$danceability"},
              f_loudness: {$avg: "$loudness"},
              f_energy: {$avg: "$energy"},
              f_speechiness: {$avg: "$speechiness"},
              f_liveness: {$avg: "$liveness"}
              }},
    {$project: {
          _id: 0,
          artist_name: "$_id",
          f_danceability: "$f_danceability",
          f_loudness: "$f_loudness",
          f_energy: "$f_energy",
          f_speechiness: "$f_speechiness",
          f_liveness: "$f_liveness"}  
        },
     {$out: "singles_features_avg"}
])
