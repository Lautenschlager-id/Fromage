## Methods
>### connect ( userName, userPassword )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | account's user name |
>| userPassword | `string` | ✔ | account's password |
>
>Connects to an account on Atelier801's forums.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the account connected or not |
>| `string` | Result string |
>

 
>### disconnect (  )
>Disconnects from an account on Atelier801's forums.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the account disconnected or not |
>| `string` | Result string |
>

 
>### requestValidationCode (  )
>Sends a validation code to the account's e-mail.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the validation code was sent or not |
>| `string` | `Result string` or `Error message` |
>

 
>### submitValidationCode ( code )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| code | `string` | ✔ | The validation code. |
>
>Submits the validation code to the forum to be validated.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the validation code was sent to be validated or not |
>| `string` | `Result string` (Empty for success) or `Error message` |
>

 
>### setEmail ( email, registration )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| email | `string` | ✔ | The e-mail to be linked to your account |
>| registration | `boolean` | ✕ | Whether this is the first e-mail assigned to the account or not |
>
>Sets the new account's e-mail.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the validation code was sent or not |
>| `string` | `Result string` or `Error message` |
>

 
>### setPassword ( password, disconnect )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| password | `string` | ✔ | The new password |
>| disconnect | `boolean` | ✕ | Whether the account should be disconnect from all the dispositives or not. (default = false) |
>
>Sets the new account's password.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the new password was set or not |
>| `string` | `Result string` or `Error message` |
>
