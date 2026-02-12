# PlantSense

**Monitoramento Bioelétrico de Plantas**

##  Objetivo
Criar um sistema que monitora sinais elétricos e variações da planta para identificar estresse hídrico, pragas e mudanças no metabolismo.

---

## a)  Ferramentas que serão usadas

### Hardware
- **ESP32** (microcontrolador principal)
- **ADS1115** (conversor ADC 16 bits)
- **INA333 ou AD620** (amplificador de sinal)
- **AD5933** (bioimpedância)
- Sensores de:
  - Temperatura da folha
  - Umidade do ambiente
- Comunicação **LoRa**

### Software
- Arduino IDE
- SQLServer

---

## b) Formato de Dados (JSON)

Os dados serão enviados em formato JSON.

Exemplo:

```json
{
  "device_id": "planta_01",
  "timestamp": "2026-02-11T14:32:00Z",
  "bioeletrico_mv": 0.87,
  "bioimpedancia_ohms": 12450,
  "temperatura_folha": 28.4,
  "umidade": 63.2
}
```
---

## c) Tecnologia/Linguagem para API
- C#
- .NET

---

## d) Plataforma de Prototipagem 
### Wokwi
- Suporta ESP32
- Melhor para simular projetos IoT

