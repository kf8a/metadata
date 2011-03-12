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
  end
end
