## Methods
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

 
>### updateTopic ( location, data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The location where the topic is. Fields 'f' and 't' are needed. |
>| data | `table` | ✕ | The new topic data. (default = Old title, active) |
>
>Updates a topic state, location and parameters.<br>
>The available data are:<br>
>string `title` -> Topic's title<br>
>boolean `fixed` -> Whether the topic should be fixed or not<br>
>string|int `state` -> The topic's state. An enum from `enumerations.displayState` (index or value)
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the topic was updated or not |
>| `string` | if #1, `topic's url`, else `Result string` or `Error message` |
>

 
>### reportElement ( element, elementId, reason, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| element | `string`, `int` | ✔ | The element type. An enum from `enumerations.element` (index or value) |
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

 
>### changeMessageState ( messageId, messageState, location, reason )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `table`, `string` | ✔ | The message id. Use `string` if it's the post number. For multiple message IDs, use a table with `ints` or `strings`. |
>| messageState | `string`, `int` | ✔ | The message state. An enum from `enumerations.messageState` (index or value) |
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

 
>### changeMessageContentState ( messageId, contentState, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `table`, `string` | ✔ | The message id. Use `string` if it's the post number. For multiple message IDs, use a table with `ints` or `strings`. |
>| contentState | `string` | ✔ | An enum from `enumerations.contentState` (index or value) |
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
