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
          
          # Support data is added via a hook and is tested in the
          # redmine_project_support_hours plugin

          should_respond_with_a_successful_xml_message { post :create, @valid_data }

          context "but with a server error" do
            setup do
              Project.any_instance.stubs(:create_or_update).returns(false)
              post :create, @valid_data
            end

            should_respond_with_a_server_error_xml_message
          end
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

      context "with an security key configured" do
        setup do
          configure_plugin('security_key' => '')
          post :create, :security_key => ''
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
          setup do
            @project = Project.generate!
            @user = User.generate_with_protected!
            @member = Member.generate!({
                                         :role_ids => @configured_roles.collect(&:id),
                                         :user => @user,
                                         :project => @project
                                       })
          end
          
          context "updates to the project" do
            context "allow updating name" do
              should_respond_with_a_successful_xml_update_message(:project => {:name => 'A new name'}) do
                put :update, :security_key => @security_key, :project => {:id => @project.id, :name => 'A new name'}
              end
            end

            context "allow updating descripton" do
              should_respond_with_a_successful_xml_update_message(:project => {:description => 'An updated description'}) do
                put :update, :security_key => @security_key, :project => {:id => @project.id, :description => 'An updated description'}
              end
            end
            
            context "allow updating homepage" do
              should_respond_with_a_successful_xml_update_message(:project => {:homepage => 'http://example.com'}) do
                put :update, :security_key => @security_key, :project => {:id => @project.id, :homepage => 'http://example.com'}
              end
            end

            should "not allow updating identifer" do
              put :update, :security_key => @security_key, :project => {:id => @project.id, :identifier => 'an-update'}
              @project.reload
              assert_not_equal 'an-update', @project.identifier
            end

          end

          context "updates the user" do
            context "allow updating firstname" do
              should_respond_with_a_successful_xml_update_message(:user => {:firstname => 'Test update'}) do
                put :update, :security_key => @security_key, :user => {:id => @user.id, :firstname => 'Test update'}
              end
            end

            context "allow updating lastname" do
              should_respond_with_a_successful_xml_update_message(:user => {:lastname => 'Another'}) do
                put :update, :security_key => @security_key, :user => {:id => @user.id, :lastname => 'Another'}
              end
            end

            context "allow updating mail" do
              should_respond_with_a_successful_xml_update_message(:user => {:mail => 'user2@example.com'}) do
                put :update, :security_key => @security_key, :user => {:id => @user.id, :mail => 'user2@example.com'}
              end
            end
          end

          context "updates for both user and project" do
            # TODO: would be nice to remove the duplication around
            # this datastructure
            should_respond_with_a_successful_xml_update_message({
                                                                  :user => {
                                                                    :firstname => 'Testing multiple',
                                                                    :lastname => 'Testing multiple'
                                                                  },
                                                                  :project => {
                                                                    :name => "A multi project",
                                                                    :description => "Doing cool stuff"
                                                                  }
                                                                }) do
              put(:update, {
                    :security_key => @security_key,
                    :user => {
                      :id => @user.id,
                      :firstname => 'Testing multiple',
                      :lastname => 'Testing multiple'
                    },
                    :project => {
                      :id => @project.id,
                      :name => "A multi project",
                      :description => "Doing cool stuff"
                    }
                  })
            end
          end

          # Support data is added via a hook and is tested in the
          # redmine_project_support_hours plugin

          context "but with a server error" do
            context "on project" do
              setup do
                Project.any_instance.stubs(:update_attributes).returns(false)
                put :update, {:security_key => @security_key, :project => {:id => @project.id, :name => 'Fail'}}
              end

              should_respond_with_a_server_error_xml_message(:message => 'Project not saved')
            end

            context "on user" do
              setup do
                User.any_instance.stubs(:update_attributes).returns(false)
                put :update, {:security_key => @security_key, :user => {:id => @user.id, :name => 'Fail'}}
              end

              should_respond_with_a_server_error_xml_message(:message => 'User not saved')
            end

            context "on both project and user" do
              setup do
                Project.any_instance.stubs(:update_attributes).returns(false)
                User.any_instance.stubs(:update_attributes).returns(false)
                put :update, {:security_key => @security_key, :user => {:id => @user.id, :name => 'Fail'}, :project => {:id => @project.id, :name => 'Fail'}}
              end

              should_respond_with_a_server_error_xml_message(:message => 'Project not saved, User not saved')
            end
          end
        end

        context "with missing data" do
          setup do
            put :update, :security_key => @security_key
          end

          should_respond_with_a_missing_required_data_error(:missing_data => {:project => [:id], :user => [:id]})
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
