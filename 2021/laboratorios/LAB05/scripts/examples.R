data("iris")
names(iris) = c("Sep.L.", "Sep.W.", "Pet.L.", "Pet.W.", "Species")

# Vamos a cargar valores faltantes en los atributos sepal y petal (1 a 4)
for(i in 1:4) {
  # Generamos aleatoriamente un número entre 1-30
  # Este número representa la cantidad de NA que vamos a definir en cada atributo
  na.count = sample(1:30, 1)
  cat('Se definen ',na.count, ' instancias NA para ', names(iris[i]),'.\n')
  inst.aleat<-sample(1:nrow(iris), na.count, replace=F)
  iris[inst.aleat, i]<-NA
}

library(VIM)

faltantes = summary(aggr(iris, sortVar=TRUE, plot=F))
print(faltantes$combinations)

matrixplot(iris, sortby = 2)

marginplot(iris[,c("Sep.L.","Sep.W.")])
