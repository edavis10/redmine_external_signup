require 'redmine'

Redmine::Plugin.register :redmine_external_signup do
  name 'External Signup'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/external-signup'
  author_url 'http://www.littlestreamsoftware.com'
  description 'External signup is a Redmine plugin that allows an external source create a new Redmine project and user.'
  version '0.1.0'

  requires_redmine :version_or_higher => '0.8.0'
end
