require File.dirname(__FILE__) + '/../test_helper'

class ExternalSignupsUpdateIntegrationTest < ActionController::IntegrationTest
  def send_request
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
      }
    }
  end

  context "posting from a remote form" do
    setup do
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

    should 'update a project' do
      send_request

      assert_response 200

      @project.reload
      assert_equal "Updated integration project", @project.name
    end

    should 'update a user' do
      send_request

      assert_response 200
      
      @user.reload
      assert_equal "Updated user", @user.firstname
    end

    should 'return an xml message to the caller' do
      send_request

      assert_response 200

      assert_equal 'application/xml', @response.content_type
    end
  end
end
