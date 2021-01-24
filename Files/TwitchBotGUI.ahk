; Start of Main Window ================================================================================================================================================================================
; UIMainWindow
global UIMainWindow := ""
Gui, New , HwndUIMainWindow, VolpesBot
; Gui +AlwaysOnTop
Gui, color, Black
Gui, font, cBBBBBB
If (SettingsCompleteLog)
	UIMainWindowWidth := A_ScreenWidth -100
Else
	UIMainWindowWidth := 400
UIMainWindowHeight := A_ScreenHeight -200
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
		If (each = 1)
		UISelectChannelsXYOffset := "y+0"
		Else 
			UISelectChannelsXYOffset := "x+0"
		Gui, Add, Checkbox, HwndUISelectChannels%Channel% %UISelectChannelsXYOffset% vUISelectChannels%Channel% gUISelectChannelsFunction h%UISelectChannelsHeight%, %Channel%
		}
	}

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
	Gui, Show, NA w%A_ScreenWidth% x%UILastCommandWindowXPos% y%UILastCommandWindowYPos%, Last Command
	}
; End of Last Command Window ==========================================================================================================================================================================

; Start of Exit Confirm Window ========================================================================================================================================================================
; UIExitConfirmWindow
global UIExitConfirmWindow := ""
global UIExitConfirmWindowWidth := 300
global UIExitConfirmWindowHeight := 100
Gui, New , HwndUIExitConfirmWindow, Exit or Restart
Gui,%UIExitConfirmWindow%: -Caption +ToolWindow  +AlwaysOnTop ; +Owner%UIMainWindow%
; UIExitConfirmWindowText
global UIExitConfirmWindowText := ""
UIExitConfirmWindowTextWidth := 300
Gui, Add, Text, HwndUIExitConfirmWindowText x0 y10 w%UIExitConfirmWindowTextWidth% R1 Center , Do you want to exit or restart? ; R1 means 1 row max
; UIExitConfirmWindowButtonExit
Gui, Add, Button, HwndUIExitConfirmWindowButtonExit x30 y+40 w80 gUIExitConfirmWindowButtonExitFunction, Exit
; UIExitConfirmWindowButtonRestart
Gui, Add, Button, HwndUIExitConfirmWindowButtonRestart x+0 w80 gUIExitConfirmWindowButtonRestartFunction, Restart
; UIExitConfirmWindowButtonCancel
Gui, Add, Button, HwndUIExitConfirmWindowButtonCancel x+0 w80 Default gUIExitConfirmWindowButtonCancelFunction, Cancel
; End of Exit Confirm Window ==========================================================================================================================================================================

; End of UI elements ==================================================================================================================================================================================
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

UIExitConfirmWindowButtonExitFunction() {
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	WinKill, SpotifySongTimer.ahk ahk_pid %SpotifySongTimerPID%
	ExitApp
	}

UIExitConfirmWindowButtonRestartFunction() {
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	WinKill, SpotifySongTimer.ahk ahk_pid %SpotifySongTimerPID%
	Reload
	}

UIExitConfirmWindowButtonCancelFunction() {
	Gui, %UIExitConfirmWindow%:Hide
	;Gui, %UIMainWindow%:Show
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