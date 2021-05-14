data = data.original
for (i in 1:(ncol(data)-1)) {
  if(is.factor(data[,i])) {
    cat('Es factor: ', names(data)[i] ,'.\n', sep="")

    for (j in (i+1):ncol(data)) {
      if(is.factor(data[,j])) {
        cat('Vamos a calcular chisqtest entre: ', names(data)[i] ,' y ',  names(data)[j], '.\n', sep="")
        tbl_cont = table(data[, i], data[, j])
        calculo = chisq.test(tbl_cont)
        
        cat('CHI2 ', names(data)[i] ,'-',  names(data)[j], ': ', calculo$statistic,'\n', sep="")
      }
    }
  }
}
