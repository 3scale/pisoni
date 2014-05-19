module ThreeScale
  module Core
    class UnknownDonbotAPIEndpoint < RuntimeError; end

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

    class UserRequiresValidService < Error
      def initialize
        super %(User requires a valid service, the service does not exist)
      end
    end

    class UserRequiresDefinedPlan < Error
      def initialize
        super %(User requires a defined plan)
      end
    end

    class InvalidProviderKeys < Error
      def initialize
        super %(Provider keys are not valid, must be not nil and different)
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
  end
end
