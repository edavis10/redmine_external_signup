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
      context "with a valid security token" do
        context "with valid data" do
          should "do things"
        end

        context "with missing data" do
          should "return a 412 error"
          should "return an XML document saying what data is missing"
        end
      end

      context "with an invalid security token" do
        should "return a 403 error"
        should "return an XML document saying the security token is invalid"
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
      should "do things"
    end

    context "DELETE" do
      setup { delete :update }
      should_respond_with_with_a_method_not_allowed(:use_method_instead => "PUT")
    end
  end
end
