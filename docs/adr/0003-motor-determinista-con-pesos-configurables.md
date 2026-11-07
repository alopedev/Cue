# 0003 · Motor determinista con los pesos en un archivo de configuración

- Estado: aceptada
- Fecha: 07/11/2026

## Contexto

El motor de «Esta noche» ordena candidatos con señales (PRD §6.5). El PRD exige una función determinista (RF-15) y prohíbe usar un modelo de lenguaje para ordenar (RF-16). Los pesos iniciales están sin decidir (D-04) y se calibrarán con Àlex usando datos reales.

## Decisión

- El motor es una función pura: con la misma lista, ventana, mood, hora (`Clock`) y pesos, devuelve siempre las mismas propuestas.
- Los pesos de cada señal viven en un archivo de configuración aparte del código, que el motor lee al arrancar. Mientras D-04 esté abierta, todos los pesos empiezan iguales.
- Cada propuesta guarda sus señales con el valor y el peso que tenían al emitirse (`WeightedSignal`), para poder analizar los rechazos aunque los pesos cambien después (§4.4).
- La frase de explicación se construye con plantillas a partir de las dos señales de más peso (RF-18).

## Alternativas descartadas

- **Pesos escritos dentro del código.** Calibrar D-04 obligaría a cambiar y recompilar código en cada ajuste.
- **Un modelo de IA para ordenar.** Lo prohíbe RF-16, no es repetible y no se puede probar con TDD.

## Consecuencias

- D-04 se ajusta cambiando un archivo, sin tocar el motor.
- Cada señal tiene su propia prueba y el motor completo se prueba con un reloj fijo.
- El formato exacto del archivo de pesos se decide en el bloque 3, cuando se construye el motor.
