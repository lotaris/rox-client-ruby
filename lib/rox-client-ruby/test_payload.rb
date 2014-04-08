require 'fileutils'
require 'digest/sha2'

module RoxClient

  class TestPayload

    class Error < RoxClient::Error; end

    def initialize run
      @run = run
    end

    def to_h options = {}
      # version 1 payload consists of one test run
      @run.to_h options
    end
  end
end
