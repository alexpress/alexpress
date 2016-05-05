# alexpress
`express-js` line API for Amazon alexa custom skills.

## Installation
Install with npm

```
npm install alexa-express
```

## Examples
### Create app
```coffeescript
app = new require("alexa-express")()
```

### Handle `LaunchRequest`
```coffeescript
app.use "/launch", ( req, res, next ) ->
  res.tell "Welcome!"
```

### Built-in Intents

```coffeescript
# AMAZON.HelpIntent
app.use "/intent/amazon/help", ( req, res, next ) ->
  res.ask "How can I help you today?"
```


### Custom Intents

```coffeescript
# StartGameIntent
app.use "/intent/startGame", ( req, res, next ) ->
  res.ask "What do you want to play?"
```

## API

#### alexpress()

Creates an alexpress application. 

```cof
alexpress = require 'alexpress'
app = alexpress()
```

### Application

Created by calling `alexpress()`.

#### **Methods**

##### **app.get**

Returns the value of **name** app setting. For example:

```coff
app.get 'foo'
# => undefined

app.set 'foo', 'bar'
app.get 'foo'
# => 'bar'
```

##### **app.handler**

##### **app.set(name, value)**

Sets setting **name** to **value**. See [app settings](#appsettings).

##### **Application Settings**

| Property |  Type  | Description                              | Default                     |
| -------- | :----: | ---------------------------------------- | --------------------------- |
| `speech` | String | Directory for the application's speech templates. | `process.cwd() + '/speech'` |
| `format` | String | Default format to use for  `outputSpeech`  and `reprompt`. Acceptable values are: `SSML`, `PlainText`. | `PlainText`                 |

##### **app.use(path, function [, function...])**

Mounts the specified middleware function or functions at the specified path. If **path** is not specified, it defaults to `'/'`.

> A route will match any path that follows its path immediately with a “/”. For example: app.use('/apple', ...) will match “/apple”, “/apple/images”, “/apple/images/news”, and so on.
>

```coffeescript
app.use '/launch', (req, res, next) ->
	console.log "#{req.sessionId}"	
    #  'amzn1.echo-api.session.0000000-0000-0000-0000-00000000000'
    console.log "#{req.applicationId}"	
    # 'amzn1.echo-sdk-ams.app.000000-d0ed-0000-ad00-000000d00ebe'
    console.log "#{req.userId}"
    # 'amzn1.account.AM3B00000000000000000000000'
    next()
```

Since path defaults to “/”, middleware mounted without a path will be executed for every request to the app.

```coffeescript
# this will be executed for every request
app.use (req, res, next) ->
  console.log "#{Date.now()}"
  next()
```

Middleware functions are executed sequentially, therefore the order of inclusion is important.

```coffeescript
# this middleware will not allow the request to go beyond it
app.use (req, res, next) ->
  res.tell 'Hello World'
  
# requests will never reach this route
app.get '/', (req, res) ->
  res.tell 'Welcome'
```

**function** can be a middleware function, a series of middleware functions, an array of middleware functions, or a combination of all of them.

### Request

The **req** object represents the Alexa skill JSON request and has properties for the intent name, slots and other parameters.

#### Properties

##### **request.new** `{Boolean}`

A boolean value indicating whether this is a new session (from the JSON request sent by Alexa). Returns true for a new session or false for an existing session.

##### **request.sessionId** `{String}`

A string that represents a unique identifier per a user’s active session.

> A sessionId is consistent for multiple subsequent requests for a user and session. If the session ends for a user, then a new unique sessionId value is provided for subsequent requests for the same user.

##### **request.applicationId** {String}

This is used to verify that the request was intended for your service.

##### **request.userId** `{String}`

A string that represents a unique identifier for the user who made the request. The length of this identifier can vary, but is never more than 255 characters. The userId is automatically generated when a user enables the skill in the Alexa app. 

> Note that disabling and re-enabling a skill generates a new identifier. 

##### **request.userAccessToken** `{String|optional}`

A token identifying the user in another system. This is only provided if the user has successfully linked their account. 

##### **request.version** `{String}`

The version specifier for the request with the value defined as: “1.0”

##### **request.type** `{String}`

The type of request. Possible values include: `LaunchRequest`, `IntentRequest` and `SessionEndedRequest`.

##### **request.timestamp** `{String | ISO 8601}`

Provides the date and time when Alexa sent the request. Use this to verify that the request is current and not part of a “replay” attack. 

##### **request.requestId** `{String}`

Represents a unique identifier for the specific request.

##### **request.reason** `{String}`

Describes why the session ended. Available only for `SessionEndedRequest`. Possible values:

* USER_INITIATED: The user explicitly ended the session.
* ERROR: An error occurred that caused the session to end.
* EXCEEDED_MAX_REPROMPTS: The user either did not respond or responded with an utterance that did not match any of the intents defined in your voice interface.

#### Methods

##### request.session(name)

Returns the value of the session attribute with the key **name**.

> The attributes map is empty for requests where a new session has started with the attribute new set to true.

##### request.slot(name)

Returns the value of **name** from request's slots.

> Slots are map of key-value pairs that further describes what the user meant based on a predefined intent schema. Populated only for `IntentRequest` type.

### response

response.version

response.keepAlive

response.session

response.ssml

response.text

response.reprompt

response.ask

response.tell

response.send

response.render





