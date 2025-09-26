# 🔑 Palabras Clave

## HLDS / ReHLDS

HLDS (Half-Life Dedicated Server):
El servidor oficial de Valve para juegos basados en GoldSrc (como CS 1.6). Corre el motor sin interfaz gráfica y permite que los jugadores se conecten.

ReHLDS: Reimplementación open-source de HLDS, optimizada y con muchos bugs corregidos. Es el estándar moderno para servidores CS 1.6.

👉 Piensa en HLDS como el “motor base del server”.

## GameDLL / ReGameDLL_CS

GameDLL: la librería que define la lógica del juego (armas, reglas, equipos).

ReGameDLL_CS: versión modernizada y ampliada de esa librería, con más “hooks” para mods.

👉 Esto es lo que “sabe” cómo funciona Counter-Strike (comprar armas, plantar bomba, etc.).

## Metamod / Metamod-R

Metamod: un “cargador de plugins” para HLDS. Permite que otras librerías se enganchen al motor del juego.

Metamod-R: versión optimizada y mantenida de Metamod.

👉 Es como un “enchufe múltiple” donde conectamos otros mods.

## AMX Mod X (AMXX)

Un sistema de scripting basado en el lenguaje Pawn.

Permite escribir plugins .sma → compilados a .amxx.

Se usa para casi todos los mods de CS 1.6 (zombie mod, admin system, etc.).

👉 Es tu “framework de mods”: aquí programás reglas nuevas.

## Zombie Plague / Biohazard

Zombie Plague (ZP): uno de los mods más famosos. Transforma el juego en “humanos vs. zombies”, con clases, habilidades, efectos especiales.

Biohazard: otro mod zombie más antiguo, menos usado hoy.

👉 Estos mods cambian la temática del server.

## Bots

Jugadores controlados por IA.

En CS 1.6 podés tener bots humanos o zombies, para poblar el servidor cuando no hay gente real.

## YaPB

Yet Another POD-Bot:
Es un bot moderno y actualizado para CS 1.6 (derivado de POD-Bot, E[POD], R2Bot, etc.).

Se integra fácil en HLDS/ReHLDS con Metamod.

Tiene waypoints: puntos en cada mapa que indican cómo moverse (caminar, saltar, subir escaleras).

Configurable: agresividad, reacción, persecución de enemigos.

👉 Es la “IA base” que sabe moverse y disparar como un jugador real.

## Waypoints

Archivos (.pwf) que marcan nodos de navegación en un mapa.

Los bots (como YaPB) usan estos nodos para saber dónde pueden ir, dónde cubrir, cómo rodear.

Los podés editar con un editor de waypoints dentro del juego.

👉 Son como el GPS del bot dentro de cada mapa.

## ReAPI

Una capa que expone funciones internas del motor para que los plugins AMXX puedan manipular cosas más profundas:
→ HP, armas, físicas, movimientos, etc.

Se usa junto a ReHLDS/ReGameDLL.

👉 Es el “puente avanzado” entre tu mod y el motor.

## Sockets (UDP)

Forma de comunicación entre procesos.

En nuestro caso: el plugin AMXX manda información del estado del juego al sidecar Python usando paquetes UDP, y recibe órdenes de vuelta.

👉 Es el “cable” entre CS 1.6 y tu IA externa.

## Sidecar Python

Programa externo que corre al lado del servidor.

Recibe snapshots del estado del juego.

Procesa esos datos con ML/heurísticas.

Devuelve órdenes de alto nivel (por dónde moverse, a quién atacar).

👉 Es como un “cerebro externo” que ayuda a los zombies a ser más inteligentes.

## XGBoost

Biblioteca de machine learning muy usada en clasificación/regresión tabular.

Entrena árboles de decisión en gradiente.

En este proyecto:

Entrenamos un modelo que, dado un estado del juego (features), decide si conviene que el zombie ataque, flanquee, se repliegue, etc.

👉 Es el motor de decisión estadístico que hace a los zombies menos predecibles.

## Features

Variables numéricas o categóricas que describen un estado.

Ejemplos en CS 1.6 zombie mod:

Distancia promedio a humanos.

Cuántos humanos están cerca (<600 unidades).

Relación numérica (zombies vs humanos vivos).

Fase del round (inicio, medio, final).

👉 Son los inputs del modelo ML.

## Snapshots

Capturas periódicas del estado del juego que el plugin arma.

Contienen info como:

Posiciones de jugadores.

Si son humanos o zombies.

Si están vivos/muertos.

HP, etc.

👉 Son las observaciones que el sidecar analiza.

## Comandos

Respuestas del sidecar hacia el plugin.

Ejemplos:

“Zombie #12 → Waypoint 134 (flank)”.

“Zombie #15 → atacar jugador #7 con agresividad 0.9”.

👉 Son las acciones de alto nivel que ejecuta la IA.

📌 En resumen:

ReHLDS/Metamod/AMXX = motor + enchufe + scripting.

Zombie Plague = tema (humanos vs zombies).

YaPB + Waypoints = bots que se mueven/disparan.

Sidecar Python + XGBoost = cerebro externo que les da inteligencia táctica.