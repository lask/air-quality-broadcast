import gpio
import i2c
import scd30
import bme280

import udp_broadcast show *

SDA ::= gpio.Pin 21
SCL ::= gpio.Pin 22


BROADCAST_INTERVAL ::= Duration --s=30

main:
  bus := i2c.Bus
    --sda=SDA
    --scl=SCL
  bme_280 := bme280.Driver
    bus.device bme280.I2C_ADDRESS_ALT

  scd30 := scd30.Scd30
    bus.device scd30.Scd30.I2C_ADDRESS

  broadcaster := Server

  print "BROADCAST VALUES"
  broadcaster.periodic_broadcast BROADCAST_INTERVAL:
    scd30_measurement := scd30.read

    continue.periodic_broadcast {
      "bme280": {
        "temperature": bme_280.read_temperature,
        "humidity": bme_280.read_humidity,
        "pressure": bme_280.read_pressure
      },
      "scd30" : {
        "temperature": scd30_measurement.temperature,
        "humidity": scd30_measurement.humidity,
        "co2": scd30_measurement.co2
      }
    }
