class ExternalSignupsController < ApplicationController
  def create
    if request.post?

    else
      invalid_method
    end
  end

  verify :method => :put, :only => :update, :redirect_to => { :action => :invalid_method }
  def update
  end

  def invalid_method
    respond_to do |format|
      format.xml {
        render :status => 405, :xml => {'error' => "Only POST methods are allowed"}.to_xml(:root => 'errors')
      }
    end
  end
end
