module RoxClient
  VERSION = '0.1.0'

  class Error < StandardError; end
  class PayloadError < Error; end
end

Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }
