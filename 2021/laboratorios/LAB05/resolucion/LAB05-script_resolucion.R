wd_doc<-"https://raw.githubusercontent.com/dm-uba/dm-uba.github.io/master/2021/laboratorios/LAB05/data/auto-mpg.data-original.txt"

# Información de atributos: https://archive.ics.uci.edu/ml/datasets/auto+mpg
# 1. mpg: continuous
# 2. cylinders: multi-valued discrete
# 3. displacement: continuous
# 4. horsepower: continuous
# 5. weight: continuous
# 6. acceleration: continuous
# 7. model year: multi-valued discrete
# 8. origin: multi-valued discrete
# 9. car name: string (unique for each instance)

data.original<-read.table(wd_doc, 
                 colClasses = c("numeric","factor","numeric","numeric","numeric","numeric","numeric","factor","character"),
                 col.names = c("mpg", "cylinders", "displacement", "horsepower", "weight", "acceleration", "model_year", "origin", "car_name"))

summary(data.original)

# Vamos a trabajar sobre data
data = data.original

# Genero una función para verificar los faltantes para un atributo
missing.proporcion <- function(x){sum(is.na(x))/length(x)*100}

# Le aplico la función a todos los atributos del dataframe
apply(data, 2, missing.proporcion)

# Se verifican los casos no completos
View(data[!complete.cases(data),])

# Se grafican las combinaciones y proporciones
library(VIM)
aggr(data, sortVar=TRUE, numbers=T, 
     cex.lab = 0.9, cex.numbers=0.9, cex = 0.8)


#############################################################
############## IMPUTACIÓN DE DATOS FALTANTES ################
#############################################################

# La imputación la realizaremos sobre: mpg

# Registros completos (no hay imputación)
reg_completos<-na.omit(data$mpg)
# Verificación
sum(is.na(reg_completos))

# Sustitución por la media
data$imp_media <-data$mpg
data$imp_media[is.na(data$imp_media)]<-mean(data$imp_media, na.rm = TRUE)

# Verificación
sum(is.na(data$imp_media))


# Imputacion por regresión

# Verifico la matriz de correlación
cor(data[,-c(2,8,9)], use="complete.obs")

#Armamos el modelo
rl_model<-lm(mpg~horsepower+weight, data = data)
summary(rl_model)

# Imputamos en base al modelo
data$imp_regresion<-data$mpg
data$imp_regresion[is.na(data$imp_regresion)]<-45.64-0.0473*data$horsepower[is.na(data$mpg)]-0.0057*data$weight[is.na(data$mpg)]

# Verificación
sum(is.na(data$imp_regresion))

# Imputación hot deck
library(VIM)
df_aux<-hotdeck(data.original, variable="mpg")
data$imp_hotdeck<-df_aux$mpg
data$imp_bool<-df_aux$mpg_imp

# Verificación
sum(is.na(data$imp_hotdeck))

# Imputación por MICE
library(mice)
imputed_Data <- mice(data.original, m=5, maxit = 3, method = 'pmm')
completeData <- complete(imputed_Data)
data$imp_mice <- completeData$mpg

# Verificación
sum(is.na(data$imp_mice))

# Reemplazamos todo el dataset por un dataset con los atributos que interesan
data = data[,-c(2:9)]

# Verificamos el dataset resultante
View(data)

# Verificamos los valores imputados
View(data[data$imp_bool,])

# Analisis grafico de los resultados
plot(data$imp_media[data$imp_bool==TRUE], 
     main = 'Imputaciones realizadas sobre mpg',
     type = "l", 
     col="blue",
     ylim = c(10, 46),
     xlab = 'Observaciones',
     ylab = 'Valores imputados')
lines(data$imp_regresion[data$imp_bool==TRUE], type = "l", col="green")
lines(data$imp_hotdeck[data$imp_bool==TRUE], type = "l", col="red")
lines(data$imp_mice[data$imp_bool==TRUE], type = "l", col="orange")
legend("topleft", ncol=4, legend=c("Media", "Regresión", "Hot deck", "MICE"), col=c("blue", "green", "red", "orange"), lty=1, cex = 0.70)

# Gráficos de densidad
plot(density(data$mpg, na.rm=TRUE), type = "l", col="black", 
     ylab = "Valores", ylim=c(0,0.05),
     main="Gráfico de densidad con las distribuciones")
lines(density(data$imp_regresion), type = "l", col="green")
lines(density(data$imp_hotdeck), type = "l", col="red")
lines(density(data$imp_media), type = "l", col="blue")
lines(density(data$imp_mice), type = "l", col="orange")
legend("topright", legend=c("Original", 'Regresión', 'Hotdeck', "Media", "MICE"), col=c("black", "green", 'red','blue', 'orange'), lty=1, cex=0.8)

# Gráfico de la distribución del dato
plot(data$imp_media, type = "l", col="blue", 
     ylab = "Valores", ylim=c(10, 60), 
     main="Series resultantes luego de imputación", xlab="Observaciones")
lines(data$imp_regresion, type = "l", col="green")
lines(data$imp_hotdeck, type = "l", col="red")
lines(data$imp_mice, type = "l", col="orange")
lines(data$mpg, type = "l", col="black")
legend("top", ncol=5, legend=c("Original", 'Regresión', 'Hotdeck', "Media", "MICE"), col=c("black", "green", 'red','blue', 'orange'), lty=1, cex=0.70)

# Gráficos de densidad (para un segmento con faltantes [0:42])
plot(data$imp_media[0:42], type = "l", col="blue",
     ylab = "Valores", ylim=c(10,45))
lines(data$imp_regresion[0:42], type = "l", col="green")
lines(data$imp_hotdeck[0:42], type = "l", col="red")
lines(data$imp_mice[0:42], type = "l", col="orange")
lines(data$mpg, type = "l", col="black")
legend("top", ncol=5, legend=c("Original", 'Regresión', 'Hotdeck', "Media", "MICE"), col=c("black", "green", 'red','blue', 'orange'), lty=1, cex=0.65)
