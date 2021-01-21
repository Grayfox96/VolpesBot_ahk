; To add more rewards append more else if statements at the end of this file, and create another CustomRewardId variable
; The custom reward id is in every message sent via a channel points redeem, look at the bot log to figure it out
CustomRewardId1 := "custom-reward-id_goes_here"
CustomRewardId2 := "and_here"
CustomRewardId3 := "and_here"
CustomRewardId4 := "and_here"
If (TagsArray["custom-reward-id"] = CustomRewardId1) { ; hardcoded value
	this.SendPRIVMSG(Channel, MoodEmotes[Channel, "happy"] " yay " DisplayName " redeemed " CustomRewardId1 " with message: " Msg) ; hardcoded value
	}
Else if (TagsArray["custom-reward-id"] = CustomRewardId2) { ; hardcoded value
	}
Else if (TagsArray["custom-reward-id"] = CustomRewardId3) { ; hardcoded value
	}
Else if (TagsArray["custom-reward-id"] = CustomRewardId4) { ; hardcoded value
	}
