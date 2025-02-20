# ChupaPotoCoin Tracker

![WoW Addon](https://img.shields.io/badge/World%20of%20Warcraft-Addon-orange)
![Lua](https://img.shields.io/badge/Language-Lua-blue)

ChupaPotoCoin Tracker es un addon para World of Warcraft diseñado para gestionar penalizaciones en raids. Permite asignar "ChupaPotoCoins" a los jugadores y expulsar automáticamente a aquellos que acumulen 6 monedas. Además, proporciona una interfaz sencilla para realizar un seguimiento de las penalizaciones.

---

## Características

- **Asignación de monedas**: Asigna 1, 2 o 3 ChupaPotoCoins a los jugadores.
- **Expulsión automática**: Expulsa automáticamente a los jugadores que acumulen 6 monedas.
- **Interfaz gráfica**: Interfaz fácil de usar para gestionar las penalizaciones.
- **Historial**: Mantén un registro de las penalizaciones asignadas.
- **Comandos de consola**: Usa comandos como `/cpc`, `/cpcui`, `/cpc reset all` y más.

---

## Instalación

1. Descarga el archivo `.zip` del addon desde la sección de [Releases](https://github.com/tuusuario/ChupaPotoCoin/releases).
2. Extrae el contenido del archivo `.zip` en la carpeta de addons de World of Warcraft:
   - **Windows**: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns`
   - **Mac**: `/Applications/World of Warcraft/_retail_/Interface/AddOns`
3. Asegúrate de que la carpeta del addon se llame `ChupaPotoCoin`.
4. Inicia World of Warcraft y activa el addon en el menú de selección de personajes.

---

## Uso

### Interfaz gráfica
- Escribe `/cpcui` para abrir la interfaz gráfica.
- Selecciona un jugador del menú desplegable.
- Usa los botones para asignar 1, 2 o 3 ChupaPotoCoins.
- Reinicia los puntos de hoy con el botón "Reiniciar Puntos de Hoy".

### Comandos de consola
- **`/cpc [jugador] [cantidad]`**: Asigna una cantidad específica de monedas a un jugador.
  - Ejemplo: `/cpc Jugador1 2`
- **`/cpcui`**: Abre o cierra la interfaz gráfica.
- **`/cpcreset [jugador]`**: Reinicia los puntos de hoy de un jugador específico.
  - Ejemplo: `/cpcreset Jugador1`
- **`/cpc reset all`**: Reinicia TODOS los puntos y el historial.
- **`/cpc help`**: Muestra una lista de comandos disponibles.

---

## Contribuciones

¡Las contribuciones son bienvenidas! Si deseas mejorar el addon o reportar un problema, sigue estos pasos:

1. Haz un fork del repositorio.
2. Crea una rama para tu contribución: `git checkout -b mi-contribucion`.
3. Realiza tus cambios y haz commit: `git commit -m "Descripción de los cambios"`.
4. Envía un pull request.

---

## Licencia

Este proyecto está bajo la licencia [MIT](LICENSE). Siéntete libre de usarlo, modificarlo y distribuirlo.

---

## Contacto

Si tienes alguna pregunta o sugerencia, no dudes en contactarme:
- **Battlenet**: DxaL#2445

---

¡Espero que disfrutes usando ChupaPotoCoin Tracker! 😊
