# frozen_string_literal: true

module Alchemy
  module GraphQL
    class PageType < ::GraphQL::Schema::Object
      description "A Alchemy Page"

      field :id, ID, null: false
      field :name, String, null: false
      field :title, String, null: false
      field :urlname, String, null: false

      field :elements, [Alchemy::GraphQL::ElementType], null: false do
        description "Filter pages elements by their name. " \
          "Either pass `only` to exclusively load Elements with this name or `except` to exclude these elements."
        argument :only, String, required: false
        argument :except, String, required: false
      end

      def elements(only: nil, except: nil)
        elements = object.elements.available
        if only
          elements.where(name: only)
        elsif except
          elements.where.not(name: except)
        else
          elements
        end
      end
    end
  end
end
