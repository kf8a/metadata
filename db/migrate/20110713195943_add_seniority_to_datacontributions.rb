class AddSeniorityToDatacontributions < ActiveRecord::Migration[4.2]
  def self.up
    add_column :data_contributions, :seniority, :integer
  end

  def self.down
    remove_column :data_contributions, :seniority
  end
end
