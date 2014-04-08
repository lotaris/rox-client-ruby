require 'fileutils'
require 'digest/sha2'

module RoxClient

  class TestPayload

    class Error < RoxClient::Error; end

    def initialize run
      @run = run
    end

    def to_h options = {}
      case options[:version]
      when 0
        { 'r' => [ @run.to_h(options) ] }
      else # version 1 by default
        @run.to_h options
      end
    end
  end
end
