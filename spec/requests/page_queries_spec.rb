require 'rails_helper'
require 'alchemy/test_support/factories/page_factory'

RSpec.describe 'Querying pages' do
  let(:page) { create(:alchemy_page, :public) }

  shared_examples 'a page query' do
    it 'returns page' do
      json = JSON.parse(response.body)
      expect(json).to have_key('data')
      expect(json['data']).to have_key('page')
      expect(json.dig('data', 'page', 'name')).to eq page.name
    end
  end

  describe 'by name' do
    context 'with exactMatch' do
      subject! do
        post '/graphql', params: {
          query: %[{ page: alchemyPage(name: "#{page.name}") { name } }]
        }
      end

      it_behaves_like 'a page query'
    end

    context 'without exactMatch' do
      let!(:page) do
        create(:alchemy_page, name: 'Contact Us', urlname: 'contact-us')
      end

      subject! do
        post '/graphql', params: {
          query: %[{ page: alchemyPage(name: "Contact", exactMatch: false) { name } }]
        }
      end

      it_behaves_like 'a page query'
    end

    context 'and by page_layout' do
      subject! do
        post '/graphql', params: {
          query: %[{
            page: alchemyPage(
              pageLayout: "#{page.page_layout}"
              name: "#{page.name}"
            ) { name }
          }]
        }
      end

      it_behaves_like 'a page query'
    end

    describe 'elements' do
      let(:page) do
        create(:alchemy_page, autogenerate_elements: true)
      end

      it 'can be included' do
        post '/graphql', params: {
          query: %[{
            page: alchemyPage(name: "#{page.name}") {
              elements {
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
          },
          {
            "name" => "article"
          }
        ])
      end

      describe 'can be filtered' do
        it 'by only' do
          post '/graphql', params: {
            query: %[{
              page: alchemyPage(name: "#{page.name}") {
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
              page: alchemyPage(name: "#{page.name}") {
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
  end

  describe 'by id' do
    subject! do
      post '/graphql', params: {
        query: %[{ page: alchemyPage(id: "#{page.id}") { name } }]
      }
    end

    it_behaves_like 'a page query'
  end

  describe 'by urlname' do
    describe 'with exactMatch' do
      subject! do
        post '/graphql', params: {
          query: %[{ page: alchemyPage(urlname: "#{page.urlname}") { name } }]
        }
      end

      it_behaves_like 'a page query'
    end

    describe 'without exactMatch' do
      let!(:page) do
        create(:alchemy_page, name: 'Contact Us', urlname: 'contact-us')
      end

      subject! do
        post '/graphql', params: {
          query: %[{ page: alchemyPage(urlname: "contact", exactMatch: false) { name } }]
        }
      end

      it_behaves_like 'a page query'
    end
  end

  describe 'by page_layout' do
    describe 'with exactMatch' do
      subject! do
        post '/graphql', params: {
          query: %[{ page: alchemyPage(pageLayout: "#{page.page_layout}") { name } }]
        }
      end

      it_behaves_like 'a page query'
    end

    describe 'without exactMatch' do
      let!(:page) do
        create(:alchemy_page, page_layout: 'standard')
      end

      subject! do
        post '/graphql', params: {
          query: %[{ page: alchemyPage(pageLayout: "stand", exactMatch: false) { name } }]
        }
      end

      it_behaves_like 'a page query'
    end
  end
end
