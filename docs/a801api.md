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
>### self:addFriend ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | The user to be added |
>
>Adds a user as friend.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `Whether` | the user was added or not |
>| `string` | `Result string` or `Error message` |
>

>### self:answerConversation ( conversationId, answer )
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
>| location | `table` | ✔ | The location where the message. Fields 'f' and 't' are needed. |
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

>### self:blacklistUser ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | The user to be blacklisted |
>
>Adds a user in the blacklist.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `Whether` | the user was blacklisted or not |
>| `string` | `Result string` or `Error message` |
>

>### self:changeConversationState ( conversationState, conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationState | `string`, `int` | ✔ | An enum from `enums.conversationState` (index or value) |
>| conversationId | `int`, `string` | ✔ | The conversation id |
>
>Changes the conversation state (opened, closed).
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the conversation state was changed or not |
>| `string` | if #1, `conversation's url`, else `Result string` or `Error message` |
>

>### self:connect ( userName, userPassword )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | account's user name |
>| userPassword | `string` | ✔ | account's password |
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

>### self:conversationInvite ( conversationId, userName )
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

>### self:deleteMicepixImage ( imageId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| imageId | `string` | ✔ | The image id |
>
>Deletes an image from the account's micepix.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `Whether` | the image was deleted or not |
>| `string` | `Result string` or `Error message` |
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

>### self:editTopicAnswer ( messageId, message, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `string` | ✔ | The message id. Use `string` if it's the post number. |
>| message | `string` | ✔ | The new message |
>| location | `table` | ✔ | The location where the message should be edited. Fields 'f' and 't' are needed. |
>
>Edits a message content.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the message content was edited or not |
>| `string` | if #1, `post's url`, else `Result string` or `Error message` |
>

>### self:favoriteElement ( element, elementId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| element | `string`, `int` | ✔ | An enum from `enums.element` (index or value) |
>| elementId | `int`, `string` | ✔ | The element id. |
>| location | `table` | ✕ | The location of the report. If it's a forum topic the fields 'f' and 't' are needed. |
>
>Favorites an element. (e.g: topic, tribe)
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the element was favorited or not |
>| `string` | `Result string` or `Error message` |
>

>### self:kickConversationMember ( conversationId, userId )
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

>### self:leaveConversation ( conversationId )
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

>### self:likeMessage ( messageId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `string` | ✔ | The message id. Use `string` if it's the post number. |
>| location | `table` | ✔ | The topic location. Fields 'f' and 't' are needed. |
>
>Likes a message.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the like was recorded or not |
>| `string` | if #1, `post's url`, else `Result string` or `Error message` |
>

>### self:movePrivateConversation ( privLocation, conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| privLocation | `string`, `int` | ✔ | An enum from `enums.privLocation` (index or value) |
>| conversationId | `int`, `table` | ✕ | The id or ids of the conversation(s) to be moved |
>
>Moves private conversations to the inbox or bin.
>To empty trash, `@conversationId` must be `nil` and `@location` must be `bin`
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the conversation was moved or not |
>| `string` | if #1, `location's url`, else `Result string` or `Error message` |
>

>### self:removeAvatar (  )
>Removes the account's avatar.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the avatar was removed or not |
>| `string` | `Result string` or `Error message` |
>

>### self:removeTribeLogo (  )
>Removes the logo of the account's tribe.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the logo was removed or not |
>| `string` | `Result string` or `Error message` |
>

>### self:reportElement ( element, elementId, reason, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| element | `string`, `int` | ✔ | An enum from `enums.element` (index or value) |
>| elementId | `int`, `string` | ✔ | The element id. |
>| reason | `string` | ✔ | The report reason. |
>| location | `table` | ✕ | The location of the report. If it's a forum message the field 'f' is needed, if it's a private message the field 'co' is needed. |
>
>Reports an element. (e.g: message, profile)
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the report was recorded or not |
>| `string` | `Result string` or `Error message` |
>

>### self:requestValidationCode (  )
>Sends a validation code to the account's e-mail.
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
>Sets the new account's e-mail.
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
>Sets the new account's password.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new password was set or not |
>| `string` | `Result string` or `Error message` |
>

>### self:unfavoriteElement ( favoriteId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| favoriteId | `int`, `string` | ✔ | The element favorite-id. |
>
>Unfavorites an element.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the element was unfavorited or not |
>| `string` | `Result string` or `Error message` |
>

>### self:updateParameters ( parameters )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| parameters | `table` | ✔ | The parameters. |
>
>Updates the account parameters.
>The available parameters are:
>boolean `online` -> Whether the account should display if it's online or not
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `Whether` | the new parameter settings were set or not |
>| `string` | `Result string` or `Error message` |
>

>### self:updateProfile ( data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The data |
>
>Updates the account's profile.
>The available data are:
>string | int `community` -> Account's community. An enum from `enums.community` (index or value)
>string `birthday` -> The birthday date (dd/mm/yyyy)
>string `location` -> The location
>string | int `gender` -> account's gender. An enum from `enums.gender` (index or value)
>string `presentation` -> Profile's presentation
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `Whether` | the profile was updated or not |
>| `string` | `Result string` or `Error message` |
>

>### self:updateTribeGreetingMessage ( message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The new message |
>
>Updates the account's tribe greeting message.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `Whether` | the tribe's greeting message was updated or not |
>| `string` | `Result string` or `Error message` |
>

>### self:updateTribeParameters ( parameters )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| parameters | `table` | ✔ | The parameters. |
>
>Updates the account's tribe's parameters.
>The available parameters are:
>boolean `greeting_message` -> Whether the tribe's profile should display the tribe's greeting message or not
>boolean `ranks` -> Whether the tribe's profile should display the tribe ranks or not
>boolean `logs` -> Whether the tribe's profile should display the history logs or not
>boolean `leader` -> Whether the tribe's profile should display the tribe leaders message or not
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `Whether` | the new tribe parameter settings were set or not |
>| `string` | `Result string` or `Error message` |
>

>### self:updateTribeProfile ( data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The data |
>
>Updates the account's tribe profile.
>The available data are:
>string | int `community` -> Account's tribe community. An enum from `enums.community` (index or value)
>string | int `recruitment` -> Account's tribe recruitment state. An enum from `enums.recruitmentState` (index or value)
>string `presentation` -> Account's tribe profile's presentation
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `Whether` | the tribe's profile was updated or not |
>| `string` | `Result string` or `Error message` |
>
