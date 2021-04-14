global TwitchClientSecret := ""
FileRead, TwitchClientSecret, Files\twitchclientsecret.txt
global TwitchClientID := ""
FileRead, TwitchClientID, Files\twitchclientid.txt
FileRead, TwitchAppOAuthTokenString, Files\twitchappoauthtoken.txt
If !TwitchAppOAuthTokenString {
	GetTwitchAppOAuthToken()
	FileRead, TwitchAppOAuthTokenString, Files\twitchappoauthtoken.txt
	}
global TwitchAppOAuthTokenArray := JSON.Load(TwitchAppOAuthTokenString)
global TwitchAuthorization := "Bearer " . TwitchAppOAuthTokenArray["access_token"]

GetTwitchAppOAuthToken() {
	Url := "https://id.twitch.tv/oauth2/token?client_id=" TwitchClientID "&client_secret=" TwitchClientSecret "&grant_type=client_credentials"
	TwitchAppOAuthToken := HTTPRequest(Url, "", "POST", "application/x-www-form-urlencoded")
	FileAppend , %TwitchAppOAuthToken%, Files\twitchappoauthtoken.txt
	}

TwitchGetUsers(LoginNameArray) {
	URL := "https://api.twitch.tv/helix/users?"
	For each, LoginName in LoginNameArray
		URL .= "login=" LoginName "&"
	URL := SubStr(URL, 1 , -1)
	Return TwitchHTTPRequest(URL)
	}

TwitchGetChannelInformation(BroadcasterIDArray){
	URL := "https://api.twitch.tv/helix/channels?"
	For each, BroadcasterID in BroadcasterIDArray
		URL .= "broadcaster_id=" BroadcasterID "&"
	URL := SubStr(URL, 1 , -1)
	Return TwitchHTTPRequest(URL)
	}

; TwitchGetUsersFollows(){}

TwitchHTTPRequest(URL, HTTPMethod := "GET", ContentType := "application/x-www-form-urlencoded") {
	Try
		{
		HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		HTTP.Open(HTTPMethod, URL, false)
		HTTP.SetRequestHeader("Content-Type", ContentType)
		HTTP.SetRequestHeader("client-id", TwitchClientID)
		HTTP.SetRequestHeader("Authorization", TwitchAuthorization)
		HTTP.Send()
		}
	Catch HTTPError
		{
		MsgBox, 16, , % "Exception thrown!`n`nwhat: " HTTPError.what "`nfile: " HTTPError.file . "`nline: " HTTPError.line "`nmessage: " HTTPError.message "`nextra: " HTTPError.extra
		}
	Return HTTP.responseText
	}
