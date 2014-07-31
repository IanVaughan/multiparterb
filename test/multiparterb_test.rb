require "test_helper"

class Notifier < ActionMailer::Base
  self.view_paths = File.expand_path("../views", __FILE__)

  layout false

  # TODO: want this to output both html and text, unless gem option given to give preferance
  # mail(:to => @recipient, :from => "john.doe@example.com")

  def contact(recipient, format_type)
    @recipient = recipient
    mail(:to => @recipient, :from => "john.doe@example.com") do |format|
      format.send(format_type)
    end
  end

  def link(format_type)
    mail(:to => 'foo@bar.com', :from => "john.doe@example.com") do |format|
      format.send(format_type)
    end
  end

  def user(format_type)
    mail(:to => 'foo@bar.com', :from => "john.doe@example.com") do |format|
      format.send(format_type)
    end
  end

  def multiple_format_contact(recipient)
    @recipient = recipient
    mail(:to => @recipient, :from => "john.doe@example.com", :template => "contact") do |format|
      format.text  { render 'contact' }
      format.html  { render 'contact' }
    end
  end
end

class MultipartErbTest < ActiveSupport::TestCase
  setup do
    MultipartErb.html_formatter = MyHTMLFormatter.new
    MultipartErb.text_formatter = MyTextFormatter.new
  end

  test "plain text should be sent as a plain text" do
    email = Notifier.contact("you@example.com", :text)
    assert_equal "text/plain", email.mime_type
    assert_equal "Contact Heading", email.body.encoded.strip
  end

  test "html should be sent as html" do
    email = Notifier.contact("you@example.com", :html)
    assert_equal "text/html", email.mime_type
    assert_equal "<h1>Contact Heading</h1>", email.body.encoded.strip
  end

  test 'dealing with multipart e-mails' do
    email = Notifier.multiple_format_contact("you@example.com")
    assert_equal 2, email.parts.size
    assert_equal "multipart/alternative", email.mime_type
    assert_equal "text/plain", email.parts[0].mime_type
    assert_equal "Contact Heading", email.parts[0].body.encoded.strip
    assert_equal "text/html", email.parts[1].mime_type
    assert_equal "<h1>Contact Heading</h1>", email.parts[1].body.encoded.strip
  end

  test 'with link' do
    email = Notifier.link(:html)
    assert_equal "text/html", email.mime_type
    assert_equal "<p>A link to <a href=\"https://econsultancy.com\">Econsultancy</a></p>", email.body.encoded.strip
  end

  test 'with partial' do
    email = Notifier.user(:html)
    assert_equal "text/html", email.mime_type
    #assert_equal '<p>User template rendering a partial User Info Partial</p>', email.body.encoded.strip
  end
end
