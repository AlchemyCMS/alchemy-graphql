# frozen_string_literal: true

require 'graphql'
require 'alchemy_cms'

module Alchemy
  module GraphQL
    autoload :Schema,        'alchemy/graphql/schema'
    autoload :Query,         'alchemy/graphql/query'
    autoload :PageFields,    'alchemy/graphql/fields/page_fields'
    autoload :ElementFields, 'alchemy/graphql/fields/element_fields'
    autoload :PageType,      'alchemy/graphql/types/page_type'
    autoload :ElementType,   'alchemy/graphql/types/element_type'
    autoload :ContentType,   'alchemy/graphql/types/content_type'
  end
end

require_relative 'graphql/engine'
