# hubot-goodreads

fetch details about a book

See [`src/goodreads.coffee`](src/goodreads.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-goodreads --save`

Then add **hubot-goodreads** to your `external-scripts.json`:

```json
[
  "hubot-goodreads"
]
```

### Configuration
Set `HUBOT_GOODREADS_API_KEY` with the goodreads API Key

## Sample Interaction

```
user1>> hubot book mistborn
hubot>> prints mistborn details
```
