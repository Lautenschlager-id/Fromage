## Methods
>### getMessage ( postId, location )
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

 
>### getTopic ( location, ignoreFirstMessage )
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

 
>### getSection ( location )
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

 
>### getTopicMessages ( location, pageNumber, getAllInfo )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The topic location. Fields 'f' and 't' are needed. |
>| pageNumber | `int` | ✕ | The topic page. To list ALL messages, use `0`. (default = 1) |
>| getAllInfo | `boolean` | ✕ | Whether the message data should be simple (ids only) or complete (getMessage). (default = true) |
>
>Gets the messages of a topic.


 
>### getSectionTopics ( location, getAllInfo, pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The topic location. Fields 'f' and 't' are needed. |
>| getAllInfo | `boolean` | ✕ | Whether the message data should be simple (ids only) or complete (getTopic). (default = true) |
>| pageNumber | `int` | ✕ | The topic page. To list ALL messages, use `0`. (default = 1) |
>
>Gets the messages of a topic.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of topics |
>| `nil`, `string` | Error Message |
>

 
>### getMessageHistory ( messageId, location )
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

 
>### createTopic ( title, message, location )
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
>| `string` | if #1, `topic's location`, else `Result string` or `Error message` |
>

 
>### answerTopic ( message, location )
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
>| `string` | if #1, `post's location`, else `Result string` or `Error message` |
>

 
>### editAnswer ( messageId, message, location )
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
>| `string` | if #1, `post's location`, else `Result string` or `Error message` |
>

 
>### createPoll ( title, message, pollResponses, location, settings )
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
>| `string` | if #1, `poll's location`, else `Result string` or `Error message` |
>

 
>### getPollOptions ( location )
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

 
>### answerPoll ( option, location, pollId )
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
>| `string` | if #1, `poll's location`, else `Result string` or `Error message` |
>

 
>### likeMessage ( messageId, location )
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
