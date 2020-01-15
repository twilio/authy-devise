# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table "users", force: :cascade do |t|
    # devise - database_authenticable, registerable
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    # devise - recoverable
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    # devise - rememberable
    t.datetime "remember_created_at"
    # devise - trackable
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    # devise - lockable
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    # devise - authy_authenticable
    t.string "authy_id"
    t.datetime "last_sign_in_with_authy"
    t.boolean "authy_enabled", default: false
    # single table inheritance so we can have lockable users
    t.string "type"

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authy_id"], name: "index_users_on_authy_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end
end
