require 'rails_helper'
require 'jwt'
require 'securerandom'

describe DDS::V1::ProjectsAPI do
  let(:json_headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json'} }
  let(:project) { FactoryGirl.create(:project) }
  let(:serialized_project) { ProjectSerializer.new(project).to_json }
  let(:project_stub) { FactoryGirl.build(:project) }

  describe 'Create a project' do
    it 'should store a project with the given payload' do
      payload = {
        name: project_stub.name,
        description: project_stub.description,
        pi_affiliate: {}
      }
      expect {
        post '/api/v1/projects', payload.to_json, json_headers
        expect(response.status).to eq(201)
        expect(response.body).to be
        expect(response.body).not_to eq('null')
      }.to change{Project.count}.by(1)

      response_json = JSON.parse(response.body)
      expect(response_json).to have_key('id')
      expect(response_json['id']).to be
      expect(response_json).to have_key('name')
      expect(response_json['name']).to eq(payload[:name])
      expect(response_json).to have_key('description')
      expect(response_json['description']).to eq(payload[:description])
      expect(response_json).to have_key('is_deleted')
      expect(response_json['is_deleted']).to eq(false)
    end
  end

  describe 'List projects' do
    it 'should return a list of projects the current user has view access on' do
      expect(project).to be_persisted
      get '/api/v1/projects', json_headers
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body).not_to eq('null')
      expect(response.body).to include(serialized_project)
    end
  end

  describe 'View project details' do
    it 'should return a json payload of the project associated with id' do
      get "/api/v1/projects/#{project.uuid}", json_headers
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body).not_to eq('null')
      expect(response.body).to include(serialized_project)
    end
  end

  describe 'Update a project' do
    it 'should update the project associated with id using the supplied payload' do
      payload = {
        name: project_stub.name,
        description: project_stub.description
      }
      project_uuid = project.uuid
      put "/api/v1/projects/#{project_uuid}", payload.to_json, json_headers
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body).not_to eq('null')

      response_json = JSON.parse(response.body)
      expect(response_json).to have_key('id')
      expect(response_json['id']).to eq(project_uuid)
      expect(response_json).to have_key('name')
      expect(response_json['name']).to eq(payload[:name])
      expect(response_json).to have_key('description')
      expect(response_json['description']).to eq(payload[:description])
      expect(response_json).to have_key('is_deleted')
      expect(response_json['is_deleted']).to eq(project.is_deleted)
      project.reload
      expect(project.uuid).to eq(project_uuid)
      expect(project.name).to eq(payload[:name])
      expect(project.description).to eq(payload[:description])
    end
  end

  describe 'Delete a project' do
    it 'logically deletes the project associated with id' do
      expect(project).to be_persisted
      expect {
        delete "/api/v1/projects/#{project.uuid}", json_headers
        expect(response.status).to eq(204)
        expect(response.body).to be
        expect(response.body).not_to eq('null')
      }.to_not change{Project.count}
      project.reload
      expect(project.is_deleted?).to be_truthy
    end
  end
end
