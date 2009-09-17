class ExternalSignupsController < ApplicationController
  def create
    if request.post?
      if security_key_valid?
        @project = Project.new(params[:project])

        if @project.name.present?
          @project.identifier = @project.name.to_url
        end

        @project.status = Project::STATUS_ACTIVE
        # TODO: Project modules

        @user = User.new(params[:user])
        @user.login = @user.mail
        if params[:user].present?
          @user.password = params[:user][:password] if params[:user][:password].present?
          @user.password_confirmation = params[:user][:password_confirmation] if params[:user][:password_confirmation].present?
        end

        # Run validations so all errors are available to the view
        @project.valid?
        @user.valid?
        @user.errors.add_on_blank([:password, :password_confirmation])

        
        if @project.errors.length == 0 && @user.errors.length == 0
          ActiveRecord::Base.transaction do
            @project.save
            # TODO: error state response
          end
        else
          missing_required_data
        end
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

  def missing_required_data
    respond_to do |format|
      format.xml {
        render :status => 412, :layout => false, :action => 'missing_data'
      }
    end
  end

  def security_key_valid?
    settings = Setting.plugin_redmine_external_signup
    return settings['security_key'] && params[:security_key] && settings['security_key'] == params[:security_key].to_s
  end

end
