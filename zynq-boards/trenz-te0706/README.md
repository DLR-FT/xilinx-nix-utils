# Trenz TE0821 ZU3EG SoM with TE0706 Carrier Board

SoM: [TE0821-01-3BE21 Rev 01](https://shop.trenz-electronic.de/de/TE0821-01-3BE21MA-MPSoC-Modul-mit-AMD-Zynq-UltraScale-ZU3EG-1E-2-GByte-DDR4-4-x-5-cm)

- [Wiki](https://wiki.trenz-electronic.de/display/PD/TE0821+Resources)
- [TRM](https://shop.trenz-electronic.de/trenzdownloads/Trenz_Electronic/Modules_and_Module_Carriers/4x5/TE0821/REV01/Documents/TRM-TE0821-01.pdf)
- [Schematic](https://shop.trenz-electronic.de/trenzdownloads/Trenz_Electronic/Modules_and_Module_Carriers/4x5/TE0821/REV01/Documents/SCH-TE0821-01-3BE21MA.PDF)

Carrier: [TE0706 Rev 03](https://shop.trenz-electronic.de/de/TE0706-04-A-TE0706-Traegerboard-fuer-Trenz-Electronic-Module-mit-4-x-5-cm-Formfaktor)

- [Wiki](https://wiki.trenz-electronic.de/display/PD/TE0706+Resources)
- [TRM](https://shop.trenz-electronic.de/trenzdownloads/Trenz_Electronic/Modules_and_Module_Carriers/4x5/4x5_Carriers/TE0706/REV03/Documents/TRM-TE0706-03.pdf)
- [Schematic](https://shop.trenz-electronic.de/trenzdownloads/Trenz_Electronic/Modules_and_Module_Carriers/4x5/4x5_Carriers/TE0706/REV03/Documents/SCH-TE0706-03.PDF)

JTAG XMOD: [TE0790 Rev 03](https://shop.trenz-electronic.de/de/TE0790-03-XMOD-FTDI-JTAG-Adapter-AMD/Xilinx-kompatibel)

- [Wiki](https://wiki.trenz-electronic.de/display/PD/TE0790+Resources)
- [TRM](https://shop.trenz-electronic.de/trenzdownloads/Trenz_Electronic/JTAG_Programmer/TE0790/REV03/Documents/TRM-TE0790-03.pdf)

## JTAG XMOD Probe:

| S2  | ON                    | OFF                            | Default | Description                              |
| --- | --------------------- | ------------------------------ | ------- | ---------------------------------------- |
| 1   | Normal Mode           | Adapter Board CPLD update mode | ON      | Update Mode; JTAG access to SC CPLD only |
| 2   | Do no use (illegal)   | Normal mode                    | OFF     | Must be in OFF state always              |
| 3   | VIO connected to 3.3V | Power VIO from pin header J2   | OFF     | User IO Voltage                          |
| 4   | Power 3.3V from USB   | Power 3.3V from pin header J2  | OFF     | Power on-board peripherals               |

On the TE0706 Carrier the JTAG Probe must be powered by USB; The Carrier does not supply power on the header. S2.4 must be ON.

Recommended: 1:ON - 2:OFF - 3:OFF - 4:ON

## Carrier

### Dip Switch S1

| S1  | Signal        | ON                                        | OFF                               | Notes                                                                                                                                                                                                          |
| --- | ------------- | ----------------------------------------- | --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Not connected |
| 2   | PROGMODE      | JTAG enabled for programming SoM Zynq-Soc | JTAG enabled for SoM SC-CPLD      |
| 3   | Boot Mode     | SD-Boot                                   | QSPI-Boot                         | Boot mode configuration, if supported by SoM. (Depends also on SoM's SC-CPLD firmware).                                                                                                                        |
| 4   | EN1           | Drive SoM SC CPLD pin 'EN1' low.          | Drive SoM SC CPLD pin 'EN1' high. | Usually used to enable/disable FPGA core-voltage supply. (Depends also on SoM's SC CPLD firmware). Note: Power-on sequence will be intermitted if S1-4 is set to OFF and if functionality is supported by SoM. |

Recommended: 1:OFF - 2:ON - 3:OFF - 4:ON

### VCCIO Jumper

Recommended: J13 SD_VCCA: 3.3V
