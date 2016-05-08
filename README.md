# alexpress
`alexpress` is an `express` like API for Amazon alexa custom skills.

[![Build Status](https://travis-ci.org/alexpress/alexpress.svg?branch=master)](https://travis-ci.org/alexpress/alexpress)

> The [Alexa Skills Kit](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit) enables you to give Alexa new abilities by building a cloud-based service. This service can be either a web service or an AWS [Lambda](http://aws.amazon.com/lambda/) function.

Unlike `express`, `alexpress` does not interface with http servers or html. Instead, `alexpress` uses with javascript objects as its input and output. You can use `alexpress` as with AWS lambda (via **application.lambda()**) or with a custom server (via **application.run()**).

`alexpress` borrows its middleware functionality from `connect`.

## Installation
Install with npm

```
npm install alexa-express
```

## Examples
##### Hello World
```coffeescript
app = require('alexpress')()

# respond to 'LaunchRequest'
app.use "/launch", ( req, res, next ) ->
  # render output speech in plain text format and close the session
  res.tell "Hello world"
 
# AWS lambda hookup
exports.handler = app.lambda
```

##### Built-in Intents

```coffeescript
# AMAZON.HelpIntent
app.use "/intent/amazon/help", ( req, res, next ) ->
  res.ask "How can I help you today?"
```


##### Custom Intents

```coffeescript
# StartGameIntent
app.use "/intent/startGame", ( req, res, next ) ->
  res.ask "What do you want to play?"
```

#### Cards

```coffeescript
app.use (req, res, next) ->
  res.simpleCard "some title", "some content"
  .send()
```

## About URLs

`application.use()` mounts middleware on an (optional) url .  `alexpress` generates urls from the underlying Alexa requests  (avaible as `request.url`) thus:

| Request Type                         | Url                     | Details                                  |
| ------------------------------------ | ----------------------- | ---------------------------------------- |
| `LaunchRequest`                      | `/launch`               |                                          |
| `SessionEndedRequest`                | `/sessionEnded`         |                                          |
| `IntentRequest` for built-in intents | `/intent/amazon/{name}` | `AMAZON.{Name}Intent`. e.g. `AMAZON.HelpIntent` maps to `/intent/amazon/help`. |
| `IntentRequest` for custom intents   | `/intent/{name}`        | `{Name}Intent`. Note that a trailing `Intent` in the intent's name is stripped out. e.g. `GetHoroscopeIntent` maps to `/intent/getHoroscope`. |

Note that urls are *not* case sensitive.

## API

##### **alexpress**()

Creates an alexpress application. 

```coffeescript
app = require('alexpress')()
```

### Application

Created by calling `alexpress()`.

#### Methods

##### **app.get**

Returns the value of **name**  [app settings](#application-settings). For example:

```coffeescript
app.get 'foo'
# => undefined

app.set 'foo', 'bar'
app.get 'foo'
# => 'bar'
```

##### **app.lambda(request, context, callback)**

Entry point invoked by AWS Lambda.

* **request**  `{Object}` contains Alexa request information as a JSON object. 
* **context** `{Object|null}` AWS Lambda uses this parameter to provide your handler the runtime information of the Lambda function that is executing.
* **callback** `Function(Error error,  Object response)` Invoked by AWS Lambda to return information to the caller.

`app.lambda` must be exported to AWS.

```coffeescript
 exports.handler = app.lambda
```

##### app.run(request, callback)

Runs the application. Call this in non AWS Lambda situations.

- **request**  is an `{Object}` containing the Alexa request.
- **callback** a `Function(Error error,  Object response)` used to return information to the caller.

##### **app.set(name, value)**

Sets setting **name** to **value**. See [app settings](#application-settings).

##### Application Settings

| Property     |  Type   | Description                              | Default                     |
| ------------ | :-----: | ---------------------------------------- | --------------------------- |
| `speech`     | String  | Directory for the application's speech templates. | `process.cwd() + '/speech'` |
| `format`     | String  | Default format to use for  `outputSpeech`  and `reprompt`. Acceptable values are: `SSML`, `PlainText`. | `PlainText`                 |
| `keep alive` | Boolean | Default value value for whether session should stay alive or end. | `false`                     |

##### **app.use(path, function [, function...])**
Utilize the given middleware `handle` to the given `route`, defaulting to '/'.
This "route" is the mount-point for the middleware, when given a
value other than '/' the middleware is only effective when that segment
is present in the request's pathname.

> A route will match any path that follows its path immediately with a “/”. For example: app.use('/apple', ...) will match “/apple”, “/apple/images”, “/apple/images/news”, and so on.

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

Middleware mounted without a path will be executed for every request to the app.

```coffeescript
# this will be executed for every request
app.use (req, res, next) ->
  console.log "#{Date.now()}"
  next()
```

Middleware functions are executed sequentially, therefore the order of
inclusion is important.

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

Returns the value of the session attribute with the key **name**. If **name** is not supplied, returns the full map of session attributes. The attributes map is empty for requests where a new session has started with the attribute new set to true. 

```coffeescript
app.use "/intent/getZodiacHoroscope", (req, res, next) ->
  console.log req.session "supportedHoroscopePeriods"	
  # => { "daily": true, "weekly": false, "monthly": false }
```

##### request.slot(name)

Returns the value of **name** from request's slots.

> Slots are map of key-value pairs that further describes what the user meant based on a predefined intent schema. Populated only for `IntentRequest` type.

```coffeescript
app.use "/intent/getZodiacHoroscope", (req, res, next) ->
  console.log req.slot "ZodiacSign"	
  # => 'virgo'
```

### Response

#### Properties

##### **response.version** `{String}`

The version specifier for the response with the value to be defined as: `“1.0”`

##### **response.locals** {Map}

Map of name, value pairs of locals for rendering templates.

#### Methods

##### response.keepAlive([alive])

Gets or sets a flag telling the system whether the session to stay active or end. 

> This is the inverse of `shouldEndSession` in Alexa's response object.

```coffeescript
# we need more information from the user so keep the session alive
app.use "/launch", (req, res, next) ->
	res.keepAlive(true).send("What's your zodiac sign?")
```
##### response.local(name [, value])

Gets or sets the value of **name** in the response's local map.

##### response.session([name, [value]])

Gets or sets the value of **name** in the response's session attribute map. 
```coffeescript
# Record the user's answer so that we have it when they respond
app.use "/intent/zodiacSign", (req, res, next) ->
	zodiacSign = req.slot 'ZodiacSign'
    res.session 'ZodiacSign', zodiacSign
	res.ask "Do you want your weekly or monthly horoscope?"
    
app.use "/intent/period", (req, res, next) ->
	zodiacSign = req.slot 'ZodiacSign'
	period = req.slot 'Period'
    horoscope = getHoroscope zodaicSign, period
	res.tell "Here's the #{period} horoscope for #{zodiacSign}: #{horoscope}"
```

##### response.ssml(speech[, prompt])

Sets the `outputSpeech` (and optionally, `reprompt` via **prompt** ) property of the response. **speech** and  **prompt** are strings containing text [marked up with SSML](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/speech-synthesis-markup-language-ssml-reference) to render to the user.  The format of the output (and reprompt) is set to `SSML`.
```coffeescript
# we need more information from the user so keep the session alive
app.use "/launch", (req, res, next) ->
	res.keepAlive(true).ssml("<speech>What's your zodiac sign</speech>")
```

##### response.plainText(speech[, prompt])

Sets the `outputSpeech` (and optionally, `reprompt` via **prompt** ) property of the response. **speech** and  **prompt** are strings containing text to render to the user.  The format of the output (and reprompt) is set to `PlainText`.
```coffeescript
app.set "format", "SSML"	# SSML format by default

# send this speech in plain text format
app.use "/launch", (req, res, next) ->
	res.keepAlive(true).plainText("<speech>What's your zodiac sign</speech>")
```

##### response.reprompt(prompt)

Sets the `reprompt` property of the response to **prompt**. The format of the **prompt** string must match the `reprompt` format which is set [separately](#outputformat).

```coffeescript
app.use "/launch", (req, res, next) ->
	res
    .keepAlive(true)
    .reprompt "I didn't get that. What's your zodiac sign?"
    .send "What's your zodiac sign?"
```

##### response.ask(speech[, prompt])

Sets the `outputSpeech` (and optionally, `reprompt) property of the response and sends the response. The session is set to stay alive.

```coffeescript
# keeps session alive 
app.use "/launch", (req, res, next) ->
	res.ask "I didn't get that. What's your zodiac sign?"
```
##### response.tell(speech[, prompt])

Sets the `outputSpeech` (and optionally, `reprompt) property of the response and sends the response. The session is set to end. 

```coffeescript
# close the session
app.use "/intent/getHoroscope", (req, res, next) ->
  	horoscope = getHoroscope req.slot "ZodiacSign"
	res.tell "Here's your horoscope: #{horoscope}"
```
##### response.send(speech[, prompt])

Sets the `outputSpeech` (and optionally, `reprompt) property of the response and sends the response. `keepAlive` must be set separetely prior to calling send(). 

```coffeescript
# send output speech and reprompt
app.use "/launch", (req, res, next) ->
	res
    .keepAlive(true)
    .send "What's your zodiac sign?", "I didn't get that. What's your zodiac sign?"
```
##### response.render(speech [,prompt] \[, locals])

##### response.renderAsk(speech [,prompt] \[, locals])

##### response.renderTell(speech [,prompt] \[, locals])

Renders template **speech** and sets the `outputSpeech` (and optionally, `reprompt) property of the response and sends the response. `Template files must be located in the directory specified by the  `speech` application setting. `renderAsk` and `renderTell` are `ask` and `tell` versions of `render`.

```coffeescript
# render speech from template 'horoscope'
app.use "/intent/getHoroscope", (req, res, next) ->
	horoscope = getHoroscope req.slot "ZodiacSign"
    res.locals.horoscope = horoscope
	res.render "horoscope"
```
Here's the speech template for the above example (uses the [doT](http://olado.github.io/doT/) template engine).

```
Here's your horoscope: {{=it.horoscope}}
```

Template context data is merged in the following order (last wins):

* **response.sessionAttributes**
* **response.locals**
* `locals` option to **response.render**

##### response.simpleCard(title, content)

##### response.standardCard(title, text [, smallImageUrl [, largeImageUrl]])

##### response.LinkAccountCard()

##### response.format([format]) <a name='outputformat'></a>

Gets or sets the format for `outputSpeech`. 

> The default format can be set via **app.set('format', format)** [application setting](#application-settings).

##### response.repromptFormat([format])

Gets or sets the format for `reprompt`. 

> The default format can be set via **app.set('format', format)** [application setting](#application-settings).

###Rendering Engine

`alexpress` uses the [doT](http://olado.github.io/doT/) rendering engine.

## Reference

### Sample Request JSON - Horoscope<a name="horoscope"></a>

```json
{
  "version": "1.0",
  "session": {
    "new": false,
    "sessionId": "amzn1.echo-api.session.0000000-0000-0000-0000-00000000000",
    "application": {
      "applicationId": "amzn1.echo-sdk-ams.app.000000-d0ed-0000-ad00-000000d00ebe"
    },
    "attributes": {
      "supportedHoroscopePeriods": {
        "daily": true,
        "weekly": false,
        "monthly": false
      }
    },
    "user": {
      "userId": "amzn1.account.AM3B00000000000000000000000"
    }
  },
  "request": {
    "type": "IntentRequest",
    "requestId": " amzn1.echo-api.request.0000000-0000-0000-0000-00000000000",
    "timestamp": "2015-05-13T12:34:56Z",
    "intent": {
      "name": "GetZodiacHoroscopeIntent",
      "slots": {
        "ZodiacSign": {
          "name": "ZodiacSign",
          "value": "virgo"
        }
      }
    }
  }
}
```


