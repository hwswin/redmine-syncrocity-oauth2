class OauthMailer < ActionMailer::Base
  include Redmine::I18n

  helper :application

  attr_reader :email, :user

  def self.default_url_options
    h = Setting.host_name
    h = h.to_s.gsub(%r{\/.*$}, '') unless Redmine::Utils.relative_url_root.blank?
    { :host => h, :protocol => Setting.protocol }
  end

  def notify_admin_on_new_user(user)
    @user = user
    @user_path = edit_user_url(@user)
    User.where(admin: true).find_each do |admin|
      mail(:from => Setting['mail_from'],
           :to => user.mail,
           :subject => I18n.t(:new_user_subject)) do |format|
        format.text
        format.html
      end
    end
  end

  def send_binding_confirmation(rq)
    @user = rq.user
    @confirm_binding_path = confirm_oauth_binding_url(rq.token)
    mail(
        :from => Setting['mail_from'],
        :to => @user.mail,
        :subject => I18n.t(:binding_confirmation_subject)
    ) do |format|
      format.text
      format.html
    end
  end
end