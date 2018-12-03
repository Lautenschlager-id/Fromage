## Settings
- [x] [Login](docs/a801api.md#selfconnect--userName-userPassword-)
- [x] [Disconnect](docs/a801api.md#selfdisconnect---)
- [x] [Send Validation Code](docs/a801api.md#selfrequestValidationCode---)
- [x] [Valid Validation Code](docs/a801api.md#selfsendValidationCode--code-)
- [x] [Add/change e-mail](docs/a801api.md#selfsetEmail--email-)
- [x] [Change password](docs/a801api.md#selfsetPassword--password-disconnect-)

## Inbox
- [x] [New Private Message](docs/a801api.md#selfcreatePrivateMessage--destinatary-subject-message-)
- [x] [New Private Discussion](docs/a801api.md#selfcreatePrivateDiscussion--destinataries-subject-message-)
- [x] [New Private Poll](docs/a801api.md#selfcreatePrivatePoll--destinataries-subject-message-pollResponses-settings-)
- [x] [Archive Private Content](docs/a801api.md#selfmovePrivateConversation--privLocation-conversationId-)
- [x] [Restore Private Content](docs/a801api.md#selfmovePrivateConversation--privLocation-conversationId-)
- [x] [Delete Private Content](docs/a801api.md#selfmovePrivateConversation--privLocation-conversationId-)
- [x] [Delete all Archived Content](docs/a801api.md#selfmovePrivateConversation--privLocation-conversationId-)
- [x] [Answer Private Conversation](docs/a801api.md#selfanswerConversation--conversationId-answer-)
- [x] [Close Private Conversation](docs/a801api.md#selfchangeConversationState--conversationState-conversationId-)
- [x] [Reopen Private Conversation](docs/a801api.md#selfchangeConversationState--conversationState-conversationId-)
- [x] [Invite guest to a Conversation](docs/a801api.md#selfconversationInvite--conversationId-userName-)
- [x] [Leave Private Conversation](docs/a801api.md#selfleaveConversation--conversationId-)
- [x] [Exclude guest from Conversation](docs/a801api.md#selfkickConversationMember--conversationId-userId-)

## Forum
- [ ] Get message
- [ ] Get topic messages (by page?)
- [ ] Get topic
- [ ] Get section topics
- [x] [Answer topic](docs/a801api.md#selfanswerTopic--message-location-)
- [x] [Create topic](docs/a801api.md#selfcreateTopic--title-message-location-)
- [x] [Create poll](docs/a801api.md#selfcreatePoll--title-message-pollResponses-location-settings-)
- [x] [Vote in a poll](docs/a801api.md#selfanswerPoll--option-location-pollId-)
- [x] [Edit message](docs/a801api.md#selfeditTopicAnswer--messageId-message-location-)
- [ ] Edit topic title
- [ ] Moderate message
- [ ] Move topic
- [ ] Postit topic
- [ ] Close topic
- [ ] Delete topic
- [ ] Undelete topic
- [ ] Restrict topic content
- [ ] Unrestrict topic content
- [ ] Message history logs
- [x] [Like post](docs/a801api.md#selflikeMessage--messageId-location-)
- [ ] Create section
- [ ] Delete section
- [ ] Edit section

## Report
- [x] (Report Message)[reportElement]
- [x] (Report Profile)[reportElement]
- [x] (Report Tribe)[reportElement]
- [x] (Report Private Message)[reportElement]
- [x] (Report Poll)[reportElement]


## Profile
- [ ] Change avatar
- [ ] Remove avatar
- [ ] Display online status
- [ ] Edit Profile
- [ ] Get player Profile
	
## Micepix
- [ ] Get micepix images (self) (by page?!)
- [ ] Get last micepix images hosted by users
- [ ] Post image
- [ ] Delete image

## Tribe
- [ ] Get tribe profile
- [ ] Get tribe members
- [ ] Get tribe history
- [ ] Report tribe
- [ ] Change logo
- [ ] Remove logo
- [ ] Edit profile
- [ ] Edit greeting message
- [ ] Edit Parameters

## Search
- [ ] Search

## Misc
- [ ] See friendlist
- [ ] See blacklist
- [ ] Add user as friend
- [ ] Add user in the blacklist
- [ ] Get user last posts
- [ ] Get user created topics
- [ ] Get dev-tracker messages
- [ ] Favorite topic
- [ ] Unfavorite topic
- [ ] Favorite tribe
- [ ] Unfavorite topic
- [ ] Get favorite topics
- [ ] Get favorite tribes
- [ ] List staff