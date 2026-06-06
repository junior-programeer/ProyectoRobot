# 🤖 Manual de Usuario

## Robot móvil seguidor de luz con evasión de obstáculos

**Materia:** Diseño Digital VLSI
**Proyecto Final:** Robot móvil seguidor de luz con evasión de obstáculos
**Tarjeta utilizada:** FPGA Intel DE10-Lite
**Lenguaje:** VHDL

---

## 👥 Integrantes

* Almodovar Tufiño Tarek - 423127375
* Najera Higuera Junior Josue - 421112869
* Romero Calixto Carlo Magno - 320187890
* Lopez Gonzalez Hector Albino - 320342732

**Fecha de entrega:** 05 de Junio de 2026

---

## 📌 Índice

1. [Presentación](#1-presentación)
2. [Objetivo del manual](#2-objetivo-del-manual)
3. [Descripción general del robot](#3-descripción-general-del-robot)
4. [Componentes principales](#4-componentes-principales)
5. [Funcionamiento general](#5-funcionamiento-general)
6. [Asignación de pines](#6-asignación-de-pines)
7. [Requisitos antes de usar el robot](#7-requisitos-antes-de-usar-el-robot)
8. [Procedimiento de conexión](#8-procedimiento-de-conexión)
9. [Encendido del robot](#9-encendido-del-robot)
10. [Calibración de sensores LDR](#10-calibración-de-sensores-ldr)
11. [Operación del robot](#11-operación-del-robot)
12. [Estados del robot](#12-estados-del-robot)
13. [Indicadores LED](#13-indicadores-led)
14. [Prueba de funcionamiento](#14-prueba-de-funcionamiento)
15. [Recomendaciones de uso](#15-recomendaciones-de-uso)
16. [Precauciones de seguridad](#16-precauciones-de-seguridad)
17. [Problemas comunes y soluciones](#17-problemas-comunes-y-soluciones)
18. [Mantenimiento](#18-mantenimiento)
19. [Limitaciones de uso](#19-limitaciones-de-uso)
20. [Apagado del robot](#20-apagado-del-robot)
21. [Video funcional](#21-video-funcional)
22. [Conclusión del manual](#22-conclusión-del-manual)
23. [Referencias](#23-referencias)
24. [Archivos recomendados para el repositorio](#24-archivos-recomendados-para-el-repositorio)
25. [Resumen rápido de uso](#25-resumen-rápido-de-uso)

---

# 1. Presentación

Este manual de usuario tiene como finalidad explicar el uso, conexión, operación y recomendaciones generales del **robot móvil seguidor de luz con evasión de obstáculos**, desarrollado como proyecto final para la materia de **Diseño Digital VLSI**.

El robot fue diseñado para detectar una fuente luminosa mediante sensores LDR y desplazarse hacia ella. Además, cuenta con un sensor ultrasónico frontal HC-SR04, el cual permite detectar obstáculos cercanos y ejecutar una maniobra de esquive.

Este documento está dirigido a cualquier persona que necesite operar, probar o revisar el funcionamiento general del robot, sin necesidad de conocer a profundidad todo el código VHDL utilizado.

---

# 2. Objetivo del manual

El objetivo de este manual es proporcionar una guía clara para utilizar correctamente el robot móvil, explicando:

* ✅ Componentes principales del sistema.
* ✅ Procedimiento de conexión.
* ✅ Encendido y apagado del robot.
* ✅ Calibración de sensores.
* ✅ Estados de funcionamiento.
* ✅ Indicadores LED.
* ✅ Recomendaciones de seguridad.
* ✅ Problemas comunes y posibles soluciones.
* ✅ Limitaciones generales del prototipo.

---

# 3. Descripción general del robot

El robot móvil seguidor de luz con evasión de obstáculos es un prototipo académico construido con una tarjeta **FPGA Intel DE10-Lite**, sensores de luz, un sensor ultrasónico, un driver de motores y dos motores de corriente directa.

Su función principal es detectar una fuente luminosa y desplazarse de acuerdo con la dirección donde se encuentre dicha fuente. Cuando el robot detecta un obstáculo frente a él, cambia temporalmente su comportamiento y realiza una maniobra de esquive.

El sistema trabaja mediante lógica digital implementada en VHDL. La FPGA recibe las señales de los sensores, procesa la información mediante una Máquina de Estados Finitos y genera señales de salida para controlar los motores.

---

# 4. Componentes principales

| Componente                       | Función                                                     |
| -------------------------------- | ----------------------------------------------------------- |
| FPGA Intel DE10-Lite             | Ejecuta la lógica digital programada en VHDL.               |
| Sensores LDR                     | Detectan la dirección de la fuente luminosa.                |
| Sensor ultrasónico HC-SR04       | Detecta obstáculos al frente del robot.                     |
| Driver de motores                | Permite controlar los motores usando señales de la FPGA.    |
| Motores DC                       | Generan el movimiento físico del robot.                     |
| Base del robot                   | Sostiene la tarjeta, sensores, cables, motores y driver.    |
| Batería o fuente de alimentación | Proporciona energía al sistema.                             |
| LEDs de estado                   | Muestran el estado actual de la Máquina de Estados Finitos. |
| Cables Dupont                    | Permiten realizar las conexiones entre módulos.             |

---

# 5. Funcionamiento general

El robot funciona mediante una combinación de sensores, lógica digital y actuadores.

Primero, los sensores LDR detectan la presencia de luz. Dependiendo del sensor que reciba mayor iluminación, la FPGA determina hacia dónde debe moverse el robot.

Al mismo tiempo, el sensor ultrasónico frontal revisa si existe un obstáculo cercano. Si se detecta un objeto a una distancia menor o igual al umbral programado, el robot deja de seguir la luz momentáneamente y ejecuta una maniobra de evasión.

## 🧠 Idea principal del sistema

```text
Sensores LDR + Sensor ultrasónico
              ↓
        FPGA DE10-Lite
              ↓
      Máquina de Estados
              ↓
       Driver de motores
              ↓
          Motores DC
```

## 🔁 Flujo básico de operación

```text
Inicio
  ↓
Buscar luz
  ↓
Detectar fuente luminosa
  ↓
Seguir luz
  ↓
¿Hay obstáculo?
  ├── Sí → Esquivar obstáculo
  └── No → Continuar siguiendo luz
  ↓
Llegar a la meta
  ↓
Detener robot
```

---

# 6. Asignación de pines

La siguiente tabla muestra la asignación de pines utilizada para conectar los sensores, motores y LEDs a la tarjeta FPGA DE10-Lite.

| Señal           | Dirección | Pin        |
| --------------- | --------- | ---------- |
| `clk`           | Entrada   | `PIN_P11`  |
| `reset`         | Entrada   | `PIN_B8`   |
| `ldr_front`     | Entrada   | `PIN_W10`  |
| `ldr_left`      | Entrada   | `PIN_W7`   |
| `ldr_right`     | Entrada   | `PIN_W9`   |
| `ldr_back`      | Entrada   | `PIN_V10`  |
| `us_echo`       | Entrada   | `PIN_AB12` |
| `us_trigger`    | Salida    | `PIN_Y11`  |
| `mot_l_a`       | Salida    | `PIN_AA15` |
| `mot_l_b`       | Salida    | `PIN_W13`  |
| `mot_r_a`       | Salida    | `PIN_W5`   |
| `mot_r_b`       | Salida    | `PIN_AA14` |
| `leds_state[0]` | Salida    | `PIN_A8`   |
| `leds_state[1]` | Salida    | `PIN_A9`   |
| `leds_state[2]` | Salida    | `PIN_A10`  |

> ⚠️ Es importante respetar esta asignación de pines para que el código funcione correctamente con la conexión física del robot.

---

# 7. Requisitos antes de usar el robot

Antes de utilizar el robot, se recomienda verificar lo siguiente:

* ✅ La tarjeta DE10-Lite debe estar correctamente alimentada.
* ✅ El archivo de programación debe estar cargado en la FPGA.
* ✅ Los sensores LDR deben estar conectados a los pines correspondientes.
* ✅ El sensor ultrasónico debe tener conectados los pines de alimentación, `trigger`, `echo` y tierra.
* ✅ La señal `echo` del sensor ultrasónico debe llegar a la FPGA con un nivel seguro de 3.3 V.
* ✅ El driver de motores debe estar conectado correctamente.
* ✅ Los motores deben estar conectados al driver.
* ✅ La batería o fuente de alimentación debe tener carga suficiente.
* ✅ El robot debe colocarse sobre una superficie plana.
* ✅ Debe existir una fuente luminosa que el robot pueda detectar.
* ✅ El área de prueba debe estar libre de objetos peligrosos o cables sueltos.
* ✅ Las ruedas deben poder girar libremente.

---

# 8. Procedimiento de conexión

Para preparar el robot antes de la prueba, se recomienda seguir este procedimiento:

1. Colocar el robot sobre una superficie plana y estable.
2. Verificar que la tarjeta DE10-Lite esté bien sujetada a la base del robot.
3. Conectar los sensores LDR a sus respectivos pines de entrada.
4. Conectar el sensor ultrasónico HC-SR04.
5. Verificar que la señal `echo` del sensor ultrasónico llegue a la FPGA con un nivel seguro de 3.3 V.
6. Conectar las señales de control de motores desde la FPGA hacia el driver.
7. Conectar los motores al driver.
8. Conectar la alimentación del driver de motores.
9. Conectar la alimentación de la tarjeta FPGA.
10. Cargar el archivo de programación en la FPGA, en caso de que no esté cargado.

> 🛠️ **Nota:** Se recomienda revisar todas las conexiones antes de energizar el sistema para evitar daños en la tarjeta, sensores o driver de motores.

---

# 9. Encendido del robot

Para encender el robot correctamente, siga los pasos indicados a continuación:

1. Colocar el robot en el área de prueba.
2. Verificar que no haya obstáculos demasiado cerca del robot al momento de iniciar.
3. Encender o conectar la alimentación de la tarjeta FPGA.
4. Encender o conectar la alimentación del driver de motores.
5. Presionar el botón de reset si se desea iniciar nuevamente el comportamiento del robot.
6. Esperar aproximadamente un segundo para que el robot pase del estado de inicio al estado de búsqueda de luz.
7. Colocar la fuente luminosa frente o alrededor del robot para iniciar el seguimiento.

Después del encendido, el robot permanecerá detenido hasta detectar una fuente luminosa mediante los sensores LDR.

---

# 10. Calibración de sensores LDR

Los sensores LDR cuentan con un potenciómetro que permite ajustar la sensibilidad de detección. Esta calibración es importante para evitar falsas detecciones provocadas por la luz del ambiente.

## 🔧 Procedimiento de calibración

1. Encender la tarjeta FPGA y alimentar los sensores.
2. Colocar el robot en el entorno donde se realizará la prueba.
3. Apuntar la fuente luminosa hacia cada sensor LDR.
4. Girar lentamente el potenciómetro del sensor hasta que la salida cambie de estado al recibir luz.
5. Repetir el procedimiento con cada sensor.
6. Verificar que el sensor no se active con la luz ambiente normal.
7. Verificar que el sensor sí se active cuando la fuente luminosa se acerque o apunte directamente hacia él.

> 💡 **Recomendación:** Realizar la calibración en el mismo lugar donde se hará la prueba final, ya que la luz ambiente puede cambiar el comportamiento de los sensores.

---

# 11. Operación del robot

Una vez conectado y calibrado, el robot puede operar de forma autónoma. Su comportamiento general es el siguiente:

* Al iniciar, el robot permanece detenido durante aproximadamente un segundo.
* Después entra al estado de búsqueda de luz.
* Si detecta luz en alguno de los sensores LDR, pasa al estado de seguimiento.
* En el estado de seguimiento, activa los motores según la dirección donde se detecta la luz.
* Si el sensor ultrasónico detecta un obstáculo cercano, el robot entra al estado de esquive.
* Después de la maniobra de esquive, el robot vuelve a buscar o seguir la luz.
* Si se cumple la condición de meta, el robot se detiene.

---

# 12. Estados del robot

La siguiente tabla muestra los estados principales del robot y su significado.

| Estado              | Descripción                                                                          |
| ------------------- | ------------------------------------------------------------------------------------ |
| `ESTADO_INICIO`     | El robot permanece detenido durante un tiempo inicial antes de comenzar la búsqueda. |
| `ESTADO_BUSCAR_LUZ` | El robot espera hasta detectar una fuente luminosa mediante los sensores LDR.        |
| `ESTADO_SEGUIR_LUZ` | El robot activa los motores de acuerdo con la dirección de la luz detectada.         |
| `ESTADO_ESQUIVE`    | El robot realiza una maniobra para evitar un obstáculo detectado al frente.          |
| `ESTADO_META`       | El robot se detiene al cumplir la condición de llegada a la fuente luminosa.         |

---

# 13. Indicadores LED

Durante la operación, el robot muestra su estado mediante tres LEDs de la tarjeta. Esto permite identificar fácilmente qué acción está ejecutando la Máquina de Estados Finitos.

| Estado              | LEDs  |
| ------------------- | ----- |
| `ESTADO_INICIO`     | `000` |
| `ESTADO_BUSCAR_LUZ` | `001` |
| `ESTADO_SEGUIR_LUZ` | `010` |
| `ESTADO_ESQUIVE`    | `011` |
| `ESTADO_META`       | `111` |

## 🟢 Interpretación rápida

```text
000 → Inicio
001 → Buscando luz
010 → Siguiendo luz
011 → Esquivando obstáculo
111 → Meta / detenido
```

> 🔍 Si el robot no se comporta como se espera, se recomienda revisar primero los LEDs para identificar en qué estado se encuentra.

---

# 14. Prueba de funcionamiento

Para realizar una prueba básica del robot, siga estos pasos:

1. Coloque el robot en una superficie plana.
2. Encienda la tarjeta FPGA y el sistema de motores.
3. Espere a que termine el estado de inicio.
4. Coloque una fuente luminosa frente al robot.
5. Observe si el robot responde al estímulo luminoso.
6. Mueva la fuente luminosa hacia un lado y observe si el robot cambia su dirección.
7. Coloque un obstáculo frente al robot a una distancia menor o igual a 20 cm.
8. Verifique que el robot cambie al estado de esquive.
9. Retire el obstáculo y observe si el robot vuelve a buscar o seguir la luz.

---

# 15. Recomendaciones de uso

Para obtener un mejor funcionamiento del robot, se recomienda:

* 💡 Utilizar una fuente luminosa clara y directa.
* 🌑 Evitar lugares con demasiada luz ambiental.
* 🔧 Calibrar los sensores LDR antes de cada prueba importante.
* 🔋 Revisar que la batería tenga suficiente carga.
* 📏 Colocar el robot en una superficie plana.
* 🚫 Evitar superficies muy rugosas o inclinadas.
* 🔌 Verificar que los cables no interfieran con el movimiento de las ruedas.
* 📦 No colocar obstáculos demasiado pequeños o con superficies que dificulten la medición ultrasónica.
* 🌡️ Revisar que el driver de motores no se caliente demasiado durante pruebas prolongadas.

---

# 16. Precauciones de seguridad

Para evitar daños en el robot o en sus componentes, se deben considerar las siguientes precauciones:

* ⚠️ No conectar señales de 5 V directamente a entradas de la FPGA si no se tiene adaptación de nivel.
* ⚠️ Verificar la polaridad de la alimentación antes de encender el sistema.
* ⚠️ No tocar conexiones expuestas mientras el robot esté energizado.
* ⚠️ No bloquear las ruedas mientras los motores estén funcionando.
* ⚠️ No permitir que cables sueltos entren en contacto con las ruedas.
* ⚠️ No operar el robot cerca de líquidos.
* ⚠️ Desconectar la alimentación si se detecta calentamiento excesivo en el driver o en los cables.
* ⚠️ Apagar el robot antes de modificar conexiones.

---

# 17. Problemas comunes y soluciones

| Problema                                      | Posible causa                                                       | Solución recomendada                                                            |
| --------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| El robot no enciende.                         | No hay alimentación o hay una conexión floja.                       | Revisar la alimentación de la FPGA, batería, cables y conexiones.               |
| Los motores no giran.                         | El driver no está alimentado o las señales no llegan correctamente. | Revisar alimentación del driver, conexiones de motores y señales desde la FPGA. |
| El robot no detecta la luz.                   | Sensores LDR mal calibrados o fuente luminosa débil.                | Calibrar los sensores y usar una fuente luminosa más directa.                   |
| El robot detecta luz todo el tiempo.          | Sensibilidad de los LDR demasiado alta.                             | Reducir la sensibilidad usando el potenciómetro del sensor.                     |
| El robot no esquiva obstáculos.               | Sensor ultrasónico mal conectado o sin lectura correcta.            | Revisar `trigger`, `echo`, alimentación y tierra del sensor.                    |
| El robot cambia de estado de forma inestable. | Ruido en sensores o cambios bruscos de luz.                         | Revisar calibración y evitar iluminación variable.                              |
| El robot se desvía mucho.                     | Motores con diferente fuerza o ruedas desalineadas.                 | Revisar motores, ruedas, base y carga de batería.                               |
| El driver se calienta demasiado.              | Consumo elevado de los motores o conexiones incorrectas.            | Apagar el sistema y revisar alimentación, cables y consumo.                     |

---

# 18. Mantenimiento

Para conservar el robot en buen estado, se recomienda realizar las siguientes acciones:

* 🔌 Revisar periódicamente que los cables estén bien conectados.
* 🧭 Verificar que los sensores no estén flojos o mal orientados.
* 🧼 Limpiar la estructura del robot si acumula polvo.
* ⚙️ Revisar que las ruedas giren libremente.
* 🔋 Revisar que la batería esté en buen estado.
* 📦 Guardar el robot en un lugar seco.
* 🛡️ Evitar golpes directos sobre la tarjeta FPGA o los sensores.

---

# 19. Limitaciones de uso

El robot fue desarrollado como prototipo académico, por lo que presenta algunas limitaciones:

* Utiliza un solo sensor ultrasónico frontal, por lo que no detecta obstáculos laterales o traseros.
* La detección de luz depende de la calibración de los sensores LDR.
* La luz ambiente puede afectar el funcionamiento del sistema.
* El control de motores se realiza mediante señales de dirección, sin control PWM en la versión final.
* No cuenta con detección directa de atasco mediante encoders.
* La estructura física está hecha con materiales ligeros, por lo que debe manipularse con cuidado.

---

# 20. Apagado del robot

Para apagar el robot de forma segura, siga este procedimiento:

1. Retirar la fuente luminosa o detener la prueba.
2. Apagar o desconectar primero la alimentación de los motores.
3. Apagar o desconectar la alimentación de la tarjeta FPGA.
4. Esperar unos segundos antes de manipular conexiones.
5. Revisar que ningún componente esté caliente antes de guardar el robot.

---

# 21. Video funcional

El funcionamiento del robot se muestra en el siguiente video:

🔗 **Video:** https://goo.su/L8QA6Ju

En el video se puede observar la respuesta general del robot ante la fuente luminosa y su comportamiento durante la prueba funcional.

---

# 22. Conclusión del manual

Este manual permite operar el robot móvil seguidor de luz con evasión de obstáculos de manera ordenada y segura. Siguiendo las instrucciones de conexión, calibración y prueba, el usuario puede verificar el comportamiento principal del robot y comprender el significado de sus estados de funcionamiento.

El robot integra sensores, motores, lógica digital y una Máquina de Estados Finitos en VHDL, por lo que representa una aplicación práctica de los temas vistos en la materia de Diseño Digital VLSI.

---

# 23. Referencias

* Material proporcionado en clase: *Robot móvil seguidor de luz con evasión de obstáculos*, Diseño Digital VLSI, Proyecto Final, 2026.
* Intel. *DE10-Lite User Manual*.
* Datasheet del sensor ultrasónico HC-SR04.
* Datasheet del driver de motores L298N o equivalente.
* Documentación de Intel Quartus Prime.
* Apuntes y material del curso de Diseño Digital VLSI.

---

# 24. Resumen rápido de uso

```text
1. Conectar FPGA, sensores, driver y motores.
2. Cargar el código en la DE10-Lite.
3. Calibrar los sensores LDR.
4. Colocar el robot en una superficie plana.
5. Encender alimentación de FPGA y motores.
6. Colocar una fuente luminosa.
7. Observar seguimiento de luz y evasión de obstáculos.
8. Apagar primero motores y después la FPGA.
```
