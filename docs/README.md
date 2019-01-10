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

- [Api](Api.md) → Useful functions to make the use of the API easier and to handle some return values.
- [Enumerations](Enumerations.md) → Useful enumerations to use in the API.
- [Extensions](Extensions.md) → Extension functions to make the use of the API easier.
- [Forum](Forum.md) → Base functions of the public forums, from messages to topics.
- [Inbox](Inbox.md) → Account's inbox data and management.
- [Micepix](Micepix.md) → Image host and galleries.
- [Miscellaneous](Miscellaneous.md) → Random functions. 
- [Moderation](Moderation.md) → Report and elements management.
- [Profile](Profile.md) → Player profile data and management.
- [Settings](Settings.md) → Account's settings and configurations.
- [Tribe](Tribe.md) → Tribe data and management.

## Tree

- [Api](Api.md)
	- [enumerations](Api.md#enumerations---)
	- [extensions](Api.md#extensions---)
	- [extractNicknameData](Api.md#extractnicknamedata--nickname-)
	- [formatNickname](Api.md#formatnickname--nickname-)
	- [getConnectionTime](Api.md#getconnectiontime---)
	- [getLocation](Api.md#getlocation--forum-community-section-)
	- [getPage](Api.md#getpage--url-)
	- [getUser](Api.md#getuser---)
	- [isAccountValidated](Api.md#isaccountvalidated---)
	- [isConnected](Api.md#isconnected---)
	- [parseUrlData](Api.md#parseurldata--href-)
	- [performAction](Api.md#performaction--uri-postdata-ajaxuri-file-)
- [Enumerations](Enumerations.md)
	- [community](Enumerations.md#community-int)
	- [contentState](Enumerations.md#contentstate-string)
	- [displayState](Enumerations.md#displaystate-int)
	- [element](Enumerations.md#element-int)
	- [forum](Enumerations.md#forum-int)
	- [forumTitle](Enumerations.md#forumtitle-string)
	- [gender](Enumerations.md#gender-int)
	- [inboxLocale](Enumerations.md#inboxlocale-int)
	- [listRole](Enumerations.md#listrole-int)
	- [location](Enumerations.md#location-table)
	- [memberState](Enumerations.md#memberstate-string)
	- [messageState](Enumerations.md#messagestate-int)
	- [misc](Enumerations.md#misc-int)
	- [recruitmentState](Enumerations.md#recruitmentstate-int)
	- [role](Enumerations.md#role-int)
	- [searchLocation](Enumerations.md#searchlocation-int)
	- [searchType](Enumerations.md#searchtype-int)
	- [section](Enumerations.md#section-string)
	- [sectionIcon](Enumerations.md#sectionicon-string)
	- [topicIcon](Enumerations.md#topicicon-string)
- [Extensions](Extensions.md)
	- [bbcodeToMarkdown](Extensions.md#bbcodetomarkdown--bbcode-)
	- [htmlEntitiesToAnsii](Extensions.md#htmlentitiestoansii--str-)
	- [os.readFile](Extensions.md#osreadfile--file-)
	- [table.add](Extensions.md#tableadd--src-list-)
	- [table.createSet](Extensions.md#tablecreateset--tbl-index-)
	- [table.search](Extensions.md#tablesearch--tbl-value-index-)
- [Forum](Forum.md)
	- [answerPoll](Forum.md#answerpoll--option-location-pollid-)
	- [answerTopic](Forum.md#answertopic--message-location-)
	- [createPoll](Forum.md#createpoll--title-message-pollresponses-location-settings-)
	- [createTopic](Forum.md#createtopic--title-message-location-)
	- [editAnswer](Forum.md#editanswer--messageid-message-location-)
	- [getAllMessages](Forum.md#getallmessages--location-getallinfo-pagenumber-)
	- [getMessage](Forum.md#getmessage--postid-location-)
	- [getPoll](Forum.md#getpoll--location-)
	- [getSection](Forum.md#getsection--location-)
	- [getSectionTopics](Forum.md#getsectiontopics--location-getallinfo-pagenumber-)
	- [getTopic](Forum.md#gettopic--location-ignorefirstmessage-)
	- [likeMessage](Forum.md#likemessage--messageid-location-)
- [Inbox](Inbox.md)
	- [answerConversation](Inbox.md#answerconversation--conversationid-answer-)
	- [changeConversationState](Inbox.md#changeconversationstate--displaystate-conversationid-)
	- [conversationInvite](Inbox.md#conversationinvite--conversationid-username-)
	- [createPrivateDiscussion](Inbox.md#createprivatediscussion--destinataries-subject-message-)
	- [createPrivateMessage](Inbox.md#createprivatemessage--destinatary-subject-message-)
	- [createPrivatePoll](Inbox.md#createprivatepoll--destinataries-subject-message-pollresponses-settings-)
	- [getConversation](Inbox.md#getconversation--location-ignorefirstmessage-)
	- [kickConversationMember](Inbox.md#kickconversationmember--conversationid-userid-)
	- [leaveConversation](Inbox.md#leaveconversation--conversationid-)
	- [moveConversation](Inbox.md#moveconversation--inboxlocale-conversationid-)
- [Micepix](Micepix.md)
	- [deleteImage](Micepix.md#deleteimage--imageid-)
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
	- [getLastPosts](Miscellaneous.md#getlastposts--pagenumber-username-extractnavbar-)
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