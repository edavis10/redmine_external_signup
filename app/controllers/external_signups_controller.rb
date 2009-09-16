class ExternalSignupsController < ApplicationController
  def create
    if request.post?
      if security_key_valid?

      else
        invalid_security_key
      end
    else
      invalid_method("POST")
    end
  end

  def update
    if request.put?
      if security_key_valid?

      else
        invalid_security_key
      end
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

  def invalid_security_key
    respond_to do |format|
      format.xml {
        render :status => 403, :xml => {'error' => "The security key is invalid.  Please check that the key from Redmine is used in the 'security_key' parameter."}.to_xml(:root => 'errors')
      }
    end
  end

  def security_key_valid?
    settings = Setting.plugin_redmine_external_signup
    return settings['security_key'] && params[:security_key] && settings['security_key'] == params[:security_key].to_s
  end
end
