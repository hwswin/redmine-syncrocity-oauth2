class OauthController < ApplicationController
  skip_before_filter :check_if_login_required


  def login
    Rails.logger.info "authorize_url = #{authorize_url}"
    redirect_to authorize_url
  end

  def callback
    token = get_token(params[:code])
    oauth_hash = get_me(token)
    return invalid_credentials unless oauth_hash
    if user = User.find_by_oauth_id(oauth_hash['id']) # Login of already oauth -enabled user
      self.logged_user = user
      redirect_to home_path
    elsif user = User.find_by_mail(oauth_hash['email']) # User found, but OAuth id is not bind yet
      redirect_to request_oauth_binding_permission_path(user, oauth_hash['id'])
    else # User not found neither by email nor by Oauth id
      Rails.logger.info oauth_hash.inspect
      user = User.where(oauth_id: oauth_hash['id']).first_or_create
      if user.new_record?
        user.login = oauth_hash['login']
        user.mail = oauth_hash['email']
        user.firstname = oauth_hash['name']
        user.lastname = oauth_hash['surname']
        user.random_password
        user.register
        user.activate
        user.admin = oauth_hash['roles'].include?('admin')
        user.last_login_on = Time.now
        if user.save
          if Setting.plugin_redmine_oauth_client[:notify_admin_on_new_users]
            OauthMailer.notify_admin_on_new_user(user).deliver
          end
          self.logged_user = user
          redirect_to home_path
        else
          flash[:error] = user.errors.full_messages.join("<br/>").html_safe
          redirect_to signin_path
        end
      end
    end
  end

  def request_oauth_binding_permission
    @user = User.find(params[:id])
    @oauth_id = params[:oauth_id]
  end

  def submit_oauth_binding_permission
    @user = User.find(params[:id])
    @oauth_id = params[:oauth_id]
    if params[:bind_oauth] == '1'
      ob_request = OauthBindingRequest.create(user: @user, oauth_id: @oauth_id, token: SecureRandom.hex(32))
      OauthMailer.send_binding_confirmation(ob_request).deliver
      flash[:notice] = l(:label_please_confirm)
      redirect_to signin_path

    else
      flash[:error] = I18n.t(:oauth_binding_cancelled)
      redirect_to signin_path
    end
  end

  def confirm_binding
    t = params[:token]
    rq = OauthBindingRequest.find_by_token(t)
    if rq
      rq.user.update_attribute(:oauth_id, rq.oauth_id)
      self.logged_user = rq.user
      rq.destroy
      redirect_to home_path
    else
      flash[:error] = I18n.t(:token_not_found)
      redirect_to signin_path
    end
  end

  private

  def invalid_credentials
    flash[:error] = l(:notice_account_invalid_creditentials)
    redirect_to signin_path
  end

  def authorize_url
    "#{authorize_endpoint}?response_type=code&client_id=#{app_id}&redirect_uri=#{redirect_uri}"
  end

  def authorize_endpoint
    "http://www.test.linkerplus.com/o/authorize/"
    #Setting.plugin_redmine_oauth_client[:authorize_endpoint_url]
  end

  def app_id
    "6vfgY6XWlPyi2fSzYBipL9aY53xkJ80BIS4F8j3u"
    #Setting.plugin_redmine_oauth_client[:app_id]
  end

  def redirect_uri
    @redirect_uri ||= view_context.oauth_callback_url
  end

  def token_endpoint
    "http://www.test.linkerplus.com/o/token/"
    #Setting.plugin_redmine_oauth_client[:token_endpoint_url]
  end

  def app_secret
    "1UD9hyFfI9NeOf4V6TqgGHstir0Vp5K7vTroDay3VTvPRbmup7vaGRrYlxV6j2SodaBppwmEx6qPefJnujJmCZ8g1RkAPGc1QQQJi1vG1TgP0s4vMbHFZReoB0wUOpl1"
    #Setting.plugin_redmine_oauth_client[:app_secret]
  end

  def get_token(code)
    response = Net::HTTP.post_form(URI.parse(token_endpoint), client_id: app_id, redirect_uri: redirect_uri, client_secret: app_secret, code: code, grant_type: 'authorization_code')
    Rails.logger.info "Body = #{response.body}"
    token = JSON.parse(response.body)['access_token']
    Rails.logger.info "token = #{token}"
    token
  end

  def api_me
    "http://www.test.linkerplus.com/o/profile/"
    #Setting.plugin_redmine_oauth_client[:api_endpoint_url]
  end

  def get_me(token)
    uri = "#{api_me}?access_token=#{token}"
    Rails.logger.info "uri = #{uri}"
    response = Net::HTTP.get(URI.parse(uri))
    Rails.logger.info "response = #{response}"
    JSON.parse response rescue nil
  end
end
