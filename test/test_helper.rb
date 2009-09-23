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
    @security_key = 'deadbeef1234'

    @configured_roles = [Role.generate!, Role.generate!]
    @roles_for_additional_users = [Role.generate!]
    configure_plugin({
                       'roles' => @configured_roles.collect(&:id).collect(&:to_s),
                       'roles_for_additional_users' => @roles_for_additional_users.collect(&:id).collect(&:to_s),
                       'security_key' => @security_key,
                       'default_user_assignment' => ''
                     })
  end
end

# Shoulda
class Test::Unit::TestCase
  def self.should_create_a_user(user_attributes, &block)
    context 'should create a user' do
      should 'saved to the database' do
        # Need to call #anonymous so the anonymous user is
        # created before the assert_difference
        User.anonymous
        assert_difference 'User.count', 1 do
          instance_eval(&block)
        end

      end

      should "create a user with the firstname" do
        instance_eval(&block)
        user = User.last
        assert user
        assert_equal user_attributes[:firstname], user.firstname
      end

      should "create a user with the lastname" do
        instance_eval(&block)
        user = User.last
        assert user
        assert_equal user_attributes[:lastname], user.lastname
      end

      should "create a user with the mail" do
        instance_eval(&block)
        user = User.last
        assert user
        assert_equal user_attributes[:mail], user.mail
      end

      should "create a user with the password" do
        instance_eval(&block)
        assert User.try_to_login(user_attributes[:mail], user_attributes[:password])
      end
      
      should "create a user using the mail as their login" do
        instance_eval(&block)
        user = User.last
        assert user
        assert_equal user.mail, user.login
      end

      should "be active" do
        instance_eval(&block)
        user = User.last
        assert user
        assert user.active?
      end
    end
    
  end

  def self.should_create_a_project(project_attributes, &block)
    context 'should create a project' do
      should "saved to the database" do
        assert_difference 'Project.count', 1 do
          instance_eval(&block)
        end
      end

      should "create a project with the name" do
        instance_eval(&block)
        project = Project.last
        assert project
        assert_equal 'A test project', project.name
      end

      should "generate an identifer" do
        instance_eval(&block)
        project = Project.last
        assert project
        assert_equal 'a-test-project', project.identifier
      end

      should "enable all the modules" do
        instance_eval(&block)
        project = Project.last
        assert project
        assert_equal Redmine::AccessControl.available_project_modules.length, project.enabled_modules.length, "not all modules where enabled"
      end

    end
  end

  def self.should_create_members_for_the_new_user_and_additional_users(options={}, &block)
    count = options.delete(:count) || 1
    
    context 'should create a member' do
      should 'be saved to the database' do
        assert_difference 'Member.count', count do
          instance_eval(&block)
        end
      end

      should 'use the created user account' do
        instance_eval(&block)
        members = Member.find(:all, :limit => count, :order => 'id desc')
        member = members[-1] # first one in this set should be the user's
        user = User.last

        assert member, "No member created"
        assert user, "No user assigned"
        assert_equal user, member.user
      end

      should 'assign each of the configured roles' do
        instance_eval(&block)
        members = Member.find(:all, :limit => count, :order => 'id desc')
        member = members[-1] # first one in this set should be the user's

        assert member, "No member created"
        assert_equal 2, member.roles.length, "No roles assigned"
        Setting.plugin_redmine_external_signup['roles'].each do |role_id|
          assert member.role_ids.include? role_id.to_i
        end
      end

    end
  end

  def self.should_respond_with_a_successful_xml_message(options={}, &block)
    context "" do
      setup do
        instance_eval(&block)
      end
      
      should_respond_with 200

      should "return an success XML document" do
        assert_select 'success' do
          assert_select('member') do
            assert_select('project')
            assert_select('user')
          end
          # Match the full path and at least the projects controller
          assert_select('project_url',/http.*projects/)
        end
      end
    end
  end

  def self.should_respond_with_a_successful_xml_update_message(updated_data, options={}, &block)
    context "" do
      setup do
        instance_eval(&block)
      end
      
      should_respond_with 200

      should "return an success XML document" do
        assert_select 'success' do
          updated_data.each do |object, fields|
            assert_select("#{object}") do
              fields.each do |field, value|
                assert_select("#{field}", /#{value}/)
              end
            end
          end
        end
      end

      should "update the fields on the record" do
        updated_data.each do |object, fields|
          instance_object = instance_variable_get('@' + object.to_s)
          assert instance_object
          
          instance_object.reload
          fields.each do |field, value|
            assert_equal value, instance_object.send(field.to_sym)
          end
        end
      end

    end
  end

  def self.should_respond_with_a_server_error_xml_message(options={})
    message = options.delete(:message) || 'ActiveRecord::RecordNotSaved'
    
    context "" do
      should_respond_with 500

      should "return a server error XML document" do
        assert_select 'errors' do
          assert_select('message', message)
        end
      end
    end
  end
  
  def self.should_respond_with_with_a_method_not_allowed(options={})
    use_method_instead = options.delete(:use_method_instead) || "POST"

    context "with an invalid HTTP method" do
      should_respond_with 405

      should "return an XML document saying to use #{use_method_instead}" do
        assert_select 'errors error', /#{use_method_instead}/
      end
    end
  end

  def self.should_respond_with_an_invalid_security_key_error(options={})
    context "" do
      should_respond_with 403

      should "return an XML document saying that the security key is invalid" do
        assert_select 'errors error', /security key is invalid/
      end
    end
  end

  def self.should_respond_with_a_missing_required_data_error(options={})
    default_data = {
      :project => [:name],
      :user => [:firstname, :lastname, :mail, :password, :password_confirmation]
    }
    missing_data = options.delete(:missing_data) || default_data
      
    context "" do
      should_respond_with 412

      should "return an XML document saying what data is missing" do
        assert_select('errors') do

          missing_data.each do |object, fields_missing|
            assert_select("#{object}") do

              fields_missing.each do |field|
                assert_select('missingData[field=?]', field)
              end

            end
          end

        end
      end # should

    end
    
  end
end
