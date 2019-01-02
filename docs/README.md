# Guide

## Installing Fromage

### Luvit

Using a command prompt or terminal, create a new directory where you would like to install Luvit executables.

Follow the installation instructions at https://luvit.io/install.html according to your operational system.<br>
###### If you get installation issues, get the executables using this: [Get-Lit](https://github.com/SinisterRectus/get-lit).

The files `lit`, `luvit`, and `luvit` are needed. Make sure that you have them in your new directory once its installed, otherwise the API will not work.

### Fromage

With the three executables installed, run `lit install Lautenschlager-id/fromage` to get a `deps` folder with the Fromage API.

# Documentation

## Topics

- [API](API.md) → Auxiliar functions to make the use of the API easier
- [ENUMERATIONS](ENUMERATIONS.md) → Useful enumerations to use in the API
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
	- [enumerations](API.md#enumerations---)
	- [extractNicknameData](API.md#extractnicknamedata--nickname-)
	- [formatNickname](API.md#formatnickname--nickname-)
	- [getLocation](API.md#getlocation--forum-community-section-)
	- [getPage](API.md#getpage--url-)
	- [getUser](API.md#getuser---)
	- [isAccountValidated](API.md#isaccountvalidated---)
	- [isConnected](API.md#isconnected---)
	- [parseUrlData](API.md#parseurldata--href-)
	- [performAction](API.md#performaction--uri-postdata-ajaxuri-file-)
- [ENUMERATIONS](ENUMERATIONS.md)
	- [community](ENUMERATIONS.md#community-int)
	- [contentState](ENUMERATIONS.md#contentstate-string)
	- [displayState](ENUMERATIONS.md#displaystate-int)
	- [element](ENUMERATIONS.md#element-int)
	- [forumTitle](ENUMERATIONS.md#forumtitle-string)
	- [gender](ENUMERATIONS.md#gender-int)
	- [inboxLocale](ENUMERATIONS.md#inboxlocale-int)
	- [listRole](ENUMERATIONS.md#listrole-int)
	- [location](ENUMERATIONS.md#location-table)
	- [messageState](ENUMERATIONS.md#messagestate-int)
	- [misc](ENUMERATIONS.md#misc-int)
	- [recruitmentState](ENUMERATIONS.md#recruitmentstate-int)
	- [role](ENUMERATIONS.md#role-int)
	- [searchLocation](ENUMERATIONS.md#searchlocation-int)
	- [searchType](ENUMERATIONS.md#searchtype-int)
	- [section](ENUMERATIONS.md#section-string)
	- [sectionIcon](ENUMERATIONS.md#sectionicon-string)
	- [topicIcon](ENUMERATIONS.md#topicicon-string)
- [Forum](Forum.md)
	- [answerPoll](Forum.md#answerpoll--option-location-pollid-)
	- [answerTopic](Forum.md#answertopic--message-location-)
	- [createPoll](Forum.md#createpoll--title-message-pollresponses-location-settings-)
	- [createTopic](Forum.md#createtopic--title-message-location-)
	- [editAnswer](Forum.md#editanswer--messageid-message-location-)
	- [getMessage](Forum.md#getmessage--postid-location-)
	- [getPoll](Forum.md#getpoll--location-)
	- [getSection](Forum.md#getsection--location-)
	- [getSectionTopics](Forum.md#getsectiontopics--location-getallinfo-pagenumber-)
	- [getTopic](Forum.md#gettopic--location-ignorefirstmessage-)
	- [getTopicMessages](Forum.md#gettopicmessages--location-getallinfo-pagenumber-)
	- [likeMessage](Forum.md#likemessage--messageid-location-)
- [Micepix](Micepix.md)
	- [deleteMicepixImage](Micepix.md#deletemicepiximage--imageid-)
	- [getAccountImages](Micepix.md#getaccountimages--pagenumber-)
	- [getLatestImages](Micepix.md#getlatestimages--quantity-)
	- [uploadImage](Micepix.md#uploadimage--image-ispublic-)
- [Miscellaneous](Miscellaneous.md)
	- [addFriend](Miscellaneous.md#addfriend--username-)
	- [blacklistUser](Miscellaneous.md#blacklistuser--username-)
	- [favoriteElement](Miscellaneous.md#favoriteelement--element-elementid-location-)
	- [getBlacklist](Miscellaneous.md#getblacklist---)
	- [getCreatedTopics](Miscellaneous.md#getcreatedtopics--username-)
	- [getDevTracker](Miscellaneous.md#getdevtracker---)
	- [getFavoriteTopics](Miscellaneous.md#getfavoritetopics---)
	- [getFavoriteTribes](Miscellaneous.md#getfavoritetribes---)
	- [getFriendlist](Miscellaneous.md#getfriendlist---)
	- [getLastPosts](Miscellaneous.md#getlastposts--pagenumber-username-)
	- [getStaffList](Miscellaneous.md#getstafflist--role-)
	- [search](Miscellaneous.md#search--searchtype-search-pagenumber-data-)
	- [unblacklistUser](Miscellaneous.md#unblacklistuser--username-)
	- [unfavoriteElement](Miscellaneous.md#unfavoriteelement--favoriteid-location-)
- [Moderation](Moderation.md)
	- [changeMessageContentState](Moderation.md#changemessagecontentstate--messageid-contentstate-location-)
	- [changeMessageState](Moderation.md#changemessagestate--messageid-messagestate-location-reason-)
	- [getMessageHistory](Moderation.md#getmessagehistory--messageid-location-)
	- [reportElement](Moderation.md#reportelement--element-elementid-reason-location-)
	- [updateTopic](Moderation.md#updatetopic--location-data-)
- [Private](Private.md)
	- [answerConversation](Private.md#answerconversation--conversationid-answer-)
	- [changeConversationState](Private.md#changeconversationstate--displaystate-conversationid-)
	- [conversationInvite](Private.md#conversationinvite--conversationid-username-)
	- [createPrivateDiscussion](Private.md#createprivatediscussion--destinataries-subject-message-)
	- [createPrivateMessage](Private.md#createprivatemessage--destinatary-subject-message-)
	- [createPrivatePoll](Private.md#createprivatepoll--destinataries-subject-message-pollresponses-settings-)
	- [getConversation](Private.md#getconversation--location-ignorefirstmessage-)
	- [kickConversationMember](Private.md#kickconversationmember--conversationid-userid-)
	- [leaveConversation](Private.md#leaveconversation--conversationid-)
	- [moveConversation](Private.md#moveconversation--inboxlocale-conversationid-)
- [Profile](Profile.md)
	- [changeAvatar](Profile.md#changeavatar--image-)
	- [getProfile](Profile.md#getprofile--username-)
	- [removeAvatar](Profile.md#removeavatar---)
	- [updateParameters](Profile.md#updateparameters--parameters-)
	- [updateProfile](Profile.md#updateprofile--data-)
- [Settings](Settings.md)
	- [connect](Settings.md#connect--username-userpassword-)
	- [disconnect](Settings.md#disconnect---)
	- [requestValidationCode](Settings.md#requestvalidationcode---)
	- [setEmail](Settings.md#setemail--email-registration-)
	- [setPassword](Settings.md#setpassword--password-disconnect-)
	- [submitValidationCode](Settings.md#submitvalidationcode--code-)
- [Tribe](Tribe.md)
	- [changeTribeLogo](Tribe.md#changetribelogo--image-)
	- [createSection](Tribe.md#createsection--data-location-)
	- [getTribe](Tribe.md#gettribe--tribeid-)
	- [getTribeForum](Tribe.md#gettribeforum--location-)
	- [getTribeHistory](Tribe.md#gettribehistory--tribeid-pagenumber-)
	- [getTribeMembers](Tribe.md#gettribemembers--tribeid-pagenumber-)
	- [getTribeRanks](Tribe.md#gettriberanks--tribeid-location-)
	- [removeTribeLogo](Tribe.md#removetribelogo---)
	- [setTribeSectionPermissions](Tribe.md#settribesectionpermissions--permissions-location-)
	- [updateSection](Tribe.md#updatesection--data-location-)
	- [updateTribeGreetingMessage](Tribe.md#updatetribegreetingmessage--message-)
	- [updateTribeParameters](Tribe.md#updatetribeparameters--parameters-)
	- [updateTribeProfile](Tribe.md#updatetribeprofile--data-)