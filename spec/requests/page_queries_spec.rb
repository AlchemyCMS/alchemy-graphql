require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'

RSpec.describe 'Querying pages' do
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

    describe 'elements can be filtered' do
      let(:page) do
        create(:alchemy_page, autogenerate_elements: true)
      end

      it 'by only' do
        post '/graphql', params: {
          query: %[{
            page: alchemyPageByName(name: "#{page.name}") {
              elements(only: "article") {
                name
              }
            }
          }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'elements')).to match_array([
          {
            "name" => "article"
          }
        ])
      end

      it 'by except' do
        post '/graphql', params: {
          query: %[{
            page: alchemyPageByName(name: "#{page.name}") {
              elements(except: "article") {
                name
              }
            }
          }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('page')
        expect(json.dig('data', 'page', 'elements')).to match_array([
          {
            "name" => "header"
          }
        ])
      end
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
