/**  -------- Query 2  ----------------     
Coleccion: charts
Calculamos un group by por artistas y calculamos la media de Position y Streams
Guarda el resultado del query en una nueva coleccion llamada: charts_avg
*/
db.charts.aggregate([
    {$group: {_id: "$Artist", 
              avg_position: {$avg: "$Position"},
              avg_streams: {$avg: "$Streams"},
              }},
    {$project: {
          _id: 0,
          artist_name: "$_id",
          avg_position: "$avg_position",
          avg_streams: "$avg_streams"}  
        },
    {$out: "charts_avg"}
])