global SettingsShowGui	:= 1																	
global SettingsTrayIcon	:= 0																	
global SettingsAddress	:= "irc.chat.twitch.tv"													
global SettingsPort		:= "6667"																
global SettingsNicks	:= "volpesbot"															
global SettingsUser		:= "volpesbot"															
global SettingsName		:= "volpesbot"															
global SettingsPass		:= ""																	
FileRead, SettingsPass, files\twitchoauth.txt													
global SettingsChannels := ["#grayfox1996", "#volpesbot", "#shaqd_", "#sirmunchkin","#lithiumtim"]
global SettingsChannelsVariable := AddChannels()												
global SettingsBotOwner	:= "grayfox1996"														
global SettingsOBSCommandPath := "C:\Users\Claudio\Documents\Portable programs\OBSCommand\"		
global SettingsOBSCommandPass := "tiavgp96"														
global ListsOfCommands := []																	
ListsOfCommands["list"]						:=	["hi", "bot", "slap", "help", "ping", "dank", "song", "nowplaying", "lastsong", "previoussong", "joinchannel", "leavechannel", "heybotmanineedhelpthanks", "commands", "command"]
ListsOfCommands["#grayfox1996", "list"]				:=	"hi, bot, slap, help, ping, dank, song, nowplaying, lastsong, previoussong, joinchannel, leavechannel, heybotmanineedhelpthanks, commands, command."
ListsOfCommands["#volpesbot", "list"]				:=	"hi, bot, slap, help, ping, dank, song, nowplaying, lastsong, previoussong, joinchannel, leavechannel, heybotmanineedhelpthanks, commands, command."
ListsOfCommands["#shaqd_", "list"]					:=	"hi, bot, slap, help, ping, dank, joinchannel, leavechannel, heybotmanineedhelpthanks, commands, command."
ListsOfCommands["#sirmunchkin", "list"]				:=	"hi, bot, slap, help, ping, dank, joinchannel, leavechannel, heybotmanineedhelpthanks, commands, command."
ListsOfCommands["#lithiumtim", "list"]				:=	"hi, bot, slap, help, ping, dank, joinchannel, leavechannel, heybotmanineedhelpthanks, commands, command."
ListsOfCommands["help"]						:=	{"hi": " i say hi back to you... Usage: hi"
												, "bot": " i say hi back to you... Usage: bot"
												, "slap": " i slap a user, it was a default command so i just left it there... Usage: !slap[ User]"
												, "help": " you are using this command right now... Usage: help {command name}"
												, "ping": " i tell you my uptime... Usage: ping"
												, "dank": " i tell you how much dank you or someone else are... Usage: dank[ User]"
												, "song": " i tell you what song is playing right now, works only if im using spotify for the music for now... Usage: song"
												, "nowplaying": " i tell you what song is playing right now, works only if im using spotify for the music for now... Usage: nowplaying"
												, "lastsong" : "temp"
												, "previoussong" : "temp"
												, "joinchannel": " makes me join your channel until the bot gets reset... Usage: joinchannel"
												, "leavechannel": " makes me leave your channel until the bot gets reset... Usage: leavechannel"
												, "heybotmanineedhelpthanks": " i ping the botman in his channel... Usage: heybotmanineedhelpthanks[ Reason]"
												, "commands": " i send a list of commands... Usage: commands"
												, "command": " i send a list of commands... Usage: command"
												, "unpausebot": " unpauses me... usage: unpausebot"
												, "pausebot": " pauses me... usage: pausebot"
												, "pyramid": "i make an emote pyramid... usage: pyramid {emote}[ tier]"
												, "timeout": " basically the /timeout command... usage: timeout {user}[ lenght in seconds]"
												, "shutdown": " shuts me off... usage: shutdown"
												, "off": " shuts me off... usage: off"
												, "togglesource": " toggles a source or scene in obs... usage: togglesource [scene name ]{source name}"
												, "showemote": " downloads an emote from the ffz or bttv emote link and shows it in obs... usage: showemote [bttv or ffz emote link]"
												, "obssetup": " open a obs setup file https://obsproject.com/forum/resources/nuttys-official-obs-commander-noobs-cmdr.1178/ ... usage: obssetup {setup name}"
												, "sendmessage": " i copy your message and send it... usage: sendmessage {body of the message}"
												, "hachudeer": " . o O ( PepeHands )"
												, "hachudeer2": " . o O ( PepeHands )"
												, "gettags": " i send the irc tags of your message... usage: gettags"
												, "newcommand": " creates a new command, it doesnt support variables for now... usage: !newcommand {name of the command} {response to the command}"
												, "deletecommand": " deletes a custom command"
												, "reload": " reloads the bot"}
global ListsOfModCommands := []																	
ListsOfModCommands["list"]					:=	["unpausebot", "pausebot", "pyramid", "timeout", "shutdown", "off", "togglesource", "showemote", "obssetup", "sendmessage", "hachudeer", "hachudeer2", "gettags", "newcommand", "deletecommand", "reload"]
ListsOfModCommands["#grayfox1996", "list"]	:=	"unpausebot, pausebot, pyramid, timeout, shutdown, off, togglesource, showemote, obssetup, sendmessage, hachudeer, hachudeer2, gettags, newcommand, deletecommand, reload."
ListsOfModCommands["#volpesbot", "list"]	:=	"unpausebot, pausebot, pyramid, timeout, shutdown, off, togglesource, showemote, obssetup, sendmessage, hachudeer, hachudeer2, gettags, newcommand, deletecommand, reload."
ListsOfModCommands["#shaqd_", "list"]		:=	"pyramid, timeout, sendmessage, newcommand, deletecommand."
ListsOfModCommands["#sirmunchkin", "list"]	:=	"pyramid, timeout, sendmessage, newcommand, deletecommand."
ListsOfModCommands["#lithiumtim", "list"]	:=	"pyramid, timeout, sendmessage, newcommand, deletecommand."
global CommandTrigger						:=	{"#grayfox1996": "#"
												, "#volpesbot": "#"
												, "#shaqd_": "#"
												,"#sirmunchkin": "#"
												,"#lithiumtim": "#"}
global EmotesTriggers						:=	{"#grayfox1996": "ayayaJAM|Anone|AYAYA|FeelsStrongMan GuitarTime|D:"
												, "#volpesbot": "FeelsDankMan|DankG|FeelsStrongMan GuitarTime|D:"
												, "#shaqd_": "FeelsDankMan 🎨 🎠 🎨 FeelsDankManR|FeelsDankMan 🙏 FeelsDankManR|FeelsDankMan 🤝 FeelsDankManR|peepoGiggles|FeelsStrongMan GuitarTime|D:|FeelsDankMan|FeelsDankManR"
												,"#sirmunchkin": "FeelsDankMan|D:"
												,"#lithiumtim": "FeelsDankMan|D:"}
; EmoteHappy,EmoteGood,EmoteWeird,EmoteBad
global MoodEmotes							:=	{"#grayfox1996": "widepeepoHappy,FeelsDankMan,grayfoxWeirdDude,KEKWait"
												, "#volpesbot": "FeelsAmazingMan,MrDestructoid,FUNgineer,FeelsBadMan"
												, "#shaqd_": "widepeepoHappy,FeelsDankMan,WEIRD,KEKWait"
												,"#sirmunchkin": "widepeepoHappy,FeelsDankMan,WEIRD,KEKWait"
												,"#lithiumtim": "widepeepoHappy,FeelsDankMan,WEIRD,KEKWait"}
global BannedPhrases						:=	{"#grayfox1996": "NaM"
												, "#volpesbot": "NaM|BannedPhrase"
												, "#shaqd_": ""
												,"#sirmunchkin": ""
												,"#lithiumtim": ""}
global NumberOfMessagesMIN					:=	{"#grayfox1996": "20"
												, "#volpesbot": "2"
												, "#shaqd_": "50"
												,"#sirmunchkin": "50"
												, "#lithiumtim": "50"}
global AutomaticMessage						:=	{"#grayfox1996": ["FeelsDankMan Join for deep art and speedrunning discussion https://discord.gg/yRvU3YQ"]
												, "#volpesbot": ["FeelsDankMan at least 2 messages were sent since the last announcement and this is announcement n1"
																, "FeelsDankMan at least 2 messages were sent since the last announcement and this is announcement n2"
																, "FeelsDankMan at least 2 messages were sent since the last announcement and this is announcement n3"]
												, "#shaqd_": ["join discord or strimmer is gonna cry https://discord.gg/jcbxYB4 doraeMate"]
												,"#sirmunchkin": ["FeelsDankMan"]
												,"#lithiumtim": ["FeelsDankMan"]}
global MiscTriggers							:=	{"NeedleRegEx":	["The raid will begin in 60 seconds",	"just redeemed shh",					"VolpesBot, you have already entered the dungeon recently",	"VolpesBot just leveled up!"]
												, "Nick":		["HuwoBot",								"StreamElements",						"HuwoBot",											"HuwoBot"]
												,"Response":	["+join",								"KEKWait shut the fuck up shakeshack",	"KEKWait",											"PogChamp"]}
global BlackList							:=	{"global": "supibot"
												, "#grayfox1996": ""
												, "#volpesbot": ""
												, "#shaqd_": ""
												,"#sirmunchkin": ""
												,"#lithiumtim": ""}
global EmotesArray := []																		
Loop, Files, %EmoteDirSlash%																	
	EmotesArray.push(A_LoopFileName)															
global EmotesArrayLenght := EmotesArray.Length()												
global MessagesSinceLastAutomatedMessage := []													
global AutomatedMessageNumber := []																
global IsMessageEven := []																		
global LastTriggeredMessageTime := []															
global PokemonGifsArray := []																	
Loop, Files, %PokemonGifsDir%*																	
	PokemonGifsArray.push(A_LoopFileName)														
global NumberOfPokemonGifs := PokemonGifsArray.Length()											
global AnnouncementFunctionTimer := 600000														; Time in milliseconds
