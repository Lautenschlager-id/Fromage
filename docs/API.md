## Methods
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
