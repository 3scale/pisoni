module ThreeScale
  module Core
    class UsageLimit < APIClient::Resource
      PERIODS = [:eternity, :year, :month, :week, :day, :hour, :minute].freeze

      attributes :service_id, :plan_id, :metric_id, :value, *PERIODS

      def self.base_uri(service_id, plan_id, metric_id, period)
        "/internal/services/#{service_id}/plans/#{plan_id}/usagelimits/#{metric_id}/#{period}"
      end

      def self.load_value(service_id, plan_id, metric_id, period)
        obj = api_read({}, uri: base_uri(service_id, plan_id, metric_id, period))
        obj and obj.public_send(period).to_i
      end

      def self.save(attributes)
        # save currently DOES NOT support multiple periods at the same time,
        # since it would mean multiple API calls per call to this method.
        periodlst = PERIODS & attributes.keys
        raise UsageLimitInvalidPeriods.new(periodlst) unless periodlst.one?

        service_id, plan_id, metric_id = attributes.fetch(:service_id), attributes.fetch(:plan_id), attributes.fetch(:metric_id)
        period = periodlst.shift
        value = attributes[period]
        fixed_fields = { service_id: service_id, plan_id: plan_id, metric_id: metric_id }.freeze

        api_update(fixed_fields.merge({period => value}), uri: base_uri(service_id, plan_id, metric_id, period))
      end

      def self.delete(service_id, plan_id, metric_id, period)
        api_delete({}, uri: base_uri(service_id, plan_id, metric_id, period))
      end

    end
  end
end
