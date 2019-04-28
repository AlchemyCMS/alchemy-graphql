# frozen_string_literal: true

module Alchemy
  module GraphQL
    class PageType < ::GraphQL::Schema::Object
      description "A Alchemy Page"

      field :id, ID, null: false
      field :name, String, null: false
      field :title, String, null: false
      field :urlname, String, null: false
      field :elements, [Alchemy::GraphQL::ElementType], null: false
    end
  end
end
