class TestActionMailer < ActionMailer::Base
  def  testmail(resource = nil)
    @resource = resource
    mail(to: 'none@example.com', subject: 'testmail')
  end
end
