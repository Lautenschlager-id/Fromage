Random functions. 
# Methods
>### search ( searchType, search, pageNumber, data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| searchType | `string`, `int` | ✔ | The type of the search (e.g.: player, message). An enum from [searchType](Enumerations.md#searchtype-int). (index or value) |
>| search | `string` | ✔ | The value to be searched. |
>| pageNumber | `int` | ✕ | The page number of the search results. To list ALL the matches, use `0`. <sub>(default = 1)</sub> |
>| data | `table` | ✕ | Additional data to be used in the `message_topic` search type. |
>
>**@`data` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	author | `string` | ✕ | The name of the message or topic author that the search system needs to look for. |
>| 	community | `string`, `int` | ✕ | The community to perform the search. An enum from [community](Enumerations.md#community-int). (index or value) |
>| 	f | `int` | ✔ | The forum id. |
>| 	s | `int` | ✕ | The section id. |
>| 	searchLocation | `string`, `int ` | ✔ | The specific search location. An enum from [searchLocation](Enumerations.md#searchlocation-int). (index or value) |
>
>Performs a deep search on forums.<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) This function may take several minutes to return the values depending on the settings.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The search matches. Total pages at `_pages`. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		author = "", -- The author of the topic or message matched. (When 'searchType' is 'message_topic')
>		community = enumerations.community, -- The community of the topic or player matched. (When 'searchType' is not 'tribe')
>		contentHtml = "", -- The HTML of the message content. (When 'searchType' is 'message_topic' and 'searchLocation' is not 'titles')
>		id = 0, -- The id of the tribe found. (When 'searchType' is 'tribe')
>		location = parseUrlData, -- The location of the message or topic. (When 'searchType' is 'message_topic')
>		name = "", -- The name of the player or tribe. (When 'searchType' is not 'message_topic')
>		post = "", -- The post id of the message. (When 'searchType' is 'message_topic' and 'searchLocation' is not 'titles')
>		timestamp = 0, -- The timestamp of when the message or topic was created.
>		title = "" -- The topic title. (When 'searchType' is 'message_topic')
>	},
>	_pages = 0 -- The total pages of available matches for the search.
>}
>```
---
>### getCreatedTopics ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string`, `int` | ✕ | User name or user id. <sub>(default = Account's id)</sub> |
>
>Gets the topics created by a user.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of topics. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		community = enumerations.community, -- The community where the topic was created.
>		location = parseUrlData, -- The location of the topic.
>		timestamp = 0, -- The timestamp of when the topic was created.
>		title = "", -- The title of the topic.
>		totalMessages = 0 -- The total of messages of the topic.
>	}
>}
>```
---
>### getLastPosts ( pageNumber, userName, extractNavbar )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| pageNumber | `int` | ✕ | The page number of the last posts list. <sub>(default = 1)</sub> |
>| userName | `string`, `int` | ✕ | User name or id. <sub>(default = Account's id)</sub> |
>| extractNavbar | `boolean` | ✕ | Whether the info should include the navigation bar or not. <sub>(default = false)</sub> |
>
>Gets the last posts of a user.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of posts. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		contentHtml = "", -- The HTML of the message content.
>		location = parseUrlData, -- The location of the message.
>		navbar = {
>			[n] = {
>				location = parseUrlData, -- The parsed-url location object.
>				name = "" -- The name of the location.
>			}
>		}, -- A list of locations of the navigation bar. (If 'extractNavbar' is true)
>		post = "", -- The post id of the message.
>		timestamp = 0, -- The timestamp of when the message was created.
>		topicTitle = "" -- The title of the topic where the message was posted.
>	},
>	_pages = 0 -- The total pages of the "last posts" list.
>}
>```
---
>### getFavoriteTopics (  )
>
>Gets the account's favorite topics.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of topics. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		community = enumerations.community, -- The community where the topic is located.
>		favoriteId = 0, -- The favorite id of the topic.
>		navbar = {
>			[n] = {
>				location = parseUrlData, -- The parsed-url location object.
>				name = "" -- The name of the location.
>			}
>		}, -- A list of locations of the navigation bar.
>		timestamp = 0 -- The timestamp of when the topic was created.
>	}
>}
>```
---
>### getFriendlist (  )
>
>Gets the account's friendlist.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of friends. |
>| `nil`, `string` | Error message. |
>
---
>### getBlacklist (  )
>
>Gets the account's blacklist.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of ignored users. |
>| `nil`, `string` | Error message. |
>
---
>### getFavoriteTribes (  )
>
>Gets the account's favorite tribes.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of tribes. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		id = 0, -- The id of the tribe.
>		name = "" -- The name of the tribe.
>	}
>}
>```
---
>### getDevTracker (  )
>
>Gets the latest messages sent by admins.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of posts. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		author = "", -- The name of the admin that posted the message.
>		contentHtml = "", -- The HTML of the message content.
>		navbar = {
>			[n] = {
>				location = parseUrlData, -- The parsed-url location object.
>				name = "" -- The name of the location.
>			}
>		}, -- A list of locations of the navigation bar.
>		post = "", -- The post id of the message.
>		timestamp = 0 -- The timestamp of when the message was created.
>	}
>}
>```
---
>### addFriend ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | The user to be added. |
>
>Adds a user as friend.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### blacklistUser ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | The user to be blacklisted. |
>
>Adds a user in the blacklist.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### unblacklistUser ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | The user to be removed from the blacklist. |
>
>Removes a user from the blacklist.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### favoriteElement ( element, elementId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| element | `string`, `int` | ✔ | The element type. An enum from [element](Enumerations.md#element-int). (index or value) |
>| elementId | `int` | ✔ | The element id. |
>| location | `table` | ✕ | The location of the element. (if `element` is `topic`) |
>
>**@`location` parameter's structure**:
>
>| Index | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| 	f | `int` | ✔ | The forum id. |
>| 	t | `int` | ✔ | The topic id. |
>
>Favorites an element. (e.g: topic, tribe)
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### unfavoriteElement ( favoriteId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| favoriteId | `int`, `string` | ✔ | The favorite id of the element. |
>| location | `table` | ✕ | The location of the element. (if `element` is `topic`) |
>
>Unfavorites an element.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### getStaffList ( role )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| role | `string`, `int<` | ✔ | The role id. An enum from [listRole](Enumerations.md#listrole-int). (index or value) |
>
>Lists the members of a specific role.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of users. |
>| `nil`, `string` | Error message. |
>