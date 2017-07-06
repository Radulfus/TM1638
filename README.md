# TM1638
AVR ASM Library to drive TM1638 from Titan Micro Electronics. 

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

With Linux you can checkout the project as follows:

> git clone https://github.com/Radulfus/TM1638.git

Assemble:

> avra tm1638cc.asm

Upload to the MCU:

> avrdude -c usbasp -p m32 -P usb -U flash:w:tm1638cc.hex

In the example above I use an ATMega32.
