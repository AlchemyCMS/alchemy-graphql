# frozen_string_literal: true

module Alchemy
  module GraphQL
    module ElementFields
      def self.included(query)
        query.field :alchemy_element_by_id, ElementType, null: true do
          description "Find Alchemy Element by `id`"
          argument :id, ::GraphQL::Types::ID, required: true
        end

        query.field :alchemy_element_by_name, ElementType, null: true do
          description "Find Alchemy Element by name. " \
            "You need to pass an exact `name` unless you also pass `exactMatch: false`."
          argument :name, ::GraphQL::Types::String, required: true
          argument :exact_match, ::GraphQL::Types::Boolean, required: false, default_value: true
        end
      end

      def alchemy_element_by_id(id:)
        Alchemy::Element.find_by(id: id)
      end

      def alchemy_element_by_name(name:, exact_match: true)
        if exact_match
          Alchemy::Element.find_by(name: name)
        else
          Alchemy::Element.where("name LIKE ?", "%#{sanitize_sql_like(name)}%").first
        end
      end
    end
  end
end
