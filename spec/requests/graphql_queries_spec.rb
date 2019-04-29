require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'

RSpec.describe ':post /graphql' do
  let(:page) { create(:alchemy_page, :public) }

  context 'using alchemyPageByName' do
    it 'works' do
      post '/graphql', params: {
        query: %[{ page: alchemyPageByName(name: "#{page.name}") { name } }]
      }
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('page')
      expect(json.dig('data', 'page', 'name')).to eq page.name
    end
  end

  context 'using alchemyPageById' do
    it 'works' do
      post '/graphql', params: {
        query: %[{ page: alchemyPageById(id: "#{page.id}") { name } }]
      }
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('page')
      expect(json.dig('data', 'page', 'name')).to eq page.name
    end
  end

  context 'using alchemyPageByUrl' do
    it 'works' do
      post '/graphql', params: {
        query: %[{ page: alchemyPageByUrl(url: "#{page.urlname}") { name } }]
      }
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('page')
      expect(json.dig('data', 'page', 'name')).to eq page.name
    end
  end
end
