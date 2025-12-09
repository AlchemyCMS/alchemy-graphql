# CLAUDE.md - AlchemyCMS GraphQL API

## Project Overview

**alchemy-graphql** is a Ruby gem that provides a GraphQL API for AlchemyCMS-powered websites. It's a Rails engine that exposes Alchemy pages, elements, and content through a GraphQL interface.

- **Repository**: https://github.com/AlchemyCMS/alchemy-graphql
- **Version**: 0.1.0
- **License**: BSD-3-Clause
- **Author**: Thomas von Deyen
- **Status**: Early development (API may change without notice)

### Key Dependencies
- **alchemy_cms**: >= 4.2.0.rc1, < 6
- **graphql**: ~> 1.9
- **Ruby**: 2.7+ (based on CI configuration)
- **Rails**: Engine-based architecture

## Repository Structure

```
alchemy-graphql/
├── app/
│   └── controllers/
│       └── alchemy/
│           └── graphql_controller.rb    # Controller for GraphQL endpoint
├── config/
│   └── routes.rb                        # Engine routes
├── lib/
│   ├── alchemy-graphql.rb              # Main entry point
│   └── alchemy/
│       └── graphql/
│           ├── engine.rb                # Rails engine definition
│           ├── schema.rb                # GraphQL schema
│           ├── query.rb                 # Root query object
│           ├── version.rb               # Gem version
│           ├── fields/
│           │   ├── page_fields.rb       # Page query fields
│           │   └── element_fields.rb    # Element query fields
│           └── types/
│               ├── page_type.rb         # Page GraphQL type
│               ├── element_type.rb      # Element GraphQL type
│               └── content_type.rb      # Content GraphQL type
├── spec/
│   ├── dummy/                           # Rails dummy app for testing
│   ├── fields/                          # Spec tests for fields
│   ├── requests/                        # Integration tests
│   └── support/                         # Test helpers
└── .github/
    └── workflows/
        └── ci.yml                       # GitHub Actions CI
```

## Architecture

### Rails Engine Pattern
This gem is built as a Rails Engine (`Alchemy::GraphQL::Engine`), which allows it to be mounted into a host Rails application. The engine provides:
- Routes for the GraphQL endpoint
- Controllers for handling GraphQL queries
- Auto-loading of GraphQL types and fields

### Module Organization
The codebase follows a clean module structure under `Alchemy::GraphQL`:

```ruby
Alchemy::GraphQL
├── Schema          # GraphQL schema definition
├── Query           # Root query object
├── PageFields      # Mixin for page queries
├── ElementFields   # Mixin for element queries
├── PageType        # Page GraphQL type
├── ElementType     # Element GraphQL type
└── ContentType     # Content GraphQL type
```

## Key Components

### 1. GraphQL Schema (`lib/alchemy/graphql/schema.rb`)
- Defines the main GraphQL schema
- Uses `Alchemy::GraphQL::Query` as the root query type
- Simple, straightforward implementation

### 2. Query Object (`lib/alchemy/graphql/query.rb`)
- Root query object that includes field modules
- Includes `PageFields` and `ElementFields` mixins
- Provides description for API consumers

### 3. Field Modules

#### PageFields (`lib/alchemy/graphql/fields/page_fields.rb`)
- Provides `alchemyPage` query field
- Supports finding pages by: id, name, urlname, page_layout
- Implements `exactMatch` parameter for fuzzy searching using SQL LIKE
- Uses `ActiveRecord::Sanitization::ClassMethods` for SQL safety

#### ElementFields (`lib/alchemy/graphql/fields/element_fields.rb`)
- Provides `alchemyElements` (collection) and `alchemyElement` (single) query fields
- Supports filtering with `only` and `except` parameters
- Implements `exactMatch` for fuzzy searching
- Uses `Alchemy::Element.available` scope to filter elements

### 4. GraphQL Types

#### PageType (`lib/alchemy/graphql/types/page_type.rb`)
- Exposes: id, name, title, urlname
- Has `elements` field with filtering (only/except)
- Elements are filtered using `object.elements.available`

#### ElementType (`lib/alchemy/graphql/types/element_type.rb`)
- Exposes: id, name, page, parent_element
- Has `contents` field with filtering (only/except)
- Self-referential for nested elements

#### ContentType (`lib/alchemy/graphql/types/content_type.rb`)
- Exposes: id, name, element, ingredient
- Uses `object.serialized_ingredient` for ingredient field
- Minimal, focused type definition

### 5. Controller (`app/controllers/alchemy/graphql_controller.rb`)
- Inherits from `ApplicationController`
- Includes Alchemy controller actions and abilities
- Executes GraphQL queries via `Alchemy::GraphQL::Schema.execute`
- Provides context with `current_alchemy_user` and `current_ability`
- Development-mode error handling with detailed backtraces

## Development Workflow

### Setup
1. Clone the repository
2. Run `bundle install`
3. The dummy app is in `spec/dummy/` for testing

### Running Tests
```bash
bundle exec rspec
```

Tests are organized by:
- `spec/fields/` - Tests for field modules
- `spec/requests/` - Integration tests for the GraphQL controller
- `spec/dummy/` - Rails dummy application for testing

### Test Configuration
- **Framework**: RSpec Rails (~> 3.8)
- **Fixtures**: Factory Bot Rails (~> 5.0)
- **Coverage**: SimpleCov (~> 0.17.1) with Code Climate integration
- **Database**: PostgreSQL (CI), SQLite3/MySQL2 supported for local dev
- **Format**: Document format (`.rspec`)
- **Transactions**: Enabled (`use_transactional_fixtures = true`)

### Continuous Integration
- **Platform**: GitHub Actions
- **Ruby Version**: 2.7
- **Database**: PostgreSQL 11
- **Coverage**: Code Climate integration
- **Artifacts**: Screenshots uploaded on failure

## Code Conventions

### 1. Frozen String Literals
All Ruby files use `# frozen_string_literal: true` at the top.

### 2. Module Structure
- Use `autoload` for lazy loading in main module file
- Organize code by responsibility (fields, types, queries)
- Follow Rails Engine conventions for namespace isolation

### 3. GraphQL Patterns

#### Field Definition Pattern
```ruby
def self.included(query)
  query.field :field_name, ReturnType, null: true do
    description "Field description"
    argument :arg_name, ::GraphQL::Types::String, required: false
  end
end
```

#### Resolver Pattern
- Define resolver methods matching field names
- Use keyword arguments for GraphQL arguments
- Return ActiveRecord relations or objects directly

#### Filtering Pattern
```ruby
def field_name(only: nil, except: nil)
  items = base_scope
  if only
    items.where(name: only)
  elsif except
    items.where.not(name: except)
  else
    items
  end
end
```

### 4. Security Considerations
- Always use `sanitize_sql_like` when building LIKE queries
- Include `ActiveRecord::Sanitization::ClassMethods` for SQL safety
- Context includes user authentication and authorization (Alchemy abilities)

### 5. Naming Conventions
- GraphQL fields prefixed with `alchemy` (e.g., `alchemyPage`, `alchemyElement`)
- Type classes end with `Type` suffix
- Field modules end with `Fields` suffix
- Use snake_case for arguments, camelCase converted automatically by GraphQL

## Testing Patterns

### 1. Factory Pattern
```ruby
let(:page) { create(:alchemy_page, :public) }
```
Uses Alchemy's test support factories (`:alchemy_page`, etc.)

### 2. GraphQL Query Testing
```ruby
subject(:json) do
  Alchemy::GraphQL::Schema.execute(query).to_h
end

let(:query) do
  %[{ page: alchemyPage(name: "#{page.name}") { name } }]
end
```

### 3. Shared Examples
```ruby
shared_examples 'a page query' do
  it 'returns page' do
    expect(json).to have_key('data')
    expect(json['data']).to have_key('page')
    expect(json.dig('data', 'page', 'name')).to eq page.name
  end
end
```

### 4. Test Structure
- Use `describe` for organizing by query type
- Use `context` for different scenarios (with/without exactMatch, etc.)
- Use shared examples for common assertions
- Test both exact and fuzzy matching

## Important Implementation Details

### 1. Fuzzy Matching
The `exactMatch` parameter (default: true) controls search behavior:
- `true`: Uses `Model.find_by(attributes)`
- `false`: Uses SQL LIKE with wildcard wrapping (`%value%`)

### 2. Available Elements Scope
All element queries use `.available` scope to ensure only appropriate elements are returned:
```ruby
elements = Alchemy::Element.available
```

### 3. Context Integration
The GraphQL controller provides Alchemy-specific context:
- `current_user`: Current Alchemy user
- `current_ability`: CanCanCan ability object for authorization

### 4. Ingredient Serialization
Content ingredients use `serialized_ingredient` method:
```ruby
def ingredient
  object.serialized_ingredient
end
```

## Integration Approaches

### Option 1: Mount the Engine (Recommended for Standalone)
```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Alchemy::GraphQL::Engine => '/'  # Must be before Alchemy::Engine
  mount Alchemy::Engine => '/'
end
```
Creates endpoint at `/graphql`

### Option 2: Include Fields in Existing Schema
```ruby
# app/graphql/query.rb
class GraphQL::Query < ::GraphQL::Schema::Object
  include Alchemy::GraphQL::PageFields
  include Alchemy::GraphQL::ElementFields
  # Your other fields...
end
```

## API Usage Examples

### Find Page by Name
```graphql
query {
  page: alchemyPage(name: "Contact", exactMatch: false) {
    name
    title
    urlname
    elements(only: "article") {
      name
      contents(only: "headline") {
        ingredient
      }
    }
  }
}
```

### Find Elements
```graphql
query {
  elements: alchemyElements(only: "article") {
    name
    contents {
      name
      ingredient
    }
  }
}
```

### Combined Query
```graphql
query {
  page: alchemyPage(
    name: "Home",
    pageLayout: "standard",
    exactMatch: true
  ) {
    name
    elements(except: "footer") {
      name
      parentElement {
        name
      }
      contents {
        name
        ingredient
      }
    }
  }
}
```

## Common Pitfalls & Best Practices

### 1. Route Mounting Order
Always mount `Alchemy::GraphQL::Engine` BEFORE `Alchemy::Engine` to avoid route conflicts. Alchemy has a catch-all route that will prevent the GraphQL endpoint from being reachable.

### 2. SQL Injection Prevention
When implementing fuzzy search, always use `sanitize_sql_like`:
```ruby
conditions = attributes.flat_map do |attribute, value|
  ["#{attribute} LIKE ?", "%#{sanitize_sql_like(value)}%"]
end
```

### 3. Available vs All Elements
Always use `.available` scope when querying elements to respect Alchemy's visibility rules:
```ruby
elements = object.elements.available  # Good
elements = object.elements            # May return hidden elements
```

### 4. Context Usage
The GraphQL context provides authentication/authorization. When adding custom fields, use the context for permission checks:
```ruby
def my_custom_field
  return nil unless context[:current_ability].can?(:read, object)
  object.sensitive_data
end
```

## Development Guidelines for AI Assistants

### When Adding New Features
1. **Follow the field module pattern** - Create mixins that can be included in query objects
2. **Maintain consistency** - Prefix fields with `alchemy`, use similar argument patterns
3. **Write tests first** - Add specs in `spec/fields/` following existing patterns
4. **Update dummy config** - If adding new element/page types, update `spec/dummy/config/alchemy/`
5. **Consider security** - Always sanitize user input, respect Alchemy abilities

### When Fixing Bugs
1. **Add a failing test** - Reproduce the bug in specs
2. **Minimal changes** - Keep fixes focused and minimal
3. **Check SQL safety** - Ensure no SQL injection vulnerabilities
4. **Test multiple scenarios** - Test with exact/fuzzy matching, filters, etc.

### When Refactoring
1. **Maintain API compatibility** - This is a public API, breaking changes affect users
2. **Run full test suite** - Ensure all tests pass
3. **Update documentation** - Keep README.md and this file in sync
4. **Check deprecation notices** - Mark deprecated features properly

### Code Style
- Use RuboCop standard style (if configured)
- Keep methods small and focused
- Prefer descriptive names over comments
- Use keyword arguments for optional parameters
- Follow GraphQL Ruby best practices

## Database Compatibility

The gem supports multiple databases:
- **PostgreSQL** (CI default)
- **MySQL 2** (via `mysql2` gem)
- **SQLite 3** (default for local development)

Set via `DB` environment variable: `DB=postgresql`, `DB=mysql`, or `DB=sqlite` (default)

## Debugging Tips

### Enable GraphiQL
Add to your Gemfile:
```ruby
gem 'graphiql-rails', '~> 1.7'
```

### Development Error Handling
The controller provides detailed errors in development mode:
- Full error messages
- Complete backtraces
- JSON response format

### Test Debugging
- Screenshots saved to `spec/dummy/tmp/screenshots` on failure
- Uploaded as CI artifacts
- Use `pry-byebug` for interactive debugging

## Related Documentation

- [AlchemyCMS Documentation](https://guides.alchemy-cms.com/)
- [GraphQL Ruby Documentation](https://graphql-ruby.org/)
- [Online Demo](https://demo.alchemy-cms.com/graphiql)
- [Repository Issues](https://github.com/AlchemyCMS/alchemy-graphql/issues)

## Version History

- **0.1.0** - Initial release
  - Basic Page, Element, and Content queries
  - Exact and fuzzy matching
  - Filter support for elements and contents
  - Alchemy 5.0 compatibility

---

*Last updated: 2025-12-09*
*Based on commit: 7d54f98*
