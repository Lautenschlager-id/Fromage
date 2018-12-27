# Methods
>### parseUrlData ( href )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| href | `string` | ✔ | The URI and data to be parsed. |
>
>Parses the URL data.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | Parsed data. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	uri = "", -- The URI.
>	raw_data = "", -- The data as string, without the URI.
>	data = { }, -- The data as index->value. ( f = 0 )
>	id = "", -- The element id, if any is given
>	num_id = '0', -- The number of the element id, if any is given. (Still a string)
>}
>```
---
>### getLocation ( forum, community, section )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| forum | `int`, `string` | ✔ | The forum id. An enum from `enumerations.forum`. (index or value) |
>| community | `string`, `int` | ✔ | The community id. An enum from `enumerations.community`. (index or value) |
>| section | `string`, `int` | ✔ | The section id. An enum from `enumerations.section`. (index or value) |
>
>Gets the location of a section on the forums.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The location. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	f = 0, -- The forum id.
>	s = 0 -- The section id.
>}
>```
---
>### isConnected (  )
>
>Checks whether the instance is connected to an account or not.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether there's already a connection or not. |
>
---
>### getUser (  )
>
>Gets the instance's account information.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | The username of the account. |
>| `int`, `nil` | The ID of the account. |
>| `int`, `nil` | the ID of the account's tribe. |
>
---
>### isAccountValidated (  )
>
>Checks whether an account was validated by an e-mail code or not.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the account is validated or not. |
>
---
>### enumerations (  )
>
>Gets the system enumerations.<br>
>Smoother alias of `require "fromage/libs/enumerations"`.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The enumerations table |
>
---
>### formatNickname ( nickname )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| nickname | `string` | ✔ | The nickname. |
>
>Formats a nickname.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string` | Formated nickname. |
>