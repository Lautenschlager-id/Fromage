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
>| `boolean` | Whether the user was added or not |
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
>| option | `int`, `table`, `string` | ✔ | The poll option to be selected. You can insert its ID or its text (highly recommended). For multiple options polls, use a table with `ints` or `strings`. |
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
>| location | `table` | ✔ | The location where the message is. Fields 'f' and 't' are needed. |
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
>| `boolean` | Whether the user was blacklisted or not |
>| `string` | `Result string` or `Error message` |
>

>### self:changeConversationState ( conversationState, conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| conversationState | `string`, `int` | ✔ | The conversation state. An enum from `enums.conversationState` (index or value) |
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

>### self:changeMessageContentState ( messageId, contentState, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `table`, `string` | ✔ | The message id. Use `string` if it's the post number. For multiple message IDs, use a table with `ints` or `strings`. |
>| contentState | `string` | ✔ | An enum from `enums.contentState` (index or value) |
>| location | `table` | ✔ | The topic location. Fields 'f' and 't' are needed. |
>
>Changes the restriction state for a message.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the message content state was changed or not |
>| `string` | if #1, `post's url`, else `Result string` or `Error message` |
>

>### self:changeMessageState ( messageId, messageState, location, reason )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `table`, `string` | ✔ | The message id. Use `string` if it's the post number. For multiple message IDs, use a table with `ints` or `strings`. |
>| messageState | `string`, `int` | ✔ | The message state. An enum from `enums.messageState` (index or value) |
>| location | `table` | ✔ | The topic location. Fields 'f' and 't' are needed. |
>| reason | `string` | ✕ | The reason for changing the message state |
>
>Changes the state of the message. (e.g: active, moderated)
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the message(s) state was(were) changed or not |
>| `string` | if #1, `post's url`, else `Result string` or `Error message` |
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

>### self:createSection ( data, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The new section data |
>| location | `table` | ✔ | The location where the section will be created. Field 'f' is needed, 's' is needed if it's a sub-section and 'tr' is needed if it's a section. |
>
>Creates a section.<br>
>The available data are:<br>
>string `name` -> Section's name<br>
>string `icon` -> Section's icon. An enum from `enums.icon` (index or value)<br>
>string `description` -> Section's description<br>
>int `min_characters` -> Minimum characters needed for a message in the new section
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the section was created or not |
>| `string` | if #1, `section's url`, else `Result string` or `Error message` |
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
>| `boolean` | Whether the image was deleted or not |
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
>| element | `string`, `int` | ✔ | The element type. An enum from `enums.element` (index or value) |
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

>### self:movePrivateConversation ( inboxLocale, conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| inboxLocale | `string`, `int` | ✔ | Where the conversation will be located. An enum from `enums.inboxLocale` (index or value) |
>| conversationId | `int`, `table` | ✕ | The id or IDs of the conversation(s) to be moved |
>
>Moves private conversations to the inbox or bin.<br>
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
>| element | `string`, `int` | ✔ | The element type. An enum from `enums.element` (index or value) |
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

>### self:setTribeSectionPermissions ( permissions, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| permissions | `table` | ✔ | The permissions |
>| location | `table` | ✔ | The section location. The fields 'f', 't' and 'tr' are needed. |
>
>Sets the permissions of each rank for a specific section on the tribe forums.<br>
>The available permissions are `canRead`, `canAnswer`, `canCreateTopic`, `canModerate`, and `canManage`.<br>
>Each one of them must be a table of IDs (`int` or `string`) of the ranks that this permission should be allowed.<br>
>To allow _non-members_, use `enums.non_member` or `"non_member"`.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new permissions were set or not |
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
>Updates the account parameters.<br>
>The available parameters are:<br>
>boolean `online` -> Whether the account should display if it's online or not
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new parameter settings were set or not |
>| `string` | `Result string` or `Error message` |
>

>### self:updateProfile ( data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The data |
>
>Updates the account's profile.<br>
>The available data are:<br>
>string | int `community` -> Account's community. An enum from `enums.community` (index or value)<br>
>string `birthday` -> The birthday date (dd/mm/yyyy)<br>
>string `location` -> The location<br>
>string | int `gender` -> Account's gender. An enum from `enums.gender` (index or value)<br>
>string `presentation` -> Profile's presentation
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the profile was updated or not |
>| `string` | `Result string` or `Error message` |
>

>### self:updateSection ( data, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The updated section data |
>| location | `table` | ✔ | The section location. Fields 'f' and 's' are needed. |
>
>Updates a section.<br>
>The available data are:<br>
>string `name` -> Section's name<br>
>string `icon` -> The section's icon. An enum from `enums.icon` (index or value)<br>
>string `description` -> Section's description<br>
>int `min_characters` -> Minimum characters needed for a message in the new section<br>
>string | int `state` -> The section's state (e.g.: opened, closed). An enum from `enums.displayState` (index or value)<br>
>int `parent` -> The parent section if the updated section is a sub-section. (default = 0)
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the section was updated or not |
>| `string` | if #1, `section's url`, else `Result string` or `Error message` |
>

>### self:updateTopic ( data, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The new topic data |
>| location | `table` | ✔ | The location where the topic is. Fields 'f' and 't' are needed. |
>
>Updates a topic state, location and parameters.<br>
>The available data are:<br>
>string `title` -> Topic's title<br>
>boolean `postit` -> Whether the topic should be fixed or not<br>
>string | int `state` -> The topic's state. An enum from `enums.displayState` (index or value)
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the topic was updated or not |
>| `string` | if #1, `topic's url`, else `Result string` or `Error message` |
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
>| `boolean` | Whether the tribe's greeting message was updated or not |
>| `string` | `Result string` or `Error message` |
>

>### self:updateTribeParameters ( parameters )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| parameters | `table` | ✔ | The parameters. |
>
>Updates the account's tribe's parameters.<br>
>The available parameters are:<br>
>boolean `greeting_message` -> Whether the tribe's profile should display the tribe's greeting message or not<br>
>boolean `ranks` -> Whether the tribe's profile should display the tribe ranks or not<br>
>boolean `logs` -> Whether the tribe's profile should display the history logs or not<br>
>boolean `leader` -> Whether the tribe's profile should display the tribe leaders message or not
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new tribe parameter settings were set or not |
>| `string` | `Result string` or `Error message` |
>

>### self:updateTribeProfile ( data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The data |
>
>Updates the account's tribe profile.<br>
>The available data are:<br>
>string | int `community` -> Account's tribe community. An enum from `enums.community` (index or value)<br>
>string | int `recruitment` -> Account's tribe recruitment state. An enum from `enums.recruitmentState` (index or value)<br>
>string `presentation` -> Account's tribe profile's presentation
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the tribe's profile was updated or not |
>| `string` | `Result string` or `Error message` |
>
