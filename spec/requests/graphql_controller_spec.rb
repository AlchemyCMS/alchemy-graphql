# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alchemy::GraphqlController do
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
