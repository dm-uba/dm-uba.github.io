

Preprocesamiento
========================================================
autosize: true
width: 1200
height: 800

<br />
Nociones básicas de integración de datos
<br />
<br />
<br />
Juan Manuel Fernandez



Preprocesamiento (Volumen I)
========================================================
<br />
Uno de los desafíos a los que nos vamos a enfrentar es la integración desde distintos orígenes de datos. <br />

Contenidos de la presentación:
- Integración de datos desde distintos orígenes de datos
      - Merge
      - SQLdf
      - dplyr
- Gestión de la granularidad

Integración de datos de múltiples fuentes
========================================================

Supongamos que tenemos dos orígenes de datos, denominados productos y stock:


```r
productos<-data.frame(Codigo=c(45, 46), Denominacion=c("Licuadora", "TV 4k"), Precio=c(1245.10, 14742))
head(productos)
```

```
  Codigo Denominacion  Precio
1     45    Licuadora  1245.1
2     46        TV 4k 14742.0
```

```r
stock<-data.frame(Cod=c(45, 46), stock=c(8650, 145))
head(stock)
```

```
  Cod stock
1  45  8650
2  46   145
```

Integración de datos de múltiples fuentes
========================================================

Puede suceder que necesitemos integrar ambos datasets, para tener las características de los productos junto con el stock. Podemos hacerlo con merge:


```r
dataset<-merge(productos, stock, by.x = "Codigo",  by.y = "Cod")
head(dataset)
```

```
  Codigo Denominacion  Precio stock
1     45    Licuadora  1245.1  8650
2     46        TV 4k 14742.0   145
```
En general, vamos a unir nuestros orígenes de datos a través de un código que identifique las instancias en cada dataframe, en este caso el código.

Integración/Manipulación de datos: sqldf
========================================================

Una lbirería interesante es sqldf, con la cual podemos manipular los dataframes como si fueran tablas sql:

```r
library(sqldf)
join_string = "SELECT Codigo, Denominacion, Precio, stock as Stock FROM productos p INNER JOIN stock s ON p.Codigo=s.Cod"
sql_query = sqldf(join_string,stringsAsFactors = FALSE)
head(sql_query)
```

```
  Codigo Denominacion  Precio Stock
1     45    Licuadora  1245.1  8650
2     46        TV 4k 14742.0   145
```
Aquí vamos a pensar las columnas del dataframe como atributos y los dataframes como tablas.

Integración/Manipulación de datos: dplyr
========================================================

Otra librería muy conocida de R para la manipulación de dataframes es dplyr:

```r
library(dplyr)
data.dplyr = productos %>% inner_join(stock, by = c("Codigo" = "Cod"))
head(data.dplyr)
```

```
  Codigo Denominacion  Precio stock
1     45    Licuadora  1245.1  8650
2     46        TV 4k 14742.0   145
```
</small>
Esta es una librería muy potente, para los que quieran profundizar aquí está la documentación oficial: https://dplyr.tidyverse.org/ <br />
Documentación sobre el Join: https://dplyr.tidyverse.org/reference/join.html
Integración de datos de múltiples fuentes (++)
========================================================
Algunas cuestiones con las que vamos a lidiar cuando integremos datos de diversas fuentes son:
+ Diferentes nombres de atributos,

```r
names(stock)
```

```
[1] "Cod"   "stock"
```

```r
names(stock)[1]="Codigo"
names(stock)
```

```
[1] "Codigo" "stock" 
```
***
+ Diferente representación de los mismos datos,

```r
celsius=c(26,32)
fahrenheit=(celsius*1.8)+32
print(fahrenheit)
```

```
[1] 78.8 89.6
```
+ Diferente granularidad.

```r
library(lubridate)
fechas <- c(as.Date("2011-06-26"), as.Date("2013-07-15"))
meses <- c(5, 8)
todos <- cbind(meses, month(fechas))
```
