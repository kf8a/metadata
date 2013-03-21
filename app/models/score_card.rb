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
    return if [309, 300, 301,175, 127,82].include? datatable.id
    result = {}
    time_key = datatable.variate_names.grep(/year/i).first
    unless time_key
      time_key = datatable.variate_names.grep(/date/i).first
    end

    if time_key
      result = data(datatable,time_key)
      # result = fill_to_present(result) unless datatable.completed
      relativize(result)
    else
      []
    end
  end

  def data(datatable, time_key)
    if time_key =~ /year/i
      query = "select #{time_key} as year, count(*) from (#{datatable.object}) as t1 group by #{time_key}"
    else
      query = "select date_part('year',#{time_key}) as year, count(*) from (#{datatable.object}) as t1 group by date_part('year',#{time_key})"
    end
    begin
    query_result = db_connection.execute(query)
    rescue Exception
      query_result = []
    end
    query_result.collect do |row|
      {:year => row['year'].to_i, :score => row['count'].to_f}
    end
  end

  def relativize(data)
    return data if data.empty?
    max_count = data.max {|a,b| a[:score] <=> b[:score] }[:score].to_f
    return data if 0 == max_count
    data.collect do |datum|
      {:year => datum[:year], :score=> datum[:score].to_f/max_count}
    end
  end

  def fill_to_present(data)
    max_year = data.keys.max
    max_year = max_year[1] + 1
    current_year = Time.now().year
    (max_year..current_year).each do |year|
      data[year] = 0
    end
    data
  end

  def self.all
    Datatable.where(:is_sql => true).all.collect do |datatable|
      next unless datatable.dataset.sponsor_id == 1
      # exclude climdb datatables and archive
      score = ScoreCard.new
      score.score(datatable)
    end.compact
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
