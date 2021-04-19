db.noticias.insertOne({  'titulo': '¿La escuela no contagia? Las 20 verdades sobre las clases presenciales',
                        'epigrafe': 'Un resumen fundamental de todas las investigaciones internacionales sobre el tema',
                        'subtitulo': 'Axel Rivas, director de la Escuela de Educación de la Universidad de San Andrés, realizó una sintesis que pone en crisis el discurso del Gobierno porteño para politizar el debate sobre las medidas de cuidado y boicotear los esfuerzos destinados a frenar la escalada de contagios.',
                        'cuerpo': '"La escuela no contagia", repite cada vez que puede el jefe de Gobierno porteño Horacio Rodríguez Larreta. Y agrega terminante: "Nosotros nos basamos en datos". Las dos afirmaciones quedan fuertemente en duda si se atiende a la extensa lista de investigaciones, realizadas en todo el mundo, sobre el impacto de la educación presencial en el marco de la pandemia de Covid 19.'
                        })

db.noticias.insertMany([
                    {   'titulo': 'Coronavirus: se registraron 248 muertes y 20.461 nuevos casos',
                        'epigrafe': 'Los números de la segunda ola',
                        'subtitulo': 'Los fallecidos desde el comienzo de la pandemina suman 59.476. La ocupación de camas de terapia intensiva a nivel nacional es de 65,8% y en el AMBA del 74,5%.',
                        'cuerpo': 'El Ministerio de Salud de la Nación informó esta tarde que en las últimas 24 horas se reportaron 20.461 nuevos contagios y 248 muertes por Covid-19, con lo cual el total acumulado de casos en el país se elevó a 2.714.475 y el de víctimas fatales a 59.476.'},
                    {   'titulo': 'La Corte se declaró competente en el conflicto por las clases presenciales',
                        'epigrafe': 'El máximo tribunal ya notificó a las partes',
                        'cuerpo': 'La Corte Suprema de Justicia resolvió este lunes que el planteo del gobierno de la Ciudad de Buenos Aires contra el decreto de necesidad y urgencia de la Nación que suspendió las clases presenciales por dos semanas en el AMBA es de "competencia originaria" de ese tribunal.'},
                    {  'titulo': 'Se equivocaron, le depositaron 1,2 millones de dólares y se negó a devolverlos',
                        'epigrafe': 'Terminó presa y acusada de robo: un caso del que habla todo Estados Unidos',
                        'cuerpo': 'Un error en una transferencia bancaria terminó generando un revuelo en Nueva Orleans, Estados Unidos: una mujer recibió por equivocación más de 1,2 millones de dólares y se negó a devolverlos, por lo que terminó detenida y acusada de robo, fraude bancario y transmisión ilegal de fondos monetarios.'},
                    {  'titulo': 'La derecha brasileña fracasó',
                       'cuerpo': 'La derecha brasileña siempre controló el poder en Brasil, desde que comenzó a imponerse a los pueblos indígenas, oprimirlos y explotar sus riquezas. Luego, cuando utilizó el fenómeno más monstruoso de la historia mundial, la esclavitud, que con el colonialismo, son los dos fenómenos fundacionales de la historia brasileña.'}
                    ])