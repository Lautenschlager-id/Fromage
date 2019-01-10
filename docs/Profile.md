Player profile data and management.
# Methods
>### getProfile ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string`, `int` | ✕ | User name or user id. <sub>(default = Account's username)</sub> |
>
>Gets the profile data of an user.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The profile data. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	avatarUrl = "", -- The profile picture url.
>	birthday = "", -- The birthday string field.
>	community = enumerations.community, -- The community of the user.
>	gender = enumerations.gender, -- The gender of the user.
>	highestRole = enumerations.role, -- The highest role of the account based on the discriminator number.
>	id = 0, -- The user id.
>	level = 0, -- The level of the user on forums.
>	location = "", -- The location string field.
>	name = "", -- The name of the user.
>	presentation = "", -- The presentation string field (HTML).
>	registrationDate = "", -- The registration date string field.
>	soulmate = "", -- The username of the account's soulmate.
>	title = enumerations.forumTitle, -- The current forum title of the account based on the level.
>	totalMessages = 0, -- The quantity of messages sent by the user.
>	totalPrestige = 0, -- The quantity of prestige (likes) obtained by the user.
>	tribe = "", -- The name of the account's tribe.
>	tribeId = 0 -- The id of the account's tribe.
>}
>```
---
>### changeAvatar ( image )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| image | `string` | ✔ | The new image. An URL or file name. |
>
>Changes the profile picture of the account.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### updateProfile ( data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✕ | The data. |
>
>**@`data` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	community | `string`, `int` | ✕ | User's community. An enum from `enumerations.community`. (index or value) <sub>(default = xx)</sub> |
>| 	birthday | `string` | ✕ | The birthday string field. (dd/mm/yyyy) |
>| 	location | `string` | ✕ | The location string field. |
>| 	gender | `string`, `int` | ✕ | User's gender. An enum from `enumerations.gender`. (index or value) |
>| 	presentation | `string` | ✕ | Profile's presentation string field. |
>
>Updates the account's profile.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### removeAvatar (  )
>
>Removes the profile picture of the account.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### updateParameters ( parameters )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| parameters | `table` | ✕ | The parameters. |
>
>**@`parameters` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	online | `boolean` | ✕ | Whether the account should display if it's online or not. <sub>(default = false)</sub> |
>
>Updates the account profile parameters.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>