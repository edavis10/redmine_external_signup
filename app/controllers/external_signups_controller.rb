class ExternalSignupsController < ApplicationController
  unloadable
  # Similar to #verify but with a rendering instead of a redirect
  before_filter :check_valid_http_method
  before_filter :check_security_key

  
  def create
    @project = Project.new(params[:project])
    @project.status = Project::STATUS_ACTIVE
    @project.enabled_module_names = Redmine::AccessControl.available_project_modules
    @project.identifier = @project.name.to_url[0,20] if @project.name.present?


    @user = User.new(params[:user])
    @user.login = @user.mail
    if params[:user].present?
      @user.password = params[:user][:password] if params[:user][:password].present?
      @user.password_confirmation = params[:user][:password_confirmation] if params[:user][:password_confirmation].present?
    end

    roles_setting = Setting.plugin_redmine_external_signup['roles']
    roles = roles_setting.collect(&:to_s) unless roles_setting.blank?
    roles ||= []

    @member = add_member({:roles => roles, :project => @project, :user => @user})
    @additional_members = add_additional_members(:project => @project)

    call_hook(:plugin_external_signup_controller_external_signups_create_pre_validate,
              {
                :project => @project,
                :user => @user,
                :member => @member,
                :params => params
              })
    # Run validations so all errors are available to the view
    @project.valid?
    @user.valid?
    @user.errors.add_on_blank([:password, :password_confirmation])
    @member.valid?
    
    if @project.errors.length == 0 &&
        @user.errors.length == 0 &&
        @member.errors.length == 0 &&
        @additional_members.all? {|m| m.errors.length == 0 }

      respond_to do |format|
        begin
          ActiveRecord::Base.transaction do
            @project.save!
            @user.save!
            @member.save!
            @additional_members.each { |member| member.save! }

            format.xml { render :layout => false }
          end
        rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotSaved => ex
          @message = ex.message
          
          format.xml { render :status => 500, :layout => false, :action => 'missing_data'}
        end
      end

    else
      missing_required_data
    end
  end

  def update
    if (params[:project] && params[:project][:id].present?) || (params[:user] && params[:user][:id].present?)
      respond_to do |format|

        project_saved, user_saved = true, true

        if params[:project] && params[:project][:id].present?
          @project = Project.find(params[:project][:id])
          project_saved = @project.update_attributes(params[:project].delete_if {|k,v| v.blank?})
        end

        if params[:user] && params[:user][:id].present?
          @user = User.find(params[:user][:id])
          user_saved = @user.update_attributes(params[:user].delete_if {|k,v| v.blank?})
        end

        call_hook(:plugin_external_signup_controller_external_signups_update,
                  {
                    :project => @project,
                    :user => @user,
                    :params => params
                  })
        
        if project_saved && user_saved
          format.xml { render :layout => false }
        else
          message = []
          message << "Project not saved" unless project_saved
          message << "User not saved" unless user_saved
          @message = message.join(', ')

          format.xml { render :status => 500, :layout => false, :action => 'missing_data'}
        end
      end
    else
      @message = "Missing a project or user id"
      @project = Project.new
      @project.errors.add(:id, "missing.  Use the integer id (e.g. 42) or the identifier (e.g. a-project)")
      @user = User.new
      @user.errors.add(:id, :empty)
      missing_required_data
    end
  end

  private

  def check_valid_http_method
    case params[:action]
    when 'create'
      invalid_method("POST") unless request.post?
    when 'update'
      invalid_method("PUT") unless request.put?
    else
      false
    end
  end
  
  def check_security_key
    invalid_security_key unless security_key_valid?
  end
  
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
    return settings['security_key'] && params[:security_key] && settings['security_key'].present? && settings['security_key'] == params[:security_key].to_s
  end

  def add_member(attributes)
    member = Member.new(:project => attributes[:project],
                         :role_ids => attributes[:roles])
    # Redmine groups compatibility
    if defined?(Principal)
      member.principal = attributes[:user]
    else
      member.user = attributes[:user]
    end

    member
  end

  def add_additional_members(attributes)
    roles_setting = Setting.plugin_redmine_external_signup['roles_for_all_users']
    role_ids = roles_setting.collect(&:to_s) unless roles_setting.blank?

    unless role_ids.blank?

      roles = Role.find(role_ids, :include => :members)
      users_to_add = roles.collect(&:members).flatten.collect(&:user).uniq

      returning [] do |members|
        users_to_add.each do |user|
          members << add_member(:user => user, :roles => role_ids, :project => attributes[:project])
        end
      end

      
    else
      return []
    end

    

  end
end
