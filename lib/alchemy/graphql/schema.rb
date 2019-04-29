# frozen_string_literal: true

module Alchemy
  module GraphQL
    class Schema < ::GraphQL::Schema
      query(Alchemy::GraphQL::Query)
    end
  end
end
