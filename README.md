@@ -12,7 +12,7 @@ Se debe construir el mejor modelo de Association Rules a través de Market Baske

Para ello puedes utilizar las distintas técnicas de Machine Learning disponibles para este tipo de problemas: Reglas de asociación, modelos de clasificación, etc…

1.- RESUMEN EL TRABAJO REALIZADO
## 1.- RESUMEN EL TRABAJO REALIZADO

Los primeros pasas dados para la resolver el reto propuesto, como en todo proyecto de datos, es la comprensión del problema mediante el análisis exhaustivo de los datos. Para esto usamos una herramienta de visualización llamada Spotfire creada por TIBCO, es una herramienta muy intuitiva  y cuya curva de aprendizaje no es muy elevada, teniendo en no mucho tiempo gráficos complejos para ser analizados. Se empezaron haciendo gráficos muy simples sobre el comportamiento global de cada variable hasta llegar a hacer gráficos más complejos que interaccionan unos con otros para conseguir comprender de los datos.

@@ -28,7 +28,7 @@ En el siguiente enlace de youtube se muestra un video donde se comenta todo el a
" target="_blank"><img src="http://img.youtube.com/vi/xB0ZPDH33lM/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="580" height="480" border="10" /></a>
	
2.- ANÁLISIS EXPLORATORIO Y COMPRESIÓN DEL NEGOCIO.
## 2.- ANÁLISIS EXPLORATORIO Y COMPRESIÓN DEL NEGOCIO.

Para hacer el análisis exploratorio se ha utilizado una herramienta de visualización llamada Spotfire, siendo muy parecida a Tableau. Con esta herramienta hemos hecho tres análisis sobre los datos. 
	
@@ -46,7 +46,7 @@ Observando que productos son los más vendidos, podemos destacar 6 productos, el
 
	
	
3.- MANIPULACIÓN DE VARIABLES
## 3.- MANIPULACIÓN DE VARIABLES
	
En este apartado se presentarán las distintas modificaciones que se le aplicaron a los conjuntos de datos de train y test así como las distintas variables adicionales que se crearon para comprender, analizar y resolver el problema.

@@ -66,7 +66,7 @@ Otra de las decisiones que se tomó, fue construir un dataset donde las columnas
		*Otra de las razones por la cuál decidimos realizar esta manipulación, es que nos permite obtener la matriz de correlación entre productos. Es decir, nos va a permitir encontrar la correlación que existe entre los productos que compran por ejemplo los clientes cuyo segmento es Agricultor. De esta forma podemos obtener información de si determinados productos se encuentran correlacionados de forma positiva, correlacionados de forma negativa o no están correlacionados.


4.- JUSTIFICACIÓN DEL MODELO (SELECCIÓN DE MODELO/S Y AJUSTE DE PARÁMETROS, ELECCIÓN DE MÉTRICA ELEGIDA Y JUSTIFICACIÓN, BONDAD DEL MODELO, INTERPRETABILIDAD DEL MODELO Y VIABILIDAD DE PUESTA EN PRODUCCIÓN)
## 4.- JUSTIFICACIÓN DEL MODELO (SELECCIÓN DE MODELO/S Y AJUSTE DE PARÁMETROS, ELECCIÓN DE MÉTRICA ELEGIDA Y JUSTIFICACIÓN, BONDAD DEL MODELO, INTERPRETABILIDAD DEL MODELO Y VIABILIDAD DE PUESTA EN PRODUCCIÓN)
	
Como hemos explicado anteriormente, el modelo utilizado es el de recomendación basado en el filtrado colaborativo. En la literatura encontramos diferentes librerías en R que nos facilita bastante la tarea de implementar el modelo.
	
