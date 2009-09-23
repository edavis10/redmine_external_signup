require File.dirname(__FILE__) + '/../test_helper'

if Redmine::Plugin.registered_plugins.keys.include?(:redmine_default_assign)

  class ExternalSignupsCreateWithDefaultAssigneeIntegrationTest < ActionController::IntegrationTest
    def send_request(default_assignee_id = nil)
      post "/external_signups/", {
        :security_key => @security_key,
        :project => {
          :name => "New integration project",
          :default_assignee_id => default_assignee_id
        },
        :user => {
          :firstname => 'Integration',
          :lastname => 'Test',
          :mail => 'test@example.com',
          :password => 'testing',
          :password_confirmation => 'testing'
        }
      }
    end

    setup do
      @default_user = User.generate_with_protected!
      Setting.plugin_redmine_external_signup = Setting.plugin_redmine_external_signup.merge({
                                                                                              'default_user_assignment' => @default_user.id.to_s
                                                                                            })
    end

    context "with the default assignee set" do
      should 'set the default assignment from the plugin' do
        setup_plugin_configuration

        send_request

        assert_response :success
        project = Project.last
        assert_equal @default_user, project.default_assignee
      end
    end

    context "with the default assignee as a parameter" do
      should 'set the default assignment from the request' do
        a_user = User.generate_with_protected!
        setup_plugin_configuration

        send_request(a_user.id)

        assert_response :success
        project = Project.last
        assert_equal a_user, project.default_assignee
        assert_contains project.members.collect(&:user), a_user
      end
    end

  end
end
