## Static Methods
>### fragmentUrl ( url )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| url | `string` | ✔ | The Atelier801's forum URL |
>
>Fragments a forum URL.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table` | Fragmented URL. The available indexes are: `uri`, `raw_data` and `data`. |
>| `string`, `nil` | Error message |
>

>### getPollOptions ( url )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| url | `string` | ✔ | The Atelier801's forum URL |
>
>Gets all the options of a poll.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table` | Poll options. The indexes are `id` and `value`. |
>| `string`, `nil` | Error message |
>

## Methods
>### self:answerConversation ( conversationId, answer )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationId | `string`, `int` | ✔ | The conversation id |
>| answer | `string` | ✔ | The answer |
>
>Answers a conversation.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the answer was posted or not |
>| `string` | if #1, `post's url`, else `Result string` or `Error message` |
>

>### self:answerPoll ( option, location, pollId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| option | `int`, `table`, `string` | ✔ | The poll option to be selected. You can insert its ID or its text (highly recommended). For multiple options polls, use a table with `numbers` or `strings`. |
>| location | `table` | ✔ | The location where the poll answer should be recorded. Fields 'f' and 't' are needed for forum poll, 'co' for private poll. |
>| pollId | `int` | ✕ | The poll id. It's obtained automatically if no value is given. |
>
>Answers a poll.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the poll option was recorded or not |
>| `string` | if #1, `poll's url`, else `Result string` or `Error message` |
>

>### self:answerTopic ( message, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The answer |
>| location | `table` | ✔ | The location where the answer should be posted. Fields 'f' and 't' are needed. |
>
>Answers a topic.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the post was created or not |
>| `string` | if #1, `post's url`, else `Result string` or `Error message` |
>

>### self:connect ( userName, userPassword )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | Account's user name |
>| userPassword | `string` | ✔ | Account's password |
>
>Connects to an account on Atelier801's forums.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the account connected or not |
>| `string` | Result string |
>

>### self:createPoll ( title, message, pollResponses, location, settings )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| title | `string` | ✔ | The title of the poll |
>| message | `string` | ✔ | The content of the poll |
>| pollResponses | `table` | ✔ | The poll response options |
>| location | `table` | ✔ | The location where the topic should be created. Fields 'f' and 's' are needed. |
>| settings | `table` | ✕ | The poll settings. The available indexes are: `multiple` and `public`. |
>
>Creates a new poll.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the poll was created or not |
>| `string` | if #1, `poll's url`, else `Result string` or `Error message` |
>

>### self:createPrivateDiscussion ( destinataries, subject, message )
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
>| `string` | if #1, `private discussion's url`, else `Result string` or `Error message` |
>

>### self:createPrivateMessage ( destinatary, subject, message )
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
>| `string` | if #1, `private message's url`, else `Result string` or `Error message` |
>

>### self:createPrivatePoll ( destinataries, subject, message, pollResponses, settings )
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
>| `string` | if #1, `private poll's url`, else `Result string` or `Error message` |
>

>### self:createTopic ( title, message, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| title | `string` | ✔ | The title of the topic |
>| message | `string` | ✔ | The initial message of the topic |
>| location | `table` | ✔ | The location where the topic should be created. Fields 'f' and 's' are needed. |
>
>Creates a topic.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the topic was created or not |
>| `string` | if #1, `topic's url`, else `Result string` or `Error message` |
>

>### self:disconnect (  )
>Disconnects from an account on Atelier801's forums.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the account disconnected or not |
>| `string` | Result string |
>

>### self:requestValidationCode (  )
>Sends a validation code to the Account's e-mail.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the validation code was sent or not |
>| `string` | `Result string` or `Error message` |
>

>### self:sendValidationCode ( code )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| code | `string` | ✔ | The validation code. |
>
>Validates the validation code.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the validation code was sent to be validated or not |
>| `string` | `Result string` (Empty for success) or `Error message` |
>

>### self:setEmail ( email )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| email | `string` | ✔ | The e-mail |
>
>Sets the new Account's e-mail.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the validation code was sent or not |
>| `string` | `Result string` or `Error message` |
>

>### self:setPassword ( password, disconnect )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| password | `string` | ✔ | The new password |
>| disconnect | `boolean` | ✕ | Whether the account should be disconnect from all the dispositives or not. (default = false) |
>
>Sets the new Account's password.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new password was set or not |
>| `string` | `Result string` or `Error message` |
>
