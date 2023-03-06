require 'rails_helper'

RSpec.describe TinyUrlsController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new TinyUrl' do
        expect do
          post :create, params: { tiny_url: { full_url: 'https://www.google.com' } }
        end.to change(TinyUrl, :count).by(1)
      end

      it 'redirects to the created tiny_url' do
        post :create, params: { tiny_url: { full_url: 'https://www.google.com' } }
        expect(response).to redirect_to(TinyUrl.last)
      end

      it 'returns a json response with the new tiny_url' do
        post :create, params: { tiny_url: { full_url: 'https://www.google.com' } }, format: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      # curl -X POST -H "Content-Type: application/json" -d '{"tiny_url":{"full_url":"https://www.google.com"}}' http://localhost:3000/tiny_url.json
    end

    context 'with invalid params' do
      it "returns unprocessable entity" do
        post :create, params: { tiny_url: { full_url: 'invalid' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a json response with errors for the new tiny_url" do
        post :create, params: { tiny_url: { full_url: 'invalid' } }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      tiny_url = TinyUrl.create_url('https://www.google.com')
      get :show, params: { id: tiny_url.to_param }
      expect(response).to be_successful
    end

    it 'returns a json response with the tiny_url' do
      tiny_url = TinyUrl.create_url('https://www.google.com')
      get :show, params: { id: tiny_url.to_param }, format: :json
      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'GET #redirect' do
    it 'redirects to the full url' do
      tiny_url = TinyUrl.create_url('https://www.google.com')
      get :redirect, params: { short_url: tiny_url.short_url.split('/').last }
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to(tiny_url.full_url)
    end

    it 'returns a not found response' do
      get :redirect, params: { short_url: 'invalid' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
