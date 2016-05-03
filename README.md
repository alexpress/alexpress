# alexa-express
Create Amazon Alexa apps with `expressjs`-like middleware.

## Installation
Install with npm

```
npm install alexa-express
```

## Example
### Create app
```coffeescript
app = new require("alexa-express")()
module.exports = app.handler
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
