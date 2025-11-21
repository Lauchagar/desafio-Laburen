# Laburen.com - Agente de Ventas Automatizado

> **Solución técnica para el desafío de Customer Success Engineer.**

Este repositorio contiene la orquestación completa de un **Agente de IA** capaz de gestionar ventas, controlar stock en tiempo real y cotizar productos a través de WhatsApp de forma totalmente autónoma.

---

## Tecnologías Utilizadas

| Tecnología | Función | Detalle |
| :--- | :--- | :--- |
| **n8n**  | Orquestación | Self-hosted en VPS Dokploy |
| **Google Gemini**  | Inteligencia Artificial | Modelo 2.5 Flash |
| **PostgreSQL**  | Base de Datos | Persistencia de productos y ventas |
| **WhatsApp**  | Mensajería | Cloud API vía Chatwoot/Meta |

---

## Arquitectura del Workflow

Debido a la complejidad lógica del agente, el flujo principal se ha dividido en **3 imagenes**.

<img width="1756" height="367" alt="agente parte 1" src="https://github.com/user-attachments/assets/17d5e03e-8825-4afd-ab91-6804068b6b81" />

El flujo inicia cuando el usuario envía un mensaje (texto o audio).

* **Webhook & Filtros:** Recibe el evento de Chatwoot. Filtra mensajes de sistema, mensajes del propio bot y verifica el estado del agente (pausado/activo).
* **Switch de Tipo:** Detecta el formato del mensaje.
    * *Si es Audio:*  Utiliza un nodo de Gemini para transcribir el audio a texto automáticamente.
* **Gestión de Contexto (Redis Buffer):**
    * Implementa una lógica de *debounce*: espera **10 segundos** para agrupar mensajes consecutivos.
    * Si el último mensaje es igual al guardado, continúa el flujo.
    * Si es distinto, acumula el mensaje.
    * **Objetivo:** Enviar al agente un bloque de contexto completo en lugar de responder mensaje por mensaje, mejorando la coherencia y el costo.

<img width="1791" height="516" alt="agente parte 2" src="https://github.com/user-attachments/assets/d4f0dc6e-a5c8-4202-a030-ae8b4b9d8e08" />

El núcleo inteligente del sistema. El mensaje atraviesa capas de seguridad antes de ser procesado.

* **Guardrails (Seguridad):** Nodo de evaluación que analiza el input.

    * Bloquea intentos de *jailbreak*, *prompt injection* o temas fuera del negocio (política, religión).
    * **Fallo:** Envía rechazo amable.
    * **Aprobado:** Pasa al Agente.

* **AI Agent:** El cerebro central con acceso a:
    * **Memoria:** Ventana de contexto de la conversación reciente.
    * **Tools (Herramientas de API):**
        * `Obtener productos`: Consulta el catálogo.
        * `Obtener un producto`: Verifica stock real y precios unitarios.
        * `Obtener carrito`: Revisa el estado actual del pedido.
        * `Crear/Editar carrito`: Ejecuta transacciones de base de datos.
        * `Calculadora`: Realiza cálculos matemáticos precisos para cotizaciones.
    * **Think Tool:** Supervisor lógico que valida la coherencia (ej: verifica que el agente realmente haya llamado a la API antes de confirmar una acción al usuario).

<img width="1786" height="365" alt="agente parte 3" src="https://github.com/user-attachments/assets/5f651785-1e21-48b4-80c2-6498a73ecf6d" />

Post-procesamiento de la respuesta para garantizar una experiencia de usuario premium en WhatsApp.


* **Format Chain (UX):** Un segundo modelo LLM toma el texto crudo y lo "embellece":
    * Divide la respuesta en burbujas lógicas (Saludo, Lista, Cierre).
    * Aplica formato Markdown (**negritas**, listas).
      
* **Envío Secuencial:**
    * El sistema recorre las partes del mensaje JSON.
    * Envía cada parte por separado a Chatwoot.
    * Utiliza nodos **Wait** entre mensajes para simular un ritmo de escritura humano y evitar "muros de texto".

---
