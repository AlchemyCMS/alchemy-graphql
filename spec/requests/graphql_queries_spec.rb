require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'
require 'alchemy/test_support/factories/element_factory'

RSpec.describe ':post /graphql' do
  describe 'PageFields' do
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

  describe 'ElementFields' do
    let(:element) { create(:alchemy_element) }

    context 'using alchemyElementByName' do
      it 'works' do
        post '/graphql', params: {
          query: %[{ element: alchemyElementByName(name: "#{element.name}") { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('element')
        expect(json.dig('data', 'element', 'name')).to eq element.name
      end
    end

    context 'using alchemyElementById' do
      it 'works' do
        post '/graphql', params: {
          query: %[{ element: alchemyElementById(id: "#{element.id}") { name } }]
        }
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('element')
        expect(json.dig('data', 'element', 'name')).to eq element.name
      end
    end
  end
end
