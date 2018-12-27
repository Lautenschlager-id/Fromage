# Methods
>### getConversation ( location, ignoreFirstMessage )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The conversation location. |
>| ignoreFirstMessage | `boolean` | ✕ | Whether the data of the first message should be ignored or not. If the conversation is a poll, it will ignore the poll data if `true`. <sub>(default = false)</sub> |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	co | `int` | ✔ | The conversation id. |
>
>Gets the data of a conversation (private message).
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The conversation data. |
>| `nil`, `string` | Message error. |
>
>**Table structure**:
>```Lua
>{
>	co = 0, -- The conversation id.
>	firstMessage = getMessage, -- The message object of the first message of the conversation. (It's ignored when 'isPoll') 
>	invitedUsers = {
>		[n] = {
>			name = "", -- Name of the user.
>			situation = "" -- Situation string field. (e.g: invited, gone, author)
>		}
>	}, -- The list of players that are in the conversation.
>	isDiscussion = false, -- If the conversation is a discussion.
>	isLocked = false, -- Whether the conversation is locked or not.
>	isPoll = false, -- If the conversation is a poll.
>	isPrivateMessage = false, -- If the conversation is a private message.
>	pages = 0, -- The total of pages in the conversation.
>	poll = getPoll, -- The poll object if 'isPoll'.
>	title = "", -- The conversation title.
>	totalMessages = 0 -- The total of messages in the conversation.
>}
>```
---
>### createPrivateMessage ( destinatary, subject, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| destinatary | `string` | ✔ | The user who is going to receive the private message. |
>| subject | `string` | ✔ | The subject of the private message. |
>| message | `string` | ✔ | The message content of the private message. |
>
>Creates a new private message.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | A parsed-url location object. |
>| `nil`, `string` | Error message. |
>
---
>### createPrivateDiscussion ( destinataries, subject, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| destinataries | `table` | ✔ | The users who are going to be invited to the private discussion. |
>| subject | `string` | ✔ | The subject of the private discussion. |
>| message | `string` | ✔ | The message content of the private discussion. |
>
>Creates a new private discussion.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | A parsed-url location object. |
>| `nil`, `string` | Error message. |
>
---
>### createPrivatePoll ( destinataries, subject, message, pollResponses, settings )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| destinataries | `table` | ✔ | The users who are going to be invited to the private poll. |
>| subject | `string` | ✔ | The subject of the private poll. |
>| message | `string` | ✔ | The message content of the private poll. |
>| pollResponses | `table` | ✔ | The poll response options. |
>| settings | `table` | ✕ | The poll settings. |
>
>**@`settings` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	multiple | `boolean` | ✕ | If users are allowed to select more than one option. |
>| 	public | `boolean` | ✕ | If users can see the results of the poll. |
>
>Creates a new private poll.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | A parsed-url location object. |
>| `nil`, `string` | Error message. |
>
---
>### answerConversation ( conversationId, answer )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationId | `int`, `string` | ✔ | The conversation id. |
>| answer | `string` | ✔ | The answer message content. |
>
>Answers a conversation.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | A parsed-url location object. |
>| `nil`, `string` | Error message. |
>
---
>### moveConversation ( inboxLocale, conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| inboxLocale | `string`, `int` | ✔ | Where the conversation will be located. An enum from `enumerations.inboxLocale`. (index or value) |
>| conversationId | `int`, `table` | ✕ | The ID(s) of the conversation(s) to be moved. Use `nil` for all. |
>
>Moves private conversations to the inbox or bin.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### changeConversationState ( displayState, conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| displayState | `string`, `int` | ✔ | The conversation display state. An enum from `enumerations.displayState`. (index or value) |
>| conversationId | `int`, `string` | ✔ | The conversation id. |
>
>Changes the conversation state (open, closed).
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### leaveConversation ( conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationId | `int`, `string` | ✔ | The conversation id. |
>
>Leaves a private conversation.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### conversationInvite ( conversationId, userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationId | `int`, `string` | ✔ | The conversation id. |
>| userName | `string` | ✔ | The name of the user to be invited. |
>
>Invites an user to a private conversation.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### kickConversationMember ( conversationId, userId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationId | `int`, `string` | ✔ | The conversation id. |
>| userId | `int`, `string` | ✔ | User name or user id. |
>
>Removes a user from a conversation.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>