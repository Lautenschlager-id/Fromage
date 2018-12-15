## Methods
>### getProfile ( userName )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string`, `int` | ✕ | User name or id. (default = Client's account name) |
>
>Gets an user profile.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The profile data, if there's any |
>| `nil`, `string` | The message error, if any occurred |
>

 
>### updateAvatar ( image )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| image | `string` | ✔ | The new image. An URL or file name. |
>
>Updates the client's account profile picture.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new avatar was set or not |
>| `string` | `Result string` or `Error message` |
>

 
>### updateProfile ( data )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| data | `table` | ✕ | The data |
>
>Updates the account's profile.<br>
>The available data are:<br>
>string|int `community` -> Account's community. An enum from `enumerations.community` (index or value)<br>
>string `birthday` -> The birthday date (dd/mm/yyyy)<br>
>string `location` -> The location<br>
>string|int `gender` -> Account's gender. An enum from `enumerations.gender` (index or value)<br>
>string `presentation` -> Profile's presentation
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the profile was updated or not |
>| `string` | `Result string` or `Error message` |
>

 
>### removeAvatar (  )
>Removes the account's avatar.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the avatar was removed or not |
>| `string` | `Result string` or `Error message` |
>

 
>### updateParameters ( parameters )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| parameters | `table` | ✕ | The parameters. |
>
>Updates the account parameters.<br>
>The available parameters are:<br>
>boolean `online` -> Whether the account should display if it's online or not
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new parameter settings were set or not |
>| `string` | `Result string` or `Error message` |
>
