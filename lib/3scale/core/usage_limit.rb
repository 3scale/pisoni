module ThreeScale
  module Core
    class UsageLimit < APIClient::Resource
      PERIODS = [:eternity, :year, :month, :week, :day, :hour, :minute].freeze

      attributes :service_id, :plan_id, :metric_id, :value, *PERIODS

      default_uri '/internal/services/'

      def self.base_uri(service_id, plan_id, metric_id, period)
        "#{default_uri}#{service_id}/plans/#{plan_id}/usagelimits/#{metric_id}/#{period}"
      end
      private_class_method :base_uri

      def self.load_value(service_id, plan_id, metric_id, period)
        obj = api_read({}, uri: base_uri(service_id, plan_id, metric_id, period))
        obj and obj.public_send(period).to_i
      end

      def self.save(attributes)
        period = validate_single_period!(attributes)
        service_id = attributes.fetch(:service_id)
        plan_id = attributes.fetch(:plan_id)
        metric_id = attributes.fetch(:metric_id)
        value = attributes.fetch(period)

        api_update(
          { service_id: service_id, plan_id: plan_id, metric_id: metric_id, period => value },
          uri: base_uri(service_id, plan_id, metric_id, period)
        )
      end

      def self.validate_single_period!(attributes)
        periods = PERIODS & attributes.keys
        raise UsageLimitInvalidPeriods.new(periods) unless periods.one?

        periods.first
      end
      private_class_method :validate_single_period!

      def self.delete(service_id, plan_id, metric_id, period)
        api_delete({}, uri: base_uri(service_id, plan_id, metric_id, period))
      end

    end
  end
end
