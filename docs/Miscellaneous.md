## Methods
>### getCreatedTopics ( userName )
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

 
>### getLastPosts ( pageNumber, userName )
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

 
>### getFavoriteTopics (  )
>Gets the client's account favorite topics.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of topics, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

 
>### getFriendlist (  )
>Gets the account's friendlist.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The friendlist, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

 
>### getBlacklist (  )
>Gets the account's blacklist.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The blacklist, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

 
>### getFavoriteTribes (  )
>Gets the client's account favorite tribes.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of tribes, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

 
>### getDevTracker (  )
>Gets the latest messages sent by admins.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The list of posts, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

 
>### addFriend ( userName )
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

 
>### blacklistUser ( userName )
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

 
>### unblacklistUser ( userName )
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

 
>### favoriteElement ( element, elementId, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| element | `string`, `int` | ✔ | The element type. An enum from `enumerations.element` (index or value) |
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

 
>### unfavoriteElement ( favoriteId )
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

 
>### getStaffList ( role )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| role | `string`, `int<` | ✔ | The role id. An enum from `enumerations.listRole` (index or value) |
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
