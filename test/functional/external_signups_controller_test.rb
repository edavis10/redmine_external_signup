require File.dirname(__FILE__) + '/../test_helper'

class ExternalSignupsControllerTest < ActionController::TestCase
  context "routing" do
    should_route :post, "/external_signups", :controller => 'external_signups', :action => 'create'
    should_route :put, "/external_signups", :controller => 'external_signups', :action => 'update'
  end

  context "#create" do
    context "GET" do
      setup { get :create }
      should_respond_with_with_a_method_not_allowed(:use_method_instead => "POST")
    end

    context "POST" do
      setup do
        setup_plugin_configuration
      end

      context "with a valid security key" do
        context "with valid data" do
          setup do
            @user_attributes = {
              :firstname => "Test",
              :lastname => "User",
              :mail => "test@example.com",
              :password => "testing123456",
              :password_confirmation => "testing123456"
            }
            @valid_data = {
              :security_key => @security_key,
              :project => {
                :name => "A test project"
              },
              :user => @user_attributes
            }
            
          end

          should_create_a_user({
                                 :firstname => "Test",
                                 :lastname => "User",
                                 :mail => "test@example.com",
                                 :password => "testing123456",
                                 :password_confirmation => "testing123456"
                               }) { post :create, @valid_data }

          should_create_a_project({:name => "A test project"}) { post :create, @valid_data }

          should_create_a_member { post :create, @valid_data }
          
          context "support data" do
            should "be created"
          end

          should 'return a 200 xml'
        end

        context "with missing data" do
          setup do
            post :create, :security_key => @security_key
          end

          should_respond_with_a_missing_required_data_error
        end
      end

      context "with an invalid security key" do
        setup do
          post :create, :security_key => 'invalid'
        end

        should_respond_with_an_invalid_security_key_error
      end

      context "without a security key" do
        setup do
          post :create
        end

        should_respond_with_an_invalid_security_key_error
      end

    end

    context "PUT" do
      setup { put :create }
      should_respond_with_with_a_method_not_allowed(:use_method_instead => "POST")
    end

    context "DELETE" do
      setup { delete :create }
      should_respond_with_with_a_method_not_allowed(:use_method_instead => "POST")
    end
  end

  context "#update" do
    context "GET" do
      setup { get :update }
      should_respond_with_with_a_method_not_allowed(:use_method_instead => "PUT")
    end

    context "POST" do
      setup { post :update }
      should_respond_with_with_a_method_not_allowed(:use_method_instead => "PUT")
    end

    context "PUT" do
      setup do
        setup_plugin_configuration
      end

      context "with a valid security key" do
        context "with valid data" do
          should "do things"
        end

        context "with missing data" do
          should "return a 412 error"
          should "return an XML document saying what data is missing"
        end
      end

      context "with an invalid security key" do
        setup do
          put :update, :security_key => 'invalid'
        end

        should_respond_with_an_invalid_security_key_error
      end

      context "without a security key" do
        setup do
          put :update
        end

        should_respond_with_an_invalid_security_key_error
      end

    end

    context "DELETE" do
      setup { delete :update }
      should_respond_with_with_a_method_not_allowed(:use_method_instead => "PUT")
    end
  end
end
