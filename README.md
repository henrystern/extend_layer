### Overview
![Layer Image](https://github.com/henrystern/extend_layer/blob/main/defaults.png?raw=true)
### Purpose
This script turns the CapsLock key into a new modifier (like shift, or ctrl), that when held down provides access to the controls shown above.
Complete navigation and mouse control becomes accessible without ever having to move your hands away from the home row. 

### Features
  * Simple and intuitive layout
  * Smooth and configurable mouse movement
  * Marks to quickly jump between cursor locations

### Tips
  * The help image can be displayed anytime by pressing Caps+Ctrl+1
  * By default CapsLock is remapped to LShift + RShift
  * A grid of evenly spaced marks across all monitors can be accessed from Caps+Shift+'
  * While waiting for a mark, pressing a number key will show you a grid of marks for that monitor (1 being primary).
  * While the mark gui is visible holding Caps+ I, J, K, or L will make minor adjustments to the mark locations
  * Shift + Scroll Up, and Shift + Scroll Down will perform horizontal scrolling.
  * Blank keys can be mapped to any ahk hotkey (See [Fully Mapped](https://github.com/henrystern/extend_layer/tree/fully_mapped))

### Benefits Over Other Extend Layers
There were two main reasons I wrote this script instead of using EPKL, or any of the other extend layers.
1. Mouse support felt like an afterthought.
    * Extend layers exist to save you from having to move off the typing position. They generally succeed when it comes to keyboard controls but they are clearly not intended to be capable of replacing the mouse. This script can work as a complete mouse replacement.
2. Arrow keys work better under the left hand.
    * Somehow the extend layer convention has become i, j, k, l arrow keys. This makes arrow keys inaccessible when the right hand is on the mouse. This script's layout (arrow keys under w, a, s, d) means that no matter if your right hand is on the mouse or keyboard, you always have both mouse and keyboard navigation control.
