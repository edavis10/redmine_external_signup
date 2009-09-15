require 'redmine'

if Rails.env == "test"
  
  # Bootstrap ObjectDaddy since it's needs to load before the Models
  # (it hooks into ActiveRecord::Base.inherited)
  require 'object_daddy'

  # Use the plugin's exemplar_path :nodoc:
  module ::ObjectDaddy
    module RailsClassMethods
      def exemplar_path
        File.join(File.dirname(__FILE__), 'test', 'exemplars')
      end
    end
  end
end

Redmine::Plugin.register :redmine_external_signup do
  name 'External Signup'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/external-signup'
  author_url 'http://www.littlestreamsoftware.com'
  description 'External signup is a Redmine plugin that allows an external source create a new Redmine project and user.'
  version '0.1.0'

  requires_redmine :version_or_higher => '0.8.0'

  settings({
             :partial => 'settings/external_signup',
             :default => {
               'roles' => [],
               'security_key' => ''
             }})

end
