# Cargo dataframe
MPI_subnational = read.csv('https://raw.githubusercontent.com/dmuba/dmuba.github.io/master/Practicos/LAB01/MPI_subnational.csv', header = TRUE, sep = ',')

# Nombres de variables
names(MPI_subnational)

# Caracteristicas de las variables
str(MPI_subnational)

# Gráfico de torta
valores = table(MPI_subnational$World.region)
etiquetas = paste(names(valores), valores, sep=" ")
pie(valores, labels = etiquetas, main="Ciudades agrupadas por región")

# Calculo la Media
apply(MPI_subnational[,5:8], 2, mean, na.rm=TRUE)

# Calculo la Mediana
apply(MPI_subnational[,5:8], 2, median, na.rm=TRUE)

# Calculo de moda
install.packages("modeest")
library(modeest)
apply(MPI_subnational[,5:8], 2, mfv, na.rm=TRUE)

# Agrupando por Región
aggregate(MPI.National ~ World.region, data=MPI_subnational, FUN=mean)

# Por país
MPI_x_WR=aggregate(MPI.National ~ World.region, data=MPI_subnational, FUN=mean)

# Genero un ranking
MPI_x_WR[order(-MPI_x_WR$MPI.National),]

# Histograma
hist(MPI_subnational$MPI.National, main = "Histograma del MPI.National", xlab = "MPI.National", ylab = "Frecuencia")

# Gráficos para atributos cualitativos
# Torta
pie(table(MPI_subnational$World.region), main="Países agrupados por región")

# Barra
barplot(table(MPI_subnational$World.region), las=2, cex.names=.5, main="Países agrupadas por región")

install.packages("RColorBrewer")
library(RColorBrewer)

x<-barplot(valores,
           legend.text=etiquetas, args.legend = list(bty = "n", x = "top", ncol = 2,  text.width=02),
           cex.names=.7,
           col=brewer.pal(6,"Set1"),border="white",
           ylim=c(0,1500),ylab="Cantidad de ciudades",
           main="Ciudades por Región")

y<-as.matrix(valores)
text(x,y+30,labels=as.character(y))

# Ayuda con las "leyendas" o etiquetas del gráfico
# https://www.dataanalytics.org.uk/legends-on-graphs-and-charts/

# Dispersión
apply(MPI_subnational[,5:8], 2, sd, na.rm=TRUE)

# Varianza
apply(MPI_subnational[,5:8], 2, var, na.rm=TRUE)

# Rango
apply(MPI_subnational[,5:8], 2, range, na.rm=TRUE)

# Boxplot
boxplot(MPI_subnational[,5:6], main="Boxplot de MPI National y Regional")

# Boxplot
boxplot(MPI_subnational[,7:8], main="Boxplot de MPI National y Regional")


# Dispersión / Scatterplot
plot(MPI_subnational[,5:8], labels = names(MPI_subnational)[5:8], col=as.factor(MPI_subnational$World.region))

# Calculo la matriz de correlaciones
matriz.correlaciones = cor(MPI_subnational[,5:8], use = "complete.obs")
colnames(matriz.correlaciones)=c("MPI.Nat","MPI.Reg","Headcount.Reg","Intensity.Reg")
rownames(matriz.correlaciones)=c("MPI.Nat","MPI.Reg","Headcount.Reg","Intensity.Reg")
print(matriz.correlaciones)

as.data.frame(table(iris$Species))
