# frozen_string_literal: true

module Alchemy
  module GraphQL
    class Engine < ::Rails::Engine
      isolate_namespace Alchemy
      engine_name 'alchemy_graphql'
    end
  end
end
