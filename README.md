### Overview
![Layer Image](https://github.com/henrystern/extend_layer/blob/main/defaults.png?raw=true)
### Purpose
This script was designed to overcome two issues I had with existing extend layouts:
  1. Most extend layers rely primarily on the right hand which limits control when that hand is on the mouse
    * Instead this layer relys on the right hand for mouse navigation and the left hand for keyboard navigation. So both mouse and keyboard navigation is always available.
  2. Mouse navigation from the extend layer often feels like an afterthought
    * This script uses smooth mouse and scrollwheel movement rather than discrete jumps
    * Mouse behaviour can be adjusted with settings for acceleration and top speed
    * The user can use Vim-style marks to instantly jump between cursor locations

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
Customization should be self explanatory from the comments and the [AHK keylist](https://www.autohotkey.com/docs/KeyList.htm)
