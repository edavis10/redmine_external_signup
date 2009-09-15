# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

Rails::Initializer.run do |config|
  config.gem "thoughtbot-shoulda", :lib => "shoulda", :source => "http://gems.github.com"
  config.gem "nofxx-object_daddy", :lib => "object_daddy", :source => "http://gems.github.com"
end

# TODO: The gem or official version of ObjectDaddy doesn't set protected attributes.
def User.generate_with_protected!(attributes={})
  user = User.spawn(attributes) do |user|
    user.login = User.next_login
    attributes.each do |attr,v|
      user.send("#{attr}=", v)
    end
  end
  user.save!
  user
end

# Helpers
class Test::Unit::TestCase
  def configure_plugin(fields={})
    Setting.plugin_redmine_external_signup = fields.stringify_keys
  end

  def setup_plugin_configuration
    configure_plugin({
                     })
  end
end

# Shoulda
class Test::Unit::TestCase
  def self.should_respond_with_with_a_method_not_allowed(options={})
    use_method_instead = options.delete(:use_method_instead) || "POST"

    context "with an invalid HTTP method" do
      should_respond_with 405

      should "return an XML document saying to use #{use_method_instead}" do
        assert_select 'errors error', /#{use_method_instead}/
      end
    end
  end
end
