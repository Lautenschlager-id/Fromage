Report and elements management.
# Methods
>### getMessageHistory ( messageId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `string` | ✔ | The message id. Use `string` if it's the post number. |
>| location | `table` | ✔ | The message location. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	t | `int` | ✔ | The topic id. |
>
>Gets the edition logs of a message.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The edition logs. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		bbcode = "", -- The bbcode of the edited message.
>		timestamp = 0 -- The timestamp of the edited message.
>	}
>}
>```
---
>### updateTopic ( location, data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✔ | The location where the topic is located. |
>| data | `table` | ✕ | The new topic data. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✔ | The section id. |
>| 	t | `int` | ✔ | The topic id. |
>
>**@`data` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	title | `string` | ✕ | The new title of the topic. <sub>(default = Current title)</sub> |
>| 	fixed | `boolean` | ✕ | Whether the topic should be fixed or not. <sub>(default = false)</sub> |
>| 	state | `string`, `int` | ✕ | The state of the topic. An enum from 'enumerations.displayState'. (index or value) |
>
>Updates a topic state, location, and parameters.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### reportElement ( element, elementId, reason, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| element | `string`, `int` | ✔ | The element type. An enum from `enumerations.element`. (index or value) |
>| elementId | `int`, `string` | ✔ | The element id. |
>| reason | `string` | ✔ | The report reason. |
>| location | `table` | ✕ | The location of the report. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. (needed for forum element) |
>| 	t | `int` | ✔ | The topic id. (needed for forum element) |
>| 	co | `int` | ✔ | The private conversation id. (needed for private element) |
>
>Reports an element. (e.g: message, profile)
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### changeMessageState ( messageId, messageState, location, reason )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `table`, `string` | ✔ | The message id. Use `string` if it's the post number. For multiple message ids, use a table with `ints` or `strings`. |
>| messageState | `string`, `int` | ✔ | The message state. An enum from `enumerations.messageState`. (index or value) |
>| location | `table` | ✔ | The message location. |
>| reason | `string` | ✕ | The state change reason. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	t | `int` | ✔ | The topic id. |
>
>Changes the state of a message. (e.g: active, moderated)
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### changeMessageContentState ( messageId, contentState, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| messageId | `int`, `table`, `string` | ✔ | The message id. Use `string` if it's the post number. For multiple message ids, use a table with `ints` or `strings`. |
>| contentState | `string` | ✔ | An enum from `enumerations.contentState` (index or value) |
>| location | `table` | ✔ | The topic location. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	t | `int` | ✔ | The topic id. |
>
>Changes the restriction state of a message.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>