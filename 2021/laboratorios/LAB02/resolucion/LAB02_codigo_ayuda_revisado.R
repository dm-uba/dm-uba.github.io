
# Cargo dataframe
MPI_national = read.csv('https://raw.githubusercontent.com/dm-uba/dm-uba.github.io/master/2021/laboratorios/LAB02/data/MPI_national.csv', header = TRUE, sep = ',')

# Cargo dataframe
MPI_subnational = read.csv('https://raw.githubusercontent.com/dm-uba/dm-uba.github.io/master/2021/laboratorios/LAB02/data/MPI_subnational.csv', header = TRUE, sep = ',')

# Selecciono todas las combinaciones de ISO y world.region
# A qué región pertenece cada país
country.by.WR = unique(MPI_subnational[,c(1, 4)])

# Verifico los nombres de los atributos de los dos df a integrar
names(MPI_national)
names(country.by.WR)

# Hago el merge entre los dos df
MPI_int = merge(MPI_national, country.by.WR, by.x = "ISO",  by.y = "ISO.country.code")


# Verifico si ahora cuento con la columna World Region
names(MPI_int)


#################################################
###### Verifico atributos redundantes ##########


# Calculo la matriz de correlación
ds.cor = cor(MPI_int[,3:8])

# Me quedo con solo una mitad
ds.cor[upper.tri(ds.cor)] <- NA

# Hago el heatmap agregando los parámetros symm = T y Rowv = F
library(gplots)
library(RColorBrewer)

dev.off()
par(mar=c(3,3,3,3))
my_palette <- colorRampPalette(c("green", "black", "red"))(n = 100)
heatmap.2(ds.cor,
          cellnote = round(ds.cor,2), 
          notecol="white",     
          trace="none",        
          margins = c(9,15), # 1er numero: margen inferior, 2do: margen izquierdo
          col=my_palette,  
          cexCol=0.75,
          cexRow=0.75,
          dendrogram="none",
          symm= T,
          Rowv=F) 


# Verificamos asociación
plot(MPI_int[,3:8])


###############################################
############### MANEJO DE RUIDO ###############

# Boxplot
par(mar=c(3,10,3,3))
boxplot(scale(MPI_int[,3:8]),  cex.axis=0.75,main = "Boxplot de los atributos numéricos")

# Plot de atributo 
#plot(MPI_int$Intensity.of.Deprivation.Urban, main = "Plot de Intensity of deprivation Urban", xlab="índice del valor", ylab="valor")
#plot(sort(MPI_int$Intensity.of.Deprivation.Urban), main = "Plot de Intensity of deprivation Urban", xlab="índice del valor", ylab="valor")

# Calculamos el Coeficiente de Variación
library(statip)
apply(MPI_int[,3:8], 2, statip::cv, na_rm=TRUE)


library(infotheo)
BINS_EQ.F = 5
BINS_EQ.W = 5
atributo = MPI_int$MPI.Urban

# Discretize recibe el atributo, el método de binning y la cantidad de bins
bin_eq_freq <- discretize(atributo,"equalfreq", BINS_EQ.F)

barplot(table(bin_eq_freq), main = "Frecuencia de bins (eqFreq)")

# Discretize recibe el atributo, el método de binning y la cantidad de bins
bin_eq_width <- discretize(atributo,"equalwidth", BINS_EQ.W)

barplot(table(bin_eq_width), main = "Frecuencia de bins (eqWidth)")

# ¿Qué problema tiene equalwidth?
atributo2 = append(atributo, 100)
bin_eq_width2 <- discretize(atributo2,"equalwidth", BINS_EQ.W)
barplot(table(bin_eq_width2), main = "Frecuencia de bins (eqWidth)")

# Incorporo atributo al dataframe
MPI_disc <- data.frame(atributo, bin_eq_freq, bin_eq_width)

# Cambio los nombres de los atributos
names(MPI_disc) <- c('Atributo.Original', 'E.Freq.Bin', 'E.Width.Bin')

# Muestro los primeros n datos
MPI_disc[1:10,]

# Por cada bin calculamos la media y reemplazamos en el atributo suavizado
for(bin in 1:5){
  # Calculo de media para ambas técnicas de binnning
  media_bin_frq = mean(MPI_disc$Atributo.Original[MPI_disc$E.Freq.Bin==bin])
  media_bin_width = mean(MPI_disc$Atributo.Original[MPI_disc$E.Width.Bin==bin])
  
  # Reemplazo los valores del bin por la media del bin
  MPI_disc$E.Freq.Suav[MPI_disc$E.Freq.Bin==bin] = media_bin_frq
  MPI_disc$E.Width.Suav[MPI_disc$E.Width.Bin==bin] = media_bin_width
}

# Muestro los primeros n datos
MPI_disc[1:10,]


# grafico Sepal.Width ordenado de menor a mayor

dev.off()
plot(sort(MPI_disc$Atributo.Original) , type = "l", col="red", ylab = "Atributo", xlab = "Observaciones", main = "Dato original vs suavizado", cex=0.7)

# Agrego la serie de la variable suavizada por anchos iguales
lines(sort(MPI_disc$E.Width.Suav), type = "l", col="blue")
# Agrego la serie de la variable suavizada por igual frecuencia
lines(sort(MPI_disc$E.Freq.Suav),type = "l", col="green")


legend("topleft", legend=c("Original", "Equal Width", "Equal Freq"), col=c("red", "blue", "green"), lty=1, cex = 0.7)

# Mismo gráfico sin ordenar las instancias
dev.off()
plot(MPI_disc$Atributo.Original , type = "l", col="red", ylab = "Atributo", xlab = "Observaciones", main = "Dato original vs suavizado", cex=0.7)

# Agrego la serie de la variable suavizada por anchos iguales
lines(MPI_disc$E.Width.Suav, type = "l", col="blue")
# Agrego la serie de la variable suavizada por igual frecuencia
lines(MPI_disc$E.Freq.Suav,type = "l", col="green")


legend("topleft",legend=c("Original", "Equal Width", "Equal Freq"), col=c("red", "blue", "green"), lty=1, cex = 0.55)
