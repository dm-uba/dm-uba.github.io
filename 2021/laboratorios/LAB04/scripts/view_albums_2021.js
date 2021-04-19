db.createView("albums_2021", "artist_audio_features", [ 
    { $match: { album_release_year: 2020.0 } },
    { $limit: 20000 }
 ])
