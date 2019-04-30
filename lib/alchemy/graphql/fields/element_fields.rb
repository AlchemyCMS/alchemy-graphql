# frozen_string_literal: true

module Alchemy
  module GraphQL
    module ElementFields
      def self.included(query)
        query.field :alchemy_element, ElementType, null: true do
          description "Find Alchemy Element by any of its attributes (id, name)."
          argument :id, ::GraphQL::Types::ID, required: false
          argument :name, ::GraphQL::Types::String, required: false
          argument :exact_match, ::GraphQL::Types::Boolean, required: false, default_value: true
        end
      end

      def alchemy_element(attributes = {})
        exact_match = attributes.delete(:exact_match)
        if exact_match
          Alchemy::Element.find_by(attributes)
        else
          conditions = attributes.flat_map do |attribute, value|
            ["#{attribute} LIKE ?", "%#{sanitize_sql_like(value)}%"]
          end
          Alchemy::Element.where(conditions).first
        end
      end
    end
  end
end
