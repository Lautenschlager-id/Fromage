Extension functions to make the use of the API easier with functions that may be useful at some point, such as bbcode to markdown.
# Methods
>### os.readFile ( file )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| file | `string` | ✔ | The file name or path. |
>
>Gets the content of a file.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | The file content. |
>
---
>### table.add ( src, list )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| src | `table` | ✔ | The source table to get new values. |
>| list | `table` | ✔ | The table that will pass the values to the source table. |
>
>Concats two tables (by reference).
>
---
>### table.createSet ( tbl, index )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tbl | `table` | ✔ | The base table. |
>| index | `string`, `int` | ✕ | The index to have its value set as index if `tbl` is a dictionary. |
>
>Creates a set of values based on a given table.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table` | The set of values. |
>
>**Table structure**:
>```Lua
>{
>	-- Without 'index'
>	[ tbl[n] ] = true,
>	-- With 'index
>	[ tbl[n][index] ] = tbl[n]
>}
>```
---
>### table.search ( tbl, value, index )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| tbl | `table` | ✔ | The table that may contain the required value. |
>| value | `*` | ✔ | The value to be searched in the table. |
>| index | `int`, `string` | ✕ | The index to be used to search the value, case it's a nested table. |
>
>Searches for a value in a given table.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `int`, `string`, `nil` | The first table index where the value was found. |
>
---
>### bbcodeToMarkdown ( bbcode )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| bbcode | `string` | ✔ | The bbcode to be converted. |
>
>Converts a BBCode into Markdown. (e.g.: [b] -> **)<br>
>![/!\\](http://images.atelier801.com/168395f0cbc.png) This function is currently in tests and bugs may occur.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string` | The markdown obtained from the bbcode. |
>
---
>### htmlEntitiesToAnsii ( str )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| str | `string` | ✔ | The HTML string to be normalized. |
>
>Normalizes most of the html entities found in the `htmlContent` fields converting them to ANSII.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string` | The normalized string without HTML entities. |
>