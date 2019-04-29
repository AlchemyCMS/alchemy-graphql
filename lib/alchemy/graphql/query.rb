# frozen_string_literal: true

module Alchemy
  module GraphQL
    class Query < ::GraphQL::Schema::Object
      description "Query Alchemy Pages by id, name or url."

      include PageFields
      include ElementFields
    end
  end
end
