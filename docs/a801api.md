## Static Methods
>### formatNickname ( nickname )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| nickname | `string` | ✔ | The nickname to be formated |
>
>Formats a nickname.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `string` | Formated nickname |
>

>### parseUrlData ( href )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| href | `string` | ✔ | The uri and data to be parsed |
>
>Parses the URL data.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | Parsed data. The available indexes are: `uri`, `raw_data` and `data` |
>| `nil`, `string` | Error message |
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

>### self:changeConversationState ( displayState, conversationId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| displayState | `string`, `int` | ✔ | The conversation display state. An enum from `enums.displayState` (index or value) |
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
>| location | `table` | ✔ | The location where the section will be created. Field 'f' is needed, 's' is needed if it's a sub-section. |
>
>Creates a section.<br>
>The available data are:<br>
>string `name` -> Section's name<br>
>string `icon` -> Section's icon. An enum from `enums.sectionIcon` (index or value)<br>
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
>| elementId | `int` | ✔ | The element id. |
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

>### self:getAccountImages ( pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| pageNumber | `int` | ✕ | The page number of the gallery. To list ALL the gallery, use `0`. (default = 1) |
>
>Gets the images that were hosted in your account.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The data of the images. Total pages at `_pages`. |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getBlacklist (  )
>Gets the account's blacklist.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The blacklist, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getConversation ( location, ignoreFirstMessage )
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

>### self:getCreatedTopics ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string`, `int` | ✕ | User name or id. (default = Client's account id) |
>
>Gets the topics created by a user.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of topics, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getDevTracker (  )
>Gets the latest messages sent by admins.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of posts, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getFriendlist (  )
>Gets the account's friendlist.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The friendlist, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getLastPosts ( pageNumber, userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| pageNumber | `int` | ✕ | The page number of the last posts list. (default = 1) |
>| userName | `string`, `int` | ✕ | User name or id. (default = Client's account id) |
>
>Gets the last posts of a user.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of posts, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getLatestImages ( quantity )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| quantity | `int` | ✕ | The quantity of images needed. Must be a number multiple of 16. (default = 16) |
>
>Gets the latest images that were hosted on Micepix.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The data of the images. |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getMessage ( postId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| postId | `int`, `string` | ✔ | The post id (note: not the message id, but the #mID) |
>| location | `table` | ✔ | The post topic or conversation location. Fields 'f' and 't' are needed for forum messages, field 'co' is needed for private message. |
>
>Gets the data of a message.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The message data, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getMessageHistory ( messageId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `string` | ✔ | The message id. Use `string` if it's the post number. |
>| location | `table` | ✔ | The message location. Fields 'f' and 't' are needed. |
>
>Gets the edition logs of a message, if possible.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The edition logs |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getPollOptions ( location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The location of the poll. Fields 'f' and 't' are needed. |
>
>Gets all the options of a poll.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | Poll options, if any is found. The indexes are `id` and `value`. |
>| `string`, `nil` | Error message |
>

>### self:getProfile ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string`, `int` | ✕ | User name or id. (default = Client's account name) |
>
>Gets an user profile.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The profile data, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getSection ( location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The section location. Fields 'f' and 's' are needed. |
>
>Gets the data of a section.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The section data, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getStaffList ( role )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| role | `string`, `int<` | ✔ | The role id. An enum from `enums.listRole` (index or value) |
>
>Lists the members of a specific role.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getTopic ( location, ignoreFirstMessage )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The topic location. Fields 'f' and 't' are needed. |
>| ignoreFirstMessage | `boolean` | ✕ | Whether the data of the first message should be ignored or not. (default = false) |
>
>Gets the data of a topic.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The topic data, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getTribe ( tribeId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribeId | `int` | ✕ | The tribe id. (default = Client's tribe id) |
>
>Gets the data of a tribe.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The tribe data, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getTribeHistory ( tribeId, pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribeId | `int` | ✕ | The tribe id. (default = Client's tribe id) |
>| pageNumber | `int` | ✕ | The page number of the history. To list ALL the history, use `0`. (default = 1) |
>
>Gets the history logs of a tribe, if possible.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The history logs. Total pages at `_pages`. |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getTribeMembers ( tribeId, pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribeId | `int` | ✕ | The tribe id. (default = Client's tribe id) |
>| pageNumber | `int` | ✕ | The list page (case the tribe has more than 30 members). To list ALL members, use `0`. (default = 1) |
>
>Gets the members of a tribe.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The names of the tribe ranks. Total pages at `_pages`, total members at `_count`. |
>| `nil`, `string` | The message error, if any occurred |
>

>### self:getTribeRanks ( tribeId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribeId | `int` | ✕ | The tribe id. (default = Client's tribe id) |
>
>Gets the ranks of a tribe, if possible.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The names of the tribe ranks |
>| `nil`, `string` | The message error, if any occurred |
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
>To allow _non-members_, use `enums.misc.non_member` or `"non_member"`.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new permissions were set or not |
>| `string` | `Result string` or `Error message` |
>

>### self:submitValidationCode ( code )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| code | `string` | ✔ | The validation code. |
>
>Submits the validation code to the forum to be validated.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the validation code was sent to be validated or not |
>| `string` | `Result string` (Empty for success) or `Error message` |
>

>### self:unblacklistUser ( userName )
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
>string|int `community` -> Account's community. An enum from `enums.community` (index or value)<br>
>string `birthday` -> The birthday date (dd/mm/yyyy)<br>
>string `location` -> The location<br>
>string|int `gender` -> Account's gender. An enum from `enums.gender` (index or value)<br>
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
>string `icon` -> The section's icon. An enum from `enums.sectionIcon` (index or value)<br>
>string `description` -> Section's description<br>
>int `min_characters` -> Minimum characters needed for a message in the new section<br>
>string|int `state` -> The section's state (e.g.: open, closed). An enum from `enums.displayState` (index or value)<br>
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
>string|int `state` -> The topic's state. An enum from `enums.displayState` (index or value)
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
>string|int `community` -> Account's tribe community. An enum from `enums.community` (index or value)<br>
>string|int `recruitment` -> Account's tribe recruitment state. An enum from `enums.recruitmentState` (index or value)<br>
>string `presentation` -> Account's tribe profile's presentation
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the tribe's profile was updated or not |
>| `string` | `Result string` or `Error message` |
>
