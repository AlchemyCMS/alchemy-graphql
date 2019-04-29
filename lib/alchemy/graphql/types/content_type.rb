# frozen_string_literal: true

module Alchemy
  module GraphQL
    class ContentType < ::GraphQL::Schema::Object
      description "A Alchemy Content"

      field :id, ID, null: false
      field :element, Alchemy::GraphQL::ElementType, null: false
      field :name, String, null: false
      field :ingredient, String, null: true

      def ingredient
        object.serialized_ingredient
      end
    end
  end
end
