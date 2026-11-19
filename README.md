
# Post-contenido — Unidad 8: Operaciones con Cadenas y Aritmética

## Descripción

Laboratorio de Arquitectura de Computadores desarrollado en NASM sobre DOSBox. La actividad comprende dos partes: instrucciones de procesamiento de cadenas y operaciones de aritmética avanzada.

## Parte 1 — Instrucciones de Cadena

### Programas

- `post1.asm`: copia de cadenas mediante REP MOVSB y REP MOVSW.
- `post1c.asm`: búsqueda de caracteres mediante REPNE SCASB.
- `post1d.asm`: comparación de cadenas mediante REPE CMPSB.
- `post1e.asm`: copia con transformación a mayúsculas mediante LODSB y STOSB.

### Funcionamiento del flag DF

El flag de dirección (`DF`) controla el sentido en que avanzan los registros `SI` y `DI` durante las operaciones con cadenas. Cuando `DF=0`, los punteros avanzan hacia direcciones de memoria superiores; cuando `DF=1`, retroceden. En los programas de la Parte 1 se utiliza el recorrido hacia adelante para copiar, buscar, comparar y transformar los caracteres de las cadenas. La instrucción `CLD` permite establecer `DF=0` antes de realizar estas operaciones.

### Decisión técnica 1 — REP MOVSB frente a LODSB/STOSB

Para realizar una copia de memoria sin modificar su contenido, se considera más conveniente utilizar REP MOVSB en lugar de un bucle manual con LODSB y STOSB. El prefijo REP permite repetir la operación de copia mediante un mecanismo optimizado del procesador, evitando ejecutar explícitamente varias instrucciones y evaluar un salto condicional por cada byte. En cambio, el bucle manual requiere cargar el carácter, procesarlo, almacenarlo y controlar cada iteración, lo que generalmente implica un mayor costo de ejecución.

Sin embargo, en post1e.asm fue necesario utilizar LODSB y STOSB porque el objetivo no consistía únicamente en copiar la cadena, sino también en convertir sus caracteres de minúsculas a mayúsculas. Para ello, cada byte debía examinarse y, cuando correspondiera, modificarse mediante la instrucción SUB AL, 20h. Esta transformación no puede realizarse directamente con REP MOVSB, ya que dicha instrucción copia los bytes sin permitir incorporar operaciones intermedias sobre cada carácter.

Por lo tanto, si el laboratorio necesitara copiar una cadena larga sin realizar transformaciones, se elegiría REP MOVSB por su menor sobrecarga de control y su ejecución optimizada. El bucle manual se reservaría para situaciones en las que fuera necesario aplicar una lógica específica a cada carácter.

### Decisión técnica 2 — ¿CX fijo o verificación manual del terminador nulo?

El uso de `REPE CMPSB` y `REPNE SCASB` con un valor fijo en el registro `CX` resulta apropiado cuando se conoce previamente la longitud de las cadenas. Sin embargo, puede generar problemas al trabajar con cadenas de longitudes diferentes o desconocidas, debido a que estas instrucciones no identifican automáticamente el terminador nulo.

Por ejemplo, al comparar dos cadenas de 5 y 8 caracteres utilizando `REPE CMPSB` con `CX=8`, la instrucción podría continuar leyendo bytes posteriores al terminador nulo de la cadena más corta. Estos bytes corresponderían a posiciones de memoria adyacentes que no forman parte de su contenido, lo que podría producir comparaciones incorrectas o resultados impredecibles. En concreto, si las cadenas coinciden en sus primeros cinco caracteres, la comparación normalmente se detendría al encontrar el terminador nulo frente al sexto carácter de la cadena larga. No obstante, depender exclusivamente de un límite fijo no garantiza un tratamiento seguro de cadenas arbitrarias.

Para comparar cadenas de longitud desconocida, se considera más adecuado implementar un bucle manual basado en `LODSB`. Este procedimiento cargaría un carácter de la primera cadena en `AL`, conservaría su valor y cargaría el carácter correspondiente de la segunda cadena utilizando el puntero apropiado. Posteriormente, compararía ambos caracteres y comprobaría si alguno es nulo. Si los caracteres fueran diferentes, finalizaría indicando que las cadenas son distintas; si ambos fueran nulos, concluiría que son iguales. En caso contrario, continuaría con el siguiente par de caracteres.

En `post1d.asm`, utilizar `REPE CMPSB` con `CX=8` es una decisión apropiada porque las tres cadenas literales tienen exactamente ocho caracteres, longitud conocida desde el ensamblado. Por tanto, el número de comparaciones está delimitado correctamente. Para cadenas de longitud variable, sería preferible comprobar explícitamente los terminadores o determinar previamente sus longitudes.

## Parte 2 — Operaciones de Aritmética Avanzada

### Programas

- `post2.asm`: suma y resta de números de 32 bits mediante `ADD/ADC` y `SUB/SBB`. Las instrucciones `ADC` y `SBB` permiten incorporar el acarreo o préstamo indicado por el flag `CF` al operar con las palabras de mayor peso.
- `post2b.asm`: suma de números BCD empaquetados mediante `DAA`, que ajusta el resultado para mantener una representación decimal válida.
- `post2das.asm`: resta de números BCD empaquetados mediante `DAS`, que realiza el ajuste decimal después de la sustracción.
- `post2c.asm`: calculadora de un dígito que utiliza `MUL` y `DIV`, convierte caracteres ASCII a valores numéricos y muestra el resultado en formato decimal.
- `post2d.asm`: suma y resta de dígitos BCD desempaquetados mediante `AAA` y `AAS`, ajustando las unidades y las decenas del resultado.

### Decisión técnica 1 — ¿DAA/DAS o AAA/AAS según el formato del dato?

La elección entre las instrucciones DAA/DAS y AAA/AAS depende del formato en el que se encuentren representados los datos decimales. Las instrucciones DAA y DAS se utilizan para ajustar operaciones con BCD empaquetado, donde un byte almacena dos dígitos decimales. Por el contrario, AAA y AAS trabajan con BCD desempaquetado, en el que cada byte representa un solo dígito decimal.

Por ejemplo, si se utiliza AAA para ajustar una operación sobre el byte 47h, que representa los dígitos empaquetados 4 y 7, se produciría un resultado incorrecto porque AAA pone en cero el nibble alto de AL, eliminando la información correspondiente a las decenas.

En la calculadora del Paso 5, los caracteres leídos mediante INT 21h se convierten de ASCII a valores numéricos restando 30h. Como cada valor representa un único dígito desempaquetado, la instrucción apropiada para ajustar una suma de estos operandos sería AAA, inicializando previamente AH para representar correctamente las decenas.

Si se suman 07h y 08h, el resultado binario es 0Fh. Aplicar DAA produciría 15h, que representa el número 15 en BCD empaquetado, mientras que AAA produciría AH=01h y AL=05h, correspondiente a dos dígitos desempaquetados. Por tanto, aunque DAA genera una representación decimal válida, sería incorrecta para el formato esperado por una operación con BCD desempaquetado.

En conclusión, DAA/DAS deben utilizarse para BCD empaquetado y AAA/AAS para BCD desempaquetado, evitando interpretar incorrectamente los resultados o perder información durante los ajustes.

### Decisión técnica 2 — ¿ADC de precisión fija o una cadena de ADC en bucle?

En el programa `post2.asm` se realiza una suma de 32 bits utilizando dos registros de 16 bits para cada número. Primero se emplea `ADD` para sumar las partes bajas y después `ADC` para sumar las partes altas, incluyendo el acarreo generado por la operación anterior.

Si se necesitaran sumar números de 48, 64 bits o de mayor precisión, sería más conveniente implementar un bucle que recorra las palabras de ambos operandos desde la de menor peso hasta la de mayor peso. La primera pareja de palabras se sumaría mediante `ADD`, mientras que las siguientes utilizarían `ADC` para incorporar el valor del flag `CF` generado en la operación anterior.

La primera suma debe realizarse con `ADD` porque no existe un acarreo previo que deba propagarse. En cambio, las operaciones posteriores requieren `ADC`, ya que utilizar nuevamente `ADD` ignoraría el acarreo de la palabra anterior y podría producir un resultado incorrecto.

La principal ventaja del bucle genérico es su mantenibilidad, debido a que permite trabajar con números de diferentes tamaños sin escribir instrucciones adicionales para cada palabra. Este procedimiento también podría utilizarse como base para implementar operaciones con enteros de precisión arbitraria.

Sin embargo, el bucle introduce un costo adicional de ejecución porque necesita actualizar los índices, controlar las iteraciones y evaluar los saltos. Por esta razón, para números de 32 bits con longitud fija, el código de `post2.asm` resulta más sencillo y puede ser más eficiente. Esta diferencia es similar a la comparación entre `REP MOVSB` y el bucle manual con `LODSB/STOSB` de la Parte 1, donde una solución genérica ofrece mayor flexibilidad, pero también puede presentar una sobrecarga de procesamiento.
