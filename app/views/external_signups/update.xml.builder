xml.instruct!
xml.success do
  xml << @project.to_xml(:skip_instruct => true) if @project
  xml << @user.to_xml(:skip_instruct => true) if @user
end
