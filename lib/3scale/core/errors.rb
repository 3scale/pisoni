module ThreeScale
  module Core
    class UnknownAPIEndpoint < RuntimeError; end

    class Error < RuntimeError
      def to_xml(options = {})
        xml = Builder::XmlMarkup.new
        xml.instruct! unless options[:skip_instruct]
        xml.error(message, :code => code)

        xml.target!
      end

      def code
        self.class.code
      end

      def self.code
        underscore(name[/[^:]*$/])
      end

      # TODO: move this over to some utility module.
      def self.underscore(string)
        # Code stolen from ActiveSupport
        string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
               gsub(/([a-z\d])([A-Z])/,'\1_\2').
               downcase
      end
    end

    NotFound = Class.new(Error)
    Invalid  = Class.new(Error)

    class ApplicationHasInconsistentData < Error
      def initialize(id, user_key)
        super %(Application id="#{id}" with user_key="#{user_key}" has inconsistent data and could not be saved)
      end
    end

    class ServiceRequiresDefaultUserPlan < Error
      def initialize
        super %(Services without the need for registered users require a default user plan)
      end
    end

    class ServiceIsDefaultService < Error
      def initialize(id = nil)
        super %(Service id="#{id}" is the default service, must be removed forcefully or make it not default before removal)
      end
    end

    class ServiceRequiresRegisteredUser < Error
      def initialize(id = nil)
        super %(Service id="#{id}" requires users to be registered before hand)
      end
    end

    class UserRequiresUsername < Error
      def initialize
        super %(User requires username)
      end
    end

    class UserRequiresServiceId < Error
      def initialize
        super %(User requires a service id)
      end
    end

    class UserRequiresValidServiceId < Error
      def initialize(id)
        super %(Service id #{id} is invalid, user requires a valid id)
      end
    end

    class UserRequiresDefinedPlan < Error
      def initialize(plan_id, plan_name)
        super %(User requires a defined plan, plan id: #{plan_id} plan name: #{plan_name})
      end
    end

    class InvalidProviderKeys < Error
      def initialize
        super %(Provider keys are not valid, must be not nil and different)
      end
    end

    class InvalidBucket < Error
      def initialize
        super %(Bucket is not valid, must be not nil nor empty)
      end
    end

    class ProviderKeyExists < Error
      def initialize(key)
        super %(Provider key="#{key}" already exists)
      end
    end

    class ProviderKeyNotFound < Error
      def initialize(key)
        super %(Provider key="#{key}" does not exist)
      end
    end

    class UsageLimitInvalidPeriods < Error
      def initialize(periods)
        super %(UsageLimit invalid periods #{periods})
      end
    end

    class InvalidPerPage < Error
      def initialize
        super %(per_page is not valid, must be positive)
      end
    end

    class ServiceTokenRequiresServiceId < Error
      def initialize
        super 'ServiceToken is invalid, service ID cannot be blank'
      end
    end

    class ServiceTokenRequiresToken < Error
      def initialize
        super 'ServiceToken is invalid, token cannot be blank'
      end
    end

    class ServiceTokenMissingParameter < Error
      def initialize(error_text)
        super %(ServiceToken is invalid, #{error_text})
      end
    end
  end
end
