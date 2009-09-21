require File.dirname(__FILE__) + '/../test_helper'

if Redmine::Plugin.registered_plugins.keys.include?(:redmine_project_support_hours)

  class ExternalSignupsCreateWithSupportHoursIntegrationTest < ActionController::IntegrationTest
    def send_request_with_support_hours
      post "/external_signups/", {
        :security_key => @security_key,
        :project => {
          :name => "New integration project"
        },
        :user => {
          :firstname => 'Integration',
          :lastname => 'Test',
          :mail => 'test@example.com',
          :password => 'testing',
          :password_confirmation => 'testing'
        },
        :support => {
          :hours => '100.2',
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
      end
      
      should 'save hours' do
        send_request_with_support_hours
        project = Project.last
        assert 100.2, project.custom_value_for(@hours_custom_field).value
      end

      should 'save start date' do
        send_request_with_support_hours
        project = Project.last
        assert 100.2, project.custom_value_for(@start_date_custom_field).value
      end

      should 'save end date' do
        send_request_with_support_hours
        project = Project.last
        assert 100.2, project.custom_value_for(@end_date_custom_field).value
      end
    end
  end

end
