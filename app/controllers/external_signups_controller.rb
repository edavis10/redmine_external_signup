class ExternalSignupsController < ApplicationController
  def create
    if request.post?

    else
      invalid_method("POST")
    end
  end

  def update
    if request.put?

    else
      invalid_method("PUT")
    end
  end

  private
  
  def invalid_method(http_method="POST")
    respond_to do |format|
      format.xml {
        render :status => 405, :xml => {'error' => "Only #{http_method} methods are allowed"}.to_xml(:root => 'errors')
      }
    end
  end
end
