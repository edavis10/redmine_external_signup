xml.instruct!
xml.errors do
  if @message
    xml.message @message
  end
  if @project.errors.length > 0
    xml.project do  
      @project.errors.each do |attr, message|
        xml.missingData(attr + ' ' + message, :field => attr)
      end
    end
  end
  if @user.errors.length > 0
    xml.user do  
      @user.errors.each do |attr, message|
        xml.missingData(attr + ' ' + message, :field => attr)
      end
    end
  end
  if @member.errors.length > 0
    xml.member do  
      @member.errors.each do |attr, message|
        xml.missingData(attr + ' ' + message, :field => attr)
      end
    end
  end
end
