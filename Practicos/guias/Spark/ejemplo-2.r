library(stringr)
library(dplyr)
library(arules)
library(SparkR)

IP_ADDR="192.168.1.142"
master_spark = paste0("spark://", IP_ADDR ,":7077")
spc = sparkR.session(master = master_spark, sparkEnvir = list(spark.driver.memory="3g"))

data("Groceries")

flatten_transactions = function(itemset){
  
  return(str_replace_all(paste(names(itemset)[itemset], sep="",  collapse = ',')," ", "_"))
}

groceries_flatten = apply(as(Groceries,"matrix"), 1, flatten_transactions)


data.trans = as.data.frame(groceries_flatten)
names(data.trans) = c("items")
head(data.trans)

# Crea el Objeto SparkDataFrame
df.groceries.items = createDataFrame(data.trans, schema = c("items"))

# Hace la conversión a transacciones
data <- selectExpr(df.groceries.items, "split(items, ',') as items")

# Configuración del Modelo FP-Growth
model = spark.fpGrowth(data = data, minSupport=0.05, minConfidence = 0.2)

# Búsqueda de Itemset Fecuentes
frequent_itemsets = spark.freqItemsets(model)

# Mostrar Itemsets Frecuentes
showDF(frequent_itemsets, truncate = F)

# Mostrar Reglas
association_rules = spark.associationRules(model)
showDF(association_rules, truncate=F)

write.parquet(association_rules, path = "~/reglas.parquet")

sparkR.session.stop()




