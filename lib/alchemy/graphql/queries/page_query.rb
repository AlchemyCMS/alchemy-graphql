# frozen_string_literal: true

module Alchemy
  module GraphQL
    class PageQuery < ::GraphQL::Schema::Object
      include ActiveRecord::Sanitization::ClassMethods

      description "Query Alchemy Pages by id, name or url."

      field :alchemy_page_by_id, Alchemy::GraphQL::PageType, null: true do
        description "Find Alchemy Page by its id."
        argument :id, ID, required: true
      end

      field :alchemy_page_by_name, Alchemy::GraphQL::PageType, null: true do
        description "Find Alchemy Page by its name. " \
          "You need to pass an exact name unless you also pass exactMatch: false"
        argument :name, String, required: true
        argument :exact_match, Boolean, required: false, default_value: true
      end

      field :alchemy_page_by_url, Alchemy::GraphQL::PageType, null: true do
        description "Find Alchemy Page by its urlname. " \
          "You need to pass an exact urlname unless you also pass exactMatch: false"
        argument :url, String, required: true
        argument :exact_match, Boolean, required: false, default_value: true
      end

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
