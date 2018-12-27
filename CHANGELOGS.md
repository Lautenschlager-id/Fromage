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
- **getUser**
- **isAccountValidated**
- **getConnectionTime**
- _getProfile_.**fullname**
- _getProfile_.**discriminator**
- _getConversation_.**invitedUsers**
- **timestamp** is now a field when _getTopicMessages_ is called with _getAllInfo` as false.

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