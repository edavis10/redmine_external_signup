require File.dirname(__FILE__) + '/../test_helper'

class ExternalSignupsIntegrationTest < ActionController::IntegrationTest
  def send_request
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
      }
    }
  end

  context "posting from a remote form" do
    setup do
      # Need to call #anonymous so the anonymous user is
      # created before the assert_difference
      User.anonymous
      setup_plugin_configuration
    end
    
    should 'create a user' do
      assert_difference 'User.count', 1 do
        send_request
      end
    end

    should 'create a project' do
      assert_difference 'Project.count', 1 do
        send_request
      end
    end

    should 'create a member' do
      assert_difference 'Member.count', 1 do
        send_request
      end
    end

    should 'return an xml message to the caller' do
      send_request
      assert_equal 'application/xml', @response.content_type
    end
  end
end
