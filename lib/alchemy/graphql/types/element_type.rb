# frozen_string_literal: true

module Alchemy
  module GraphQL
    class ElementType < ::GraphQL::Schema::Object
      description "A Alchemy Element"

      field :id, ID, null: false
      field :page, Alchemy::GraphQL::PageType, null: false
      field :parent_element, self, null: true
      field :name, String, null: false

      field :contents, [Alchemy::GraphQL::ContentType], null: false do
        description "Filter elements contents by their name. " \
          "Either pass `only` to exclusively load Contents with this name or `except` to exclude these contents."
        argument :only, String, required: false
        argument :except, String, required: false
      end

      def contents(only: nil, except: nil)
        contents = object.contents
        if only
          contents.where(name: only)
        elsif except
          contents.where.not(name: except)
        else
          contents
        end
      end
    end
  end
end
