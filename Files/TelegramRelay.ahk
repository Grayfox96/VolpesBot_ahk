global TelegramBotAPIToken := ""
FileRead, TelegramBotAPIToken, Files\telegrambotapitoken.txt						; place the bot token BotFather gives you in this file
global BaseTelegramURL := "https://api.telegram.org/bot" TelegramBotAPIToken "/"	; this is the base of the telegram api url
global TelegramChatID := ""
FileRead, TelegramChatID, Files\telegrambotchatid.txt

SendTelegramMessage(chat_id, text, disable_notification := 0, reply_to_message_id := "", reply_markup := "") {
	MethodUrl := BaseTelegramURL . "sendMessage"
	JSONArray := []
	JSONArray["chat_id"] := chat_id
	JSONArray["text"] := text
	if disable_notification
		JSONArray["disable_notification"] := disable_notification
	If reply_to_message_id
		JSONArray["reply_to_message_id"] := reply_to_message_id
	If reply_markup
		JSONArray["reply_markup"] := reply_markup
	; PrintArray(JSONArray) ; debug
	JSONString := JSON.Dump(JSONArray)
	; MsgBox, % JSONString ; debug
	Return HTTPRequest(MethodUrl, JSONString)
	}
