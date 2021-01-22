; Start of Main Window ================================================================================================================================================================================
; UIMainWindow
global UIMainWindow := ""
Gui, New , HwndUIMainWindow, VolpesBot
; Gui +AlwaysOnTop
Gui, color, Black
Gui, font, cBBBBBB
UIMainWindowWidth := 1200
UIMainWindowHeight := 800
UIMainWindowXPos := A_ScreenWidth - UIMainWindowWidth - 40
UIMainWindowYPos := 40
Gui, Show, w%UIMainWindowWidth% h%UIMainWindowHeight% x%UIMainWindowXPos% y%UIMainWindowYPos%, VolpesBot

; UIChatLog
global UIChatLog := ""
global UIChatLogVariable := ""
UIChatLogHeight := UIMainWindowHeight -65
UIChatLogWidth := UIMainWindowWidth +17
Gui, Add, Edit, HwndUIChatLog w%UIChatLogWidth% h%UIChatLogHeight% x0 y0 vUIChatLogVariable ReadOnly , 

; UISelectChannels
global UISelectChannels := []
UISelectChannelsHeight := 20
For each, Channel in SettingsChannels {
	If Channel {
		UISelectChannelsXYOffset := (each = 1) ? "y+0" : "x+0"
		Gui, Add, Checkbox, HwndUISelectChannels%Channel% %UISelectChannelsXYOffset% vUISelectChannels%Channel% gUISelectChannelsFunction h%UISelectChannelsHeight%, %Channel%
		}
	}

; UIRestartButton
global UIRestartButton := ""
UIRestartButtonWidth := 200
UIRestartButtonHeight := UISelectChannelsHeight
UIRestartButtonLabel := "Restart"
UIRestartButtonXPos := UIMainWindowWidth - UIRestartButtonWidth
UIRestartButtonYPos := UIChatLogHeight
Gui, Add, Button, x%UIRestartButtonXPos% y%UIRestartButtonYPos% HwndUIRestartButton w%UIRestartButtonWidth% h%UIRestartButtonHeight% gUIRestartButtonFunction , %UIRestartButtonLabel%

; UISendMessageEdit
Gui, font, c000000
global UISendMessageEdit := ""
global UISendMessageEditVariable := ""
UISendMessageHeight := UIMainWindowHeight - UIChatLogHeight - UISelectChannelsHeight
UISendMessageYPos := UIMainWindowHeight - UISendMessageHeight
UISendMessageEditWidth := UIMainWindowWidth - UISendMessageHeight
UISendMessageEditLimit := 500 ; hardcoded value, twitch's limit
Gui, Add, Edit, HwndUISendMessageEdit x0 y%UISendMessageYPos% w%UISendMessageEditWidth% h%UISendMessageHeight% Limit%UISendMessageEditLimit% -WantReturn WantTab vUISendMessageEditVariable gUISendMessageEditFunction,

; UISendMessageButton
global UISendMessageButton := ""
UISendMessageButtonWidth := UISendMessageHeight
UISendMessageButtonHeight := UISendMessageHeight
UISendMessageButtonLabel := "Send"
Gui, Add, Button, x+0 HwndUISendMessageButton y%UISendMessageYPos% w%UISendMessageButtonWidth% h%UISendMessageButtonHeight% gUISendMessageButtonFunction , %UISendMessageButtonLabel%
GuiControl, Disable, %UISendMessageButton%
; End of Main Window ==================================================================================================================================================================================

; Start of Last Command Window ========================================================================================================================================================================
; UILastCommandWindow
If (SettingsShowLastCommandGui) {
	global UILastCommandWindow := ""
	UILastCommandWindowXPos := 0 ; 1920
	UILastCommandWindowYPos := 0 ; 220
	Gui, New , HwndUILastCommandWindow, Last Command
	Gui,%UILastCommandWindow%:+Owner%UIMainWindow% +E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop ; +E0x20 adds the clickthrough property
	WinSet, Transparent, 255
	Gui, color, 00FF00
	WinSet, TransColor, 00FF00
	Gui, font, cFFFFFF s14 q3 ; s14 is size, q3 removes antialiasing so transcolor works properly
	; UILastCommandWindowText
	global UILastCommandWindowText := ""
	Gui, Add, Text, HwndUILastCommandWindowText R1 x0 y0, This displays the last command sent to the bot ; R1 means 1 row max
	; End of Last Command Window ==========================================================================================================================================================================
	Gui, Show, NA w%A_ScreenWidth% x%UILastCommandWindowXPos% y%UILastCommandWindowYPos%, Last Command
	}
; End of UI elements ============================================================================================================================================================================================
Gui, Submit , NoHide


; Start of functions

UISelectChannelsFunction() {
	global
	Gui, Submit , NoHide
	For each, Channel in SettingsChannels {
		UISelectChannels[Channel] := UISelectChannels%Channel%
		}
	}

UISendMessageEditFunction() {
	Gui, Submit , NoHide
	If (UISendMessageEditVariable) {
		GuiControl, Enable, %UISendMessageButton%
		GuiControl, +Default, %UISendMessageButton%
		}
	Else {
		GuiControl, Disable, %UISendMessageButton%
		}
	}

UIRestartButtonFunction() {
	global MyBot
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	WinKill, SpotifySongTimer.ahk ahk_pid %SpotifySongTimerPID%
	Sleep 500
	Reload
	}

UISendMessageButtonFunction() {
	global
	Gui, Submit , NoHide
	If (UISendMessageEditVariable) {
		GuiControl, Disable, %UISendMessageButton%
		For each, Channel in SettingsChannels {
			If (Channel and UISelectChannels[Channel]) {
				MyBot.SendPRIVMSG(Channel, UISendMessageEditVariable)
				}
			}
		}
	GuiControl,, %UISendMessageEdit% , 
	ControlFocus, , ahk_id %UISendMessageEdit%
	}