require 'fileutils'
require 'rake/tasklib'
require 'paint'

module RoxClient

  class Tasks < ::Rake::TaskLib

    def initialize

      namespace :spec do

        namespace :rox do

          desc "Generate a test run UID to group test results in ROX Center (stored in an environment variable)"
          task :uid do
            trace do
              uid = uid_manager.generate_uid_to_env
              puts Paint["ROX - Generated UID for test run: #{uid}", :cyan]
            end
          end

          namespace :uid do

            desc "Generate a test run UID to group test results in ROX Center (stored in a file)"
            task :file do
              trace do
                uid = uid_manager.generate_uid_to_file
                puts Paint["ROX - Generated UID for test run: #{uid}", :cyan]
              end
            end

            desc "Clean the test run UID (file and environment variable)"
            task :clean do
              trace do
                uid_manager.clean_uid
                puts Paint["ROX - Cleaned test run UID", :cyan]
              end
            end
          end
        end
      end
    end

    private

    def trace &block
      if Rake.application.options.trace
        block.call
      else
        begin
          block.call
        rescue UID::Error => e
          warn Paint["ROX - #{e.message}", :red]
        end
      end
    end

    def uid_manager
      UID.new RoxClient.config.client_options
    end
  end
end
