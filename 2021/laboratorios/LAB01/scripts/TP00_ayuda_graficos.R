# Revisión TP00

# Cargo dataframe
MPI_subnational = read.csv('https://raw.githubusercontent.com/dmuba/dmuba.github.io/master/Practicos/LAB01/MPI_subnational.csv', header = TRUE, sep = ',')

# Paleta de colores
install.packages("RColorBrewer")
library(RColorBrewer)

# Separamos valores de etiquetas
valores = table(MPI_subnational$World.region)
# Generamos las etiquetas con nombre y valor
etiquetas = paste(names(valores), valores, sep=" ")

# Realizamos el Gráfico de torta con los parámetros y etiquetas generadas
pie(valores, 
    labels = etiquetas, main="Ciudades agrupadas por región",
    col=brewer.pal(6,"Set1"), border="white", cex=0.6, radius = 2)


# Generamos el gráfico de barras con la misma paleta de colores
x<-barplot(valores,
           cex.names=.7,
           col=brewer.pal(6,"Set1"),border="white",
           ylim=c(0,800),ylab="Cantidad de ciudades",
           main="Ciudades por Región")

# Generamos los valores para cada barra y los graficamos encima de ellas
y<-as.matrix(valores)
text(x,y+30,labels=as.character(y))

# Ayuda con las "leyendas" o etiquetas del gráfico
# https://www.dataanalytics.org.uk/legends-on-graphs-and-charts/
