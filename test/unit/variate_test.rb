require File.expand_path('../../test_helper',__FILE__)
require 'nokogiri'

class VariateTest < ActiveSupport::TestCase

  should belong_to :datatable
  should belong_to :unit

  context 'A variate' do
    setup do
      @variate = Factory :variate
    end

    context '#to_eml' do
      setup do
        @to_eml = Nokogiri::XML(@variate.to_eml)
      end

      should 'be successful' do
        assert @to_eml.present?
      end
    end
  end

  context 'A variate with a description' do
    setup do
      @variate = Factory :variate, :description => 'A description'
    end

    context '#to_eml' do
      setup do
        @to_eml = Nokogiri::XML(@variate.to_eml)
      end

      should 'include that description in attributeDefinition tags' do
        assert_equal 1, @to_eml.css('attribute attributeDefinition').count
      end
    end
  end

  context 'A variate with an interval measurement scale' do
    setup do
      @variate = Factory :variate, :measurement_scale => 'interval'
    end

    context '#to_eml' do
      setup do
        @to_eml = Nokogiri::XML(@variate.to_eml)
      end

      should 'include the scale' do
        assert_equal 1, @to_eml.css('measurementScale interval').count
      end
    end

    context 'and precision' do
      setup do
        @variate.precision = 0.1
      end

      context '#to_eml' do
        setup do
          @to_eml = Nokogiri::XML(@variate.to_eml)
        end

        should 'include the precision' do
          assert_equal 1, @to_eml.css('precision').count
          assert_equal '0.1', @to_eml.at_css('precision').text
        end
      end
    end

    context 'and a data type' do
      setup do
        @variate.data_type = 'Simple data'
      end

      context '#to_eml' do
        setup do
          @to_eml = Nokogiri::XML(@variate.to_eml)
        end

        should 'include the data type' do
          assert_equal 1, @to_eml.css('numberType').count
          assert_equal 'Simple data', @to_eml.at_css('numberType').text
        end
      end
    end

    context 'and belongs to a unit' do
      setup do
        @unit = Factory :unit, :name => 'Good name'
        @variate.unit = @unit
      end

      context '#to_eml' do
        setup do
          @to_eml = Nokogiri::XML(@variate.to_eml)
        end

        should 'include the scale' do
          assert_equal 1, @to_eml.css('customUnit').count
          assert_equal 'Good name', @to_eml.at_css('customUnit').text
        end
      end

      context 'unit is in_eml' do
        setup do
          @unit.in_eml = true
        end

        context '#to_eml' do
          setup do
            @to_eml = Nokogiri::XML(@variate.to_eml)
          end

          should 'include the scale' do
            assert_equal 1, @to_eml.css('standardUnit').count
            assert_equal 'Good name', @to_eml.at_css('standardUnit').text
          end
        end
      end
    end
  end

  context 'A variate with a ratio measurement scale' do
    setup do
      @variate = Factory :variate, :measurement_scale => 'ratio'
    end

    context '#to_eml' do
      setup do
        @to_eml = Nokogiri::XML(@variate.to_eml)
      end

      should 'include the scale' do
        assert_equal 1, @to_eml.css('measurementScale ratio').count
      end
    end

    context 'and a precision' do
      setup do
        @variate.precision = 0.2
      end

      context '#to_eml' do
        setup do
          @to_eml = Nokogiri::XML(@variate.to_eml)
        end

        should 'include the precision' do
          assert_equal 1, @to_eml.css('precision').count
          assert_equal '0.2', @to_eml.at_css('precision').text
        end
      end
    end

    context 'and a data type' do
      setup do
        @variate.data_type = 'Better type'
      end

      context '#to_eml' do
        setup do
          @to_eml = Nokogiri::XML(@variate.to_eml)
        end

        should 'include the data type' do
          assert_equal 1, @to_eml.css('numberType').count
          assert_equal 'Better type', @to_eml.at_css('numberType').text
        end
      end
    end
  end

  context 'A variate with an ordinal measurement scale' do
    setup do
      @variate = Factory :variate, :measurement_scale => 'ordinal'
    end

    context '#to_eml' do
      setup do
        @to_eml = Nokogiri::XML(@variate.to_eml)
      end

      should 'include the scale' do
        assert_equal 1, @to_eml.css('measurementScale ordinal').count
      end
    end
  end

  context 'A variate with a nominal measurement scale' do
    setup do
      @variate = Factory :variate, :measurement_scale => 'nominal'
    end

    context '#to_eml' do
      setup do
        @to_eml = Nokogiri::XML(@variate.to_eml)
      end

      should 'include the scale' do
        assert_equal 1, @to_eml.css('measurementScale nominal nonNumericDomain textDomain').count
      end
    end

    context 'and a description' do
      setup do
        @variate.description = 'A nominal description'
      end

      context '#to_eml' do
        setup do
          @to_eml = Nokogiri::XML(@variate.to_eml)
        end

        should 'include the description' do
          assert_equal 1, @to_eml.css('nominal nonNumericDomain textDomain definition').count
        end
      end
    end
  end

  context 'A variate with a date time measurement scale' do
    setup do
      @variate = Factory :variate, :measurement_scale => 'dateTime'
    end

    context '#to_eml' do
      setup do
        @to_eml = Nokogiri::XML(@variate.to_eml)
      end

      should 'include a measurementScale element' do
        assert_equal 1, @to_eml.css('measurementScale').count
      end
    end

    context 'and a date format' do
      setup do
        @variate.date_format = 'Normal format'
      end

      context '#to_eml' do
        setup do
          @to_eml = Nokogiri::XML(@variate.to_eml)
        end

        should 'include a formatString element' do
          assert_equal 1, @to_eml.css('formatString').count
          assert_equal 'Normal format', @to_eml.at_css('formatString').text
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: variates
#
#  id                      :integer         not null, primary key
#  name                    :string(255)
#  datatable_id            :integer
#  weight                  :integer
#  description             :text
#  missing_value_indicator :string(255)
#  unit_id                 :integer
#  measurement_scale       :string(255)
#  data_type               :string(255)
#  min_valid               :float
#  max_valid               :float
#  date_format             :string(255)
#  precision               :float
#  query                   :text
#  variate_theme_id        :integer
#

