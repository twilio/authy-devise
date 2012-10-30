class DeviseAuthyAddToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string  :authy_id
      t.datetime  :last_sign_in_with_authy
    end

  end

  def self.down
    change_table :users do |t|
      t.remove :authy_id, :last_sign_in_with_authy
    end
  end
end
