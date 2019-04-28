# frozen_string_literal: true

require 'graphql'
require 'alchemy_cms'

module Alchemy
  module GraphQL
    autoload :PageQuery,    'alchemy/graphql/queries/page_query'
    autoload :ElementQuery, 'alchemy/graphql/queries/element_query'
    autoload :PageType,     'alchemy/graphql/types/page_type'
    autoload :ElementType,  'alchemy/graphql/types/element_type'
    autoload :ContentType,  'alchemy/graphql/types/content_type'
  end
end

require_relative 'graphql/engine'
