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
>| `string` | if #1, `post's url`, else `Result string` |
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

>### self:createPrivateDiscussion ( destinataryUsers, messageSubject, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| destinataryUsers | `table` | ✔ | The users who are going to be invited to the private discussion |
>| messageSubject | `string` | ✔ | The subject of the private discussion |
>| message | `string` | ✔ | The content of the private discussion |
>
>Creates a new private discussion.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the private discussion was created or not |
>| `string` | if #1, `private discussion's url`, else `Result string` |
>

>### self:createPrivateMessage ( destinataryUser, messageSubject, message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| destinataryUser | `string` | ✔ | The user who is going to receive the private message |
>| messageSubject | `string` | ✔ | The subject of the private message |
>| message | `string` | ✔ | The content of the private message |
>
>Creates a new private message.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the private message was created or not |
>| `string` | if #1, `private message's url`, else `Result string` |
>

>### self:createPrivatePoll ( destinataryUsers, pollSubject, message, pollResponses, settings )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| destinataryUsers | `table` | ✔ | The users who are going to be invited to the private poll |
>| pollSubject | `string` | ✔ | The subject of the private poll |
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
>| `string` | if #1, `private poll's url`, else `Result string` |
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
