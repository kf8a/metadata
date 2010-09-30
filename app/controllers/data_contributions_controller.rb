class DataContributionsController < ApplicationController
  def new
    @data_contribution = DataContribution.new
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'data-contributions', :partial => "new", :locals => {:people => Person.by_sur_name}
        end
      end
    end
  end
end
