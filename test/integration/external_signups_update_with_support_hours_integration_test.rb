require File.dirname(__FILE__) + '/../test_helper'

if Redmine::Plugin.registered_plugins.keys.include?(:redmine_project_support_hours)

  class ExternalSignupsUpdateWithSupportHoursIntegrationTest < ActionController::IntegrationTest
    def send_request_with_support_hours

      put "/external_signups/", {
        :security_key => @security_key,
        :project => {
          :id => @project.id,
          :name => "Updated integration project"
        },
        :user => {
          :id => @user.id,
          :firstname => 'Updated user',
          :lastname => 'Test',
          :mail => 'test@example.com'
        },
        :support => {
          :hours => '1002.2',
          :start_date => '2009-09-01',
          :end_date => '2009-12-31'
        }
      }

    end

    context "with support hours" do
      setup do
        # configure the redmine_project_support_plugin
        @hours_custom_field = ProjectCustomField.generate!(:field_format => 'float')
        @start_date_custom_field = ProjectCustomField.generate!(:field_format => 'date')
        @end_date_custom_field = ProjectCustomField.generate!(:field_format => 'date')

        Setting.plugin_redmine_project_support_hours = {
          'hours_field' => @hours_custom_field.id.to_s,
          'start_date_field' => @start_date_custom_field.id.to_s,
          'end_date_field' => @end_date_custom_field.id.to_s
        }

        # Need to call #anonymous so the anonymous user is
        # created before the assert_difference
        User.anonymous
        setup_plugin_configuration
        @project = Project.generate!
        @user = User.generate_with_protected!
        @member = Member.generate!({
                                     :role_ids => @configured_roles.collect(&:id),
                                     :user => @user,
                                     :project => @project
                                   })

      end
      
      should 'update hours' do
        send_request_with_support_hours

        assert_response 200

        @project.reload
        assert_equal '1002.2', @project.custom_value_for(@hours_custom_field).value
      end

      should 'update start date' do
        send_request_with_support_hours

        assert_response 200

        @project.reload
        assert_equal '2009-09-01', @project.custom_value_for(@start_date_custom_field).value
      end

      should 'update end date' do
        send_request_with_support_hours

        assert_response 200

        @project.reload
        assert_equal '2009-12-31', @project.custom_value_for(@end_date_custom_field).value
      end
    end
  end

end
