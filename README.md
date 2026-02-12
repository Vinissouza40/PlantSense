
#TLDRAW

https://www.tldraw.com/f/4Ac_cOc2QJAMJ0gpoT5GK?d=v-482.-487.4243.2416.page


![Modelagem](https://github.com/user-attachments/assets/5c4c9b06-4c1e-4493-80f0-e348af73f202)

# PlantSense

**Monitoramento Bioelétrico de Plantas**

##  Objetivo
Criar um aplicativo que monitora sinais elétricos e variações da planta para identificar estresse hídrico, pragas e mudanças no metabolismo.

---

## a)  Ferramentas que serão usadas

### Hardware
- **ESP32** (microcontrolador principal)(Lorawan)
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
- Postgree
- Google Firebase
- MQTT

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

## c) Tecnologia/Linguagem para API e APP
- FLUTTER
- C#
- .NET
- C

---

## d) Plataforma de Prototipagem 
### Wokwi
- Suporta ESP32
- Melhor para simular projetos IoT


Edge Computing

1️ - Filtragem

Mediana

Média móvel

Remover ruído

2️-Rejeição de leitura ruim

Se acelerômetro detectar vento → descarta leitura

Se valor saturar → ignora

3️- Extração de feature

Em vez de enviar 64 amostras cruas:

Ele envia:

Valor médio

Variação percentual

Tendência

Isso reduz:

Tráfego

Consumo de energia

Dependência da nuvem
