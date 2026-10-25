# frozen_string_literal: true

module Formtastic
  module Inputs
    class CustomCountryInput
      include Base

      class CountrySelectPluginMissing < StandardError
      end

      def to_html
        unless builder.respond_to?(:country_select)
          raise CountrySelectPluginMissing,
                'To use the :country input, please install a country_select plugin, like this one: https://github.com/stefanpenner/country_select'
        end

        input_wrapping do
          label_html <<
            builder.country_select(method, input_options.reverse_merge(priority_countries:), input_html_options)
        end
      end

      def priority_countries
        options[:priority_countries] || builder.priority_countries
      end
    end
  end
end
