xml.instruct!
xml.success do
  xml << @member.to_xml(:skip_instruct => true, :include => [:user, :project])
  xml.project_url url_for(:controller => 'projects', :action => 'show', :id => @project.identifier, :only_path => false)
end
