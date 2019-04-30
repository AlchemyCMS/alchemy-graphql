# frozen_string_literal: true

require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'

RSpec.describe Alchemy::GraphqlController do
  let(:page) { create(:alchemy_page) }

  describe 'execute' do
    context 'with a valid query' do
      it 'returns json response' do
        post '/graphql', params: {
          query: "{ page: alchemyPage(id: #{page.id}) { name } }"
        }
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json')
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'name')).to eq page.name
      end
    end

    context 'if query causes exception' do
      before do
        expect(Alchemy::GraphQL::Schema).to receive(:execute) do
          raise 'Boom!'
        end
      end

      context 'in development env' do
        before do
          expect(Rails.env).to receive(:development?).at_least(:once) do
            true
          end
        end

        it 'returns error details in JSON response' do
          post '/graphql'
          expect(response.status).to eq(500)
          json = JSON.parse(response.body)
          expect(json).to have_key 'error'
          expect(json['error']).to have_key 'message'
          expect(json['error']).to have_key 'backtrace'
          expect(json.dig('error', 'message')).to eq 'Boom!'
        end
      end

      context 'in any other env' do
        it 'raises error' do
          expect {
            post '/graphql'
          }.to raise_error('Boom!')
        end
      end
    end
  end
end
