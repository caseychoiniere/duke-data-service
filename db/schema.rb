# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160329164550) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "affiliations", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "project_id"
    t.uuid     "user_id"
    t.string   "project_role_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "api_keys", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "software_agent_id"
    t.string   "key"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "audits", force: :cascade do |t|
    t.uuid     "auditable_id"
    t.string   "auditable_type"
    t.uuid     "associated_id"
    t.string   "associated_type"
    t.uuid     "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.jsonb    "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["comment"], name: "index_audits_on_comment", using: :gin
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "auth_roles", id: false, force: :cascade do |t|
    t.string   "id",                            null: false
    t.string   "name"
    t.string   "description"
    t.jsonb    "permissions"
    t.jsonb    "contexts"
    t.boolean  "is_deprecated", default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "auth_roles", ["contexts"], name: "index_auth_roles_on_contexts", using: :gin
  add_index "auth_roles", ["permissions"], name: "index_auth_roles_on_permissions", using: :gin

  create_table "authentication_services", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "service_id"
    t.string   "base_uri"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chunks", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "upload_id"
    t.integer  "number"
    t.integer  "size"
    t.string   "fingerprint_value"
    t.string   "fingerprint_algorithm"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "containers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.uuid     "parent_id"
    t.uuid     "project_id"
    t.uuid     "creator_id"
    t.uuid     "upload_id"
    t.boolean  "is_deleted", default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "label"
  end

  create_table "file_versions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "data_file_id"
    t.integer  "version_number"
    t.string   "label"
    t.uuid     "upload_id"
    t.boolean  "is_deleted",     default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "project_permissions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "project_id"
    t.uuid     "user_id"
    t.string   "auth_role_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "project_roles", id: false, force: :cascade do |t|
    t.string   "id",                            null: false
    t.string   "name"
    t.string   "description"
    t.boolean  "is_deprecated", default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "projects", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.uuid     "creator_id"
    t.string   "etag"
    t.boolean  "is_deleted",  default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "software_agents", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.uuid     "creator_id"
    t.string   "repo_url"
    t.boolean  "is_deleted",  default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "storage_providers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "display_name"
    t.string   "description"
    t.string   "name"
    t.string   "url_root"
    t.string   "provider_version"
    t.string   "auth_uri"
    t.string   "service_user"
    t.string   "service_pass"
    t.string   "primary_key"
    t.string   "secondary_key"
    t.boolean  "is_deprecated",        default: false, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "chunk_hash_algorithm", default: "md5"
  end

  create_table "system_permissions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.string   "auth_role_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "uploads", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "project_id"
    t.string   "name"
    t.string   "content_type"
    t.integer  "size",                  limit: 8
    t.string   "fingerprint_value"
    t.string   "fingerprint_algorithm"
    t.uuid     "storage_provider_id"
    t.datetime "error_at"
    t.string   "error_message"
    t.datetime "completed_at"
    t.string   "etag"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.uuid     "creator_id"
  end

  create_table "user_authentication_services", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "authentication_service_id"
    t.string   "uid"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "username"
    t.string   "etag"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "display_name"
    t.datetime "last_login_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
