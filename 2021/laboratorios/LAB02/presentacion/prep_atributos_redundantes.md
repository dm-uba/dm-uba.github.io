
Preprocesamiento
========================================================
autosize: true
width: 1200
height: 800

<br />
Técnicas básicas de detección de atributos redundantes
<br />
<br />
<br />
Juan Manuel Fernandez



Preprocesamiento (Volumen I)
========================================================
<br />
En esta clase, vamos a trabajar con dos técnicas básicas de detección de atributos redundantes:
- Test de Chi-Cuadrado (atributos discretos)
- Coeficiente de correlación de Pearson (atributos numéricos)

Cuando integramos datos desde múltiples fuentes podemos encontrar distintos atributos con el mismo comportamiento. El objetivo de estas técnicas es detectarlos para luego decidir si desechamos alguno de los atributos para nuestro proceso KDD.

Reducción de datos: Atributos Redundantes
========================================================
autosize:true
<small>
En datos de tipo cualitativos/nominales: Test de Chi-Cuadrado
<br />
<br />
Hacemos la tabla de contingencia:

```r
library(MASS)
tbl_cont = table(survey$Smoke, survey$Exer)
print(tbl_cont)
```

```
       
        Freq None Some
  Heavy    7    1    3
  Never   87   18   84
  Occas   12    3    4
  Regul    9    1    7
```
***
<br />
<br />
<br />
Luego aplicamos el Test de Chi-cuadrado:

```r
chisq.test(tbl_cont)
```

```

	Pearson's Chi-squared test

data:  tbl_cont
X-squared = 5.4885, df = 6, p-value = 0.4828
```
</small>

Reducción de datos: Atributos Redundantes (++)
========================================================
<small>
En datos de tipo cuantitativos/numéricos: Coeficiente de Correlación & Covarianza

```r
llamadas=read.csv('llamadas.csv')
```

```r
cor(llamadas$minutos,llamadas$unidades)  # Coeficiente de Pearson
```

```
[1] 0.9936987
```
<br />
<br />
Debemos recordar validar los supuestos para una regresión -a menudo, esto no aparece en la Bibliografía-
***
<center>

```r
plot(llamadas$minutos,llamadas$unidades, main = "Relación entre unidades y minutos", xlab = "Duración de la llamada (minutos)", ylab = "Unidades") # Gráficamente
```

![plot of chunk unnamed-chunk-5](prep_atributos_redundantes-figure/unnamed-chunk-5-1.png)
</center>
</small>
