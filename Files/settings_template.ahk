global SettingsShowGui	:= 1																		;	1 for yes, 0 for no
global SettingsTrayIcon	:= 1																		;	1 for yes, 0 for no
global SettingsAddress	:= "irc.chat.twitch.tv"
global SettingsPort		:= "6667"
global SettingsNicks	:= "volpesbot"																;	login name of the bot
global SettingsUser		:= "volpesbot"																;	login name of the bot
global SettingsName		:= "volpesbot"																;	login name of the bot
global SettingsPass		:= ""
FileRead, SettingsPass, files\twitchoauth.txt														;	place the oauth key in this file
global SettingsChannels := ["#channel1", "#channel2"]												;	array list of channels you want your bot to connect to
global SettingsChannelsVariable := AddChannels()
global SettingsBotOwner	:= "botowner"																;	your login name
global SettingsOBSCommandPath := "C:\some\folder\name goes here\OBSCommand\"						;	location of your OBSCommand executable
global SettingsOBSCommandPass := "supersecretpassword"												;	password of the obs websocket server plugin
global ListsOfCommands := []
ListsOfCommands["list"]						:=	["hi", "bot", "slap", "help", "ping", "dank", "song", "nowplaying", "lastsong", "previoussong", "joinchannel", "leavechannel", "heybotmanineedhelpthanks", "commands", "command"]	; array of all commands
ListsOfCommands["#channel1", "list"]				:=	"hi, bot, slap, help, ping, dank, song, nowplaying, lastsong, previoussong, joinchannel, leavechannel, heybotmanineedhelpthanks, commands, command."	; a string of all commands you want active in a particular channel
ListsOfCommands["#channel2", "list"]				:=	"hi, bot, slap, help, ping, dank, song, nowplaying, lastsong, previoussong, joinchannel, leavechannel, heybotmanineedhelpthanks, commands, command."	; a string of all commands you want active in a particular channel
ListsOfCommands["help"]						:=	{"hi": " i say hi back to you... Usage: hi"																														; associative array of all commands as keys and their descriptions are values
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
ListsOfModCommands["list"]					:=	["unpausebot", "pausebot", "pyramid", "timeout", "shutdown", "off", "togglesource", "showemote", "obssetup", "sendmessage", "hachudeer", "hachudeer2", "gettags", "newcommand", "deletecommand", "reload"]	; array of all mod commands
ListsOfModCommands["#channel1", "list"]	:=	"unpausebot, pausebot, pyramid, timeout, shutdown, off, togglesource, showemote, obssetup, sendmessage, hachudeer, hachudeer2, gettags, newcommand, deletecommand, reload."									; a string of all mod commands you want active in a particular channel
ListsOfModCommands["#channel2", "list"]	:=	"unpausebot, pausebot, pyramid, timeout, shutdown, off, togglesource, showemote, obssetup, sendmessage, hachudeer, hachudeer2, gettags, newcommand, deletecommand, reload."									; a string of all mod commands you want active in a particular channel
global CommandTrigger						:=	{"#channel1": "#"	;	prefix to trigger the bot by channel
												, "#channel2": "#"}
global EmotesTriggers						:=	{"#channel1": "ayayaJAM|Anone|AYAYA|FeelsStrongMan GuitarTime|D:"	; string of phrases and emotes the bot copies when they are sent in a channel
												, "#channel2": "FeelsDankMan|DankG|FeelsStrongMan GuitarTime|D:"}

global MoodEmotes							:=	{"#channel1": "widepeepoHappy,FeelsDankMan,grayfoxWeirdDude,KEKWait"	; string of "mood" emotes the bot uses in his messages
												, "#channel2": "FeelsAmazingMan,MrDestructoid,FUNgineer,FeelsBadMan"}	; "EmoteHappy,EmoteGood,EmoteWeird,EmoteBad"
global BannedPhrases						:=	{"#channel1": "NaM|AYAYA"	;string of banned phrases
												, "#channel2": "NaM|BannedPhrase|BannedPhrase2"}
global NumberOfMessagesMIN					:=	{"#channel1": "20"	;minimum number of messages before the bot sends one of his automatic messages per channel
												, "#channel2": "2"}
global AnnouncementFunctionTimer := 600000																; Time in milliseconds between automated bot messages
global AutomaticMessage						:=	{"#channel1": ["FeelsDankMan Join for deep art and speedrunning discussion https://discord.gg/yRvU3YQ"] ; associative array with channel as the key and an array of messages as the value
												, "#channel2": ["FeelsDankMan at least 2 messages were sent since the last announcement and this is announcement n1"
																, "FeelsDankMan at least 2 messages were sent since the last announcement and this is announcement n2"
																, "FeelsDankMan at least 2 messages were sent since the last announcement and this is announcement n3"]}
global MiscTriggers							:=	{"NeedleRegEx":	["trigger number one",	"test123"]	; associative array: the 3 keys are a regex needle array, a nick array and a response array, the bot answers to the specific sender sending the specific message with a specific answer
												, "Nick":		["usernumberone",		"streamelements"]
												,"Response":	["hello usernumberone",	"stop testing streamelements"}
global BlackList							:=	{"global": "a_bot|some_other_user"	;array of strings with "global" and channel names as the keys and a string of blacklisted usernames as the values
												, "#channel1": "bad_guys_name|annoying_dude"
												, "#channel2": "another_annoying_dude|that_guy_you_dont_like"}
global EmotesArray := []
Loop, Files, %EmoteDirSlash%
	EmotesArray.push(A_LoopFileName)
global EmotesArrayLenght := EmotesArray.Length()
global MessagesSinceLastAutomatedMessage := []
global AutomatedMessageNumber := []
global IsMessageEven := []
global LastTriggeredMessageTime := []
global PokemonGifsArray := []
global PokemonGifsDir := "C:\some\folder\with\some\Pokemon gifs\"							; directory for a list of gifs
Loop, Files, %PokemonGifsDir%*
	PokemonGifsArray.push(A_LoopFileName)
global NumberOfPokemonGifs := PokemonGifsArray.Length()
