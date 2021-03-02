# TP01: Manejo de datos con geometrías

Vamos a ver cómo podemos combinar diferentes colecciones de datos a partir de relaciones espaciales. 
El primer paso es generar una columna de geometría en nuestra colección __Sucursal__ para poder realizar un JOIN con otros datos de CABA.

## Generar location a partir de la longitud y la latitud

Necesitamos generar un atributo location para convertir nuestra tabla a de Json plano a GeoJson.

Veamos un registro de la colección __sucursales__.

´´´
> db.sucursales.findOne()
{
	"_id" : ObjectId("5cbc698b7af152186c0cd13f"),
	"sucursalTipo" : "Autoservicio",
	"direccion" : "Av Dr. Ricardo Balbin 4881",
	"provincia" : "AR-C",
	"banderaId" : 1,
	"localidad" : "Capital Federal",
	"banderaDescripcion" : "Supermercados DIA",
	"lat" : -34.5521177,
	"comercioRazonSocial" : "DIA Argentina S.A",
	"lng" : -58.4984145,
	"sucursalNombre" : "480 - Saavedra",
	"comercioId" : 15,
	"sucursalId" : "480",
	"id" : "15-1-480"
}
´´´

El script que se precisa para esto es un poco complejo para este nivel del curso pero es necesario, en resumen este código permite tomar los atributos existentes en la colección sucursales y generar un feature a location con __lng__ y __lat__.


´´´R
var bulk = db.sucursales.initializeOrderedBulkOp();
var counter = 0;

db.sucursales.find().forEach(function(doc) {
     bulk.find({ "_id": doc._id }).updateOne({
        "$set": {
            "location": {
                "type": "Point",
                "coordinates": [ doc.lng, doc.lat ]
            }
        },
        "$unset": {  "lng": 1, "lat": 1 } 
     });

     counter++;
     if ( counter % 1000 == 0 ) {
         bulk.execute();
         bulk = db.sucursales.initializeOrderedBulkOp();
     }

})

if ( counter % 1000 != 0 )
    bulk.execute();
´´´


Ahora podemos corroborar que nuestra colección ahora tiene un atributo que representa la geometría de su ubicación:

´´´
> db.sucursales.findOne()
{
	"_id" : ObjectId("5cbc698b7af152186c0cd13f"),
	"sucursalTipo" : "Autoservicio",
	"direccion" : "Av Dr. Ricardo Balbin 4881",
	"provincia" : "AR-C",
	"banderaId" : 1,
	"localidad" : "Capital Federal",
	"banderaDescripcion" : "Supermercados DIA",
	"comercioRazonSocial" : "DIA Argentina S.A",
	"sucursalNombre" : "480 - Saavedra",
	"comercioId" : 15,
	"sucursalId" : "480",
	"id" : "15-1-480",
	"location" : {
		"type" : "Point",
		"coordinates" : [
			-58.4984145,
			-34.5521177
		]
	}
}
´´´

## Obtener el barrio de una sucursal


var barrio = db.barrios.findOne()
db.sucursales.find( { location: { $geoIntersects: { $geometry: barrio.geometry } } } ).count()

db.sucursales.aggregate([{ $match :
		{ location: { $geoIntersects: { $geometry: barrio.geometry } } }
	},
	{$lookup:
	   {
		   from: barrios,
		   as: "UNION"
	   }
	}
])



db.TableB.aggregate([
{
  $match:{col2:"ABC"}
},
{
   $lookup:
   {
       from: TableA,
       localField: "col1",
       foreignField: "col1",
       as: "aliasForTable1Collection"
   }
}
])



