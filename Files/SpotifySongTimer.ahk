#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#KeyHistory 0
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
#Persistent
CoordMode tooltip, screen
#NoTrayIcon
#Include SendData.ahk

Loop, {
	WinWait, ahk_exe Spotify.exe
	SpotifyWindowID := RetrieveSpotifyWindowID()
	WinGetTitle, SongArtistAndTitleFromSpotify , ahk_id %SpotifyWindowID%
	If ((SongArtistAndTitleFromSpotify = "Advertisement") or (SongArtistAndTitleFromSpotify = "Spotify") or (SongArtistAndTitleFromSpotify = "Spotify Free"))
		SendData("VolpesBot", "SpotifySongChanged,SendDataVar1,,SendDataVar2,Nothing")
	Else if (SongArtistAndTitleFromSpotify)
		SendData("VolpesBot", "SpotifySongChanged,SendDataVar1,Now playing: ,SendDataVar2," SongArtistAndTitleFromSpotify)
	WinWaitClose, %SongArtistAndTitleFromSpotify% ahk_exe Spotify.exe, , 600
	}



Return

RetrieveSpotifyWindowID() { ; Spotify has multiple windows open but the only one with a title is the one you actually want to pull the title from
	WinGet, ListOfSpotifyWindows, List, ahk_exe Spotify.exe ; so just check if the window has a title and return that one
	Loop %ListOfSpotifyWindows% {
		WinGetTitle, SpotifyWindowTitle , % "ahk_id " ListOfSpotifyWindows%A_Index%
		If (SpotifyWindowTitle and !(SpotifyWindowTitle = "")) {
			; MsgBox, % SpotifyWindowTitle ; debugging
			Return ListOfSpotifyWindows%A_Index%
			}
		}
	Return
	}