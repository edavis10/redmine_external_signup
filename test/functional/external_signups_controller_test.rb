require File.dirname(__FILE__) + '/../test_helper'

class ExternalSignupsControllerTest < ActionController::TestCase
  context "routing" do
    should_route :post, "/external_signups", :controller => 'external_signups', :action => 'create'
    should_route :put, "/external_signups", :controller => 'external_signups', :action => 'update'
  end

  context "#create" do
    context "GET" do
      setup do
        get :create
      end
      
      should_respond_with 405

      should "return an XML document saying to use POST" do
        assert_select 'errors error', /POST/
      end
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
      setup do
        put :create
      end

      should_respond_with 405

      should "return an XML document saying to use POST" do
        assert_select 'errors error', /POST/
      end
    end

    context "DELETE" do
      setup do
        delete :create
      end

      should_respond_with 405

      should "return an XML document saying to use POST" do
        assert_select 'errors error', /POST/
      end
    end
  end

  context "#update" do
    context "GET" do
      should "return a 405 error"
      should "return an XML document saying to use PUT"
    end

    context "POST" do
      should "return a 405 error"
      should "return an XML document saying to use PUT"
    end

    context "PUT" do
      should "do things"
    end

    context "DELETE" do
      should "return a 405 error"
      should "return an XML document saying to use PUT"
    end
  end
end
