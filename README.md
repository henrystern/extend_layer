### Overview
![Layer Image](https://github.com/henrystern/extend_layer/blob/main/defaults.png?raw=true)
### Purpose
This script repurposes the wasted Capslock key and gives you complete navigation control without ever having to reach for the arrow keys or mouse.

Features:
  * Intuitive and balanced layout
  * Smooth mouse and scrollwheel
  * Vim style marks for cursor locations
  * Easymotion inspired grid of cursor marks
  * Customizable cursor speed and acceleration

### Setup
If you have AHK installed:
  * Clone repository
  * Run extend_layer.ahk

Otherwise:
  * Clone repository
  * Download [Latest Release](https://github.com/henrystern/extend_layer/releases/latest) and place in repository folder
  * Run extend_layer.exe

### Run on Startup
* Win+r 'shell:startup'
* In the startup folder, place a shortcut to the script or .exe (depending on if you have AHK installed).

### Customization
Customization is encouraged and should be self explanatory from the comments and the [AHK keylist](https://www.autohotkey.com/docs/KeyList.htm)

### Tips
* By default CapsLock is remapped to LShift + RShift
* Monitor grid marks can be accessed from both Ext+~ and Ext+Shift+'
* While waiting for a mark, pressing any number key will give a grid of marks for the monitor of that number.
* If you notice underlying key presses slipping through, especially on rapid or combined keypresses, you can try changing USB ports, using a PS/2 adapter, or reducing mouse intervals
