require 'csv'

# scores = Array of structs each an datatable_id, array of scores
class ScoreCard
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :db_connection

  def persisted?
    false
  end

  def db_connection
    unless @db_connection
     @db_connection = ActiveRecord::Base.connection
    end
    @db_connection
  end

  def score(datatable)
    # exclude climdb datatables and archive
    return if [309, 300, 301,175, 127,82].include? datatable.id
    result = {}
    time_key = datatable.variate_names.grep(/year/i).first
    unless time_key
      time_key = datatable.variate_names.grep(/date/i).first
    end

    if time_key
      result = data(datatable,time_key)

      result = fill_to_present(result, update_frequency_years(datatable)) unless 'completed' == datatable.status
      result
    else
      []
    end
  end

  def update_frequency_years(datatable)
    update_frequency = datatable.update_frequency_days || 365
    update_frequency = update_frequency / 365
    update_frequency = 1 if 0 == update_frequency
    update_frequency
  end

  def data(datatable, time_key)
    if time_key =~ /year/i
      query = "select #{time_key} as year, count(*) from (#{datatable.object}) as t1 group by #{time_key}"
      approved_query = "select #{time_key} as year, count(*) from (#{datatable.approved_data_query}) as t1 group by #{time_key}"
    else
      query = "select date_part('year',#{time_key}) as year, count(*) from (#{datatable.object}) as t1 group by date_part('year',#{time_key})"
      approved_query = "select date_part('year',#{time_key}) as year, count(*) from (#{datatable.approved_data_query}) as t1 group by date_part('year',#{time_key})"
    end
    begin
      query_result    = db_connection.execute(query)
      approved_result = db_connection.execute(approved_query)

    rescue Exception => e
      query_result = []
      approved_result = []
    end
    result = query_result.collect do |row|
      {:year => row['year'].to_i, :count => row['count'].to_f}
    end
    approved_result.collect do |row|
      r = result.index {|x| x[:year] == row['year'].to_i}
      if r
        result[r][:approved] = row['count'].to_f
        result[r]
      else
        {:year => row['year'].to_i, :count => 0, :approved => row['count'].to_f}
      end
    end
  end

  def fill_to_present(data, update_frequency_years = 1)
    return if data.empty?
    max_year_record = data.max {|a,b| a[:year] <=> b[:year]}
    max_year = max_year_record[:year].to_i
    max_year += update_frequency_years
    add_years = (max_year..current_year).step(update_frequency_years).collect { |year| {:year => year, :count => 0} }
    add_years + data
  end

  def current_year
    Time.now().year
  end

  def self.update_all
    score = ScoreCard.new
    Datatable.where(:is_sql => true).all.each do |datatable|
      datatable.scores  = score.score(datatable).to_json
      datatable.save
    end
  end

  # send all of the scores to a csv file
  def self.scores_to_csv
    CSV.open('scores.csv', 'w') do |csv|
      Datatable.all.each do |datatable|
        next unless datatable.dataset.sponsor_id == 1
        next unless datatable.is_sql
        # exclude climdb datatables and archive
        next if [309, 300, 301,175, 127,82].include? datatable.id
        s = score(datatable)
        if s
          s.each do |a|
            csv << [datatable.id, datatable.completed, datatable.name, datatable.title, a[0],a[1][:score]]
          end
        end
      end
    end
  end
end
