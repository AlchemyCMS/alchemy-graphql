# frozen_string_literal: true

module Alchemy
  module GraphQL
    class ElementQuery < ::GraphQL::Schema::Object
      field :element, ElementType, null: true do
        description "Find Alchemy Element by name"
        argument :name, String, required: true
      end

      def element(name:)
        Alchemy::Element.find_by(name: name)
      end
    end
  end
end
