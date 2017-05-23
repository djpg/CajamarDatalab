#---------------------------------------------------------------------------------------------------------------#
#------------------------------- C?DIGO PARA LA REALIZACI?N DEL RETO CAJAMAR -----------------------------------#
#---------------------------------------------------------------------------------------------------------------#
#                                                                                                               #  
# En este Script se exponen todas las sentencias de R que se han ejecutado para hacer la exploracion de los     #
# datos y compresion del negocio. La disposici?n del c?digo es la siguiente:                                    #
#                                                                                                               #
#          1- RENOMBRADO DE COLUMNAS: Se hace el renombrado de las variables del conjunto de entrenamiento.     # 
#            Se cambian los valores num?ricos por su correspondiente etiqueta, con el fin de tener un conjunto  #
#            de entrenamiento m?s interpretable. Para el test se ha seguido exactamente el mismo procedimiento  #
#            pero con el fin de simplificar el c?digo no se ha incluido. Para renombrar el test bastar?a con    #                               
#            cambiar el fichero de entrada por el test.								                                          #
#                                                                                                   		        #
#         2- AN?LISIS TIME SERIE: En este punto se an?lizara la evoluci?n temporal del banco, con el objetivo   #
#            de comprobar la existencia de estacionalidad, es decir, que dependiendo de la epoca del a?o se     #
#            contraten unos productos u otros                                                                   #
#                                                                                                               #
#         3- CLIENTES: Se unifica los clientes contruyendo un dataset donde cada fila esta formada por un       #
#            cliente a?adiendo una columna adicional indicando los productos que compra, entre otras            #
#            variables adicionales. Este mismo procedimiento se hace para el caso del test, siguiendo           #
#            exactamente los mismos pasos el c?digo queda obviado por simplicidad                               #
#                                                                                                               #
#         4- CORRELACION: Se construye un dataset adicional donde por cada fila hay un cliente y en cada        #
#            columna se colocan todos los productos, marcando con 0 o 1 si ha comprado ese producto o no        #
#            a partir de esta información se construyen matrices de correlacion.                                #
#														                                                                                    #
#         5- PRODUCTOS NO COMPRADOS: A partir de an?lisis de correlaciones y de productos, se puede inferir     #
#            aquellos productos que un cliente no comprar?.Con esta informaci?n se construye una funci?n que    #
#            que devuelve el listado de productos que comprar? un nuevo cliente.                                #
#                        											                                                                  #
#         6- ALGORITMO DE RECOMENDACIÃN: En este punto se expone el algoritmo utilizado hasta llegar a la      #
#            predicciÃ³n del nuevo producto a adquirir por parte de los clientes del grupo test.                #
#                                                                                                               #
#         HERRAMIENTA_ADICIONAL: Por otro lado se ha programado una serie de sentencias de R que dado un c?digo #   
#           de producto escribe dos ficheros, uno de ellos est? compuesto por los clientes que han comprado ese #
#           producto, y el otro fichero est? compuesto por los clientes que no comprar ese producto. El fin de  #
#           estas sentencias es poder an?lizar facilmente es nuestra herramiento de visualizaci?n las           #
#           caracter?sticas de los clientes que compran un producto o no                                        #
#                                                                                                               #
#################################################################################################################

#Cargamos las librer?as de las que vamos hacer uso
library(data.table)
library(stringr)
library(tidyr)
library(dplyr)
library(plyr)
library(stats)
library(reshape2)
library(recommenderlab)

#--------------------------------------------------------------------------------------------------------------#
#------------------------------- 1- RENOMBRADO DE COLUMNAS Y ETIQUETADO DE VALORES ----------------------------#
#--------------------------------------------------------------------------------------------------------------#

setwd("C:/Users/RaulPortatil/Dropbox/Datathon_cajamar")

path <- paste0(getwd(),"/dataset/train2.txt")
t <- read.csv(path, sep="|",dec=",")

colnames(t) <- c("ID","Cod_Prod","Fecha","cod_Edad","cod_Antiguedad","cod_Ingresos","cod_Sexo","cod_Segmento")
d.t <- data.table(t)
setkeyv(d.t, c("ID"))

#EDAD: Cambiamos el c?digo de edad por su correspondiente etiqueta
d.t$Edad <- as.character(d.t$cod_Edad)
d.t$Edad <- ifelse(d.t$Edad == "1","< 18",d.t$Edad)
d.t$Edad <- ifelse(d.t$Edad == "2","[18-30]",d.t$Edad)
d.t$Edad <- ifelse(d.t$Edad == "3","[30-45]",d.t$Edad)
d.t$Edad <- ifelse(d.t$Edad == "4","[45-65]",d.t$Edad)
d.t$Edad <- ifelse(d.t$Edad == "5",">= 65",d.t$Edad)

#ANTIG?EDAD: Cambiamos el c?digo de antig?edad por su correspondiente etiqueta
d.t$Antiguedad <- as.character(d.t$cod_Antiguedad)
d.t$Antiguedad <- ifelse(d.t$Antiguedad == "1","< 1",d.t$Antiguedad)
d.t$Antiguedad <- ifelse(d.t$Antiguedad == "2","[1-5]",d.t$Antiguedad)
d.t$Antiguedad <- ifelse(d.t$Antiguedad == "3","[5-10]",d.t$Antiguedad)
d.t$Antiguedad <- ifelse(d.t$Antiguedad == "4","[10-20]",d.t$Antiguedad)
d.t$Antiguedad <- ifelse(d.t$Antiguedad == "5",">= 20",d.t$Antiguedad)

#INGRESOS: Cambiamos el c?digo de ingresos por su correspondiente etiqueta
d.t$Ingresos <- as.character(d.t$cod_Ingresos)
d.t$Ingresos <- ifelse(d.t$Ingresos == "1","< 6M",d.t$Ingresos)
d.t$Ingresos <- ifelse(d.t$Ingresos == "2","[6M-12M]",d.t$Ingresos)
d.t$Ingresos <- ifelse(d.t$Ingresos == "3","[12M-24M]",d.t$Ingresos)
d.t$Ingresos <- ifelse(d.t$Ingresos == "4","[24M-32M]",d.t$Ingresos)
d.t$Ingresos <- ifelse(d.t$Ingresos == "5",">= 32M",d.t$Ingresos)

#SEXO: Cambiamos el c?digo de sexo por su correspondiente etiqueta
d.t$Sexo <- as.character(d.t$cod_Sexo)
d.t$Sexo <- ifelse(d.t$Sexo == "1","Hombre",d.t$Sexo)
d.t$Sexo <- ifelse(d.t$Sexo == "2","Mujer",d.t$Sexo)

#SEGMENTO: Cambiamos el c?digo de segmento por su correspondiente etiqueta
d.t$Segmento <- as.character(d.t$cod_Segmento)
d.t$Segmento <- ifelse(d.t$Segmento == "0","Particular",d.t$Segmento)
d.t$Segmento <- ifelse(d.t$Segmento == "1","Agricultor",d.t$Segmento)
d.t$Segmento <- ifelse(d.t$Segmento == "2","Comercio",d.t$Segmento)
d.t$Segmento <- ifelse(d.t$Segmento == "3","Autonomo",d.t$Segmento)

#PASAR A DATE: Para esto hay que a?adir el campo d?a, por ejemplo el d?a 1 de cada mes
d.t$Fecha <- as.Date(paste0(d.t$Fecha,"-01"))

#A?ADIMOS EN COLUMNAS SEPARADAS EL MES, EL A?O Y EL D?A
a <- as.data.frame(str_split_fixed(as.character(d.t$Fecha), "-", 3))
colnames(a) <- c("A?o","Mes","Dia")
a$Date <- paste(a$Dia,a$Mes,a$A?o, sep="-" )
a$Dia <- NULL
d.t <- cbind(d.t,a)
d.t$Fecha <- NULL

#A?adimos una nueva variable que se va a denominar estaci?n que nos va indicar la estaci?n en la 
#cual el cliente contrato un determinado producto 
d.t$Estacion <- ifelse(d.t$Mes =="3" | d.t$Mes == "4" | d.t$Mes == "5",
                                       "Primavera", d.t$Mes)

d.t$Estacion <- ifelse(d.t$Mes == "6"| d.t$Mes == "7" | d.t$Mes == "8",
                                       "Verano", d.t$Estacion)

d.t$Estacion <- ifelse(d.t$Mes == "9" | train$Mes == "10" | d.t$Mes == "11",
                                       "Oto?o", d.t$Estacion)

d.t$Estacion <- ifelse(d.t$Mes == "12" | d.t$Mes == "1" | d.t$Mes == "2",
                                       "Invierno", d.t$Estacion)
out_file <- paste0(getwd(),"/dataset/train_procesado.csv")
write.table(d.t,out_file,row.names = FALSE,sep = "|", quote = FALSE)

#-----------------------------------------------------------------------------------------------#
#---------------------------------- 2- AN?LISIS DE TIME SERIES ---------------------------------#
#-----------------------------------------------------------------------------------------------#

# setwd("C:/Users/RaulPortatil/Dropbox/Datathon_cajamar")
# setwd("D:/Dropbox/Datathon_cajamar")

path <- paste0(getwd(),"/dataset/train_procesado.csv")
t <- read.csv(path, sep="|",dec=",",stringsAsFactors = FALSE)
#Se pone la variable Date en el formato y tipo correcto para su posterior procesamiento
t$Date <- as.Date(t$Date,format = "%d-%m-%Y")

#Se resume cada producto en una sola l?nea a?adiendo, la primera y ultima compra que se realiz? de dicho
#producto y el n?mero de clientes que lo han comprado.
df <- ddply(t,.(Cod_Prod),summarise,min_date = min(Date), max_date = max(Date),n_customers = length(Cod_Prod))

#Se a?ade otra columna que indica el tiempo que ha pasado entre la ?ltima y primera compra del producto en a?os.
df$diff <- round((as.Date(as.character(df$max_date), format="%Y-%m-%d") - as.Date(as.character(df$min_date), format="%Y-%m-%d"))/365)
df <- dplyr::arrange(df,n_customers,diff)

#Se filtrar para obtener el dataset con a?os completos, que tenga los 12 meses, esto pasa a partir de 1969
ts <- t[t$A?o >= 1969,]

out_file <- paste0(getwd(),"/dataset/time_series_complete.csv")
write.table(ts,out_file,row.names = FALSE,sep = "|", quote = FALSE)

#-----------------------------------------------------------------------------------------------#
#--------------------------------------- 3- RESUMIR CLIENTES -----------------------------------#
#-----------------------------------------------------------------------------------------------#

#Al igual que se hace con los productos, se hace sobre los clientes. Poner en una sola linea los clientes
#junto con sus productos que ha comprado y otras variables extras que se explican a continuaci?n.
# setwd("C:/Users/RaulPortatil/Dropbox/Datathon_cajamar")
setwd("D:/Dropbox/Datathon_cajamar")

path <- paste0(getwd(),"/dataset/train_procesado.csv")
t <- read.csv(path, sep="|",dec=",",stringsAsFactors = FALSE)
t$Date <- as.Date(t$Date,format = "%d-%m-%Y")
#Se ordena por fecha para asi poder obtener los productos que compra un cliente por el orden de compra.
t <- dplyr::arrange(t, Date)
t <- data.table(t)
setkeyv(t, c("ID"))

#Se hace un resumen de los clientes y se le a?ade a cada fila la lista de productos en formato lista
#y en formato character junto con el n?mero de prodcutos que ha comprado ese cliente y la fecha de la primera
#y ultima compra de producto.
df.t <- data.frame(t[, list(list_prod = list(Cod_Prod),array_prod = paste(Cod_Prod,collapse = "-"),n_prod = length(Cod_Prod),min_date = min(Date), max_date = max(Date)), by=key(t)])

#Otra variable adicional que se calcula es la frecuencia de compra que tiene un cliente, este calculo
#se hace restando la fecha del primer producto y el ?ltimo y diviendola por el n?mero de productos.
df.t$Freq <- as.integer(round((as.Date(as.character(df.t$max_date), format="%Y-%m-%d") - as.Date(as.character(df.t$min_date), format="%Y-%m-%d"))/365))
df.t$Freq <- format(round(df.t$Freq/df.t$n_prod, 1), nsmall = 1)

t2 <- t
t2$Cod_Prod <- NULL
t2$Date <- NULL
t2$Mes <- NULL
t2$A?o <- NULL

#La informaci?n calculada anteriormente se le hace un join con la tabla cliente para asingarle a cada
#cliente toda la informaci?n previa.
t2 <- t2[!duplicated(t2),]
t2 <- dplyr::select(t2,ID,Edad,Antiguedad,Ingresos,Sexo,Segmento)
df.t <- merge(t2,df.t,by = ("ID"),all.x = TRUE)

df.t$list_prod <- NULL
out_file <- paste0(getwd(),"/dataset/summarise_client.csv")
write.table(df.t,out_file,row.names = FALSE,sep = "|", quote = FALSE)


#-----------------------------------------------------------------------------------------------#
#---------------------------------------- 4- CORRELACION ---------------------------------------#
#-----------------------------------------------------------------------------------------------#


#A continuaci?n vamos a proceder a manipular el dataset, de forma que vamos a poner cada producto como 
#una columna en nuestro dataset. Para ello hacemos uso de la funci?n dcast del paquete reshape2. El 
#objetivo final es para cada cliente tener el valor de 1 o 0 en funci?n de si tiene o no tiene un 
#determinado producto.

path <- "C:/Users/fvilchez/Dropbox/Datathon_cajamar/dataset"
setwd(path)
files <- list.files(path)
train <-read.delim(files[8], header = TRUE, sep = "|")
train[3:7] <- NULL

train_reshape <- reshape2::dcast(train, ID + Edad + Antiguedad + Ingresos + Sexo + Segmento + Anyo + Estacion ~ Cod_Prod)

#Liberamos espacio en memoria
rm(train)

#Pasamos nuestro nuevo dataset a tipo data.table con el fin de operar de forma m?s eficiente
setDT(train_reshape)

#Almacenamos los distintos c?digos de producto que tenemos
cod_prod <- names(train_reshape[,9:102])

#Funci?n que le asigna un 1 si el cliente tiene contratado dicho producto y 0 en caso contrario
asocia_producto <- function(Cod_Prod,df){
  df[[Cod_Prod]] <- ifelse(is.na(df[[Cod_Prod]]),0,1)
}

#Nos creamos una lista  de listas donde cada posici?n de nuestra lista ser? nuestro producto con el 
#valor de 0 y 1 en funci?n de si un cliente tiene o no un determinado producto.
lista <- lapply(cod_prod, asocia_producto, train_reshape)

#Nos creamos un datafrema con la lista de listas que ten?amos anteriormente y nombramos de forma adecuada
#cada una de las columnas
lista <- data.frame(matrix(unlist(lista),ncol = 94, byrow=FALSE))
names(lista) <- cod_prod

#Pasamos una vez m?s a tipo data.table con el fin de optimizar los c?lculos
setDT(lista)

#La agregamos la informaci?n de los clientes
train_reshape <- cbind(train_reshape[,1:8, with = FALSE], lista)

#Liberamos espacio en memoria
rm(lista)

#A continuaci?n procedemos a agrupar los clientes de forma ?nica, es decir tras esto vamos a obtener un
#data frame que cada fila ser? un cliente ?nico. De cada cliente tendremos la siguiente informaci?n: ID,
#Edad, Antiguedad, Ingresos, Sexo, Segmento y para cada producto tendr? el valor de 0 si dicho cliente
#no contrat? dicho producto y el valor de 1 si el cliente contrato dicho producto. Finalmente el
#dataframe df_cliente tendr? unas dimensiones de 676370 x 100

train_reshape <- as.data.frame(train_reshape)
train_reshape_ID <- aggregate(x=train_reshape[,9:102], by=list(ID=train_reshape$ID),max,na.rm = TRUE)
summarise_client <-read.delim(files[4], header = TRUE, sep = "|")
setDT(summarise_client)
df_info_client <- summarise_client[,1:6, with = FALSE]
#Hacemos un merge por ID
df_cliente <- merge(df_info_client, train_reshape_ID, by = "ID")


#Una vez tenemos nuestro dataframe modificado, vamos a proceder a calcular la correlaci?n existente entre productos.

#Funci?n que nos permite eliminar componentes redundantes de la matriz de correlaci?n.
elimina_redundantes <- function(x){
  paste(sort(c(x[1],x[2])),collapse = "_")
}

#Funci?n que nos calcula la matriz de correlaci?n entre productos del dataframe filtrado por un campo
#concreto y su valor.  Debemos pasarle el data_frame denominado df_cliente.
#Ejemplo: si queremos obtener la correlaci?n de los productos de los clientes cuyo valor de segmento es 
#Agricultor deberiamos realizar la siguiente llamada:
#correlacion_productos_agricultor <- calcula_matriz_correlacion(df, df$Segmento, "Agricultor")

calcula_matriz_correlacion <- function(df, campo, valor){
  df_filtrado <- filter(df,campo == valor)
  productos_no_comprados <- names(which(colSums(df_filtrado[7:100]) == 0))
  df_filtrado[productos_no_comprados] <- NULL
  matriz_corr <- cor(df_filtrado[,7:ncol(df_filtrado)])
  matriz_corr_order <- as.data.frame(as.table(matriz_corr))
  matriz_corr_order$Var1 <- as.character(matriz_corr_order$Var1)
  matriz_corr_order$Var2 <- as.character(matriz_corr_order$Var2)
  df <- select(matriz_corr_order, Var1, Var2)
  b <- data.frame(Var3 = apply(df, 1, elimina_redundantes))
  matriz_corr_order<- cbind(matriz_corr_order,b)
  df_unique <- ddply(matriz_corr_order,.(Var3),summarise,Freq = format(max(Freq), scientific=FALSE))
  df_unique <- separate(df_unique, Var3, c("Codigo1", "Codigo2"), sep = "_")
}


#-----------------------------------------------------------------------------------------------#
#-------------------------------------- 5- USER_COD_PROD ---------------------------------------#
#-----------------------------------------------------------------------------------------------#

setwd("C:/Users/RaulPortatil/Dropbox/Datathon_cajamar")
# setwd("D:/Dropbox/Datathon_cajamar")

path <- paste0(getwd(),"/dataset/train_procesado.csv")
df <- read.csv(path, sep="|",dec=",",stringsAsFactors = FALSE)

setwd("C:/Users/RaulPortatil/Dropbox/Datathon_cajamar")
path <- paste0(getwd(),"/dataset/summarise_client.csv")
df_user <- read.csv(path, sep="|",dec=",",stringsAsFactors = FALSE)

prod <- data.frame(Prod = unique(df$Cod_Prod))
prod$Prod <- as.character(prod$Prod)

#Mediante el an?lisis previo se puede saber cuales son los productos que no compra un cliente en 
#funcion del valor de cada variable que tenga. A continuaci?n se crean tantos vectores diferentes
#como posibles valores pueda asignarle a cada variable. A cada uno de estos vectores se asigna los valores
#de los productos que no compra.

Agricultor <- data.frame(Val = c("502","804","1014","1305","1308","1312","2104","2502","2901"))
Comercio <- data.frame(Val = c("502","803","1305","1308","1312","2104"))
Autonomos <- data.frame(Val = c("1308","1312"))

i_menor_6M <- data.frame(Val = c("502","1308","1312","2502"))
i_6M_12M <- data.frame(Val = c("502","1308","1312"))
i_12M_24M <- data.frame(Val = c("1312","2901"))
i_24M_32M <- data.frame(Val = c("502","803","1014","1308","1312","2801"))

s_mujeres <- data.frame(Val = c("1312","2901"))

e_menor_18 <- data.frame(Val = c("101","102","103","104","502","503","504","506","705","801","803","804","1001","1002","1004","1005","1006","1007","1008","1009","1010","1011",
                                 "1012","1014","1015","1017","1019","1020","1021","1022","1305","1308","1312","1401","1501","1801","1803","1805","1806","2103","2104","2105","2106",
                                 "2201","2202","2203","2204","2206","2502","2601","2701","2702","2703","2706","2707","2801","2901","3001","3101","3401"))
e_18_30 <- data.frame(Val = c("502","504","703","803","804","1004","1014","1015", "1305","1308","1312","1803","1806","2104","2105","2502","2801","2901"))
e_30_45 <- data.frame(Val = c("1014","1312","2104","2105"))
e_45_65 <- data.frame(Val = c("502","1308","1312","2901"))
e_mayor_65 <- data.frame(Val = c("502","803","2901"))

a_menor_1 <- data.frame(Val = c("101","104","502","504","702","703","705","708","803","804","1004","1005","1007","1008","1012","1014","1015","1019","1021","1301",
                                "1302","1305","1308","1312","1401","1803","1806","2104","2105","2203","2502","2703","2706","2801","2901","3101"))
a_1_5 <- data.frame(Val = c("104","502","504","703","705","1004","1014","1015","1305","1308","1312","1803","2104","2502","2801"))
a_5_10 <- data.frame(Val = c("1004","1014","1308","1312"))
a_10_20 <- data.frame(Val = c("502"))
a_mayor_20 <- data.frame(Val = c("803","1312"))

#Funcion que devuevle por dada cliente del dataset que productos comprar?. Esto se hace restando al listado de
#productos totales que es conocido, cada uno de los vectores declarados anteriormente.
fun1 <- function(x,prod,e_menor_18,e_18_30,e_30_45,e_45_65,e_mayor_65,
                 a_menor_1,a_1_5,a_5_10,a_10_20,a_mayor_20,i_menor_6M,
                 i_6M_12M,i_12M_24M,i_24M_32M,s_mujeres,Agricultor,Autonomos,Comercio){
  
  edad <- x[2]
  antigueda <- x[3]
  ingresos <- x[4]
  sexo <- x[5]
  segmento <- x[6]
  
  
  if(edad == "< 18"){
    prod <- data.frame(Prod = setdiff(prod$Prod,e_menor_18$Val))
  }else if(edad == "[18-30]"){
    prod <- data.frame(Prod = setdiff(prod$Prod,e_18_30$Val))
  }else if(edad == "[30-45]"){
    prod <- data.frame(Prod = setdiff(prod$Prod,e_30_45$Val))
  }else if(edad == "[45-65]"){
    prod <- data.frame(Prod = setdiff(prod$Prod,e_45_65$Val))
  }else if(edad == ">= 65"){
    prod <- data.frame(Prod = setdiff(prod$Prod,e_mayor_65$Val))
  }
  
  if(antigueda == "< 1"){
    prod <- data.frame(Prod = setdiff(prod$Prod,a_menor_1$Val))
  }else if(antigueda == "[1-5]"){
    prod <- data.frame(Prod = setdiff(prod$Prod,a_1_5$Val))
  }else if(antigueda == "[5-10]"){
    prod <- data.frame(Prod = setdiff(prod$Prod,a_5_10$Val))
  }else if(antigueda == "[10-20]"){
    prod <- data.frame(Prod = setdiff(prod$Prod,a_10_20$Val))
  }else if(antigueda == ">= 20"){
    prod <- data.frame(Prod = setdiff(prod$Prod,a_mayor_20$Val))
  }
  
  if(segmento == "< 6"){
    prod <- data.frame(Prod = setdiff(prod$Prod,i_menor_6M$Val))
  }else if(segmento == "[6M-12M]"){
    prod <- data.frame(Prod = setdiff(prod$Prod,i_6M_12M$Val))
  }else if(segmento == "[12M-24M]"){
    prod <- data.frame(Prod = setdiff(prod$Prod,i_12M_24M$Val))
  }else if(segmento == "[24M-32M]"){
    prod <- data.frame(Prod = setdiff(prod$Prod,i_24M_32M$Val))
  }
  
  if(sexo == "Mujer"){
    prod <- data.frame(Prod = setdiff(prod$Prod,s_mujeres$Val))
  }
  
  if(ingresos == "Agricultor"){
    prod <- data.frame(Prod = setdiff(prod$Prod,Agricultor$Val))
  }else if(ingresos == "Autonomo"){
    prod <- data.frame(Prod = setdiff(prod$Prod,Autonomos$Val))
  }else if(ingresos == "Comercio"){
    prod <- data.frame(Prod = setdiff(prod$Prod,Comercio$Val))
  }
  prod$Prod <- as.character(prod$Prod)
  exit <- data.frame(ID = x[1],Prod = paste(prod$Prod,collapse = "-"), N = dim(prod)[1])
  exit
}

#Se aplica un apply a la funcion
out <- apply(df_user,1,fun1,prod,e_menor_18,e_18_30,e_30_45,e_45_65,e_mayor_65,a_menor_1,a_1_5,a_5_10,a_10_20,a_mayor_20,i_menor_6M,i_6M_12M,i_12M_24M,i_24M_32M,s_mujeres,Agricultor,Autonomos,Comercio)
#Se pasa a dataframe
list_df <- lapply(out, data.frame, stringsAsFactors = FALSE)
df_final <- ldply(list_df, data.frame)
df_final$.id <- NULL

#-----------------------------------------------------------------------------------------------#
#------------------------------- 6- ALGORITMO DE RECOMENDACIÃN --------------------------------#
#-----------------------------------------------------------------------------------------------#

# Para crear el algoritmo de recomendaciÃ³n solamente necesitamos hacer uso del dataset df_clientes,
# ya que cada fila es un Ãºnico cliente elimanaremos las columnas ID, Edad, Antiguedad, Ingresos, 
# Sexo, Segmento y nos quedaremos con cada columna que representa cada producto, con 1 Ã³ 0 si el cliente
# ha comprado dicho producto o no respectivamente.
# Finalmente el dataframe df_cliente tendrÃ¡ unas dimensiones de 676370 x 94
# Hacemos lo mismo con el test dataset.

datos <- df_cliente[,-(1:6)]
data_test0 <- read.csv(file="~/Dropbox/Datathon_cajamar/dataset/test_reshape.csv", header = TRUE, check.names=FALSE)
data_test <- data_test0[,-1]

# Tenemos que transformar los datos al formato "binaryRatingMatrix". Necesitamos previamente pasarlos
# a factor para transformarlos a "transactions" y posteriormente a "binaryRatingMatrix".

for(i in 1:length(datos)){
  datos[[i]] <- as.factor(datos[[i]])
}
datos <- as(datos, "transactions") 
datos <- as(datos, "binaryRatingMatrix")

for(i in 1:length(data_test)){
  data_test[[i]] <- as.factor(data_test[[i]])
}
data_test <- as(data_test, "transactions") 
data_test <- as(data_test, "binaryRatingMatrix")


# Para evitar un sobreajuste del modelo realizamos validaciÃ³n cruzada. AsÃ� obtendremos un modelo mÃ¡s genÃ©rico
# que nos pueda dar los mejores resultados en cualquier nueva situaciÃ³n.
eval_sets <- evaluationScheme(data = datos,method = "cross-validation",k = 4, given = 10)

# Para la optimizaciÃ³n del parÃ¡metro K usamos un grid con diferentes valores. Con la curva ROC obtenemos el 
# valor de k que mejor resultado nos reporta. El mÃ©todo es el IBCF y como la matrix de rating es binary, 
# establecemos el mÃ©todo de distancia entre preoductos como Jaccard.

n_recommendations <- 1
model_to_evaluate <- "IBCF"
vector_k <- c(10, 20, 30, 40)
models_to_evaluate <- lapply(vector_k, function(k){
  list(name = "IBCF", param = list(method = "Jaccard", k = k))
})
names(models_to_evaluate) <- paste0("IBCF_k_", vector_k)

list_results <- evaluate(x = eval_sets, method = models_to_evaluate, n = n_recommendations)
plot(list_results, annotate = 1, legend = "topleft") 
title("ROC curve")
plot(list_results, "prec/rec", annotate = TRUE, main = "Precision-recall")
# El mejor valor de K es 30, que es el que viene por defecto.

recc_model <- Recommender(data = datos, method = "IBCF", parameter = list(method = "Jaccard"))
recc_predicted <- predict(object = recc_model, newdata = data_test, n = n_recommendations)
recc_matrix <- sapply(recc_predicted@items, function(x){
  colnames(datos)[x]
})
output <- matrix(unlist(recc_matrix), ncol = 1, byrow = TRUE)
output <- gsub('=1','',output)
t <- as.data.frame(data_test0[,1])
colnames(t) <- "ID_Custumer"
colnames(output) <- "Cod_Prod"
Test_Mission <- cbind(t,output)

out_file <- paste0(getwd(),"/dataset/Test_Mission.txt")
write.table(Test_Mission, out_file, row.names = FALSE, sep = "|", quote = FALSE)


#-----------------------------------------------------------------------------------------------#
#-------------------------------------- HERRAMIENTA AUXILIAR -----------------------------------#
#----------------------------------------- FIND COD_PROD ---------------------------------------#
#-----------------------------------------------------------------------------------------------#

setwd("C:/Users/RaulPortatil/Dropbox/Datathon_cajamar")
# setwd("D:/Dropbox/Datathon_cajamar")

#Funcion que filtra que clientes compran o no compran un producto dado como par?metro y escribiendo
#dos ficheros con esta informacion.
find_prod <- function(original.t,df.t,prod){
  
  eq <- data.table(filter(original.t,Cod_Prod %in% prod) %>% select(ID))
  user_unique <- data.table(ID = unique(original.t$ID))
  neq <- data.table(ID = setdiff(user_unique$ID,eq$ID))
  eq <- merge(eq,df.t, by = ("ID"),all.x = TRUE)
  neq <- merge(neq,df.t, by = ("ID"),all.x = TRUE)
  
  eq$cod_prod = paste0(prod,collapse = "-")
  neq$cod_prod = paste0(prod,collapse = "-")
  
  out_file <- paste0(getwd(),"/dataset/equal_cod_prod.csv")
  write.table(eq,out_file,row.names = FALSE,sep = "|", quote = FALSE)
  
  out_file <- paste0(getwd(),"/dataset/nequal_cod_prod.csv")
  write.table(neq,out_file,row.names = FALSE,sep = "|", quote = FALSE)
  
}

path <- paste0(getwd(),"/dataset/train_procesado.csv")
t <- read.csv(path, sep="|",dec=",",stringsAsFactors = FALSE)

path <- paste0(getwd(),"/dataset/summarise_client.csv")
df <- read.csv(path, sep="|",dec=",",stringsAsFactors = FALSE)

df.t <- setDT(df, keep.rownames = FALSE, key= "ID")
original.t <- setDT(t, keep.rownames = FALSE, key= "ID")
#En este punto se indica que productos o productos queremos que procese la funci?n.
prod <- c(601)

find_prod(original.t,df.t,prod)


