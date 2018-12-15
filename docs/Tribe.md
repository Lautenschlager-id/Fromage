## Methods
>### getTribe ( tribeId )
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

 
>### getTribeMembers ( tribeId, pageNumber )
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

 
>### getTribeRanks ( tribeId )
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

 
>### getTribeHistory ( tribeId, pageNumber )
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

 
>### updateTribeGreetingMessage ( message )
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

 
>### updateTribeParameters ( parameters )
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

 
>### updateTribeProfile ( data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The data |
>
>Updates the account's tribe profile.<br>
>The available data are:<br>
>string|int `community` -> Account's tribe community. An enum from `enumerations.community` (index or value)<br>
>string|int `recruitment` -> Account's tribe recruitment state. An enum from `enumerations.recruitmentState` (index or value)<br>
>string `presentation` -> Account's tribe profile's presentation
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the tribe's profile was updated or not |
>| `string` | `Result string` or `Error message` |
>

 
>### updateTribeLogo ( image )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| image | `string` | ✔ | The new image. An URL or file name. |
>
>Removes the logo of the account's tribe.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new logo was set or not |
>| `string` | `Result string` or `Error message` |
>

 
>### removeTribeLogo (  )
>Removes the logo of the account's tribe.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the logo was removed or not |
>| `string` | `Result string` or `Error message` |
>

 
>### createSection ( data, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The new section data |
>| location | `table` | ✔ | The location where the section will be created. Field 'f' is needed, 's' is needed if it's a sub-section. |
>
>Creates a section.<br>
>The available data are:<br>
>string `name` -> Section's name<br>
>string `icon` -> Section's icon. An enum from `enumerations.sectionIcon` (index or value)<br>
>string `description` -> Section's description<br>
>int `min_characters` -> Minimum characters needed for a message in the new section
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the section was created or not |
>| `string` | if #1, `section's location`, else `Result string` or `Error message` |
>

 
>### updateSection ( data, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✔ | The updated section data |
>| location | `table` | ✔ | The section location. Fields 'f' and 's' are needed. |
>
>Updates a section.<br>
>The available data are:<br>
>string `name` -> Section's name<br>
>string `icon` -> The section's icon. An enum from `enumerations.sectionIcon` (index or value)<br>
>string `description` -> Section's description<br>
>int `min_characters` -> Minimum characters needed for a message in the new section<br>
>string|int `state` -> The section's state (e.g.: open, closed). An enum from `enumerations.displayState` (index or value)<br>
>int `parent` -> The parent section if the updated section is a sub-section. (default = 0)
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the section was updated or not |
>| `string` | if #1, `section's url`, else `Result string` or `Error message` |
>

 
>### setTribeSectionPermissions ( permissions, location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| permissions | `table` | ✔ | The permissions |
>| location | `table` | ✔ | The section location. The fields 'f', 't' and 'tr' are needed. |
>
>Sets the permissions of each rank for a specific section on the tribe forums.<br>
>The available permissions are `canRead`, `canAnswer`, `canCreateTopic`, `canModerate`, and `canManage`.<br>
>Each one of them must be a table of IDs (`int` or `string`) of the ranks that this permission should be allowed.<br>
>To allow _non-members_, use `enumerations.misc.non_member` or `"non_member"`.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new permissions were set or not |
>| `string` | `Result string` or `Error message` |
>
