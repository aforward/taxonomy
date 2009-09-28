require File.dirname(__FILE__) + '/../test_helper'
require 'password_mailer'

class PasswordMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  fixtures :users

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.mime_version= "1.0"
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_password
  
    @expected.subject = 'Software Application Taxonomy - Your Secret Password'
    @expected.body    = read_fixture('password')
    @expected.date    = Time.now
    @expected.from    = "aforward@site.uottawa.ca" 
    @expected.to      = 'james@email.ca'  

    assert_equal @expected.encoded, PasswordMailer.create_password(users(:james), @expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/password_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end