library(arules)
library(arulesViz)
# Documentación: https://cran.r-project.org/web/packages/arulesViz/vignettes/arulesViz.pdf

# Cargo los datos y genero reglas
data("Groceries")
rules <- apriori(Groceries, parameter = list(support=0.01, confidence=0.01, target = "rules"))

# Plot x-y con 3 dimensiones
plot(rules)
# Es posible redefinir el orden de las métricas
plot(rules, measure = c("support", "lift"), shading = "confidence")

# El método two-key permite incluir la dimensión de orden (cantidad de items)
plot(rules, method = "two-key plot")

# Es posible generar un gráfico interactivo
sel <- plot(rules, measure = c("support", "lift"), shading = "confidence", interactive = TRUE)

# Muestra las reglas de forma matricial y por índice de los items
plot(subrules2, method = "matrix", shading = "support")

# Me quedo con un subconjunto de las reglas
subrules2 <- head(rules, n = 10, by = "lift")
# The width of the arrows represents support 
# the intensity of the color represent confidence. 
# For larger rule sets visual analysis becomes difficult since with an increasing number of 
# rules also the number of crossovers between the lines increases Yang (2003)
plot(subrules2, method = "paracoord")