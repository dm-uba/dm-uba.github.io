/**  -------- Query 3  ----------------      
Ejemplo de LOOKUP ("JOIN") entre colecciones
Colecciones: singles_features_avg y charts_avg
Hacemos una union de ambas colecciones utilizando el operador $lookup
el atributo para unirlas es el nombre del artista (artist_name)
**/    
db.singles_features_avg.aggregate([
     {
       $lookup:
         {
           from: "charts_avg",
           localField: "artist_name", 
           foreignField: "artist_name",
           as: "chr"
         }
    },
    {
       $project: {
            artist_name : "$artist_name",
            f_danceability : "$f_danceability",
            f_danceability: "$f_danceability",
            f_loudness: "$f_loudness",
            f_energy: "$f_energy",
            f_speechiness: "$f_speechiness",
            f_liveness: "$f_liveness",
            avg_position: {"$arrayElemAt": ["$chr.avg_position", 0]},
            avg_streams: {"$arrayElemAt": ["$chr.avg_streams", 0]}
            }
        }
])