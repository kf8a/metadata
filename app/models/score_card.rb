# frozen_string_literal: true

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
    @db_connection = ActiveRecord::Base.connection unless @db_connection
    @db_connection
  end

  def score(datatable)
    # exclude climdb datatables and archive
    return if [309, 300, 301, 175, 127, 82].include? datatable.id

    result = {}

    if time_key(datatable)
      result = data(datatable, time_key(datatable))

      if datatable.status == 'completed'
        result
      else
        fill_to_present(result, update_frequency_years(datatable))
      end
    else
      []
    end
  end

  def time_key(datatable)
    time_key_value = datatable.variate_names.grep(/year/i).first
    time_key_value = datatable.variate_names.grep(/date/i).first unless time_key_value
    time_key_value
  end

  def update_frequency_years(datatable)
    update_frequency = datatable.update_frequency_days || 365
    update_frequency /= 365
    update_frequency = 1 if update_frequency.zero?
    update_frequency
  end

  def data(datatable, time_key)
    if time_key =~ /year/i
      query = "select #{time_key} as year, count(*) from (#{datatable.object})"\
              " as t1 group by #{time_key}"
      approved_query = "select #{time_key} as year, count(*)"\
                       " from (#{datatable.approved_data_query}) as t1 group by #{time_key}"
    else
      query = "select date_part('year',#{time_key}) as year, count(*)"\
              " from (#{datatable.object}) as t1 group by date_part('year',#{time_key})"
      approved_query = "select date_part('year',#{time_key}) as year,"\
                       " count(*) from (#{datatable.approved_data_query})"\
                       " as t1 group by date_part('year',#{time_key})"
    end
    begin
      query_result    = db_connection.execute(query)
      approved_result = db_connection.execute(approved_query)
    rescue Exception
      query_result = []
      approved_result = []
    end
    result = query_result.collect do |row|
      { year: row['year'].to_i, count: row['count'].to_f }
    end

    approved_result.each do |row|
      r = result.index { |x| x[:year] == row['year'].to_i }
      result[r][:approved] = row['count'].to_f
    end

    result
  end

  def fill_to_present(data, update_frequency_years = 1)
    return if data.empty?

    max_year_record = data.max_by { |a| a[:year] }
    max_year = max_year_record[:year].to_i
    max_year += update_frequency_years
    add_years = (max_year..current_year).step(update_frequency_years)
                                        .collect { |year| { year: year, count: 0 } }
    add_years + data
  end

  def current_year
    Time.zone.now.year
  end

  def self.update_all
    score = ScoreCard.new
    Datatable.where(is_sql: true).find_each do |datatable|
      datatable.scores = score.score(datatable).to_json
      datatable.save
    end
  end

  # send all of the scores to a csv file
  def self.scores_to_csv
    CSV.open('scores.csv', 'w') do |csv|
      Datatable.find_each do |datatable|
        score_for_csv(datatable, csv)
      end
    end
  end

  # TODO: this should probably be the same as the
  # score method
  def self.score_for_csv(datatable, csv)
    return unless datatable.dataset.sponsor_id == 1 &&
                  datatable.is_sql
    # exclude climdb datatables and archive
    return if [309, 300, 301, 175, 127, 82].include? datatable.id

    s = score(datatable)
    return unless s

    s.each do |a|
      csv << [datatable.id,
              datatable.completed,
              datatable.name,
              datatable.title,
              a[0],
              a[1][:score]]
    end
  end
end
