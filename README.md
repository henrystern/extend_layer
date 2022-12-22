### Overview
![Layer Image](https://github.com/henrystern/extend_layer/blob/main/defaults.png?raw=true)
### Purpose
This script turns the CapsLock key into a new modifier (like shift, or ctrl), that when held down provides access to the controls shown above.
Complete navigation and mouse control becomes accessible without ever having to move your hands away from the home row. 

### Features
  * Intuitive layout
  * Smooth and configurable mouse movement
  * Marks to jump between cursor locations

### Setup
1. Clone the repository or download and extract the zip file.
1. If you have AHK V1.1 installed run extend_layer.ahk
1. Otherwise run extend_layer.exe (windows will warn you that the .exe is unsigned)

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

### Benefits Over Other Extend Layers
There were two main reasons I wrote this script instead of using EPKL, or any of the other extend layers.
1. Mouse support felt like an afterthought.
    * Extend layers exist to save you from having to move off the typing position. 
    * They generally succeed when it comes to keyboard controls but they are clearly not intended to be capable of replacing the mouse. 
    * This script can work as a complete mouse replacement.
2. Arrow keys work better under the left hand.
    * Somehow the extend layer convention has become i, j, k, l arrow keys. 
    * This makes arrow keys inaccessible when the right hand is on the mouse. 
    * This script's layout (arrow keys under w, a, s, d) means that no matter if your right hand is on the mouse or keyboard, you always have both mouse and keyboard navigation control.
