# Guide

## Installing Fromage

### Luvit

Using a command prompt or terminal, create a new directory where you would like to install Luvit executables.

Follow the installation instructions at https://luvit.io/install.html according to your operational system.

The files `lit`, `luvit`, and `luvit` are needed. Make sure that you have them in your new directory once its installed, otherwise the API will not work.

### Fromage

With the three executables installed, run `lit install Lautenschlager-id/fromage` to get a `deps` folder with the Fromage API.

# Documentation

## Topics

- [API](API.md) → Auxiliar functions to make the use of the API easier
- [Settings](Settings.md) → Account's settings and configurations
- [Profile](Profile.md) → Player profiles
- [Private](Private.md) → Account's inbox
- [Forum](Forum.md) → General
- [Moderation](Moderation.md) → Report and element management
- [Tribe](Tribe.md) → Player tribes
- [Micepix](Micepix.md) → Image host and galleries
- [Miscellaneous](Miscellaneous.md)

## Tree

- [API](API.md)
	- [parseUrlData](API.md#parseurldata---href--)
	- [getLocation](API.md#getlocation---forum--community--section--)
	- [formatNickname](API.md#formatnickname---nickname--)
	- [isConnected](API.md#isconnected-----)
	- [getTribeForum](API.md#gettribeforum---location--)
- [Settings](Settings.md)
	- [connect](Settings.md#connect---username--userpassword--)
	- [disconnect](Settings.md#disconnect-----)
	- [requestValidationCode](Settings.md#requestvalidationcode-----)
	- [submitValidationCode](Settings.md#submitvalidationcode---code--)
	- [setEmail](Settings.md#setemail---email--registration--)
	- [setPassword](Settings.md#setpassword---password--disconnect--)
- [Profile](Profile.md)
	- [getProfile](Profile.md#getprofile---username--)
	- [changeAvatar](Profile.md#changeavatar---image--)
	- [updateProfile](Profile.md#updateprofile---data--)
	- [removeAvatar](Profile.md#removeavatar-----)
	- [updateParameters](Profile.md#updateparameters---parameters--)
- [Private](Private.md)
	- [getConversation](Private.md#getconversation---location--ignorefirstmessage--)
	- [createPrivateMessage](Private.md#createprivatemessage---destinatary--subject--message--)
	- [createPrivateDiscussion](Private.md#createprivatediscussion---destinataries--subject--message--)
	- [createPrivatePoll](Private.md#createprivatepoll---destinataries--subject--message--pollresponses--settings--)
	- [answerConversation](Private.md#answerconversation---conversationid--answer--)
	- [movePrivateConversation](Private.md#moveprivateconversation---inboxlocale--conversationid--)
	- [changeConversationState](Private.md#changeconversationstate---displaystate--conversationid--)
	- [leaveConversation](Private.md#leaveconversation---conversationid--)
	- [conversationInvite](Private.md#conversationinvite---conversationid--username--)
	- [kickConversationMember](Private.md#kickconversationmember---conversationid--userid--)
- [Forum](Forum.md)
	- [getMessage](Forum.md#getmessage---postid--location--)
	- [getTopic](Forum.md#gettopic---location--ignorefirstmessage--)
	- [getPoll](Forum.md#getpoll---location--)
	- [getSection](Forum.md#getsection---location--)
	- [getTopicMessages](Forum.md#gettopicmessages---location--getallinfo--pagenumber--)
	- [getSectionTopics](Forum.md#getsectiontopics---location--getallinfo--pagenumber--)
	- [createTopic](Forum.md#createtopic---title--message--location--)
	- [answerTopic](Forum.md#answertopic---message--location--)
	- [editAnswer](Forum.md#editanswer---messageid--message--location--)
	- [createPoll](Forum.md#createpoll---title--message--pollresponses--location--settings--)
	- [answerPoll](Forum.md#answerpoll---option--location--pollid--)
	- [likeMessage](Forum.md#likemessage---messageid--location--)
- [Moderation](Moderation.md)
	- [getMessageHistory](Moderation.md#getmessagehistory---messageid--location--)
	- [updateTopic](Moderation.md#updatetopic---location--data--)
	- [reportElement](Moderation.md#reportelement---element--elementid--reason--location--)
	- [changeMessageState](Moderation.md#changemessagestate---messageid--messagestate--location--reason--)
	- [changeMessageContentState](Moderation.md#changemessagecontentstate---messageid--contentstate--location--)
- [Tribe](Tribe.md)
	- [getTribe](Tribe.md#gettribe---tribeid--)
	- [getTribeMembers](Tribe.md#gettribemembers---tribeid--pagenumber--)
	- [getTribeRanks](Tribe.md#gettriberanks---tribeid--location--)
	- [getTribeHistory](Tribe.md#gettribehistory---tribeid--pagenumber--)
	- [updateTribeGreetingMessage](Tribe.md#updatetribegreetingmessage---message--)
	- [updateTribeParameters](Tribe.md#updatetribeparameters---parameters--)
	- [updateTribeProfile](Tribe.md#updatetribeprofile---data--)
	- [changeTribeLogo](Tribe.md#changetribelogo---image--)
	- [removeTribeLogo](Tribe.md#removetribelogo-----)
	- [createSection](Tribe.md#createsection---data--location--)
	- [updateSection](Tribe.md#updatesection---data--location--)
	- [setTribeSectionPermissions](Tribe.md#settribesectionpermissions---permissions--location--)
- [Micepix](Micepix.md)
	- [getAccountImages](Micepix.md#getaccountimages---pagenumber--)
	- [getLatestImages](Micepix.md#getlatestimages---quantity--)
	- [uploadImage](Micepix.md#uploadimage---image--ispublic--)
	- [deleteMicepixImage](Micepix.md#deletemicepiximage---imageid--)
- [Miscellaneous](Miscellaneous.md)
	- [search](Miscellaneous.md#search---searchtype--search--pagenumber--data--)
	- [getCreatedTopics](Miscellaneous.md#getcreatedtopics---username--)
	- [getLastPosts](Miscellaneous.md#getlastposts---pagenumber--username--)
	- [getFavoriteTopics](Miscellaneous.md#getfavoritetopics-----)
	- [getFriendlist](Miscellaneous.md#getfriendlist-----)
	- [getBlacklist](Miscellaneous.md#getblacklist-----)
	- [getFavoriteTribes](Miscellaneous.md#getfavoritetribes-----)
	- [getDevTracker](Miscellaneous.md#getdevtracker-----)
	- [addFriend](Miscellaneous.md#addfriend---username--)
	- [blacklistUser](Miscellaneous.md#blacklistuser---username--)
	- [unblacklistUser](Miscellaneous.md#unblacklistuser---username--)
	- [favoriteElement](Miscellaneous.md#favoriteelement---element--elementid--location--)
	- [unfavoriteElement](Miscellaneous.md#unfavoriteelement---favoriteid--location--)
	- [getStaffList](Miscellaneous.md#getstafflist---role--)