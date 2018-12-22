# Examples

- To run the examples, a file named `account` is necessary.
- **It must contain a valid username / password.**

###### A sub login is necessary in `message_n_topic.lua` because of the `Fromage.likeMessage` method

```
return {
	username = "Test#0000",
	password = "12345",
	sub_username = "Test2#0000",
	sub_password = "678910"
}
```