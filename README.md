## Patagonia Game Jam 2024, grupo 7

### Game Design Document (GDD)

#### 1. **Título del Juego**:  
**Turismo Costa Argentina**

#### 2. **Descripción General**:  
Un juego de carreras por las costas del mar argentino, con vista desde arriba, inspirado en *Road Fighter*, y con la mecánica física del *GTA 2*. El jugador compite en circuitos que recorren las playas desde el norte hasta Santa Cruz, enfrentando terrenos complicados y desafiantes, con autos comunes en la ruta y otros competidores que también están corriendo.

#### 3. **Objetivo del Juego**:  
Completar cada circuito en el menor tiempo posible, competir contra otros autos y evitar salir de la ruta para no perder velocidad o destruir el vehículo.

#### 4. **Mecánicas de Juego**:

- **Controles**:  
  - *Aceleración*: Tecla `↑` (Arriba) o `W`  
  - *Frenado/Retroceso*: Tecla `↓` (Abajo) o `S`  
  - *Giro Izquierda*: Tecla `←` (Izquierda) o `A`  
  - *Giro Derecha*: Tecla `→` (Derecha) o `D`  
  - *Turbo/Boost*: Tecla `Espacio`

- **Progresión**:  
  - El jugador empieza en la playa más al norte y desbloquea nuevas pistas al ganar carreras.
  - Cada nivel tiene mayor complejidad, con más tráfico y terrenos más difíciles.

- **Competencia y Desafíos**:  
  - *Competidores*: Otros autos también corren en la pista y compiten por el primer lugar.
  - *Tráfico Común*: Autos de tráfico normal en la ruta que el jugador debe esquivar.
  - *Terrenos Difíciles*: Tramos con arena suelta, agua, barro, acantilados.

- **Obstáculos y Penalizaciones**:  
  - *Obstáculos*: Charcos de agua, rocas, troncos.
  - *Penalizaciones*: Salirse de la ruta principal provoca pérdida de velocidad; caer en agua o por un acantilado resulta en la destrucción del vehículo.

- **Decoración Visual**:  
  - *Adornos Visuales*: Gaviotas volando, ballenas saltando, barcos, surfistas, y otros elementos costeros, sin afectar el gameplay.

#### 5. **Ambientación y Arte**:

- **Estilo Visual**:  
  Pixel art o gráficos 2D que recuerden al GTA 2. Colores vibrantes para las playas del norte y tonos más fríos para las del sur.
  
- **Detalles Ambientales**:  
  - Gaviotas volando cerca de la costa.
  - Ballenas saltando en las playas más al sur.
  - Fondos con barcos, surfistas, y elementos costeros.

#### 6. **Niveles/Circuitos**:

1. **Playa del Norte**: Terreno plano, arena dorada, tráfico moderado, autos comunes y competidores.
2. **Playas de Mar del Plata**: Mayor tráfico, surfistas, pequeñas embarcaciones, terreno resbaladizo.
3. **Playas Patagónicas**: Terrenos irregulares, tráfico más denso, rocas y troncos en el camino.
4. **Santa Cruz**: Playas salvajes con acantilados, ballenas saltando, alta dificultad.

#### 7. **Sonido y Música**:

- Música inspirada en sonidos playeros y rock argentino.
- Efectos de sonido para: motores, olas del mar, derrapes, colisiones, y el tráfico.

#### 8. **Plan de Expansión**:

- **Versiones Futuras**:  
  - Más vehículos con diferentes estadísticas (velocidad, manejo, resistencia).
  - Modos multijugador online/local.
  - Clima dinámico (lluvia, tormentas de arena).
  - Circuitos nocturnos.

#### 9. **Desarrollo iterativo**:

##### 1 **Etapa 1**:
- Circuito simple con mecánicas básicas de conducción y competición.
- Implementación de al menos un tipo de obstáculo (como charcos de agua) y una penalización por salirse de la ruta.
- Arte mínimo funcional para el primer circuito (Playa del Norte).
- Simulación de tráfico con autos comunes y al menos un competidor.


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## IDEA 2

## Nombre del Juego:
Bubble Ocean

## Descripción General:
Bubble Ocean es un juego de rompecabezas casual en 2D ambientado en un vibrante mundo submarino. Las burbujas de colores caen desde la parte superior de la pantalla, y cuando dos o más burbujas del mismo color se tocan, se fusionan y forman una burbuja más grande. El objetivo del juego es crear la burbuja más grande posible antes de que la pantalla se llene de burbujas. A medida que el jugador avanza en los niveles, la velocidad y la complejidad aumentan, añadiendo nuevos desafíos.

## Estilo Visual:
Paleta de Colores: Colores suaves y relajantes inspirados en el mar: azules profundos, turquesas, verdes esmeralda, y toques de coral y rosa.
Ilustraciones: Las burbujas están diseñadas para parecerse a criaturas marinas y objetos como medusas, estrellas de mar, y conchas. Cada burbuja tiene un toque animado que simula el movimiento suave bajo el agua.
Fondo: Un paisaje submarino con corales, peces nadando y plantas marinas que se mueven lentamente con la corriente. A medida que se avanza en los niveles, el fondo cambia para reflejar diferentes partes del océano, desde arrecifes coloridos hasta profundidades más oscuras y misteriosas.
Diseño de Sonido:
Música de Fondo: Melodías suaves y ambientales con sonidos de agua, burbujas estallando y ocasionales cantos de ballenas para crear una atmósfera tranquila y relajante.
Efectos de Sonido: Cada vez que las burbujas se fusionan, se escucha un suave "pop" o un sonido de burbujeo. Al formar una burbuja más grande, se puede escuchar un efecto más profundo y resonante.

## Diseño del Juego (Game Design):
Mecánicas de Juego:

Las burbujas caen desde la parte superior de la pantalla en intervalos regulares.
El jugador puede mover las burbujas lateralmente para alinearlas con otras del mismo color.
Cuando dos o más burbujas del mismo color se tocan, se fusionan en una burbuja más grande.
Las burbujas más grandes pueden fusionarse con otras iguales o con burbujas más pequeñas para crear combinaciones.
Si la pantalla se llena de burbujas, el juego termina.
Progresión de Niveles:

Los primeros niveles son más lentos, permitiendo que el jugador se familiarice con las mecánicas.
A medida que avanzan los niveles, la velocidad de caída de las burbujas aumenta y se introducen nuevos colores, dificultando la fusión.
Se añaden obstáculos como corales que bloquean ciertas áreas de la pantalla, aumentando la dificultad.
Objetivo:

El objetivo principal es alcanzar la mayor puntuación posible al crear la burbuja más grande.
Se pueden incluir niveles con objetivos específicos, como crear una burbuja de un tamaño determinado o alcanzar una cierta puntuación en un tiempo limitado.

##Desarrollo:
Herramientas: Utiliza motores como Unity o Godot, que permiten un desarrollo rápido y eficiente de juegos 2D.
Plataformas: El juego podría lanzarse en dispositivos móviles (iOS, Android) o en navegadores web.
Animaciones: Las animaciones suaves y fluidas son clave para dar vida al entorno submarino. Puedes usar programas como Spine o DragonBones para animar las burbujas y los fondos.
Optimización: Dado que es un juego casual, es importante mantener un rendimiento fluido, especialmente en dispositivos móviles. Mantén los gráficos ligeros y optimiza las animaciones para que el juego funcione sin problemas.

##Dificultad:
Aumento Gradual: El juego comienza con un ritmo lento y sencillo, pero la dificultad aumenta con la velocidad de las burbujas, la cantidad de colores y la introducción de obstáculos.
Modos de Juego: Considera incluir diferentes modos, como un modo infinito (endless) donde el objetivo es sobrevivir el mayor tiempo posible, y un modo desafío con niveles predefinidos.

##Narrativa:
Historia: Aunque es un juego casual, podrías incluir una narrativa ligera, como seguir a una pequeña burbuja marina que busca crecer y explorar el vasto océano. Los fondos podrían cambiar a medida que la burbuja avanza, representando diferentes ecosistemas marinos.
