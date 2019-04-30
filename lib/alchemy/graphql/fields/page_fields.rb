# frozen_string_literal: true

module Alchemy
  module GraphQL
    module PageFields
      def self.included(query)
        query.field :alchemy_page, Alchemy::GraphQL::PageType, null: true do
          description "Find Alchemy Page by any of its attributes (id, name, urlname, page_layout)."
          argument :id, ::GraphQL::Types::ID, required: false
          argument :name, ::GraphQL::Types::String, required: false
          argument :urlname, ::GraphQL::Types::String, required: false
          argument :page_layout, ::GraphQL::Types::String, required: false
          argument :exact_match, ::GraphQL::Types::Boolean, required: false, default_value: true
        end
      end

      include ActiveRecord::Sanitization::ClassMethods

      def alchemy_page(attributes = {})
        exact_match = attributes.delete(:exact_match)
        if exact_match
          Alchemy::Page.find_by(attributes)
        else
          conditions = attributes.flat_map do |attribute, value|
            ["#{attribute} LIKE ?", "%#{sanitize_sql_like(value)}%"]
          end
          Alchemy::Page.where(conditions).first
        end
      end
    end
  end
end
