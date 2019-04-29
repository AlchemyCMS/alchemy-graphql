[![CircleCI](https://circleci.com/gh/AlchemyCMS/alchemy-graphql/tree/master.svg?style=svg)](https://circleci.com/gh/AlchemyCMS/alchemy-graphql/tree/master)
[![Maintainability](https://api.codeclimate.com/v1/badges/d5ccbf59314f813ce195/maintainability)](https://codeclimate.com/github/AlchemyCMS/alchemy-graphql/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/d5ccbf59314f813ce195/test_coverage)](https://codeclimate.com/github/AlchemyCMS/alchemy-graphql/test_coverage)

# AlchemyCMS GraphQL API
Add a GraphQL API to your AlchemyCMS powered site.

**WARNING: This is in an early state and changes to the API may be applied without any further announcement!**

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'alchemy-graphql', github: 'AlchemyCMS/alchemy-graphql'
```

And then execute:
```bash
$ bundle
```

## Setup

There are two ways of setting up the GraphQL API for AlchemyCMS.

### Use the provided GraphQL endpoint

This is the easiest way of setting up the AlchemyCMS GraphQL API. Recommended for apps not having a GraphQL API or stand alone Alchemy installations.

```rb
# config/routes
Rails.application.routes.draw do
  mount Alchemy::GraphQL::Engine => '/'
  mount Alchemy::Engine => '/'
  ...
end
```

_NOTE:_ It is necessary to mount the `Alchemy::GraphQL::Engine` before mounting the `Alchemy::Engine` otherwise Alchemys catch all route will make your GraphQL endpoint unreachable.

Your GraphQL endpoint will be available at `/graphql`.

_TIP:_ Mounting the engine at a different path (ie `/cms`) will prefix the GraphQL endpoint with that path (ie. `/cms/graphql`)

### Build your own GraphQL endpoint

This is the more advanced way of setting up the AlchemyCMS GraphQL API.
It is recommended for apps already having a GraphQL API or people who want to build their own schema.

Include one or all of the [provided fields](https://github.com/AlchemyCMS/alchemy-graphql/tree/master/lib/alchemy/graphql/fields/) in your `GraphQL::Schema::Object` class.

```rb
# app/graphql/query.rb
class GraphQL::Query < ::GraphQL::Schema::Object
  field :my_field, String, null: true
  include Alchemy::GraphQL::PageFields
end
```

## Usage

We recommend using [GraphiQL](https://github.com/rmosolgo/graphiql-rails) in your app to have an interactive API explorer in your browser.

Nevertheless here are some example queries.

### Find an Alchemy page by its name

```graphql
query {
  page: alchemyPageByName(name: "A page") {
    name
    elements(only: "article") {
      contents(only: "headline") {
        ingredient
      }
    }
  }
}
```

will return

```json
{
  "data": {
    "page": {
      "name": "A page",
      "elements": [
        {
          "contents": [
            {
              "ingredient": "My headline"
            }
          ]
        }
      ]
    }
  }
}
```

It is also possible to find pages by a name match instead of an exact name.

```graphql
query {
  page: alchemyPageByName(name: "Contact", exactMatch: false) {
    name
  }
}
```

will return

```json
{
  "data": {
    "page": {
      "name": "Contact us"
    }
  }
}
```

### Find an Alchemy page by its url

```graphql
query {
  page: alchemyPageByUrl(url: "a-page") {
    elements {
      contents {
        ingredient
      }
    }
  }
}
```

will return

```json
{
  "data": {
    "page": {
      "elements": [
        {
          "contents": [
            {
              "ingredient": "My headline"
            },
            {
              "ingredient": "<p>My paragraph.</p>"
            }
          ]
        }
      ]
    }
  }
}
```

It is also possible to find pages by an url match instead of an exact url.

```graphql
query {
  page: alchemyPageByUrl(url: "contact", exactMatch: false) {
    urlname
  }
}
```

will return

```json
{
  "data": {
    "page": {
      "urlname": "contact-us"
    }
  }
}
```

### Find an Alchemy element by its name

```graphql
query {
  element: alchemyElementByName(name: "article") {
    name
    contents(only: "headline") {
      ingredient
    }
  }
}
```

will return

```json
{
  "data": {
    "element": {
      "name": "article",
      "contents": [
        {
          "ingredient": "My headline"
        }
      ]
    }
  }
}
```

It is also possible to find elements by a name match instead of an exact name.

```graphql
query {
  element: alchemyElementByName(name: 'head', exactMatch: false) {
    name
  }
}
```

will return

```json
{
  "data": {
    "element": {
      "name": "header"
    }
  }
}
```

## License

The gem is available as open source under the terms of the [BSD-3-Clause License](https://opensource.org/licenses/BSD-3-Clause).
