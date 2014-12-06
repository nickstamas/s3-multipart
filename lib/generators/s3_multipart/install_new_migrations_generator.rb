require 'rails/generators'

module S3Multipart
  class InstallNewMigrationsGenerator < Rails::Generators::Base
    desc "Generates the migrations necessary when updating the gem to the latest version"

    source_root File.expand_path("../templates", __FILE__)

    def create_latest_migrations
      copy_file "add_unique_to_uploads.rb", "db/migrate/#{migration_time}_add_unique_to_uploads.rb"
    end

    private

      def migration_time
        Time.now.strftime("%Y%m%d%H%M%S")
      end

  end
end
