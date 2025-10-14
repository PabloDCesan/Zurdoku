# Zurdoku - Juego de Sudoku en Flutter

Un juego de Sudoku completo desarrollado en Flutter para Android, con múltiples temas, diferentes niveles de dificultad y sistema de progreso.

## Características

### 🎮 Funcionalidades del Juego
- **5 niveles de dificultad**: Principiante, Medio, Avanzado, Experto, Maestro
- **Generación automática de puzzles**: Cada juego es único
- **Validación en tiempo real**: Detecta errores inmediatamente
- **Cronómetro**: Rastrea el tiempo de completado
- **Mejores tiempos**: Guarda récords por dificultad

### 🎨 Sistema de Temas
- **Tema Claro**: Colores brillantes y limpios
- **Tema Oscuro**: Modo nocturno elegante
- **Tema Azul** (ORTORT): Esquema azulado desbloqueable
- **Tema Rojo** (HELPME): Esquema de colores rojo y blanco

### ⚙️ Configuraciones
- **Audio**: Activar/desactivar música y efectos de sonido
- **Códigos de desbloqueo**: Sistema de códigos para temas especiales
- **Reinicio de progreso**: Volver al estado inicial

## Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
└── src/
    ├── app.dart                 # Configuración principal de la app
    ├── models/                  # Modelos de datos
    │   ├── sudoku.dart         # Modelos del juego (Sudoku, GameState, etc.)
    │   └── theme.dart          # Modelos de temas
    ├── providers/              # Gestión de estado con Riverpod
    │   ├── game_provider.dart  # Estado del juego
    │   └── progress_provider.dart # Progreso y configuraciones
    ├── screens/                # Pantallas de la aplicación
    │   ├── splash_screen.dart  # Pantalla de inicio
    │   ├── loading_screen.dart # Pantalla de carga
    │   ├── main_menu_screen.dart # Menú principal
    │   ├── difficulty_selection_screen.dart # Selección de dificultad
    │   ├── game_screen.dart    # Pantalla principal del juego
    │   └── options_screen.dart # Pantalla de opciones
    ├── widgets/                # Widgets reutilizables
    │   ├── sudoku_grid.dart    # Grilla del Sudoku
    │   ├── game_timer.dart     # Cronómetro del juego
    │   ├── victory_dialog.dart # Diálogo de victoria
    │   └── number_buttons.dart # Botones numéricos
    ├── themes/                 # Sistema de temas
    │   └── app_theme.dart      # Configuración de temas
    ├── services/               # Servicios
    │   └── sudoku_generator.dart # Generador de puzzles
    └── utils/                  # Utilidades
```

## Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo
- **Riverpod**: Gestión de estado reactiva
- **Go Router**: Navegación declarativa
- **Shared Preferences**: Persistencia de datos locales

## Instalación y Ejecución

1. **Clonar el repositorio**:
   ```bash
   git clone <url-del-repositorio>
   cd zurdoku
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## Códigos de Desbloqueo

- **ORTORT**: Desbloquea el tema azul
- **HELPME**: Desbloquea el tema rojo (estilo Cruz Roja)

## Flujo de la Aplicación

1. **Splash Screen**: Pantalla negra con animación del logo (2 segundos)
2. **Loading Screen**: Logo con barra de progreso (5 segundos)
3. **Main Menu**: Botones para Comenzar, Continuar y Opciones
4. **Difficulty Selection**: 5 niveles de dificultad disponibles
5. **Game Screen**: Juego principal con grilla interactiva
6. **Victory Dialog**: Celebración al completar el puzzle

## Características Técnicas

### Gestión de Estado
- **Riverpod**: Estado reactivo y eficiente
- **NotifierProvider**: Para estado mutable del juego
- **Persistencia**: Guardado automático de progreso

### Generación de Sudoku
- **Algoritmo propio**: Generación de puzzles válidos
- **Diferentes dificultades**: Control de celdas vacías
- **Validación**: Verificación de reglas del Sudoku

### Temas Dinámicos
- **Aplicación en tiempo real**: Cambio inmediato de temas
- **Persistencia**: Guardado de preferencias
- **Códigos de desbloqueo**: Sistema de recompensas

## Próximas Mejoras

- [ ] Efectos de sonido y música
- [ ] Sistema de logros
- [ ] Estadísticas detalladas
- [ ] Modo multijugador
- [ ] Exportar/importar progreso
- [ ] Más temas desbloqueables

## Contribución

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.