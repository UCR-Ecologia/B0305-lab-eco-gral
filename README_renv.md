# 📦 Configuración del Entorno R para B0305 Lab Eco Gral

Este archivo `renv.lock` garantiza que todos los estudiantes tengan exactamente las mismas versiones de paquetes R para el curso.

## 🎯 Paquetes Incluidos para Ecología

### **📊 Análisis de Datos Básico:**
- `tidyverse` - Suite completa para manipulación y visualización de datos
- `dplyr` - Manipulación de datos
- `ggplot2` - Gráficos y visualizaciones
- `readr` / `readxl` - Importar datos CSV y Excel
- `writexl` - Exportar a Excel

### **🔬 Análisis Ecológico Especializado:**
- `vegan` - Análisis de comunidades ecológicas y biodiversidad
- `palmerpenguins` - Dataset de ejemplo para enseñanza

### **📈 Visualización y Presentación:**
- `plotly` - Gráficos interactivos
- `viridis` - Paletas de colores científicas
- `RColorBrewer` - Paletas de colores adicionales
- `kableExtra` - Tablas bonitas para reportes

### **📝 Reportes y Documentos:**
- `rmarkdown` - Documentos reproducibles
- `quarto` - Documentos científicos modernos
- `knitr` - Generación de reportes
- `DT` - Tablas interactivas

### **🧹 Limpieza de Datos:**
- `janitor` - Limpieza rápida de datos
- `here` - Manejo de rutas de archivos
- `lubridate` - Manipulación de fechas

## 🚀 Instrucciones para Estudiantes

### **Paso 1: Instalar renv**
```r
install.packages("renv")
```

### **Paso 2: Activar el entorno**
```r
# En RStudio, navegar al directorio del curso y ejecutar:
renv::restore()
```

### **Paso 3: Verificar instalación**
```r
# Verificar que los paquetes principales estén disponibles:
library(tidyverse)
library(vegan)
library(ggplot2)
library(palmerpenguins)

# Si no hay errores, ¡todo está listo! 🎉
```

## 🔧 Para Instructores

### **Actualizar el entorno:**
```r
# Después de instalar nuevos paquetes:
renv::snapshot()
```

### **Compartir con estudiantes:**
```r
# Los estudiantes solo necesitan ejecutar:
renv::restore()
```

## 📋 Versiones Específicas

- **R Version**: 4.4.1
- **Fecha de bloqueo**: Agosto 2025
- **Fuente**: CRAN (https://cran.rstudio.com)

## ⚠️ Solución de Problemas

Si tienes problemas con la instalación:

1. **Actualizar R y RStudio** a las versiones más recientes
2. **Limpiar caché**:
   ```r
   renv::clean()
   renv::restore()
   ```
3. **Reinstalar renv**:
   ```r
   remove.packages("renv")
   install.packages("renv")
   ```

## 📞 Soporte

Para problemas técnicos, contactar a los profesores del curso:
- Prof. G. Avalos: faetornis@gmail.com  
- Prof. T. Nakov: teofiln@gmail.com
