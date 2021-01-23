class IRC
	{
	__New(ShowHex=false)
		{
			this.TCP := new SocketTCP()
			this.TCP.Parent := this
			this.TCP.onRecv := this._HandleRecv
			this.TCP.onDisconnect := this._HandleDisc
			this.ShowHex := ShowHex
			
			return this
		}
	
	Connect(Server, Port, Nick, User="", Name="", Pass="")
		{
			this.Channels := []
			this.Mode := []
			this.Prefix := {"Letters":{}, "Symbols":{}}
			this.CanJoin := false
			this.ChannelBuffer := ""
			
			this.Server := Server
			this.Port := Port
			this.Nick := Nick
			this.User := User ? User : Nick
			this.DefaultUser := User
			this.Name := Name ? Name : Nick
			this.Pass := Pass
			
			Sock := this.TCP.Connect([Server, Port])
			
			this._SendRaw("CAP REQ :twitch.tv/tags twitch.tv/commands") ; last modified lines
			if Pass
				this._SendPASS("PASS " Pass)
			this._SendRaw("NICK " this.Nick)
			this._SendRaw("USER " this.User " 0 * :" this.Name)
			
			return Sock
		}
	
	; Called in the context of the socket instance
	_HandleRecv()
		{
			Data .= this.RecvText()
			
			DatArray := StrSplit(Data, "`r`n", "`r`n")
			Data := DatArray.Remove(DatArray.MaxIndex())
			
			for each, Segment in DatArray
				this.Parent._OnRecv(Segment)
			
			return
		}
	
	; Called in the context of the socket instance
	_HandleDisc()
		{
			this.Parent.onDisconnect(this)
		}
	
	_OnRecv(Data)
		{
			static RegEx := "^@?(?P<Tags>([^\s=;]+=[^\s=;]*[; ])*)(?:\:(?P<Nick>[^\!\@ ]+)(?:\!(?P<User>[^\@ ]+))?(?:\@(?P<Host>[^ ]+))? )?(?P<Cmd>[^ ]+)(?: (?P<Params>[^\:][^ ]*(?: [^\:][^ ]*)*))?(?: \:(?P<Msg>.*))?$"
;				`"^(?:\:(?P<Nick>[^\!\@ ]+)(?:\!(?P<User>[^\@ ]+))?(?:\@(?P<Host>[^ ]+))? )?(?P<Cmd>[^ ]+)(?: (?P<Params>[^\:][^ ]*(?: [^\:][^ ]*)*))?(?: \:(?P<Msg>.*))?$`"
			
			if (!Data)
				return
			
			if (!RegExMatch(Data, RegEx, p))
			{
				this.Log("Malformed data recieved:" Data)
				return
			}
			Params := StrSplit(pParams, " ")
;			If (pNick and pUser and pHost and pMsg)
;				{
;				MessageToLog := Params[1] . " " . pNick . ": " . pMsg
;				this.Log(MessageToLog) ; This sends only the name and the message
;				}
;			Else
;				{
				this.Log(Data) ; This sends the whole message received
;				}
			if this.ShowHex
				this._LogHex(Data)
			; If no return value, go on to regular handler
			if (!this["_on" pCmd](pTags,pNick,pUser,pHost,pCmd,Params,pMsg,Data))
				this["on" pCmd](pTags,pNick,pUser,pHost,pCmd,Params,pMsg,Data)
		}
	
	_onNICK(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			if (Nick == this.Nick)
				this.Nick := Msg
			
			for Channel, NickList in this.Channels
				if NickList[Nick]
					NickList[Msg] := NickList[Nick], NickList.Remove(Nick)
		}
	
	_onPING(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			this._SendRaw("PONG :" Msg)
		}
	
	_onJOIN(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			Channel := Params[1] ? Params[1] : Msg
			if (Nick == this.Nick)
				this.Channels.Insert(Channel, [])
			else
				this.Channels[Channel].Insert(Nick, {"MODE":[]})
		}
	
	_onPART(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			if (Nick == this.Nick)
				this.Channels.Remove(Params[1])
			else
				this.Channels[Params[1]].Remove(Nick)
		}
	
	_onKICK(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			if (Params[2] == this.Nick)
				this.Channels.Remove(Params[1])
			else
				this.Channels[Params[1]].Remove(Nick)
		}
	
	_onQUIT(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			for Channel,NickList in % this.Channels
				NickList.Remove(Nick)
		}
	
	_onPRIVMSG(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			if (RegExMatch(Msg, "^\x01(?<Command>[^ ]+)(?: (.*))?\x01$", Match))
			{
				If (MatchCommand = "ACTION")
					Return false
				this.onCTCP(Tags,Nick,User,Host,Match1,Params,Match2,Data)
				return true ; true, we should stop from calling user function
			}
		}
	
	; ERR_NOMOTD
	_on422(p*)
		{
			this._on376(p*)
		}
	
	; RPL_ENDOFMOTD
	_on376(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			this.CanJoin := true
;			this._SendRaw("WHOIS " this.Nick) ; The Twitch API does not support WHO, part of the IRC specification. https://dev.twitch.tv/docs/irc/guide#command--message-limits
			this.SendJOIN("")
		}
	
	_onMODE(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			if (Params[1] == this.Nick)
				return False ; Return and call user function
			plus := true, i := 2, MODE := Params[2]
			Loop, Parse, MODE
			{
				if (A_Loopfield == "+")
					plus := True
				else if (A_LoopField == "-")
					plus := False
				else
				{
					i++
					if Plus
						this.Channels[Params[1], Params[i], "MODE"].Insert(A_LoopField, true)
					else
						this.Channels[Params[1], Params[i], "MODE"].Remove(A_LoopField)
				}
			}
		}
	
	; RPL_WHOISUSER
	_on311(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			if (Params[2] == this.Nick)
			{
				this.User := Params[3]
				this.Host := Params[4]
			}
		}
	
	;RPL_NAMREPLY
	_on353(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			Channel := this.Channels[Params[3]]
			
			for i, Nick in StrSplit(Msg, " ")
			{
				MODE := []
				; Only loop 5 times, just in case we hang somehow
				Loop, 5
				{
					; If we can convert the leading symbol into mode letter
					if (this.Prefix.Symbols.HasKey(Prefix := SubStr(Nick, 1, 1)))
					{
						; Add the mode letter to the mode table,
						;  and remove the symbol from the nick
						MODE.Insert(this.Prefix.Symbols[Prefix], true)
						Nick := SubStr(Nick, 2)
					}
					else
						break
				}
				Channel.Insert(Nick, {"MODE":MODE})
			}
		}
	
	; RPL_ISUPPORT
	_on005(Tags,Nick,User,Host,Cmd,Params,Msg,Data)
		{
			for i,Param in Params
			{
				if (KeyVal := StrSplit(Param, "="))
					this.MODE.Insert(KeyVal[1], KeyVal[2])
				else
					this.MODE.Insert(KeyVal[1], "")
			}
			
			if (RegExMatch(this.MODE.PREFIX, "^\((.+)\)(.+)$", Match))
			{
				Loop, % StrLen(Match1)
				{
					this.Prefix.Letters.Insert(SubStr(Match1, A_Index, 1), SubStr(Match2, A_Index, 1))
					this.Prefix.Symbols.Insert(SubStr(Match2, A_Index, 1), SubStr(Match1, A_Index, 1))
				}
			}
		}
	
	GetMODE(Channel, MODE)
		{
			if (!this.isIn(Channel))
				return False
			
			Out := []
			for Nick, Meta in this.Channels[Channel]
			{
				Needs := true
				Loop, Parse, MODE
				{
					if (A_LoopField == "+")
						Needs := true
					else if (A_LoopField == "-")
						Needs := false
					
					if A_LoopField is not alpha
						continue
					
					if (Needs && !Meta["MODE"].HasKey(A_LoopField)) ; If it should have, but doesn't
						Continue, 2
					else if (!Needs && Meta["MODE"].HasKey(A_LoopField)) ; If it shouldn't have, but does
						Continue, 2
				}
				
				Out.Insert(Nick, Meta)
			}
			return Out
		}
	
	_SendRaw(Message, RecvPrefix="", Prefix="", Suffix="", Encoding="UTF-8")
		{
			Max := 1530  - this._ByteCount(RecvPrefix, Encoding) - this._ByteCount(Suffix, Encoding)
			Out := []
			Loop, Parse, Message, `r`n, `r`n
			{
				for each, Split in this._ByteSplit(A_LoopField, Max)
				{
					Msg := Prefix . Split . Suffix "`r`n"
					Out.Insert(Split)
					this._SendTCP(Msg, Encoding)
				}
			}
			return Out
		}
	
	_SendTCP(Message, Encoding="UTF-8")
		{
			Messages := this._ByteSplit(Message, 1532)
			if Messages.MaxIndex() > 1
			{
				this.Log(Message)
				this.Log("Message too long, trimming")
			}
			Message := Messages[1]
			this.Log(Message)
			if this.ShowHex
				this._LogHex(Message)
			
			Length := this._ByteCount(Message, Encoding)
			VarSetCapacity(Buffer, Length)
			StrPut(Message, &Buffer, Length, Encoding)
			
			return this.TCP.send(&Buffer, Length)
		}
	
	_SendPASS(Message, RecvPrefix="", Prefix="", Suffix="", Encoding="UTF-8") ; This script used to send the oauth token to the log so i hid it just in case
		{
			Max := 510 - this._ByteCount(RecvPrefix, Encoding) - this._ByteCount(Suffix, Encoding)
			Out := []
			Loop, Parse, Message, `r`n, `r`n
			{
				for each, Split in this._ByteSplit(A_LoopField, Max)
				{
					Msg := Prefix . Split . Suffix "`r`n"
					Out.Insert(Split)
					Messages := this._ByteSplit(Msg, 512)
					if Messages.MaxIndex() > 1
					{
						this.Log(Msg)
						this.Log("Message too long, trimming")
					}
					Msg := Messages[1]
					this.Log("PASS oauth:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
					if this.ShowHex
						this._LogHex(Msg)
					Length := this._ByteCount(Msg, Encoding)
					VarSetCapacity(Buffer, Length)
					StrPut(Msg, &Buffer, Length, Encoding)
					return this.TCP.send(&Buffer, Length)
				}
			}
			return Out
		}
	
	IsIn(Channel)
		{
			return this.Channels.HasKey(Channel)
		}
	
	SendCTCP(Nick, Command, Text)
		{
			return this.SendPRIVMSG(Nick, Text, Chr(1) . Command " ", Chr(1))
		}
	
	SendCTCPReply(Nick, Command, Text)
		{
			return this.SendNOTICE(Nick, Text, Chr(1) . Command " ", Chr(1))
		}
	
	SendACTION(Channel, Text)
		{
			return this.SendCTCP(Channel, "ACTION", Text)
		}
	
	SendPRIVMSG(Channel, Text, Prefix="", Suffix="")
		{
			Header := "PRIVMSG " Channel " :" Prefix
			RecvHeader := ":" this.Nick "!" this.User "@" this.Host " " Header
			return this._SendRaw(Text, RecvHeader, Header, Suffix)
		}
	
	SendJOIN(Channels)
		{
		If !(this.ChannelBuffer)
			this.ChannelBuffer := ""
		ChannelsSplit := StrSplit(Channels , ",")
		loop
			{
			If (ChannelsSplit[A_Index])
				{
				TempChannel := ChannelsSplit[A_Index] . ","
				If !(InStr(this.ChannelBuffer, TempChannel))
					{
					this.ChannelBuffer .= TempChannel
					}
				}
			Else
				{
				Break
				}
			}
		if !this.CanJoin {
			this.Log("Join attempt failed, channels in the buffer: " this.ChannelBuffer "- Channels in ""Channels""" Channels)
			return
			}
		this.Log("Join attempt, channels in the buffer: " this.ChannelBuffer "- Channels in ""Channels""" Channels)
		this._SendRaw("JOIN " this.ChannelBuffer)
		}
	
	SendPART(Channel,Message="")
		{
			return this._SendRaw("PART " Channel (Message ? " :" Message : ""))
		}
	
	SendNICK(NewNick)
		{
			return this._SendRaw("NICK " NewNick)
		}
	
	SendQUIT(Message="")
		{
			return this._SendRaw("QUIT" (Message ? " :" Message : ""))
		}
	
	SendNOTICE(User, Message, Prefix="", Suffix="")
		{
			Header := "NOTICE " User " :" Prefix
			RecvHeader := ":" this.Nick "!" this.User "@" this.Host " " Header
			return this._SendRaw(Message, RecvHeader, Header, Suffix)
		}
	
	_ByteSplit(String, Bytes, encoding="UTF-8")
		{
			Out := []
			while (String != "") ; We want to be able to chat 0
			{
				VarSetCapacity(x, Bytes, 0)
				StrPut(String, &x, Bytes, Encoding)
				Out.Insert(Sub := StrGet(&x, Encoding))
				String := SubStr(String, StrLen(Sub)+1)
			}
			return Out
		}
	
	_ByteCount(String, Encoding="UTF-8")
		{
			return StrPut(String, Encoding) - 1
		}
	
	_LogHex(String, Encoding="UTF-8")
		{
			Length := this._ByteCount(String, Encoding)
			VarSetCapacity(Buffer, Length)
			StrPut(String, &Buffer, Length, Encoding)
			
			SetFormat, IntegerFast, Hex
			Out := ""
			Loop, % Length
				Out .= SubStr(*(&Buffer+A_Index-1), 3) " "
			SetFormat, IntegerFast, Dec
			
			return this.Log(Out "- " Length+0)
		}
	}