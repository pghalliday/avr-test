# test

```
make
avrdude -p m328p -c arduino -P /dev/ttyUSB0 -b 57600 -U flash:w:build/main.hex
```
