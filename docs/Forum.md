Base functions of the public forums, from messages to topics.
# Methods
>### getMessage ( postId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| postId | `int`, `string` | ✔ | The post id. (note: not the message id, but the #mID) |
>| location | `table` | ✔ | The post topic or conversation location. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. (needed for forum message) |
>| 	t | `int` | ✔ | The topic id. (needed for forum message) |
>| 	co | `int` | ✔ | The private conversation id. (needed for private conversation message) |
>
>Gets the data of a message.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The message data. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	author = "", -- The user name of the message author.
>	canLike = true, -- Whether the message can be liked or not. (forum message only)
>	co = 0, -- The conversation id. (private message only)
>	content = "", -- The message content.
>	contentHtml = "", -- The HTML of the message content.
>	editionTimestamp = 0, -- The timestamp of the last edition. (forum message only)
>	f = 0, -- The forum id.
>	id = 0, -- The message id.
>	isEdited = false, -- Whether the message was edited or not. (forum message only)
>	isModerated = false, -- Whether the message is moderated or not. (forum message only)
>	moderatedBy = "", -- The name of the sentinel that moderated the message. (forum message only)
>	p = 0, -- The page where the message is located.
>	post = "", -- The post id.
>	prestige = 0, -- The quantity of prestiges that the message has. (forum message only)
>	reason = "", -- The moderation reason. (forum message only)
>	t = 0, -- The topic id. (forum message only)
>	timestamp = 0 -- The timestamp of when the message was created.
>}
>```
---
>### getTopic ( location, ignoreFirstMessage )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The topic location. |
>| ignoreFirstMessage | `boolean` | ✕ | Whether the data of the first message should be ignored or not. If the topic is a poll, it will ignore the poll data if `true`. <sub>(default = false)</sub> |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	t | `int` | ✔ | The topic id. |
>
>Gets the data of a topic.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The topic data. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	community = enumerations.community, -- The community where the topic is located.
>	elementId = 0, -- The element id of the topic.
>	f = 0, -- The forum id.
>	favoriteId = 0, -- The favorite id of the topic, if 'isFavorited'.
>	firstMessage = getMessage, -- The message object of the first message of the topic. (It's ignored when 'isPoll')
>	isDeleted = false, -- Whether the topic is deleted or not.
>	isFavorited = false, -- Whether the topic is favorited or not.
>	isFixed = false, -- Whether the topic is fixed in the section or not.
>	isLocked = false, -- Whether the topic is locked or not.
>	isPoll = false, -- If the conversation is a poll.
>	navbar = {
>		[n] = {
>			location = parseUrlData, -- The parsed-url location object.
>			name = "" -- The name of the location.
>		}
>	}, -- A list of locations of the navigation bar.
>	pages = 0, -- The quantity of pages in the topic.
>	poll = getPoll, -- The poll object if 'isPoll'.
>	t = 0, -- The topic id.
>	title = "", -- The name of the topic.
>	totalMessages = 0 -- The total of messages in the topic.
>}
>```
---
>### getPoll ( location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The poll location. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. (needed for forum topic) |
>| 	t | `int` | ✔ | The topic id. (needed for forum topic) |
>| 	co | `int` | ✔ | The private conversation id. (needed for private conversation) |
>
>Gets the data of a poll.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The poll data. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	allowsMultiple = false, -- Whether the poll allows multiple selections or not.
>	author = "", -- The user name of the poll author.
>	co = 0, -- The conversation id. (private poll only)
>	contentHtml = "", -- The HTML of the poll content.
>	f = 0, -- The forum id.
>	id = 0, -- The poll id.
>	isPublic = 0, -- Whether the users are allowed to see the results of the poll.
>	options = {
>		[n] = {
>			id = 0, -- The id of the option.
>			value = "", -- The option string field.
>			votes = 0, -- The total of votes for the option. (-1 if it can't be calculated)
>		}
>	}, -- The poll options.
>	t = 0, -- The topic id. (forum poll only)
>	timestamp = 0, -- The timestamp of when the poll was created.
>	totalVotes = 0 -- The total of votes in the poll. (-1 if it can't be calculated)
>}
>```
---
>### getSection ( location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The section location. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✔ | The section id. |
>
>Gets the data of a section.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The section data. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	community = enumerations.community, -- The community where the section is located.
>	f = 0, -- The forum id.
>	hasSubsections = false, -- Whether the section has subsections or not.
>	icon = enumerations.sectionIcon, -- The icon of the section.
>	isSubsection = false, -- Whether the section is a subsection or not.
>	name = "", -- The name of the section.
>	navbar = {
>		[n] = {
>			location = parseUrlData, -- The parsed-url location object.
>			name = "" -- The name of the location.
>		}
>	}, -- A list of locations of the navigation bar.
>	pages = 0, -- The quantity of pages in the section.
>	parent = {
>		location = parseUrlData, -- The parsed-url location object.
>		name = "" -- The name of the parent section.
>	}, -- The parent section of the subsection
>	s = 0, -- The section id.
>	subsections = {
>		[n] = {
>			location = parseUrlData, -- The parsed-url location object.
>			name = "" -- The name of the subsection.
>		}
>	}, -- A list of subsections of the section.
>	totalFixedTopics = 0, -- Total of topics that are fixed in the section.
>	totalSubsections = 0, -- Total of subsections in the section.
>	totalTopics = 0 -- Total of topics in the section.
>}
>```
---
>### getAllMessages ( location, getAllInfo, pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The topic or conversation location. |
>| getAllInfo | `boolean` | ✕ | Whether the message data should be simple (see return structure) or complete ([getMessage](Forum.md#getmessage--postid-location-)). <sub>(default = true)</sub> |
>| pageNumber | `int` | ✕ | The topic page. To list ALL messages, use `0`. <sub>(default = 1)</sub> |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. (needed for topic) |
>| 	t | `int` | ✔ | The topic id. (needed for topic) |
>| 	co | `int` | ✔ | The private conversation id. (needed for private conversation) |
>
>Gets the messages of a topic or conversation.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) This function may take several minutes to return the values depending on the total of pages of the topic.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of message datas. |
>| `nil`, `string` | Error Message. |
>
>**Table structure**:
>```Lua
>{
>	-- Structure if not 'getAllInfo'
>	[n] = {
>		co = 0, -- The private conversation id.
>		f = 0, -- The forum id.
>		id = 0, -- The message id.
>		p = 0, -- The page where the message is located.
>		post = "", -- The post id.
>		t = 0, -- The topic id.
>		timestamp = 0 -- The timestamp of when the message was created.
>	},
>	_pages = 0 -- The total pages of the topic or conversation.
>}
>```
---
>### getSectionTopics ( location, getAllInfo, pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The section location. |
>| getAllInfo | `boolean` | ✕ | Whether the topic data should be simple (ids only) or complete ([getTopic](Forum.md#gettopic--location-ignorefirstmessage-)). <sub>(default = true)</sub> |
>| pageNumber | `int` | ✕ | The section page. To list ALL topics, use `0`. <sub>(default = 1)</sub> |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✔ | The section id. |
>
>Gets the topics of a section.<br>
>![/!\\](https://i.imgur.com/HQ188PK.png) This function may take several minutes to return the values depending on the total of pages of the section.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of topic datas. |
>| `nil`, `string` | Error Message. |
>
>**Table structure**:
>```Lua
>{
>	-- Structure if not 'getAllInfo'
>	[n] = {
>		author = "", -- The name of the topic author, without discriminator.
>		f = 0, -- The forum id.
>		s = 0, -- The section id.
>		t = 0, -- The topic id.
>		timestamp = 0, -- The timestamp of when the topic was created.
>		title = "" -- The name of the topic.
>	},
>	_pages = 0 -- The total pages of the section.
>}
>```
---
>### createTopic ( title, message, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| title | `string` | ✔ | The title of the topic |
>| message | `string` | ✔ | The initial message content of the topic. |
>| location | `table` | ✔ | The location where the topic should be created. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✔ | The section id. |
>
>Creates a topic.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | A parsed-url location object. |
>| `nil`, `string` | Error message. |
>
---
>### answerTopic ( message, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The answer message content. |
>| location | `table` | ✔ | The topic location. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	t | `int` | ✔ | The topic id. |
>
>Answers a topic.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | A parsed-url location object. |
>| `nil`, `string` | Error message. |
>
---
>### editAnswer ( messageId, message, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `string` | ✔ | The message id. Use `string` if it's the post number. |
>| message | `string` | ✔ | The new message content. |
>| location | `table` | ✔ | The message location. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	t | `int` | ✔ | The topic id. |
>
>Edits the content of a message.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### createPoll ( title, message, pollResponses, location, settings )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| title | `string` | ✔ | The title of the poll. |
>| message | `string` | ✔ | The message content of the poll. |
>| pollResponses | `table` | ✔ | The poll response options. |
>| location | `table` | ✔ | The location where the topic should be created. |
>| settings | `table` | ✕ | The poll settings. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✔ | The section id. |
>
>**@`settings` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	multiple | `boolean` | ✕ | If users are allowed to select more than one option. |
>| 	public | `boolean` | ✕ | If users can see the results of the poll. |
>
>Creates a new poll.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | A parsed-url location object. |
>| `nil`, `string` | Error message. |
>
---
>### answerPoll ( option, location, pollId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| option | `int`, `table`, `string` | ✔ | The poll option to be selected. You can insert its id (highly recommended) or its text value. For multiple options, use a table with `ints` or `strings`. |
>| location | `table` | ✔ | The location where the poll answer should be recorded. |
>| pollId | `int` | ✕ | The poll id. It's obtained automatically if no value is given. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. (needed for forum poll) |
>| 	t | `int` | ✔ | The topic id. (needed for forum poll) |
>| 	co | `int` | ✔ | The private conversation id. (needed for private poll) |
>
>Answers a poll.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### likeMessage ( messageId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `string` | ✔ | The message id. Use `string` if it's the post number. |
>| location | `table` | ✔ | The topic location. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	t | `int` | ✔ | The topic id. |
>
>Likes a message.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>