## Methods
>### parseUrlData ( href )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| href | `string` | ✔ | The uri and data to be parsed |
>
>Parses the URL data.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | Parsed data. The available indexes are: `uri`, `raw_data` and `data` |
>| `nil`, `string` | Error message |
>

 
>### getLocation ( forum, community, section )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| forum | `int`, `string` | ✔ | The forum of the location. An enum from `enumerations.forum` (index or value) |
>| community | `string`, `int` | ✔ | The location community. An enum from `enumerations.community` (index or value) |
>| section | `string`, `int` | ✔ | The section of the location. An enum from `enumerations.section` (index or value) |
>
>Gets the location of a section on forums based on its community.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table` | The location table. Fields `f` and `s`. |
>

 
>### formatNickname ( nickname )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| nickname | `string` | ✔ | The nickname to be formated |
>
>Formats a nickname.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `string` | Formated nickname |
>

 
>### isConnected (  )
>Checks whether the instance is connected to an account or not.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether there's already a connection or not. |
>| `string`, `nil` | If #1, the user name |
>| `int`, `nil` | If #1, the user id |
>

 
>### getTribeForum ( location )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| location | `table` | ✕ | The location of the tribe forum. Field 'tr' (tribeId) is needed if it's a forum, fields 'f' and 's' are needed if it's a sub-forum. (default = Client's tribe forum) |
>
>Gets the sections of a tribe forum.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The data of each section. |
>| `nil`, `string` | Error message, if any occurred. |
>
