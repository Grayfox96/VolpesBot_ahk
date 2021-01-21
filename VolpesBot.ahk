#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
#KeyHistory 0
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#SingleInstance Force
#Persistent
CoordMode, ToolTip , Screen
Menu, Tray, Icon , Files\Twitch.ico ; hardcoded value
#Include Files\Socket.ahk ; Include the Socket library ; hardcoded value
#Include Files\MyRC.ahk ; Include the IRC library ; hardcoded value
#Include Files\SendData.ahk ; hardcoded value
Run, SpotifySongTimer.ahk, %A_WorkingDir%\Files\, , SpotifySongTimerPID
SendData(True, False) ;Autorun. False means look for a label name in the first comma separated value
global SongArtistAndTitleFromSpotify := ""
global PreviousSongArtistAndTitleFromSpotify := ""
global SendDataVar1 := ""
global SendDataVar2 := ""
global SendDataVar3 := ""
global SendDataVar4 := ""
global SendDataVar5 := ""
global TimeAtStartup := A_TickCount
global A_Enter := "`n"
global A_InvisibleCharacter := " 󠀀 "
global WorkingDirSlash := A_WorkingDir . "\"
global EmoteDirSlash := WorkingDirSlash . "Emotes\"
If !(InStr(FileExist(EmoteDirSlash), "D") ) {
	MsgBox, % "Emotes directory missing, you can download emotes there using the ""showemote"" command" ; hardcoded value
	ExitApp
	}
global Paused := 0
If !(FileExist("Files\Settings.ahk")) {
	MsgBox, % "edit the ""settings_template.ahk"" file in the ""Files"" directory and rename it ""Settings.ahk"", bot might break if you dont fill out all the fields" ; hardcoded value
	ExitApp
	}
#Include Files\Settings.ahk
If !(SettingsTrayIcon)
	#NoTrayIcon
If !(InStr(FileExist(GifsDir), "D") ) {
	MsgBox, % "Gifs directory missing" ; hardcoded value
	ExitApp
	}
If (SettingsShowGui)
	#Include Files\TwitchBotGUI.ahk ; Include the IRC library ; hardcoded value
MyBot := new IRCBot() ; Create a new instance of your bot
MyBot.Connect(SettingsAddress, SettingsPort, SettingsNicks, SettingsUser, SettingsName, SettingsPass) ; Connect to an IRC server
MyBot.SendJOIN(SettingsChannelsVariable) ; Join the channels
; Sleep, 2000
; SendMessageToEveryChannel("FeelsDankMan 👍 Bot Online")
SetTimer, AnnouncementFunction, %AnnouncementFunctionTimer%
Return
;										
;				HOTKEYS					
;										
SpotifySongChanged:
	SaveCurrentSong()
Return
GuiClose:
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	WinKill, SpotifySongTimer.ahk ahk_pid %SpotifySongTimerPID%
	ExitApp
Return
;										
;				BOT CLASS				
;										
class IRCBot extends IRC { ; Create a bot that extends the IRC library
	onPRIVMSG(Tags,Nick,User,Host,Cmd,Params,Msg,Data) { ; This function gets called on every PRIVMSG (IRC protocol name for incoming chat message)
		Channel := Params[1] ; In a PRIVMSG, the channel the message came from is stored as the first parameter. This line sets the variable "Channel" to the channel the message came from.
		MessagesSinceLastAutomatedMessage[Channel] := ((IsMessageEven[Channel]) ? (MessagesSinceLastAutomatedMessage[Channel] + 1) : 1)
		TagsArray := CreateTagsSplit(Tags)
		DisplayName := TagsArray["display-name"] ; hardcoded value
		ModCheck := TagsArray["Mod"] ; hardcoded value
		BroadcasterCheck := InStr(TagsArray["badges"], "broadcaster") ; hardcoded value
		BannedPhrasesNeedleRegEx := "(?:^|\h|\R|\v)(" . BannedPhrases[Channel] . "|" . BannedPhrases["global"] . ")(?:$|\h|\R|\v)"
		If RegExMatch(Msg, BannedPhrasesNeedleRegEx) {
			this.SendPRIVMSG(Channel, "/delete " TagsArray["id"])
			}
				; REWARDS REDEEMS
		If (TagsArray["custom-reward-id"]) { ; Redeems points rewards
			If (TagsArray["custom-reward-id"] = "ec6e4fe7-10aa-4edf-af39-feed316d9f81") { ; hardcoded value
				this.SendPRIVMSG(Channel, "ClappyJam yay " DisplayName " redeemed Test1 with message: " Msg) ; hardcoded value
				}
			Else if (TagsArray["custom-reward-id"] = "e65cdfd3-a37b-42e3-8612-cfae55bcad3a") { ; hardcoded value
				TimeoutRewardSplit := StrSplit(Msg , A_Space)
				this.SendPRIVMSG(Channel, "/timeout " TimeoutRewardSplit[1] " 600")
				}
			Else if (TagsArray["custom-reward-id"] = "de3ba6b8-2059-480f-859e-540023f24f5a") { ; hardcoded value
				TimeoutRewardSplit := StrSplit(Msg , A_Space)
				this.SendPRIVMSG(Channel, "/vip " TimeoutRewardSplit[1])
				}
			Else if (TagsArray["custom-reward-id"] = "9ce19df5-40c8-4893-80c6-4f21727e93ef") { ; hardcoded value
				TimeoutRewardSplit := StrSplit(Msg , A_Space)
				this.SendPRIVMSG(Channel, "/unvip " TimeoutRewardSplit[1])
				}
			}
				; TRIGGERS
		PingedNeedleRegEx := "i)(?:^|\h|\R|\v)(@" SettingsUser ")(?:$|\h|\R|\v)"
		If RegExMatch(Msg, PingedNeedleRegEx) {
			this.SendPRIVMSG(Channel, "👋 " MoodEmotes[Channel, "good"] " hi " DisplayName "! I'm a bot.") ; hardcoded value
			}
		TimeDifference := TagsArray["tmi-sent-ts"] - LastTriggeredMessageTime[Channel] - 30000
		EmotesTriggersNeedleRegEx := "(?:^|\h|\R|\v)(" . EmotesTriggers[Channel] . ")(?:$|\h|\R|\v)"
		If (((TimeDifference > 0) or !(LastTriggeredMessageTime[Channel])) and (RegExMatch(Msg, EmotesTriggersNeedleRegEx, Emote))) { ; Sends an emote if its in the list ; hardcoded value
			If (IsMessageEven[Channel] = !IsMessageEven[Channel])
				Emote .= A_InvisibleCharacter
			LastTriggeredMessageTime[Channel] := TagsArray["tmi-sent-ts"]
			this.SendPRIVMSG(Channel, Emote)
			}
		For each, Needle in MiscTriggers["NeedleRegEx"] {
			If (RegExMatch(Msg, Needle) and Nick = MiscTriggers["Nick", each])
			this.SendPRIVMSG(Channel, MiscTriggers["Response", each])
			}
				; COMMANDS
		CommandTriggerNeedleRegEx := "^\s*" . CommandTrigger[Channel] . "(\S+)(?:\s+(.+?))?\s*$"
		BlackListNeedleRegEx := "i)^(" . BlackList[Channel] . "|" . BlackList["global"] . ")$"
		If ((RegExMatch(Msg, CommandTriggerNeedleRegEx, CommandRegExMatch)) and !(RegExMatch(User, BlackListNeedleRegEx))) {
			Command := CommandRegExMatch1 ; Command is the first capturing subpattern in the RegEx
			Param := CommandRegExMatch2 ; The parameter is the second capturing subpattern in the RegEx
			If (SettingsShowGui)
				ShowLastCommandSent(Channel " <" DisplayName ">: " Msg)
			Else
				ToolTip, %LastCommandMessage% , 1900, 1040, 1 ; This displays a ToolTip in the form of "<DisplayName> Message someone sent"
			If (Paused) { ; Actions if the bot is paused
				If (Command = "UnpauseBot" and Nick = SettingsBotOwner) { ; Unpauses the bot
					this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 👍 turning commands on")
					PauseBot(0)
					}
				}
			Else if (!Paused) { ; Actions if the bot is unpaused
				IniRead, CustomCommandOutput, Files\CustomCommands.ini, %Channel%, % "customcommand" . Command, %A_Space%
				CommandCheckNeedleRegEx := "i)" . Command . "[,|.]"
				If (RegExMatch(ListsOfCommands[Channel, "list"], CommandCheckNeedleRegEx) or RegExMatch(ListsOfModCommands[Channel, "list"], CommandCheckNeedleRegEx) or CustomCommandOutput) { ; Checks if the command exists or not
					If (Param) { ; Checks if the first character might be a trigger for another bot and changes it to an emoji
						FirstCharacter := SubStr(Param, 1, 1)
						If (FirstCharacter = "!") {
							Param := StrReplace(Param, "!", "❗", , 1)
							}
						Else if (FirstCharacter = "$") {
							Param := StrReplace(Param, "$", "💲", , 1)
							}
						Else if (FirstCharacter = "$") {
							Param := StrReplace(Param, "#", "#⃣", , 1)
							}
						}
					If (CustomCommandOutput) { ; Sends the output of a custom command
						this.SendPRIVMSG(Channel, CustomCommandOutput)
						}
					Else if (Command = "Hi" or Command = "Bot") { ; Send a chat message saying "Hello Nick!" in the channel that the command was triggered in
						this.SendPRIVMSG(Channel, "👋 " MoodEmotes[Channel, "good"] " hi " DisplayName "! I'm a bot. You can find a copy of me here https://grayfox96.github.io/VolpesBot/")
						}
					Else if (Command = "Slap") { ; Send a "/me slaps Parameter" to the channel the command was triggered in
						this.SendACTION(Channel, "slaps " Param)
						}
					Else if (Command = "Help") { ; Sends command help information 
						If (Param) {
							StringLower, Param, Param
							CommandExplanation := (ListsOfCommands["help", Param]) ? (ListsOfCommands["help", Param]) : "idk sory"
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] CommandExplanation)
							}
						Else {
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " if you need help with a command type " CommandTrigger[Channel] "help {name of the command}, if you want to talk to " SettingsBotOwner " type " CommandTrigger[Channel] "HeyBotmanINeedHelpThanks followed by a reason")
							}
						}
					Else if (Command = "Ping") { ; Sends a test message with the uptime
						this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 🏓 pong... ive been alive since " Uptime() " ago.")
						}
					Else if (Command = "Dank") { ; Tells you how much dank you are
						Random, rand, 1, 100
						If (Param) {
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 📣 " Param " is " rand "% dank")
							}
						Else {
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 📣 " DisplayName " is " rand "% dank")
							}
						}
					Else if (Command = "Song" or Command = "Nowplaying") { ; Sends the current song playing in chat (only spotify implemented for now)
						If (SongArtistAndTitleFromSpotify) {
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 📣 Now playing: " SongArtistAndTitleFromSpotify "")
							}
						Else
							{
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "bad"] " idk ask grayfox") ; hardcoded value
							}
						}
					Else if (Command = "Lastsong" or Command = "Previoussong") {
						If (PreviousSongArtistAndTitleFromSpotify) {
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 📣 The last song was: " PreviousSongArtistAndTitleFromSpotify "")
							}
						Else
							{
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "bad"] " idk ask grayfox") ; hardcoded value
							}
						}
					Else if (Command = "Joinchannel") { ; Joins a channel
						If (Nick = SettingsBotOwner) {
							ParamSplit := StrSplit(Param, A_Space)
							If (RegExMatch(Paramsplit[1], "^[a-zA-Z0-9][\w]{3,24}$")) {
								JoinNewChannel(ParamSplit[1])
								this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " joined channel " Paramsplit[1])
								}
							Else {
								this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " to make me join a channel type ""joinchannel {channel name}""") ; hardcoded value
								}
							}
						Else {
							JoinNewChannel(Nick)
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " joined channel " Nick)
							this.SendPRIVMSG("#grayfox1996", MoodEmotes[Channel, "good"] " i joined " Nick "'s channel") ; hardcoded value
							}
						}
					Else if (Command = "Leavechannel") { ; Parts a channel
						ChannelName := StrReplace(Channel, "#")
						If (Nick = SettingsBotOwner) {
							ParamSplit := StrSplit(Param, A_Space)
							If (RegExMatch(Paramsplit[1], "^[a-zA-Z0-9][\w]{3,24}$")) {
								PartChannel(ParamSplit[1])
								this.SendPRIVMSG(Channel, MoodEmotes[Channel, "bad"] " left channel " Param[1])
								}
							Else {
								this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " to make me leave a channel type ""!leavechannel {channel name}""") ; hardcoded value
								}
							}
						Else if (Nick = ChannelName) {
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "bad"] " you can find me again in " SettingsBotOwner "'s channel if you want me to join again")
							PartChannel(Nick)
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "bad"] " left channel " Nick)
							}
						Else {
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "weird"] " you cant use that command in this channel") ; hardcoded value
							}
						}
					Else if (Command = "HeyBotmanINeedHelpThanks") { ; Pings the botman in his channel
						this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " i pinged " SettingsBotOwner " in his channel, give him a sec")
						If (Param)
							this.SendPRIVMSG("#" SettingsBotOwner, MoodEmotes[Channel, "good"] " 📣 hey " SettingsBotOwner ", " DisplayName " in " Channel " needs your help: " Param) ; hardcoded value
						Else
							this.SendPRIVMSG("#" SettingsBotOwner, MoodEmotes[Channel, "good"] " 📣 hey " SettingsBotOwner ", " DisplayName " in " Channel " needs your help") ; hardcoded value
						}
					Else if (Command = "Command" or Command = "Commands") { ; Sends a list of commands
						this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 📣 List of commands: " ListsOfCommands[Channel, "list"] " Mod only commands: " ListsOfModCommands[Channel, "list"])
						}
				; MOD COMMANDS
					Else if ((Nick = SettingsBotOwner) or ModCheck or BroadcasterCheck) { ; Checks if the bot owner or a mod or the broadcaster are requesting the command
						If (Command = "PauseBot") { ; Pauses the bot
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 👍 turning commands off")
							PauseBot(1)
							}
						Else if (Command = "Pyramid") { ; Sends multiple messages to create a pyramid of emotes
							If (Param) {
								MsgPyramidSplit := StrSplit(Param , A_Space)
								SendAPyramid(Channel, MsgPyramidSplit[1], MsgPyramidSplit[2])
								}
							Else {
								this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " you forgot the emote")
								}
							}
						Else if (Command = "Timeout") { ; Times out a user
							this.SendPRIVMSG(Channel, "/timeout " Param)
							}
						Else if (Command = "Shutdown" or Command = "Off") { ; Shuts down the bot
							ShutdownBot("")
							}
						Else if (Command = "ToggleSceneOrSource") { ; Toggles a source in OBS
							ToggleSceneOrSource(Param)
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 👍 done")
							}
						Else if (Command = "Showemote") { ; Downloads an emote file and shows it in OBS
							If (Param) {
								If (Param = "random") {
									Response := SendEmoteToOBS("random")
									this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " showing " Response)
									}
								Else {
									Response := ParseEmoteUrl(Param)
									If (Response[2]) {
										SendEmoteToOBS(Response[2])
										}
									this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " downloaded " Response[1])
									}
								}
							Else {
								this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " you forgot the emote link")
								}
							}
						Else if (Command = "OBSSetup") { ; Changes settings in obs by opening a NOOBS CMDR file https://obsproject.com/forum/resources/nuttys-official-obs-commander-noobs-cmdr.1178/
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " OBS set to " Param) ; hardcoded value
							OBSSetup := Param . ".vbs"
							Run, %Param% , NOOBS CMDR Commands\, Hide, ; hardcoded value
							}
						Else if (Command = "Sendmessage") { ; Sends "Param", useful to make the bot send commands like /color
							this.SendPRIVMSG(Channel, Param)
							}
						Else if (Command = "Hachudeer") { ; widepeepoHappy https://www.twitch.tv/hachubby
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "happy"] " ⣿⣿⣿⣿⣿⣿⣿⢿⣿⠏⠉⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠻⣿⣿⣿⣿ ⣿⣿⣿⣿⣿⣿⠄⠄⠈⠄⠄⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⠄⣿⣿⣿⣿ ⣿⣿⣿⣿⣿⣿⣿⣦⠄⠄⠄⠿⠿⠛⠛⠛⠛⠿⠿⣿⣿⣿⣿⡟⠄⠄⠘⠛⢻⣿ ⣿⣿⣿⣿⣿⣿⣿⡿⠃⣀⣤⣴⣶⣶⣶⣶⣶⣦⣤⣀⠉⠛⠋⠄⠄⢀⣤⣤⣾⣿ ⣿⣿⠿⠛⠋⠉⢀⣴⡏⠄⢀⠿⠟⠛⠛⠿⢿⣿⡟⠛⠛⣦⡀⠄⢰⣿⣿⣿⣿⣿ ⣿⡇⠄⢶⠟⠠⠿⠛⠛⠉⠁⠄⠸⠿⠗⠄⠄⠙⠳⢤⣤⣿⣿⡄⠄⠙⢿⣿⣿⣿ ⣿⣧⡀⠄⠄⠄⢀⣠⣴⣶⠆⣀⣀⠄⠄⢀⣀⠠⣄⠄⠙⢿⣿⣿⠄⠄⠄⠈⠻⣿ ⣿⣿⣿⡇⣠⣾⠿⢛⣉⣴⣾⣿⣿⣿⣿⣿⣿⣷⣌⢿⣦⡀⠙⠁⠄⠄⠄⠄⠄⣿ ⣿⣿⡟⡰⠋⠄⣾⡇⠄⣻⣿⣿⣿⣿⣿⠏⠉⣿⣿⡌⣿⣿⡀⠄⠄⠄⢀⣀⣼⣿ ⣿⣿⢡⠃⠠⢠⣿⣿⣾⣿⣿⣿⣿⣿⣿⣷⣴⣿⣿⣷⢈⣭⡅⠄⠄⣸⣿⣿⣿⣿ ⣿⣿⡈⣆⠄⣾⣿⣿⣿⣷⣝⣛⣫⣾⣿⣿⣿⣿⣿⣿⣿⣿⠇⠄⠄⣿⣿⣿⣿⣿ ⣿⣿⣧⠹⣧⠈⢿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⢀⣴⡄⢿⣿⣿⣿⣿ ⣿⣿⣿⡇⣿⡇⠄⠄⠄⠉⠻⠛⠟⠋⠉⠄⠄⠙⠋⠁⠄⢠⣿⣿⡇⢸⣿⣿⣿⣿ ⣿⡿⢋⣴⡿⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠸⣿⡿⠃⢸⣿⣿⣿⣿ ⣿⣷⣿⣿⣾⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣾⣶⣶⣿⣿⣿⣿⣿ ") ; hardcoded value
							}
						Else if (Command = "Gettags") { ; Sends out the tags of the message
							this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " These are the tags of your message: " Tags)
							}
						Else if (Command = "Newcommand") { ; Creates a custom command
							NewCommandNeedleRegEx := "^" . CommandTrigger[Channel] . "i)(?:[newcomad]{10}) (?P<Name>[^ !\$#]*) (?P<Parameter>.*)$"
							If (RegExMatch(Msg, NewCommandNeedleRegEx, RegExCommand)) {
								NewCommandNeedleRegEx := "i)" . RegExCommandName . "[,|.]"
								IniRead, CustomCommandOutput, Files\CustomCommands.ini, %Channel%, % "customcommand" . RegExCommandName, %A_Space%
								If !(RegExMatch(ListsOfCommands[Channel, "list"], NewCommandNeedleRegEx) or RegExMatch(ListsOfModCommands[Channel, "list"], NewCommandNeedleRegEx) or CustomCommandOutput) { ; Checks if the command exists or not
									CommandFileSection :=
									IniRead, CommandFileSection, Files\CustomCommands.ini, %Channel%
									CommandFileSection := CommandFileSection . "customcommand" . RegExCommandName . "=" . RegExCommandParameter
									IniWrite, %CommandFileSection%, Files\CustomCommands.ini, %Channel%
									this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " created command """ RegExCommandName """")
									}
								Else {
									this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " the """ RegExCommandName """ command already exists") ; hardcoded value
									}
								}
							Else {
								this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " to create a new command type ""!newcommand {name of the command} {reply to the command}, it doesnt support variables for now") ; hardcoded value
								}
							}
						Else if (Command = "Deletecommand") { ; Deletes a custom command
							DeleteCommandNeedleRegEx := "^" . CommandTrigger[Channel] . "i)(?:[deltcoman]{13}) (?P<Name>[^ !\$#]*)"
							If (RegExMatch(Msg, DeleteCommandNeedleRegEx, RegExCommand)) {
								NewCommandNeedleRegEx := "i)" . RegExCommandName . "[,|.]"
								If !(RegExMatch(ListsOfCommands[Channel, "list"], NewCommandNeedleRegEx) or RegExMatch(ListsOfModCommands[Channel, "list"], NewCommandNeedleRegEx)) {
									IniRead, CommandToBeDeleted, Files\CustomCommands.ini, %Channel%, % "customcommand" . RegExCommandName, %A_Space%
									If (CommandToBeDeleted) {
										IniDelete, Files\CustomCommands.ini, %Channel%, % "customcommand" . RegExCommandName
										this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " deleted command """ RegExCommandName """")
										}
									Else {
										this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " the """ RegExCommandName """ command doesnt exist") ; hardcoded value
										}
									}
								Else {
									this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " you cant delete built-in commands") ; hardcoded value
									}
								}
							Else {
								this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " to delete a command type ""!deletecommand {name of the command}""") ; hardcoded value
									}
							}
						Else if (Command = "Reload") { ; Reloads this script
							if this.CanJoin
								this.SendPRIVMSG(Channel, MoodEmotes[Channel, "good"] " 👍 reloading the script")
							Sleep 500
							Reload
							}
						}
					Else if (RegExMatch(ListsOfModCommands[Channel, "list"], CommandCheckNeedleRegEx)) { ; Warns the user they cant use a mod command
						this.SendPRIVMSG(Channel, MoodEmotes[Channel, "weird"] " you cant use that command")
						}
					}
				}
			}
		}
				; WHISPER COMMANDS
	onWHISPER(Tags,Nick,User,Host,Cmd,Params,Msg,Data) {
		BlackListNeedleRegEx := "i)^(" . BlackList["global"] . ")$"
		WhisperWhiteListNeedleRegEx := "i)^(" . WhisperWhitelist . ")$"
		If ((Nick = SettingsBotOwner or RegExMatch(Nick, WhisperWhiteListNeedleRegEx)) and !RegExMatch(User, BlackListNeedleRegEx)) {
			CommandTriggerNeedleRegEx := "^\s*#(\S+)(?:\s+(.+?))?\s*$"
			If RegExMatch(Msg, CommandTriggerNeedleRegEx, Match) {
				Command := Match1 ; Command is the first capturing subpattern in the RegEx
				Param := Match2 ; The parameter is the second capturing subpattern in the RegEx
				If (Command = "PauseBot") { ; Unpauses the bot
					PauseBot(1)
					}
				Else if (Command = "UnpauseBot") {
					PauseBot(0)
					}
				Else if (Command = "Shutdown" or Command = "Off") { ; Shuts down the bot
					ShutdownBot("")
					}
				}
			}
		}
	onNOTICE(Tags,Nick,User,Host,Cmd,Params,Msg,Data){
		; this.SendPRIVMSG("#" SettingsNicks, "Data recieved from a NOTICE command:" Data)
		}
	Log(Data) { ; This function gets called for every raw line from the server 
		Print(Data) ; Print the raw data received from the server
		}
	}
;										
;				FUNCTIONS				
;										
Print(Params*) {
	; static _ := DllCall("AllocConsole") ; Create a console on script start
	; StdOut := FileOpen("*", "w") ; Open the standard output
	for each, Param in Params { ; Iterate over function parameters
		; StdOut.Write(Param "`n") ; Append the parameter to the standard output
		If (SettingsShowGui) {
			Gui, Submit , NoHide
			UIChatLogVariable := UIChatLogVariable . Param . "`n`n"
			UIChatLogVariable := SubStr(UIChatLogVariable, -20000)
			GuiControl,, %UIChatLog% , %UIChatLogVariable%
			SendMessage, 0x0115, 7, 0, , ahk_id %UIChatLog% ; WM_VSCROLL SB_RIGHT
			}
		}
	}

ToggleSceneOrSource(SceneOrSourceName) {
	StringLower, SceneOrSourceName, SceneOrSourceName
	SceneOrSourceName := """" . SceneOrSourceName . """"
	Run, OBSCommand.exe /password=%SettingsOBSCommandPass% /togglesource=%SceneOrSourceName%, %SettingsOBSCommandPath%, Hide,  ; hardcoded value
	}

RetrieveSpotifyWindowID() { ; Spotify has multiple windows open but the only one with a title is the one you actually want to pull the title from,
	WinGet, ListOfSpotifyWindows, List, ahk_exe Spotify.exe ; so just check if the window has a title and return that one
	Loop %ListOfSpotifyWindows% {
		WinGetTitle, SpotifyWindowTitle , % "ahk_id " ListOfSpotifyWindows%A_Index%
		If (SpotifyWindowTitle) {
			SpotifyWindowID := ListOfSpotifyWindows%A_Index%
			Return ListOfSpotifyWindows%A_Index%
			}
		}
	TrayTip , "Spotify Window ID", "Spotify Window ID could not be retrieved.", , 16
	}

ParseEmoteUrl(EmoteUrl) {
	SplitPath, EmoteUrl, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	If (OutDrive = "https://betterttv.com" or OutDrive = "https://cdn.betterttv.net") {
		If (OutDrive = "https://betterttv.com") {
			EmoteUrl := "https://cdn.betterttv.net/emote/" . OutFileName . "/3x"
			}
		Else if (OutDrive = "https://cdn.betterttv.net") {
			EmoteUrlSplit := StrSplit(EmoteUrl , "/")
			OutFileName := EmoteUrlSplit[5]
			}
		OutFileName .= ".gif"
		OutFileFullPath := EmoteDirSlash . OutFileName
		If !(FileExist(OutFileFullPath)) {
			downloadFile(EmoteUrl, EmoteDirSlash, OutFileName)
			EmotesArrayLenght++
			Return [OutFileName, OutFileName]
			}
		Else {
			Return ["already", OutFileName]
			}
		}
	Else if (OutDrive = "https://www.frankerfacez.com" or OutDrive = "https://cdn.frankerfacez.com") {
		If (OutDrive = "https://www.frankerfacez.com") {
			OutFileNameSplit := StrSplit(OutFileName, "-")
			EmoteUrl := "https://cdn.frankerfacez.com/emoticon/" . OutFileNameSplit[1] . "/4"
			}
		Else if (OutDrive = "https://cdn.frankerfacez.com") {
			EmoteUrlSplit := StrSplit(EmoteUrl , "/")
			OutFileName := EmoteUrlSplit[5]
			}
		OutFileName .= ".png"
		OutFileFullPath := EmoteDirSlash . OutFileName
		If !(FileExist(OutFileFullPath)) {
			downloadFile(EmoteUrl, EmoteDirSlash, OutFileName)
			EmotesArrayLenght++
			Return [OutFileName, OutFileName]
			}
		Else {
			Return ["already", OutFileName]
			}
		}
	Else {
		Return ["nothing, link must be from FFZ or BTTV", ""]
		}
	}

downloadFile(FileUrlToDownload, dir , NameOfDownloadedFile := "") {
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", FileUrlToDownload, true)
	whr.Send()
	whr.WaitForResponse()
	body := whr.ResponseBody
	data := NumGet(ComObjValue(body) + 8 + A_PtrSize, "UInt")
	size := body.MaxIndex() + 1
	if !InStr(FileExist(dir), "D")
		FileCreateDir % dir
	SplitPath FileUrlToDownload, urlFileName
	f := FileOpen(dir (NameOfDownloadedFile ? NameOfDownloadedFile : urlFileName), "w")
	f.RawWrite(data + 0, size)
	f.Close()
	}

SendEmoteToOBS(EmoteFileName) {
	If (EmoteFileName = "random") {
		Random, number, 1, %EmotesArrayLenght%
		EmoteFileName := % EmotesArray[number]
		}
	EmoteDirSlashForward := StrReplace(EmoteDirSlash, "\" , "/")
	json := """SetSourceSettings={'sourceName': 'emote', 'sourceSettings': {'local_file': '" . EmoteDirSlashForward . EmoteFileName . "'}}""" ; hardcoded value (emote)
	Run, OBSCommand.exe /password=%SettingsOBSCommandPass% /sendjson=%json%, %SettingsOBSCommandPath%, Hide,
	Return EmoteFileName
	}

Uptime() {
	TimeAtCommandExecution := A_TickCount
	TimeSinceStartupInMilliSeconds := (TimeAtCommandExecution - TimeAtStartup)
	TimeSinceStartupInHours := Floor(TimeSinceStartupInMilliSeconds / 3600000)
	TimeSinceStartupInMinutes := Mod(Floor(TimeSinceStartupInMilliSeconds / 60000), 60)
	TimeSinceStartupInSeconds := Mod(Floor(TimeSinceStartupInMilliSeconds / 1000), 60)
	Return TimeSinceStartupInHours . " hours, " . TimeSinceStartupInMinutes . " minutes and " . TimeSinceStartupInSeconds . " seconds"
	}

SendMessageToEveryChannel(Message) {
	global MyBot
	For each, Channel in SettingsChannels {
		MyBot.SendPRIVMSG(SettingsChannels[A_Index], Message)
		}
	}

ShutdownBot(Message := "") {
	If (Message)
		SendMessageToEveryChannel(Message)
	Sleep 500
	ExitApp
	}

JoinNewChannel(ChannelName) {
	global MyBot
	ChannelName := "#" ChannelName
	If (RegExMatch(ChannelName, "^#[a-zA-Z0-9][\w]{3,24}$")) { ; checks if the channelname is valid
		MyBot.SendJOIN(ChannelName)
		AddChannels(ChannelName)
		}
	}

AddChannels(NewChannel := "") {
	If !(NewChannel) {
		For Index, Channel in SettingsChannels
			TempChannelList .= Channel . ","
		TempChannelList := SubStr(TempChannelList, 1 , -1)
		Return TempChannelList
		}
	Else {
		SettingsChannels.Push(NewChannel)
		SettingsChannelsVariable .= "," . NewChannel
		}
	}

PartChannel(ChannelName) {
	global MyBot
	ChannelName := "#" ChannelName
	If (RegExMatch(ChannelName, "^#[a-zA-Z0-9][\w]{3,24}$")) ; checks if the channelname is valid
		MyBot.SendPART(ChannelName)
	}

AnnouncementFunction() {
	global MyBot
	For Channel , NumberOfMessages in MessagesSinceLastAutomatedMessage {
		If ((NumberOfMessages >= NumberOfMessagesMIN[Channel]) and (NumberOfMessagesMIN[Channel])) {
			MessagesSinceLastAutomatedMessage[Channel] := 0
			If (AutomaticMessage[Channel, NumberOfMessages]) {
				MyBot.SendPRIVMSG(Channel, AutomaticMessage[Channel, NumberOfMessages])
				AutomatedMessageNumber[Channel]++
				}
			Else {
				MyBot.SendPRIVMSG(Channel, AutomaticMessage[Channel, NumberOfMessages])
				AutomatedMessageNumber[Channel] := 2
				}
			}
		}
	}

CreateTagsSplit(Tags) {
	TagsArray := []
	TempArray := StrSplit(Tags, ";")
	For key, value in TempArray {
		TagSplit := StrSplit(value, "=")
		ObjRawSet(TagsArray, TagSplit[1], TagSplit[2])
		}
	Return TagsArray
	}

SendAPyramid(Channel, Emote, Tier := "") {
	global MyBot
	If !(Tier)
		Tier := 3
	If (Tier > 5)
		Tier := 5
	Loop, % Tier + Tier - 1
		{
		If(A_Index <= Tier) {
			MessageToSend := ""
			Loop %A_Index% {
				MessageToSend := MessageToSend . " " . Emote
				}
			MyBot.SendPRIVMSG(Channel, MessageToSend)
			}
		Else if (A_Index > Tier) {
			MessageToSend := ""
			Counter++
			Loop % Tier - Counter {
				MessageToSend := MessageToSend . " " . Emote
				}
			MyBot.SendPRIVMSG(Channel, MessageToSend)
			}
		}
	}

PauseBot(PauseOrNot = 1) {
	If (PauseOrNot) {
		Paused := 1
		ToolTip, Bot Paused, 1900, 989, 2
		}
	Else if (!PauseOrNot) {
		Paused := 0
		ToolTip, , , , 2
		}
	}

SaveCurrentSong() {
	; global MyBot
	If !(SongArtistAndTitleFromSpotify = "Nothing") and !(SendDataVar2 = "Nothing")
		PreviousSongArtistAndTitleFromSpotify := SongArtistAndTitleFromSpotify
	If (SendDataVar2)
		SongArtistAndTitleFromSpotify := SendDataVar2
	; MyBot.SendPRIVMSG("#" SettingsNicks, SendDataVar1 SendDataVar2 SendDataVar3 SendDataVar4 SendDataVar5)
	}

ShowLastCommandSent(MessageText := "") {
	If (SettingsShowGui) {
		If (MessageText) {
			GuiControl,, %UILastCommandWindowText% , %MessageText%
			SetTimer, ShowLastCommandSent, 10000
			}
		Else {
			GuiControl,, %UILastCommandWindowText% , 
			SetTimer, ShowLastCommandSent, Off
			}
		}
	}

RandomGif() {
	Random, number, 1, %NumberOfGifs%
	GifsDirForward := StrReplace(GifsDir, "\" , "/")
	GifFullPath := GifsDirForward . GifsArray[number]
	json := """SetSourceSettings={'sourceName': 'gif', 'sourceSettings': {'local_file': '" GifFullPath . "'}}""" ; hardcoded value
	Run, OBSCommand.exe /password=%SettingsOBSCommandPass% /sendjson=%json%, %SettingsOBSCommandPath%, Hide, ; hardcoded value
	}