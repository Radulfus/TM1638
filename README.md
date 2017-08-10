# TM1638
AVR ASM Library to drive the TM1638 chip from Titan Micro Electronics. 

TM1638 is an IC dedicated to LED (light emitting diode display) drive control and equipped
with a keypad scan interface. It integrates MCU digital interface, data latch, LED drive, and
keypad scanning circuit. 

Features
• CMOS technology
• 10 segments × 8 bits display
• Keypad scanning (8 × 3 bits)
• Brightness adjustment circuit (8-level adjustable duty ratio)
• Serial interfaces (CLK, STB, DIO)
• Oscillation mode: RC oscillation
• Built-in power-on reset circuit
• Package type: SOP28

This project claims the development of a driver in AVR assembly language. 

Under Linux you can clone the project as follows:

> git clone https://github.com/Radulfus/TM1638.git

If you want to clone the sAVR branch please use:

> git clone https://github.com/Radulfus/TM1638.git  --branch sAVR

Assemble:

> avra tm1638cc.asm

Upload to the MCU:

> avrdude -c usbasp -p m32 -P usb -U flash:w:tm1638cc.hex

In the example above I use ATMega32/ATMega168 and a USBASP.

The branch sAVR uses a precompiler (s'AVR) from Eberhard Haug. This nice
tool allows structured AVR ASM programming. For Details take a look at:
http://led-treiber.de/html/s-avr.html

