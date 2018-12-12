## Methods
>### deleteMicepixImage ( imageId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| imageId | `string` | ✔ | The image id |
>
>Deletes an image from the account's micepix.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the image was deleted or not |
>| `string` | `Result string` or `Error message` |
>


>### getAccountImages ( pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| pageNumber | `int` | ✕ | The page number of the gallery. To list ALL the gallery, use `0`. (default = 1) |
>
>Gets the images that were hosted in your account.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The data of the images. Total pages at `_pages`. |
>| `nil`, `string` | The message error, if any occurred |
>


>### getLatestImages ( quantity )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| quantity | `int` | ✕ | The quantity of images needed. Must be a number multiple of 16. (default = 16) |
>
>Gets the latest images that were hosted on Micepix.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The data of the images. |
>| `nil`, `string` | The message error, if any occurred |
>


>### uploadImage ( image, isPublic )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| image | `string` | ✔ | The new image. An URL or file name. |
>| isPublic | `boolean` | ✕ | Whether the image should appear in the gallery or not. (default = false) |
>
>Uploads an image in Micepix.
>
>**Returns**
>
>| Type | Description |
>| :-: | - |
>| `boolean` | Whether the image was hosted or not |
>| `string` | if #1, `image's url`, else `Result string` or `Error message` |
>
