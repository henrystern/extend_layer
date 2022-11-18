### Overview
![Layer Image](https://github.com/henrystern/extend_layer/blob/main/defaults.png?raw=true)
### Purpose
This script gives the user complete navigation control from the home position by remapping the CapsLock key to function as a modifier.

This layer was designed to overcome two issues I had with existing extend layers:
  1. Most extend layers rely primarily on the right hand which limits control when that hand is on the mouse
       * Instead this layer uses the right hand for mouse navigation and the left hand for keyboard navigation, so both forms are always available.
  3. Mouse navigation support in existing extend layers feels like an afterthought
      * This script uses smooth mouse and scrollwheel movement rather than discrete jumps giving the user much more fluidity and control
      * The script also uses Vim-style marks that let you instantly jump between cursor locations

### Setup
If you have AHK installed:
  * Clone repository
  * Run extend_layer.ahk

Otherwise:
  * Download [Latest Release](https://github.com/henrystern/extend_layer/releases/latest)
  * Run extend_layer.exe

### Run on Startup
* Win+r 'shell:startup'
* In the startup folder, place a shortcut to the script or .exe (depending on if you have AHK installed).

### Customization
Customization is encouraged and should be self explanatory from the comments and the [AHK keylist](https://www.autohotkey.com/docs/KeyList.htm)

### Tips
* By default CapsLock is remapped to LShift + RShift
* Monitor grid marks can be accessed from both Ext+~ and Ext+Shift+'
* While awaiting a mark, pressing any number key will give a grid of marks for the monitor of that number.
