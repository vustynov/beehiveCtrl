# beehiveCtrl


### Brief
This project can be interesting for amateur beekeeping. The project is designed to monitor the temperature and control the heating of beehives remotely. The device and software can also be used to control temperature control in other projects, such as an incubator.

The device is based on the microcontroller [ESP8266](http://www.esp8266.com) and firmware [NodeMCU](https://en.wikipedia.org/wiki/NodeMCU).

### Features
 * Remote control the temperature in the hive via browser on your computer, smartphone, tablets
 * Remote set the parameters of heater (minimal and maximal temperature)
 * Transfer of the temperature and the current status of the heater to the [thingspeak.com](http://thingspeak.com) every X minutes
 * Builds the [charts](https://thingspeak.com/channels/185299)
 

### Schems and Circuit board
Directory **board** contains schematic and circuit board of device developed in [EAGLE](https://www.autodesk.com/products/eagle/overview). 
The scheme is very simple. It consists the power regulatots (LM7805 and 1117S33) for the relay coil and microcontroller. To switch on the relay a driver is used the BC546 transistor.


### Source code
Software of the project wroted on Lua based on [NodeMCU API](https://nodemcu.readthedocs.io/en/master/).


### How to build
1. Build the board according to the schematic diagram showed on **board/BeeTermostat.sch**
2. Connect *+12-18V* power to *X1* connector on your board without installing the ESP8266 and check the correctness of the voltage at the points of the circuit where the power of the microcontroller must be approached. It should be the "3.3V".
3. Power off your board, install the ESP8266 to the socket on the board, and connect the **JP3** (TX,RX,GND) connector to the computer via USB-TTL adapter. For example, you can use [this device](http://www.instructables.com/id/USB-to-TTL-Converter-PL2303HX/) for that.
4. Power on your board and check the WiFi new access points in you environment. You should discover a new access point with a default name (installed by [Expressif](https://www.espressif.com/) ).
5. Build and download the NodeMCU firmware from the [nodemcu-build.com](https://nodemcu-build.com/) Choose the following modules:
 - DS18B20
 - file
 - GPIO
 - net
 - node
 - 1-wire
 - timer
 - UART
 - WiFi
 - float

6. Install the NodeMCU firmware to microcontroller. Under Linux you can use the [esptool](https://github.com/espressif/esptool) (read this [esp-linux-guide](http://www.whatimade.today/flashing-the-nodemcu-firmware-on-the-esp8266-linux-guide/) for that. Example of install:
```
$ sudo ./esptool-master/esptool.py --port /dev/ttyUSB0 --baud 460800 write_flash --flash_size 32m -fm dio 0x00000 ./nodemcu-master-10-modules-2017-09-25-18-22-58-float.bin
```

7. Install the [ESPlorer](https://esp8266.ru/esplorer/) or some another tools for working with NodeMCU to your computer.
8. Upload the lua scripts from directory **src** to your ESP microcontoller by using the ESPlorer or some another tools.
9. Restart module, find new WiFi access point *beehive* and try to connect to this AP with password *11111111*. You can change *SID* and *password* before in the **src/bc-init.cfg**.
10. If connect is successfull, try to open http://192.168.2.1 in your browser. You sould see the page with configuration of your beehive controller.
11. Try to change the temperature settings and check your heater.




