# Methods
>### connect ( userName, userPassword )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| userName | `string` | ✔ | Account's username. |
>| userPassword | `string` | ✔ | Account's password. |
>
>Connects to an account on Atelier801's forums.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `boolean`, `nil` | Whether the connection succeeded or not. |
>| `nil`, `string` | Error message. |
>
---
>### disconnect (  )
>
>Disconnects from an account on Atelier801's forums.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `boolean`, `nil` | Whether the account was disconnected or not. |
>| `nil`, `string` | Error message. |
>
---
>### requestValidationCode (  )
>
>Sends a validation code to the account's e-mail.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### submitValidationCode ( code )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| code | `string` | ✔ | The validation code. |
>
>Submits the validation code to the forum to be validated.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `boolean`, `nil` | Whether the validation code is valid or not. |
>| `string` | Result string or Error message. |
>
---
>### setEmail ( email, registration )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| email | `string` | ✔ | The e-mail to be linked to the account. |
>| registration | `boolean` | ✕ | Whether this is the first e-mail assigned to the account or not. <sub>(default = false)</sub> |
>
>Sets the new account's e-mail.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>
---
>### setPassword ( password, disconnect )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| password | `string` | ✔ | The new password. |
>| disconnect | `boolean` | ✕ | Whether the account should be disconnect from all the dispositives or not. <sub>(default = false)</sub> |
>
>Sets the new account's password.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `boolean`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>