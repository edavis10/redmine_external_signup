class ExternalSignupsController < ApplicationController
  verify :method => :post, :only => :create, :redirect_to => { :action => :invalid_method }
  def create
  end

  verify :method => :put, :only => :update, :redirect_to => { :action => :invalid_method }
  def update
  end

  def invalid_method

  end
end
