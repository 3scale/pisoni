module ThreeScale
  module Core
    class UsageLimit < APIClient::Resource
      PERIODS = [:eternity, :year, :month, :week, :day, :hour, :minute].freeze

      attributes :service_id, :plan_id, :metric_id, :value, *PERIODS

      def self.base_uri
        '/internal/services'
      end

      def self.load_value(service_id, plan_id, metric_id, period)
        obj = api_read({}, uri: "#{base_uri}/#{service_id}/plans/#{plan_id}/usagelimits/#{metric_id}/#{period}")
        obj and obj.public_send(period).to_i
      end

      def self.save(attributes)
        service_id, plan_id, metric_id = attributes.fetch(:service_id), attributes.fetch(:plan_id), attributes.fetch(:metric_id)
        fixed_fields = { service_id: service_id, plan_id: plan_id, metric_id: metric_id }.freeze
        PERIODS.map do |period|
          value = attributes.fetch(period, nil)
          next unless value
          api_update(fixed_fields.merge({period.to_sym => value}), uri: "#{base_uri}/#{service_id}/plans/#{plan_id}/usagelimits/#{metric_id}/#{period}")
        end.last
      end

      def self.delete(service_id, plan_id, metric_id, period)
        api_delete({}, uri: "#{base_uri}/#{service_id}/plans/#{plan_id}/usagelimits/#{metric_id}/#{period}")
      end

    end
  end
end
