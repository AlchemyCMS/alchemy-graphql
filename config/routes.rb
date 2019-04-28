# frozen_string_literal: true

Alchemy::GraphQL::Engine.routes.draw do
  post "/graphql", to: 'graphql#execute'
end
