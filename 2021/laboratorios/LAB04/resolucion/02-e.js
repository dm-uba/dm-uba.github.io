db.createView("compilations", "artist_audio_features", [
                                         {$match: {album_type: 'compilation'}},
                                         {$project: { artist_name: 1, disc_number: 1, album_release_date: 1, track_name: 1, duracion_ms:1 }}
                                    ])
