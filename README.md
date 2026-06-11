# 🤖 ProyectoRobot — Seguidor de Luz con Evasión de Obstáculos

> Proyecto Final — Diseño Digital VLSI  
> Implementación en FPGA de un robot móvil autónomo capaz de localizar una fuente luminosa y alcanzarla evadiendo obstáculos.

---

## 👥 Equipo

| Nombre | Usuario GitHub | No. de Cuenta |
|--------|---------------|---------------|
| Najera Higuera Junior Josue | junior-programeer | 421112869 |
| Romero Calixto Carlo Magno | CarloRomer0 | 320187890 |
| Héctor Albino López González | donut004 | 320342732 |
| Tarek Almodovar Tufiño | tarekalmodovar | 423127375 |

---

## 📋 Descripción

El robot opera en una arena de **1m × 1.7m** con obstáculos aleatorios. Utiliza sensores LDR para detectar la dirección de una fuente de luz (foco) y sensores ultrasónicos para detectar y evadir obstáculos, todo controlado por una FSM implementada en VHDL sobre FPGA.

### Características principales
- Seguimiento de fuente luminosa mediante 4 fotoresistencias (LDR)
- Evasión autónoma de obstáculos con sensores ultrasónicos HC-SR04
- Control de 2 motores DC mediante PWM ≥ 8 bits a ≥ 18 kHz
- FSM principal con 5 estados: `BUSCAR → SEGUIR → ESQUIVAR → GIRO_ESQUINA → META`
- Detección de atasco con maniobra de escape automática
- Visualización de estado por LEDs

---

## 🗂️ Estructura del repositorio

```
ProyectoRobot/
├── README.md
├── docs/
│   ├── reporte.pdf
│   ├── diagramas/
│   │   ├── bloques.png         # Diagrama de bloques general
│   │   ├── fsm.png             # Diagrama de la FSM principal
│   │   └── esquematico.png     # Esquemático eléctrico
│   └── datasheets/
│       ├── L293D.pdf
│       ├── LM339.pdf
│       └── HC-SR04.pdf
├── codigo-vhdl/
│   ├── top.vhd                 # Entidad top-level
│   ├── fsm.vhd                 # FSM principal
│   ├── ultrasonico_hcsr04.vhd  # Controlador HC-SR04
│   ├── Robot_PFVLSI_2026-2.qar #Proyecto empaquetado
```

---

## ⚙️ Especificaciones técnicas

| Parámetro | Valor |
|-----------|-------|
| Dimensiones máximas del robot | 20 cm × 20 cm × 20 cm |
| Sensores de luz | 4 × LDR + comparador LM339 |
| Sensores de distancia |  HC-SR04 (ultrasónico) |
| Driver de motores | L293D (puente H dual) |
| Resolución PWM | ≥ 8 bits |
| Frecuencia PWM | ≥ 18 kHz |
| Estados FSM | 5 (BUSCAR, SEGUIR, ESQUIVAR, GIRO_ESQUINA, META) |

---

## 🔌 Diagrama de bloques

```
         ┌─────────────┐
LDRs ───►│  ldr_sensor │──► dirección luz
         └─────────────┘         │
                                 ▼
HC-SR04 ►│ ultrasonico │──►  ┌────────┐     ┌─────┐
         └─────────────┘     │  FSM   │────►│ PWM │──► L293D ──► Motores
                         ┌──►│ principal│    └─────┘
         ┌─────────────┐ │   └────────┘
Botones ►│  debounce   │─┘        │
         └─────────────┘          ▼
                             UART / 7-seg / LEDs
```

---

## 🔁 FSM Principal

```
         ┌──────────┐
  inicio │  BUSCAR  │◄─────────────────────┐
         └────┬─────┘                      │
         luz detectada                     │
              ▼                            │
         ┌──────────┐   obstáculo     ┌────┴──────┐
         │  SEGUIR  │────────────────►│ ESQUIVAR  │
         └────┬─────┘                 └────┬──────┘
         llegó a meta               camino libre
              ▼                            │
         ┌──────────┐                      │
         │   META   │    ┌─────────────────┘
         └──────────┘    ▼
                    ┌──────────────┐
                    │ GIRO_ESQUINA │
                    └──────────────┘
```

---

## 🚀 Cómo reproducir el proyecto

### Requisitos
- FPGA: MaxDe 10-lite
- Software: Quartus
- Hardware: L293D, 4× LDR, HC-SR04, 2× motor DC, chasis



## 📅 Cronograma

| Semana | Actividad | Estado |
|--------|-----------|--------|
| 1 | Propuesta, diagrama de bloques, esquemático, plan de pruebas | ✅ |
| 2 | Divisor de reloj, debounce, timers, PWM base, sensores | ✅ |
| 3 | FSM básica, integración en chasis, prueba de seguimiento de luz |  ✅ |
| 4 | Prueba de evasión de obstáculos |  ✅ |
| 5 | Integración final |  ✅  |
| 6 | Validación final y entrega de reporte |  ✅  |

---

## 📦 Entregables

- [x] Repositorio público con código, documentación y archivos de diseño
- [x] Video demo (≤ 5 min) — grabado en entrega presencial
- [x] Reporte PDF con: arquitectura, FSMs, verificación, recursos, resultados y límites
- [x] Datasheets y esquemas como anexos del reporte

---

## 📚 Referencias y datasheets

- [L293D — Dual H-Bridge Motor Driver](docs/datasheets/L293D.pdf)
- [LM339 — Quad Voltage Comparator](docs/datasheets/LM339.pdf)
- [HC-SR04 — Ultrasonic Ranging Module](docs/datasheets/HC-SR04.pdf)

---

## 📝 Licencia

Proyecto académico — Diseño Digital VLSI · 2026
