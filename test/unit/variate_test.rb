require File.expand_path('../../test_helper',__FILE__)

class VariateTest < ActiveSupport::TestCase

  should belong_to :datatable
  should belong_to :unit

  context 'A variate' do
    setup do
      @variate = Factory :variate
    end

    context '#to_eml' do
      setup do
        @to_eml = @variate.to_eml.to_s
      end

      should 'be successful' do
        assert_equal "<attribute><attributeName>date</attributeName><attributeDefinition/></attribute>", @to_eml
      end
    end
  end

  context 'A variate with a description' do
    setup do
      @variate = Factory :variate, :description => 'A description'
    end

    context '#to_eml' do
      setup do
        @to_eml = @variate.to_eml.to_s
      end

      should 'include that description in attributeDefinition tags' do
        assert @to_eml.include?('<attributeDefinition>A description</attributeDefinition>')
      end
    end
  end

  context 'A variate with an interval measurement scale' do
    setup do
      @variate = Factory :variate, :measurement_scale => 'interval'
    end

    context '#to_eml' do
      setup do
        @to_eml = @variate.to_eml.to_s
      end

      should 'include the scale' do
        assert @to_eml.include?('<measurementScale><interval><unit><customUnit/></unit><precision>1<!--default precision none specified--></precision><numericDomain><numberType/></numericDomain></interval></measurementScale>')
      end
    end

    context 'and precision' do
      setup do
        @variate.precision = 0.1
      end

      context '#to_eml' do
        setup do
          @to_eml = @variate.to_eml.to_s
        end

        should 'include the precision' do
          assert @to_eml.include?('<precision>0.1</precision>')
        end
      end
    end

    context 'and a data type' do
      setup do
        @variate.data_type = 'Simple data'
      end

      context '#to_eml' do
        setup do
          @to_eml = @variate.to_eml.to_s
        end

        should 'include the data type' do
          assert @to_eml.include?('<numberType>Simple data</numberType>')
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
          @to_eml = @variate.to_eml.to_s
        end

        should 'include the scale' do
          assert @to_eml.include?('<customUnit>Good name</customUnit>')
        end
      end

      context 'unit is in_eml' do
        setup do
          @unit.in_eml = true
        end

        context '#to_eml' do
          setup do
            @to_eml = @variate.to_eml.to_s
          end

          should 'include the scale' do
            assert @to_eml.include?('<standardUnit>Good name</standardUnit>')
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
        @to_eml = @variate.to_eml.to_s
      end

      should 'include the scale' do
        assert @to_eml.include?('<measurementScale><ratio><unit/><precision>1<!--default precision none specified--></precision><numericDomain><numberType/></numericDomain></ratio></measurementScale>')
      end
    end

    context 'and a precision' do
      setup do
        @variate.precision = 0.2
      end

      context '#to_eml' do
        setup do
          @to_eml = @variate.to_eml.to_s
        end

        should 'include the precision' do
          assert @to_eml.include?('<precision>0.2</precision>')
        end
      end
    end

    context 'and a data type' do
      setup do
        @variate.data_type = 'Better type'
      end

      context '#to_eml' do
        setup do
          @to_eml = @variate.to_eml.to_s
        end

        should 'include the data type' do
          assert @to_eml.include?('<numberType>Better type</numberType>')
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
        @to_eml = @variate.to_eml.to_s
      end

    should 'include the scale' do
        assert @to_eml.include?('<measurementScale><ordinal/></measurementScale>')
      end
    end
  end

  context 'A variate with a nominal measurement scale' do
    setup do
      @variate = Factory :variate, :measurement_scale => 'nominal'
    end

    context '#to_eml' do
      setup do
        @to_eml = @variate.to_eml.to_s
      end

      should 'include the scale' do
        assert @to_eml.include?('<attributeDefinition/><measurementScale><nominal><nonNumericDomain><textDomain><definition/></textDomain></nonNumericDomain></nominal></measurementScale>')
      end
    end

    context 'and a description' do
      setup do
        @variate.description = 'A nominal description'
      end

      context '#to_eml' do
        setup do
          @to_eml = @variate.to_eml.to_s
        end

        should 'include the description' do
          assert @to_eml.include?('<nominal><nonNumericDomain><textDomain><definition>A nominal description</definition></textDomain></nonNumericDomain></nominal>')
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
        @to_eml = @variate.to_eml.to_s
      end

      should 'include the scale' do
        assert @to_eml.include?("<measurementScale><dateTime><formatString/><dateTimePrecision>86400</dateTimePrecision><dateTimeDomain><bounds><minimum exclusive='true'>1987-4-18</minimum></bounds></dateTimeDomain></dateTime></measurementScale>")
      end
    end

    context 'and a date format' do
      setup do
        @variate.date_format = 'Normal format'
      end

      context '#to_eml' do
        setup do
          @to_eml = @variate.to_eml.to_s
        end

        should 'include the scale' do
          assert @to_eml.include?('><formatString>Normal format</formatString>')
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

