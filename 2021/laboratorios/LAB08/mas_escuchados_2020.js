db.createView("mas_escuchados_2020", "charts", [
                                         {$match: {week_start: {$regex: "^2020.*"}}},
                                         {$sort: { Streams: -1 }}
                                    ])