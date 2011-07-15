class AddSeniorityToDatacontributions < ActiveRecord::Migration
  def self.up
    add_column :data_contributions, :seniority, :integer
  end

  def self.down
    remove_column :data_contributions, :seniority
  end
end
