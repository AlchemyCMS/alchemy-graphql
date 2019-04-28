# frozen_string_literal: true

require 'alchemy/graphql/queries/page_query'

module Alchemy
  module GraphQL
    class Schema < ::GraphQL::Schema
      query(Alchemy::GraphQL::PageQuery)
    end
  end
end
