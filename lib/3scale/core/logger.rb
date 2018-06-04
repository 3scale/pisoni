require 'injectedlogger'

module ThreeScale
  module Core
    module Logger
      InjectedLogger.use(:error, :info, :debug) {}
      InjectedLogger.after_injection do |logger|
        logger.prefix = '[pisoni]' unless logger.prefix
      end
    end
  end
end
