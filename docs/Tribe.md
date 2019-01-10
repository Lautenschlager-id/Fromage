Tribe data and management.
# Methods
>### getTribe ( tribeId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribeId | `int` | ✕ | The tribe id. <sub>(default = = Account's tribe id)</sub> |
>
>Gets the data of a tribe.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The tribe data. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	community = enumerations.community, -- The tribe community.
>	creationDate = "", -- The date of the tribe creation.
>	favoriteId = 0, -- The favorite id of the tribe, if 'isFavorited'.
>	greetingMessage = "", -- The tribe greeting messages string field.
>	id = 0, -- The tribe id.
>	isFavorited = false, -- Whether the tribe is favorited or not.
>	leaders = { "" }, -- The list of tribe leaders.
>	name = "", -- The name of the tribe.
>	presentation = "", -- The tribe presentation string field.
>	recruitment = enumerations.recruitmentState -- The current recruitment state of the tribe.
>}
>```
---
>### getTribeMembers ( tribeId, pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribeId | `int` | ✕ | The tribe id. <sub>(default = = Accounts's tribe id)</sub> |
>| pageNumber | `int` | ✕ | The list page (if the tribe has more than 30 members). To list ALL members, use `0`. <sub>(default = 1)</sub> |
>
>Gets the members of a tribe.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The names of the tribe ranks. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		community = enumerations.community, -- The community of the member.
>		name = "", -- The name of the member.
>		rank = "", -- The name of the rank assigned to the member. (needs tribe permissions or to be a tribe member)
>		timestamp = 0 -- The timestamp of when the member joined the tribe. (needs to be a tribe member)
>	},
>	_pages = 0, -- The total pages of the member list.
>	_count = 0 -- The total of members in the tribe.
>}
>```
---
>### getTribeRanks ( tribeId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribeId | `int` | ✕ | The tribe id. <sub>(default = Account's tribe id)</sub> |
>| location | `table` | ✕ | The location where the ranks should be taken. Use `nil` if you don't need the role ids. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✔ | The section id. |
>
>Gets the ranks of a tribe.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The names of the tribe ranks |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	-- If not 'location', the struct is a string array.
>	[n] = {
>		id = 0, -- The role id.
>		name = "" -- The role name.
>	}
>}
>```
---
>### getTribeHistory ( tribeId, pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tribeId | `int` | ✕ | The tribe id. <sub>(default = Account's tribe id)</sub> |
>| pageNumber | `int` | ✕ | The page number of the history list. To list ALL the history, use `0`. <sub>(default = 1)</sub> |
>
>Gets the history logs of a tribe.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The history logs. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		log = "", -- The log value.
>		timestamp = 0 -- The timestamp of the log.
>	},
>	_pages = 0 -- The total pages of the history list.
>}
>```
---
>### getTribeForum ( location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✕ | The location of the tribe forum. <sub>(default = Account's tribe forum)</sub> |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✕ | The forum id. (needed if sub-forum) |
>| 	s | `int` | ✕ | The section id. (needed if sub-forum) |
>| 	tr | `int` | ✕ | The tribe id. (needed if forum) |
>
>Gets the sections of a tribe forum.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The data of each section. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		f = 0, -- The forum id.
>		name = "", -- The section name.
>		s = 0, -- The section id.
>		tr = 0 -- The tribe id.
>	}
>}
>```
---
>### updateTribeGreetingMessage ( message )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| message | `string` | ✔ | The new message content. |
>
>Updates the account's tribe's greetings message string field.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### updateTribeParameters ( parameters )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| parameters | `table` | ✔ | The parameters. |
>
>**@`parameters` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	displayGreetings | `boolean` | ✕ | Whether the tribe's profile should display the tribe's greetings message or not. |
>| 	displayRanks | `boolean` | ✕ | Whether the tribe's profile should display the tribe ranks or not. |
>| 	displayLogs | `boolean` | ✕ | Whether the tribe's profile should display the history logs or not. |
>| 	displayLeaders | `boolean` | ✕ | Whether the tribe's profile should display the tribe leaders or not. |
>
>Updates the account's tribe's profile parameters.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### updateTribeProfile ( data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The data |
>
>**@`data` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	community | `string`, `int` | ✕ | Tribe's community. An enum from [community](Enumerations.md#community-int). (index or value) <sub>(default = xx)</sub> |
>| 	recruitment | `string`, `int` | ✕ | Tribe's recruitment state. An enum from [recruitmentState](Enumerations.md#recruitmentstate-int). (index or value) |
>| 	presentation | `string` | ✕ | Tribe's profile's presentation string field. |
>
>Updates the account's tribe's profile.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### changeTribeLogo ( image )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| image | `string` | ✔ | The new image. An URL or file name. |
>
>Changes the logo of the account's tribe.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### removeTribeLogo (  )
>
>Removes the logo of the account's tribe.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### createSection ( data, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The new section data. |
>| location | `table` | ✕ | The location where the section will be created. |
>
>**@`data` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	name | `string` | ✔ | Section's name. |
>| 	icon | `string` | ✔ | Section's icon. An enum from [sectionIcon](Enumerations.md#sectionicon-string). (index or value) |
>| 	description | `string` | ✕ | Section's description. <sub>(default = Section name)</sub> |
>| 	min_characters | `int` | ✕ | Minimum characters needed to send a message in the section. <sub>(default = 4)</sub> |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✕ | The section id. (needed if sub-section) |
>
>Creates a section.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The location of the new section. |
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
>### updateSection ( data, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The updated section data |
>| location | `table` | ✔ | The section location. Fields 'f' and 's' are needed. |
>
>**@`data` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	name | `string` | ✔ | The name of the section. |
>| 	icon | `string` | ✔ | The icon of the section. An enum from [sectionIcon](Enumerations.md#sectionicon-string). (index or value) |
>| 	description | `string` | ✔ | The section's description string field. |
>| 	min_characters | `int` | ✔ | Minimum characters needed for a message in the new section |
>| 	state | `string`, `int` | ✔ | The section's state (e.g.: open, closed). An enum from [displayState](Enumerations.md#displaystate-int). (index or value) |
>| 	parent | `int` | ✔ | The parent section if the updated section is a sub-section. <sub>(default = 0)</sub> |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✔ | The section id. |
>
>Updates a section.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### setTribeSectionPermissions ( permissions, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| permissions | `table` | ✔ | The permissions of the section. |
>| location | `table` | ✔ | The section location. |
>
>**@`permissions` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	canRead | `table` | ✕ | A list of role names or ids that should be allowed to read the topics of the section. |
>| 	canAnswer | `table` | ✕ | A list of role names or ids that should be allowed to send messages in the topics of the section. |
>| 	canCreateTopic | `table` | ✕ | A list of role names or ids that should be allowed to create topics in the section. |
>| 	canModerate | `table` | ✕ | A list of role names or ids that should be allowed to moderate in the section. |
>| 	canManage | `table` | ✕ | A list of role names or ids that should be allowed to manage the section. |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✔ | The section id. |
>
>Sets the permissions of each rank for a specific section on the account's tribe's forum.<br>
>To allow _non-members_, use `enumerations.misc.non_member` or `"non_member"` in the permissions list.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>