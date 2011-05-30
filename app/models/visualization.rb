class Visualization < ActiveRecord::Base
  belongs_to :datatable

  def data
    ActiveRecord::Base.connection.execute(self.query)
  end
end
