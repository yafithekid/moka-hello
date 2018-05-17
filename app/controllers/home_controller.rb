class HomeController < ApplicationController
  def index
  end

  def refresh_token
    return_to = params[:return_to]
    refresh_token = session[:refresh_token]
    uri = URI("#{ENV['MOKA_HOST_PROVIDER']}/oauth/token")
    res = Net::HTTP.post_form(uri, 'grant_type' => 'refresh_token', 'client_id' => ENV['MOKA_APP_ID'], 'client_secret' => ENV['MOKA_SECRET_KEY'], 'refresh_token' => refresh_token)
    new_credential = JSON.parse(res.body)
    session[:access_token] = new_credential["access_token"]
    session[:refresh_token] = new_credential["refresh_token"]
    session[:expires_at] = new_credential["expires_at"]
    redirect_to return_to.present? ? return_to : root_path
  end


  def register
    @profile = call_profile
    @business = call_business['data']['business']
  end

  private
  def call_profile
    uri = URI("#{ENV['MOKA_HOST_PROVIDER']}/v1/profile/self")
    params = {access_token: session[:access_token]}
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get(uri)
    JSON.parse(res)
  end

  def call_business
    uri = URI("#{ENV['MOKA_HOST_PROVIDER']}/v1/businesses")
    params = {access_token: session[:access_token]}
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get(uri)
    JSON.parse(res)
  end
end
