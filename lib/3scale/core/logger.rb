require 'injectedlogger'

module ThreeScale
  module Core
    module Logger
      InjectedLogger.use(:error, :info, :debug) {}
      InjectedLogger.after_injection do |logger|
        logger.prefix = '[core]'
      end
    end
  end
end
