# frozen_string_literal: true

module Alchemy
  module GraphQL
    module PageFields
      def self.included(query)
        query.field :alchemy_page_by_id, Alchemy::GraphQL::PageType, null: true do
          description "Find Alchemy Page by its id."
          argument :id, ::GraphQL::Types::ID, required: true
        end

        query.field :alchemy_page_by_name, Alchemy::GraphQL::PageType, null: true do
          description "Find Alchemy Page by its name. " \
            "You need to pass an exact name unless you also pass exactMatch: false"
          argument :name, ::GraphQL::Types::String, required: true
          argument :exact_match, ::GraphQL::Types::Boolean, required: false, default_value: true
        end

        query.field :alchemy_page_by_url, Alchemy::GraphQL::PageType, null: true do
          description "Find Alchemy Page by its urlname. " \
            "You need to pass an exact urlname unless you also pass exactMatch: false"
          argument :url, ::GraphQL::Types::String, required: true
          argument :exact_match, ::GraphQL::Types::Boolean, required: false, default_value: true
        end
      end

      include ActiveRecord::Sanitization::ClassMethods

      def alchemy_page_by_id(id:)
        Alchemy::Page.find_by(id: id)
      end

      def alchemy_page_by_name(name:, exact_match: true)
        if exact_match
          Alchemy::Page.find_by(name: name)
        else
          Alchemy::Page.where("name LIKE ?", "%#{sanitize_sql_like(name)}%").first
        end
      end

      def alchemy_page_by_url(url:, exact_match: true)
        if exact_match
          Alchemy::Page.find_by(urlname: url)
        else
          Alchemy::Page.where("urlname LIKE ?", "%#{sanitize_sql_like(url)}%").first
        end
      end
    end
  end
end
