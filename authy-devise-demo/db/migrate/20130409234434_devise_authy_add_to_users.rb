class DeviseAuthyAddToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string    :authy_id
      t.datetime  :last_sign_in_with_authy
      t.boolean   :authy_enabled, :default => false
      t.integer   :failed_attempts, :default => 0
      t.string    :unlock_token
      t.datetime  :locked_at
    end

    add_index :users, :authy_id
  end

  def self.down
    change_table :users do |t|
      t.remove :authy_id, :last_sign_in_with_authy, :authy_enabled, :failed_attempts, :unlock_token, :locked_at
    end
  end
end

