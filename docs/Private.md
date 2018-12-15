## Methods
>### getConversation ( location, ignoreFirstMessage )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The conversation location. Field 'co' is needed. |
>| ignoreFirstMessage | `boolean` | ✕ | Whether the data of the first message should be ignored or not. (default = false) |
>
>Gets the data of a conversation.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The conversation data, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

 
>### createPrivateMessage ( destinatary, subject, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| destinatary | `string` | ✔ | The user who is going to receive the private message |
>| subject | `string` | ✔ | The subject of the private message |
>| message | `string` | ✔ | The content of the private message |
>
>Creates a new private message.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the private message was created or not |
>| `string` | if #1, `private message's location`, else `Result string` or `Error message` |
>

 
>### createPrivateDiscussion ( destinataries, subject, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| destinataries | `table` | ✔ | The users who are going to be invited to the private discussion |
>| subject | `string` | ✔ | The subject of the private discussion |
>| message | `string` | ✔ | The content of the private discussion |
>
>Creates a new private discussion.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the private discussion was created or not |
>| `string` | if #1, `private discussion's location`, else `Result string` or `Error message` |
>

 
>### createPrivatePoll ( destinataries, subject, message, pollResponses, settings )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| destinataries | `table` | ✔ | The users who are going to be invited to the private poll |
>| subject | `string` | ✔ | The subject of the private poll |
>| message | `string` | ✔ | The content of the private poll |
>| pollResponses | `table` | ✔ | The poll response options |
>| settings | `table` | ✕ | The poll settings. The available indexes are: `multiple` and `public`. |
>
>Creates a new private poll.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the private poll was created or not |
>| `string` | if #1, `private poll's location`, else `Result string` or `Error message` |
>

 
>### answerConversation ( conversationId, answer )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationId | `int`, `string` | ✔ | The conversation id |
>| answer | `string` | ✔ | The answer |
>
>Answers a conversation.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the answer was posted or not |
>| `string` | if #1, `post's location`, else `Result string` or `Error message` |
>

 
>### movePrivateConversation ( inboxLocale, conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| inboxLocale | `string`, `int` | ✔ | Where the conversation will be located. An enum from `enumerations.inboxLocale` (index or value) |
>| conversationId | `int`, `table` | ✕ | The id or IDs of the conversation(s) to be moved. `nil` for all. |
>
>Moves private conversations to the inbox or bin.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the conversation was moved or not |
>| `string` | if #1, `location's url`, else `Result string` or `Error message` |
>

 
>### changeConversationState ( displayState, conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| displayState | `string`, `int` | ✔ | The conversation display state. An enum from `enumerations.displayState` (index or value) |
>| conversationId | `int`, `string` | ✔ | The conversation id |
>
>Changes the conversation state (open, closed).
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the conversation display state was changed or not |
>| `string` | if #1, `conversation's url`, else `Result string` or `Error message` |
>

 
>### leaveConversation ( conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationId | `int`, `string` | ✔ | The conversation id |
>
>Leaves a private conversation.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the account left the conversation or not |
>| `string` | if #1, `conversation's url`, else `Result string` or `Error message` |
>

 
>### conversationInvite ( conversationId, userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationId | `int`, `string` | ✔ | The conversation id |
>| userName | `string` | ✔ | The username to be invited |
>
>Invites an user to a private conversation.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the username was added in the conversation or not |
>| `string` | if #1, `conversation's url`, else `Result string` or `Error message` |
>

 
>### kickConversationMember ( conversationId, userId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationId | `int`, `string` | ✔ | The conversation id |
>| userId | `int`, `string` | ✔ | The user id or nickname |
>
>Excludes a user from a conversation.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the user was excluded from the conversation or not |
>| `string` | if #1, `conversation's url`, else `Result string` or `Error message` |
>
