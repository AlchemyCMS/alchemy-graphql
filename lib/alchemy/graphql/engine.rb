# frozen_string_literal: true

module Alchemy
  module GraphQL
    class Engine < ::Rails::Engine
      isolate_namespace Alchemy
    end
  end
end
