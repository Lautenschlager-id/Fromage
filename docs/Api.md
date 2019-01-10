Useful functions to make the use of the API easier and to handle some return values.
# Methods
>### getPage ( url )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| url | `string` | ✔ | The URL for the GET request. The forum path is not necessary. |
>
>Performs a GET request using the connection cookies.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Page HTML. |
>| `table`, `string` | Page headers or Error message. |
>
---
>### getLocation ( forum, community, section )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| forum | `int`, `string` | ✔ | The forum id. An enum from [forum](Enumerations.md#forum-int). (index or value) |
>| community | `string`, `int` | ✔ | The community id. An enum from [community](Enumerations.md#community-int). (index or value) |
>| section | `string`, `int` | ✔ | The section id. An enum from [section](Enumerations.md#section-string). (index or value) |
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
>### getUser (  )
>
>Gets the instance's account information.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | The username of the account. |
>| `int`, `nil` | The account id. |
>| `int`, `nil` | the id of the account's tribe. |
>
---
>### getConnectionTime (  )
>
>Gets the total time since the last login performed in the instace.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int` | Total time since the connection of the current account. |
>
---
>### enumerations (  )
>
>Gets the system enumerations.<br>
>Smoother alias for `require "fromage/libs/enumerations"`.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The enumerations table |
>
---
>### extensions (  )
>
>Gets the extension functions of the API.<br>
>Smoother alias for `require "fromage/libs/extensions"`.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The extension functions. |
>
---
>### performAction ( uri, postData, ajaxUri, file )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| uri | `string` | ✔ | The URI code for the POST request. (Function) |
>| postData | `table` | ✕ | The headers for the POST request. |
>| ajaxUri | `string` | ✕ | The ajax URI code for the POST request. (Forum) |
>| file | `string` | ✕ | The file (image) content. If set, this will change most of the standard headers. |
>
>Performs a POST request using the connection cookies.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
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
---
>### extractNicknameData ( nickname )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| nickname | `string` | ✔ | The nickname. |
>
>Extracts the data of a nickname. (Name, Discriminator)
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The nickname data. |
>
>**Table structure**:
>```Lua
>{
>	discriminator = "", -- The nickname's discriminator.
>	fullname = "", -- The full nickname. (Name and Discriminator)
>	name = "" -- The nickname without the discriminator.
>}
>```
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