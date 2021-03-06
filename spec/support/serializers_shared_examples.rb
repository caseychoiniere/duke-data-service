shared_context 'with auditor' do
  let(:auditor) { FactoryGirl.create(:user) }
end

shared_context 'with software_agent' do
  let(:software_agent) {
    FactoryGirl.create(:software_agent)
  }
end

shared_context 'creation' do |with_software_agent|
  if with_software_agent
    include_context 'with software_agent'
    let(:created) {
      creation_audit = resource.audits.where(action: 'create').take
      new_comment = creation_audit.comment
      agent_comment = { software_agent_id: software_agent.id }
      if new_comment
        new_comment.merge!(agent_comment)
      else
        new_comment = agent_comment
      end
      creation_audit.update_attributes!(comment: new_comment)
    }
  else
    let(:created) { true }
  end
end

shared_context 'with update' do |with_software_agent|
  include_context 'with auditor'
  let(:update_attribute) { 'updated_at' }
  let(:update_value) { DateTime.now }
  let(:update_action) { '/update' }

  if with_software_agent
    include_context 'with software_agent'
    let(:updated) {
      Audited.audit_class.as_user(auditor) do
        resource.update_attributes!(
          update_attribute => update_value,
          :audit_comment => {"action": update_action, "software_agent_id": software_agent.id }
        )
      end
     }
  else
    let(:updated) {
      Audited.audit_class.as_user(auditor) do
        resource.update_attributes!(
          update_attribute => update_value,
          :audit_comment => {"action": update_action}
        )
      end
     }
  end
end

shared_context 'with destroy' do |with_software_agent|
  include_context 'with auditor'
  let(:destroy_action) { '/destroy' }
  if with_software_agent
    include_context 'with software_agent'
    let(:deleted) {
      Audited.audit_class.as_user(auditor) do
        resource.audit_comment = {"action": destroy_action}
        if is_logically_deleted
          resource.update(is_deleted: true)
          resource.audits.last.update(comment: {action: 'DELETE', software_agent_id: software_agent.id})
        else
          resource.destroy
          resource.audits.last.update(comment: {action: 'DELETE', software_agent_id: software_agent.id})
        end
      end
    }
  else
    let(:deleted) {
      Audited.audit_class.as_user(auditor) do
        resource.audit_comment = {"action": destroy_action}
        if is_logically_deleted
          resource.update(is_deleted: true)
          resource.audits.last.update(comment: {action: 'DELETE'})
        else
          resource.destroy
        end
      end
    }
  end
end

shared_examples 'a json serializer' do
  let(:serializer) { described_class.new resource }
  subject { JSON.parse(serializer.to_json) }

  it 'should serialize to json' do
    expect{subject}.to_not raise_error
  end
end

shared_examples 'a serializer with a serialized audit' do
  # YOU MUST RUN THIS WITHIN A 'a json serializer' shared example block
  include_context 'with auditor'
  before do
    Audited.audit_class.as_user(auditor) do
      expect(resource).to be_persisted
    end
  end

  it 'should serialize with an audit' do
    is_expected.to have_key('audit')
    audit = subject['audit']
    expect(audit).to be
  end

  context 'at creation' do
    before do
      expect(created).to be_truthy
    end

    context 'with browser client' do
      include_context 'creation'

      it 'should report created_by and created_on' do
        is_expected.to have_key('audit')
        audit = subject['audit']
        expect(audit).to have_key("created_on")
        expect(audit).to have_key("created_by")
        creation_audit = resource.audits.where(action: "create").first
        expect(creation_audit).to be
        expect(DateTime.parse(audit["created_on"]).to_i).to be_within(1).of(creation_audit.created_at.to_i)
        if creation_audit.user_id
          creator = User.find(creation_audit.user_id)
          expected_creation_audit = {
            "id" => creator.id,
            "username" => creator.username,
            "full_name" => creator.display_name
          }
          expect(audit["created_by"]).to eq(expected_creation_audit)
        else
          expect(audit["created_by"]).not_to be
        end
      end
    end

    context 'with software_agent' do
      include_context 'creation', 'with software_agent'

      it 'should report agent in created_by' do
        is_expected.to have_key('audit')
        audit = subject['audit']
        expect(audit).to have_key("created_on")
        expect(audit).to have_key("created_by")
        creation_audit = resource.audits.where(action: "create").first
        expect(creation_audit).to be
        expect(DateTime.parse(audit["created_on"]).to_i).to be_within(1).of(creation_audit.created_at.to_i)
        if creation_audit.user_id
          creator = User.find(creation_audit.user_id)
          expected_creation_audit = {
            "id" => creator.id,
            "username" => creator.username,
            "full_name" => creator.display_name,
            "agent" => {
              "id" => software_agent.id,
              "name" => software_agent.name
            }
          }
          expect(audit["created_by"]).to eq(expected_creation_audit)
        else
          expect(audit["created_by"]).not_to be
        end
      end
    end
  end

  context 'for an updated resource' do
    before do
      expect(updated).to be_truthy
    end

    context 'with browser client' do
      include_context 'with update'

      it 'should report last_updated_on and last_updated_by' do
        is_expected.to have_key('audit')
        audit = subject['audit']
        expect(audit).to have_key("last_updated_on")
        expect(audit).to have_key("last_updated_by")
        last_update_audit = resource.audits.where(action: "update").last
        expect(last_update_audit).to be
        expect(DateTime.parse(audit["last_updated_on"]).to_i).to be_within(1).of(last_update_audit.created_at.to_i)
        updator = User.find(last_update_audit.user_id)
        expected_update_audit = {
          "id" => updator.id,
          "username" => updator.username,
          "full_name" => updator.display_name
        }
        expect(audit["last_updated_by"]).to eq(expected_update_audit)
      end
    end

    context 'with software_agent' do
      include_context 'with update', 'with software_agent'

      it 'should report agent in last_updated_by' do
        is_expected.to have_key('audit')
        audit = subject['audit']
        expect(audit).to have_key("last_updated_on")
        expect(audit).to have_key("last_updated_by")
        last_update_audit = resource.audits.where(action: "update").last
        expect(last_update_audit).to be
        expect(DateTime.parse(audit["last_updated_on"]).to_i).to be_within(1).of(last_update_audit.created_at.to_i)
        updator = User.find(last_update_audit.user_id)
        expected_update_audit = {
          "id" => updator.id,
          "username" => updator.username,
          "full_name" => updator.display_name,
          "agent" => {
            "id" => software_agent.id,
            "name" => software_agent.name
          }
        }
        expect(audit["last_updated_by"]).to eq(expected_update_audit)
      end
    end
  end

  context 'for a deleted resource' do
    before do
      expect(deleted).to be_truthy
    end

    context 'with browser client' do
      include_context 'with destroy'

      it 'should report deleted_on and deleted_by' do
        is_expected.to have_key('audit')
        audit = subject['audit']
        expect(audit).to have_key("deleted_on")
        expect(audit).to have_key("deleted_by")
        delete_audit = is_logically_deleted ?
          resource.audits.where(action: "update").where('comment @> ?', {action: 'DELETE'}.to_json).first :
          resource.audits.where(action: "destroy").first
        expect(delete_audit).to be
        expect(DateTime.parse(audit["deleted_on"]).to_i).to be_within(1).of(delete_audit.created_at.to_i)
        deleter = User.find(delete_audit.user_id)
        expected_deletion_audit = {
          "id" => deleter.id,
          "username" => deleter.username,
          "full_name" => deleter.display_name
        }
        expect(audit["deleted_by"]).to eq(expected_deletion_audit)
      end
    end

    context 'with software_agent' do
      include_context 'with destroy', 'with software_agent'

      it 'should report agent in deleted_by' do
        is_expected.to have_key('audit')
        audit = subject['audit']
        expect(audit).to have_key("deleted_on")
        expect(audit).to have_key("deleted_by")
        delete_audit = is_logically_deleted ?
          resource.audits.where(action: "update").where('comment @> ?', {action: 'DELETE'}.to_json).first :
          resource.audits.where(action: "destroy").first
        expect(delete_audit).to be
        expect(DateTime.parse(audit["deleted_on"]).to_i).to be_within(1).of(delete_audit.created_at.to_i)
        deleter = User.find(delete_audit.user_id)
        expected_deletion_audit = {
          "id" => deleter.id,
          "username" => deleter.username,
          "full_name" => deleter.display_name,
          "agent" => {
            "id" => software_agent.id,
            "name" => software_agent.name
          }
        }
        expect(audit["deleted_by"]).to eq(expected_deletion_audit)
      end
    end
  end
end

shared_examples 'a has_one association with' do |name, serialized_with, root: name|
  it "#{name} serialized using #{serialized_with}" do
    expect(described_class._associations).to have_key(name)
    expect(described_class._associations[name]).to be_a(ActiveModel::Serializer::Association::HasOne)
    expect(described_class._associations[name].serializer_from_options).to eq(serialized_with)
    expect(described_class._associations[name].embedded_key).to eq(root)
  end
end

shared_examples 'a has_many association with' do |name, serialized_with|
  it "#{name} serialized using #{serialized_with}" do
    expect(described_class._associations).to have_key(name)
    expect(described_class._associations[name]).to be_a(ActiveModel::Serializer::Association::HasMany)
    expect(described_class._associations[name].serializer_from_options).to eq(serialized_with)
  end
end
