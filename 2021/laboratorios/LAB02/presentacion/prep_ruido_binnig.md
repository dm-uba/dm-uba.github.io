
Preprocesamiento
========================================================
autosize: true
width: 1200
height: 800

<br />
Técnica de Binning para gestión de ruido
<br />
<br />
<br />
Juan Manuel Fernandez

Preprocesamiento (Volumen I)
========================================================
<small>
En esta clase, vamos a abordar la implementación de la técnica de binning (por igual ancho e igual frecuencia) para la gestión de ruido en datos.
<center>
![plot of chunk unnamed-chunk-1](prep_ruido_binnig-figure/unnamed-chunk-1-1.png)

Puede entenderse al ruido como un error aleatorio o varianza en una variable medida.
</small>
</center>

Limpieza de datos: Manejo de Ruido (Igual frecuencia)
========================================================
<small>
Vamos a trabajar con la librería infotheo para la discretización de atributos. <br />
Se etiquetan las instancias de acuerdo al bin que le corresponde según la técnica Equal Freq:
<center>

```r
library(infotheo)

# Discretize recibe el atributo, el método de binning y la cantidad de bins
bin_eq_freq <- discretize(iris$Sepal.Width,"equalfreq", 5)

# Incorporo atributo al dataframe
iris_disc <- data.frame(iris$Sepal.Width, bin_eq_freq)

# Cambio los nombres de los atributos
names(iris_disc) <- c('Sepal.Width', 'E.Freq.Bin')

# Muestro los primeros 3 datos
iris_disc[1:3,]
```

```
  Sepal.Width E.Freq.Bin
1         3.5          5
2         3.0          2
3         3.2          4
```
</small>

Limpieza de datos: Manejo de Ruido (Igual ancho)
========================================================
<small>
Se etiquetan las instancias de acuerdo al bin que le corresponde según la técnica Equal Width:
<center>

```r
library(infotheo)

# Discretize recibe el atributo, el método de binning y la cantidad de bins
bin_eq_width <- discretize(iris$Sepal.Width,"equalwidth", 5)

# Incorporo atributo al dataframe
iris_disc <- data.frame(iris_disc, bin_eq_width)

# Cambio los nombres de los atributos
names(iris_disc) <- c('Sepal.Width', 'E.Freq.Bin', 'E.Width.Bin')

# Muestro los primeros 3 datos
iris_disc[1:3,]
```

```
  Sepal.Width E.Freq.Bin E.Width.Bin
1         3.5          5           4
2         3.0          2           3
3         3.2          4           3
```
</small>

Manejo de Ruido (Suavizado por la media)
========================================================
Ahora se realiza el suavizado por la media según la discretización por igual frecuencia:

```r
# Por cada bin calculamos la media y reemplazamos en el atributo suavizado
for(bin in 1:5){
  # Calculo de media
  media_bin = mean(iris_disc$Sepal.Width[iris_disc$E.Freq.Bin==bin])
  #
  iris_disc$E.Freq.Suav[iris_disc$E.Freq.Bin==bin] = media_bin
}

iris_disc[1:3,]
```

```
  Sepal.Width E.Freq.Bin E.Width.Bin E.Freq.Suav
1         3.5          5           4    3.752000
2         3.0          2           3    2.924000
3         3.2          4           3    3.296774
```
</center>

Manejo de Ruido (Suavizado por la media)
========================================================
También realizamos el suavizado por la media según la discretización por igual ancho:

```r
# Por cada bin calculamos la media y reemplazamos en el atributo suavizado
for(bin in 1:5){
  # Calculo de media
  media_bin = mean(iris_disc$Sepal.Width[iris_disc$E.Width.Bin==bin])
  #
  iris_disc$E.Width.Suav[iris_disc$E.Width.Bin==bin] = media_bin
}

iris_disc[1:3,]
```

```
  Sepal.Width E.Freq.Bin E.Width.Bin E.Freq.Suav E.Width.Suav
1         3.5          5           4    3.752000     3.671429
2         3.0          2           3    2.924000     3.151471
3         3.2          4           3    3.296774     3.151471
```
</center>

Manejo de Ruido (Análisis gráfico)
========================================================
<center>
<small>

```r
# grafico Sepal.Width ordenado de menor a mayor
plot(sort(iris_disc$Sepal.Width) , type = "l", col="red", ylab = "Sepal.Width", xlab = "Observaciones", main = "Dato original vs suavizado")
# Agrego la serie de la variable media 
lines(sort(iris_disc$E.Width.Suav),
      type = "l", col="blue")
legend("topleft", legend=c("Original", "Suavizado"), col=c("red", "blue"), lty=1)
```
</small>
***
![plot of chunk unnamed-chunk-7](prep_ruido_binnig-figure/unnamed-chunk-7-1.png)
</center>
