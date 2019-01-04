# Methods
>### getAccountImages ( pageNumber )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| pageNumber | `int` | ✕ | The page number of the gallery. To list ALL the gallery, use `0`. <sub>(default = 1)</sub> |
>
>Gets the images that were hosted by the logged account.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The data of the images. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		id = "", -- The image id.
>		timestamp = 0 -- The timestamp of when the image was hosted.
>	},
>	_pages = 0 -- The total pages of the images gallery.
>}
>```
---
>### getLatestImages ( quantity )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| quantity | `int` | ✕ | The quantity of images to be returned. Must be a number multiple of 16. <sub>(default = 16)</sub> |
>
>Gets the latest images that were hosted by people on Micepix.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | The data of the images. |
>| `nil`, `string` | Error message. |
>
>**Table structure**:
>```Lua
>{
>	[n] = {
>		hoster = "", -- The name of the hoster of the image.
>		id = "", -- The image id.
>		timestamp = 0 -- The timestamp of when the image was hosted.
>	}
>}
>```
---
>### uploadImage ( image, isPublic )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| image | `string` | ✔ | The new image. An URL or file name. |
>| isPublic | `boolean` | ✕ | Whether the image should appear in the gallery or not. <sub>(default = false)</sub> |
>
>Uploads an image in Micepix.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `table`, `nil` | A parsed-url location object. |
>| `nil`, `string` | Error message. |
>
---
>### deleteImage ( imageId )
>| Parameter | Type | Required | Description |
>| :-: | :-: | :-: | - |
>| imageId | `string`, `table` | ✔ | The image(s) id(s) to be deleted. |
>
>Deletes an image from the account's micepix gallery.
>
>**Returns**:
>
>| Type | Description |
>| :-: | - |
>| `string`, `nil` | Result string. |
>| `nil`, `string` | Error message. |
>