class DeviseAuthyAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    change_table :<%= table_name %> do |t|
      t.string    :authy_id
      t.datetime  :last_sign_in_with_authy
    end

    add_index :<%= table_name %>, :authy_id, :unique => true
  end

  def self.down
    change_table :<%= table_name %> do |t|
      t.remove :authy_id, :last_sign_in_with_authy
    end
  end
end
