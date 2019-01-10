# Changelogs v0.3.7

## Developer
### Changes
- Improved `docgen.lua`.
- The file **autoupdate** can now be both a non-extension or **txt** file.
- **getList** and **getBigList** now have a parameter `inif` that executes an initial function with the head and the body before everything else.

## Class
### News
- Transformice Adventures location added. (`xx.transformice_adventures`)
- **extensions**.
- Added the extension file `extensions.lua` that provides a bunch of interesting functions and is open for pull requests!

### Fixes
- **getTribe** was setting the field **greetingMessage** as **presentation** when the tribe greeting message was an empty string.
- **getTribeMembers** was failing when there was more than one page in the list.
- **search** was not working properly when 'searchLocation' was tribe.

# Changelogs v0.3.6
### News
- **getAllMessages** can now list the private conversation messages.
- **getTopicMessages** is now an alias for **getAllMessages**.
- **deleteMicepixImage** is now an alias for **deleteImage**.

### Changes
- **getTopicMessages** was renamed to **getAllMessages**.

# Changelogs v0.3.5
### News
- Added an autoupdater for the lib. All you need to do is to create a file named `autoupdate` in the bot path.

### Fixes
- /!\\ **getTopicMessages** had the fields _timestamp_ and _id_ switched.
- Minor fixes with function error naming.

# Changelogs v0.3.4
### News
- **getLastPosts** has now a third parameter, _extractNavbar_.

### Changes
- _getConversation_.invitedUsers is now a 'dictionary' and not an 'array'.
- When an enum fails `enum(x) or x`, `x` will be appended to a `@`.
- **deleteMicepixImage** was renamed to **deleteImage**.
- **deleteImage** now accepts a table of images as parameter.

### Fixes
-  /!\\ **getCreatedTopics** and **getLastPosts** were not working when the player discriminator was different of `#0000`.
-  /!\\ **uploadImage** was throwing an error related to the 10th position of the file table.

# Changelogs v0.3.3

## Developer
### Changes
- **getNavbar** has now a second parameter `isNavbar` to ignore the first match when content = navbar.

## Class
### News
- _getSectionTopics_.**author**. (when `getAllInfo` is false)
- **extractNicknameData**.

### Changes
- **getProfile** does not have the fields **fullname** and **discriminator** anymore, and **name** has the _fullname_ value.

### Fixes
- **getFavoriteTopics** now uses the developer function _getNavbar_ that boosts its performance.
- /!\\ Typo was breaking the navigation bar system.

# Changelogs v0.3.2
### Changes
- The development functions **performAction** and **getPage** can now be accessed.
- **formatNickname** now adds `#0000` if the nickname doesn't have a discriminator.

### Fixes
- **parseUrlData** was not working properly.

# Changelogs v0.3.1

### Fixes
- The last topic message was ignored in **getTopicMessages**.

# Changelogs v0.3

## Developer
- **performAction** now returns only one value, the result data.
- **getPage** now returns only one value, the data.
- Added hexcodes in the unknown error messages, so they can be tracked easily.
- The order of processment of some functions were changed, so it uses less mememory if an error occurs.
- Documentation remade entirely.
- Navigation bars now with a better performance.

## Class
### News
- **getUser**.
- **isAccountValidated**.
- **getConnectionTime**.
- _getProfile_.**fullname**.
- _getProfile_.**discriminator**.
- _getConversation_.**invitedUsers**.
- **timestamp** is now a field when _getTopicMessages_ is called with _getAllInfo_ as false.
- _getMessage_.**canLike**

### Changes
- **isConnected** now only returns whether the account is logged or not, other values were split in getters.
- _getProfile_.**name** does not contain the discriminator anymore.
- **movePrivateConversation** was renamed to **moveConversation**.
- All the **messageHtml** fields were renamed to **contentHtml**.
- _getPoll_.**allowMultiple** was renamed to _getPoll_.**allowsMultiple**.
- The data parameters in **updateTribeParameters** were renamed. `greeting_message`->`displayGreetings`; `ranks`->`displayRanks`; `logs`->`displayLogs`; `leader`->`displayLeaders`
- The **author** field was renamed to **hoster** in _getLatestImages_.
- The **topicTitle** field was renamed to **title** in _search_.

### Fixes
- _getProfile_.**highestRole** didn't work as expected.
- **updateTribeProfile** was not verifying the _community_ parameter.