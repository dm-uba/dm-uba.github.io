
### Ayuda LAB03 Detección de Outliers ###

# Cargo dataframe
data = read.csv('https://raw.githubusercontent.com/dm-uba/dm-uba.github.io/master/2021/laboratorios/LAB03/MPI_national.csv', header = TRUE)

# Info de variables
str(data)
summary(data)

# Para visualizaciones usaremos ggplot2
# install.packages("ggplot2")
library(ggplot2)

# Instalamos una librería que permite visualizar
# varios charts en una ventana
# https://github.com/thomasp85/patchwork

# devtools::install_github("thomasp85/patchwork")
library(patchwork)


# Visualizamos los datos relacionados a zonas urbanas

u1 <- qplot(data$MPI.Urban, geom="histogram", main = "Hist MPI.Urban",  
            xlab = "MPI.Urban", ylab = "Frecuencia", binwidth=diff(range(data$MPI.Urban))/30) 

u2 <- qplot(data$Headcount.Ratio.Urban, main = "Hist HC Ratio Urban", geom="histogram",  
            xlab = "Headcount Ratio Urban", ylab = "Frecuencia", binwidth=diff(range(data$Headcount.Ratio.Urban))/30) 

u3 <- qplot(data$Intensity.of.Deprivation.Urban, main = "Hist. Intensity of Deprivation Urban", geom="histogram",  
            xlab = "Intensity of Depr.", ylab = "Frecuencia", binwidth=diff(range(data$Intensity.of.Deprivation.Urban))/30) 

# Y los mismos para zonas Rurales
r1 <- qplot(data$MPI.Rural, geom="histogram", main = "Hist MPI Rural",  
            xlab = "MPI.Urban", ylab = "Frecuencia", binwidth=diff(range(data$MPI.Rural))/30) 

r2 <- qplot(data$Headcount.Ratio.Rural, main = "Hist HC Ratio Rural", geom="histogram",  
            xlab = "Headcount Ratio Rural", ylab = "Frecuencia", binwidth=diff(range(data$Headcount.Ratio.Rural))/30) 

r3 <- qplot(data$Intensity.of.Deprivation.Rural, main = "Hist. Intensity of Deprivation Rural", geom="histogram",  
            xlab = "Intensity of Depr. Rural", ylab = "Frecuencia", binwidth=diff(range(data$Intensity.of.Deprivation.Rural))/30) 


# Y los graficamos en paralelo para facilitar la comparacion
(u1 | u2 | u3) /
  (r1 | r2 | r3)

# Veamos los boxplots para cada una de las métricas
boxplot(data[,c(3,6)], main="MPI Rural y Urbano")

boxplot(data[,c(4,7)], main="HC Ratio Rural y Urbano")

boxplot(data[,c(5,8)], main="HC Ratio Rural y Urbano")


# Normalizamos de variables con z-score para que sean comparables
# también nos informa sobre a cuántos desvíos de la media se distribuyen los datos


for(i in 3:ncol(data)) {
data[,i] <- (data[,i]-mean(data[,i]))/(sd(data[,i]))}


# Según el boxplot hay dos métricas que presentan outliers
boxplot(data[,c(3:8)])

# Que paises son outliers segun boxplot 
MPI.Urban_Umbral = boxplot(data[,c(3)])$stats[5]
data["Country"][data$MPI.Urban > MPI.Urban_Umbral,]

# Que paises son outliers segun boxplot de Headcount Ratio Urban
HC.Ratio.Urban_umbral = boxplot(data[,c(4)])$stats[5]
data["Country"][data$Headcount.Ratio.Urban > HC.Ratio.Urban_umbral,]


### Focalicemos el análisis en MPI Urban ###

# Rango intercuartil
Q1 = as.numeric(quantile(data$MPI.Urban)["25%"])
Q3 = as.numeric(quantile(data$MPI.Urban))[4]

IQR = Q3 - Q1

lim_sup = Q3 + 1.5*IQR
lim_inf = Q1 - 1.5*IQR

# Veamos de qué pais estamos hablando
sort(data$Country[data$MPI.Urban > lim_sup]) 

# Observemos la distribución de MPI Urban sin outliers
# Por la asimetría de la distribución, aparecen nuevos outliers

MPI.Urban_nuevo_bp = boxplot(data[c(3)][data[c(3)] <= MPI.Urban_Umbral],main="MPI Urban sin outliers") 

# Luego de eliminar los outliers, el nuevo valor atipico es:
MPI.Urban_nuevo_bp$out

# Los paises considerados outliers con Boxplot son los 
# mismos que con IQR

data["Country"][data[, "MPI.Urban"] == MPI.Urban_nuevo_bp$out,]

### Metodos Multivariados ###

# Distancia Mahalanobis
vector_medias = colMeans(data[,c(3:5)]) 
matriz_var_cov = cov(data[,c(3:5)])

# Creamos una variable con la distancia
data$maha = sqrt(mahalanobis(data[,c(3:5)],vector_medias,matriz_var_cov))

# Los 3 registros mas distantes
top_maha <- head(data[order(data$maha,decreasing = TRUE),],3)


# Analicemos con LOF las variables relacionadas a zonas rurales
library(Rlof)
library(scatterplot3d)

data$LOF_score<-lof(data[,c(6:8)], k=5) 
top_LOF <- head(data[order(data$LOF_score,decreasing = TRUE),],3) 


# Veamos donde se ubican los puntos
scatterplot3d(data[,6], data[,7],data[,8], 
              color=ifelse(data$LOF_score>=min(top_LOF$LOF_score),
                           "red","black"))
