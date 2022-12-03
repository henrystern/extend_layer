### Overview
![Layer Image](https://github.com/henrystern/extend_layer/blob/main/defaults.png?raw=true)
### Purpose
This script makes the CapsLock key the most useful key on the keyboard, by repurposing it as the gateway to complete navigation and mouse control.

### Features
  * Intuitive and balanced layout
  * Smooth and configurable mouse movement
  * Vim style marks to jump between cursor locations

### Setup
1. First clone the repository or download and extract the zip file.
1. If you have AHK installed run extend_layer.ahk
1. Otherwise run extend_layer.exe

### Run on Startup
* Win+r 'shell:startup'
* In the startup folder, place a shortcut to the script or .exe (depending on if you have AHK installed).

### Customization
* Customization should be self explanatory from the comments and the [AHK keylist](https://www.autohotkey.com/docs/KeyList.htm)

### Tips
* By default CapsLock is remapped to LShift + RShift
* Monitor grid marks can be accessed from both Ext+~ and Ext+Shift+'
* While waiting for a mark, pressing a number key will show you a grid of marks for that monitor (1 being primary).
* If you notice underlying key presses slipping through, especially on rapid or combined keypresses, you can try changing USB ports, using a PS/2 adapter, or reducing mouse intervals
