#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#installkeybdhook

;settings
mouse_offset = 20 ;Mouse movement step

*CapsLock::return ;* so caps is not triggered on mod+caps
LShift & RShift::CapsLock

;release modifiers if they are still held when extend is released
CapsLock up::
    If GetKeyState("sc032", "P")
        send {Shift up}
    If GetKeyState("sc033", "P")
        send {Ctrl up}
    If GetKeyState("sc034", "P")
        send {Alt up}
    return

#If, GetKeyState("CapsLock", "P") ;Your CapsLock hotkeys go below

;;  *** Row 0 - function keys
;;
;;

F1::Volume_Mute
F2::Volume_Down
F3::Volume_Up
F4::Media_Play_Pause
F5::Media_Prev
F6::Media_Next
;F7::
;F8::
;F9::
;F10::
;F11::
;F12::

;;  *** Row 1 - number row
;;  ||`     |1     |2     |3     |4     |5     |6     |7     |8     |9     |0     |-     |=     |Back  ||
;;  ||sc029 |sc002 |sc003 |sc004 |sc005 |sc006 |sc007 |sc008 |sc009 |sc00a |sc00b |sc00c |sc00d |sc00e ||

;sc029::
sc002::send {F1}
sc003::send {F2}
sc004::send {F3}
sc005::send {F4}
sc006::send {F5}
sc007::send {F6}
;sc008::
;sc009::
;sc00a::
;sc00b::
;sc00c::
;sc00d::

;sc00e::

;;  *** Row 2 - upper letter row
;;  ||Tab     |Q     |W     |E     |R     |T     |Y     |U     |I     |O     |P     |[     |]     ||
;;  ||RWWc00f |sc010 |sc011 |sc012 |sc013 |sc014 |sc015 |sc016 |sc017 |sc018 |sc019 |sc01a |sc01b ||

sc010::Home
sc011::Up
sc012::End
sc013::Delete
sc014::Esc
sc015::PgUp
;sc016::
sc017::MouseMove, 0, (mouse_offset * -1), 0, R
;sc018::
;sc019::
;sc01a::
;sc01b::

;;  *** Row 3 - home row
;   ||Caps  |A     |S     |D     |F     |G     |H     |J     |K     |L     |;     |'     |\     ||
;;  ||sc03a |sc01e |sc01f |sc020 |sc021 |sc022 |sc023 |sc024 |sc025 |sc026 |sc027 |sc028 |sc02b ||

sc01e::Left
sc01f::Down
sc020::Right
sc021::Backspace
sc022::Appskey
sc023::PgDn
sc024::MouseMove, (mouse_offset * -1), 0, 0, R
sc025::MouseMove, 0, mouse_offset, 0, R
sc026::MouseMove, mouse_offset, 0, 0, R
sc027::^Backspace
;sc028::
;sc02b::

;;  *** Row 4 - lower letter row
;;  ||LS/GT |Z     |X     |C     |V     |B     |N     |M     |,     |.     |/     |Enter |Space ||
;;  ||sc056 |sc02c |sc02d |sc02e |sc02f |sc030 |sc031 |sc032 |sc033 |sc034 |sc035 |sc01c |sc039 ||

sc056::^z
sc02c::^x
sc02d::^c
sc02e::LButton
sc02f::^v
sc030::RButton
;sc031::
sc032::Shift
sc033::Ctrl
sc034::Alt
;sc035::

;sc01c::
sc039::Enter

;; *** Mouse Buttons
;XButton1::
;XButton2::

