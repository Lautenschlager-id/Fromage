## Settings
- [x] [Login](docs/a801api.md#selfconnect--userName-userPassword-)
- [x] [Disconnect](docs/a801api.md#selfdisconnect---)
- [x] [Send Validation Code](docs/a801api.md#selfrequestValidationCode---)
- [x] [Valid Validation Code](docs/a801api.md#selfsubmitValidationCode--code-)
- [x] [Add/change e-mail](docs/a801api.md#selfsetEmail--email-)
- [x] [Change password](docs/a801api.md#selfsetPassword--password-disconnect-)

## Inbox
- [ ] Get conversation
- [x] [New Private Message](docs/a801api.md#selfcreatePrivateMessage--destinatary-subject-message-)
- [x] [New Private Discussion](docs/a801api.md#selfcreatePrivateDiscussion--destinataries-subject-message-)
- [x] [New Private Poll](docs/a801api.md#selfcreatePrivatePoll--destinataries-subject-message-pollResponses-settings-)
- [x] [Archive Private Content](docs/a801api.md#selfmovePrivateConversation--inboxLocale-conversationId-)
- [x] [Restore Private Content](docs/a801api.md#selfmovePrivateConversation--inboxLocale-conversationId-)
- [x] [Delete Private Content](docs/a801api.md#selfmovePrivateConversation--inboxLocale-conversationId-)
- [x] [Delete all Archived Content](docs/a801api.md#selfmovePrivateConversation--inboxLocale-conversationId-)
- [x] [Answer Private Conversation](docs/a801api.md#selfanswerConversation--conversationId-answer-)
- [x] [Close Private Conversation](docs/a801api.md#selfchangeConversationState--conversationState-conversationId-)
- [x] [Reopen Private Conversation](docs/a801api.md#selfchangeConversationState--conversationState-conversationId-)
- [x] [Invite guest to a Conversation](docs/a801api.md#selfconversationInvite--conversationId-userName-)
- [x] [Leave Private Conversation](docs/a801api.md#selfleaveConversation--conversationId-)
- [x] [Exclude guest from Conversation](docs/a801api.md#selfkickConversationMember--conversationId-userId-)

## Forum
- [x] [Get message](docs/a801api.md#selfgetMessage--postId-location-)
- [x] [Get topic](docs/a801api.md#selfgetTopic--location-ignoreFirstMessage-)
- [x] [Get section](docs/a801api.md#selfgetSection---)
- [ ] Get topic messages (by page?)
- [ ] Get section topics
- [x] [Answer topic](docs/a801api.md#selfanswerTopic--message-location-)
- [x] [Create topic](docs/a801api.md#selfcreateTopic--title-message-location-)
- [x] [Create poll](docs/a801api.md#selfcreatePoll--title-message-pollResponses-location-settings-)
- [x] [Vote in a poll](docs/a801api.md#selfanswerPoll--option-location-pollId-)
- [x] [Edit message](docs/a801api.md#selfeditTopicAnswer--messageId-message-location-)
- [x] [Edit topic title](docs/a801api.md#selfupdateTopic--data-location-)
- [x] [Moderate message](docs/a801api.md#selfchangeMessageState--messageId-messageState-location-reason-)
- [x] [Unmoderate message](docs/a801api.md#selfchangeMessageState--messageId-messageState-location-reason-)
- [x] [Move topic](docs/a801api.md#selfupdateTopic--data-location-)
- [x] [Postit topic](docs/a801api.md#selfupdateTopic--data-location-)
- [x] [Close topic](docs/a801api.md#selfupdateTopic--data-location-)
- [x] [Delete topic](docs/a801api.md#selfupdateTopic--data-location-)
- [x] [Undelete topic](docs/a801api.md#selfupdateTopic--data-location-)
- [x] [Restrict topic content](docs/a801api.md#selfchangeMessageContentState--messageId-contentState-location-)
- [x] [Unrestrict topic content](docs/a801api.md#selfchangeMessageContentState--messageId-contentState-location-)
- [ ] Message history logs
- [x] [Like post](docs/a801api.md#selflikeMessage--messageId-location-)

## Report
- [x] [Report Message](docs/a801api.md#selfreportElement--element-elementId-reason-location-)
- [x] [Report Profile](docs/a801api.md#selfreportElement--element-elementId-reason-location-)
- [x] [Report Tribe](docs/a801api.md#selfreportElement--element-elementId-reason-location-)
- [x] [Report Private Message](docs/a801api.md#selfreportElement--element-elementId-reason-location-)
- [x] [Report Poll](docs/a801api.md#selfreportElement--element-elementId-reason-location-)


## Profile
- [ ] Change avatar
- [x] [Remove avatar](docs/a801api.md#selfremoveAvatar---)
- [x] [Display online status](docs/a801api.md#selfupdateParameters--parameters-)
- [x] [Edit Profile](docs/a801api.md#selfupdateProfile--data-)
- [x] [Get player Profile](docs/a801api.md#selfgetProfile--userName-)

## Micepix
- [ ] Get micepix images (self) (by page?!)
- [ ] Get last micepix images hosted by users
- [ ] Post image
- [x] [Delete image](docs/a801api.md#selfdeleteMicepixImage--imageId-)

## Tribe
- [ ] Get tribe profile
- [ ] Get tribe members
- [ ] Get tribe history
- [ ] Change logo
- [x] [Remove logo](docs/a801api.md#selfremoveTribeLogo---)
- [x] [Edit profile](docs/a801api.md#selfupdateTribeProfile--data-)
- [x] [Edit greeting message](docs/a801api.md#selfupdateTribeGreetingMessage--message-)
- [x] [Edit Parameters](docs/a801api.md#selfupdateTribeParameters--parameters-)
- [x] [Create section](docs/a801api.md#selfcreateSection--data-location-)
- [x] [Delete section](docs/a801api.md#selfupdateSection--data-location-)
- [x] [Edit section](docs/a801api.md#selfupdateSection--data-location-)
- [x] [Edit section permissions](docs/a801api.md#selfsetTribeSectionPermissions--permissions-location-)
- [ ] Get tribe ranks

## Search
- [ ] Search

## Misc
- [ ] Get friendlist
- [ ] Get blacklist
- [x] [Add user as friend](docs/a801api.md#selfaddFriend--userName-)
- [x] [Add user in the blacklist](docs/a801api.md#selfblacklistUser--userName-)
- [ ] Get user last posts
- [ ] Get user created topics
- [ ] Get dev-tracker messages
- [x] [Favorite topic](docs/a801api.md#selffavoriteElement--element-elementId-location-)
- [x] [Unfavorite topic](docs/a801api.md#selfunfavoriteElement--favoriteId-)
- [x] [Favorite tribe](docs/a801api.md#selffavoriteElement--element-elementId-location-)
- [x] [Unfavorite topic](docs/a801api.md#selfunfavoriteElement--favoriteId-)
- [ ] Get favorite topics
- [ ] Get favorite tribes
- [x] [List staff](docs/a801api.md#selfgetStaffList--role-)