class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :set_csp
  before_action :getCitiesLinkCloud

  protected

    # Needed to easyly access google maps
    def createSimpleLocations(locations)
      simpleLocations = Array.new
      if !locations.blank?
        locations.each do |l|
          if l.geocoded?
            simpleLocation =  SimpleLocation.new()
            simpleLocation.id = l.id
            simpleLocation.listing_name = l.listing_name
            simpleLocation.latitude = l.latitude
            simpleLocation.longitude = l.longitude
            simpleLocations.push simpleLocation
          end
        end
      end
      return simpleLocations
    end

  # Load cities cloud
  def getCitiesLinkCloud
      # Cache these a bit?
      @linkClouds =  Location.where(active: true).select('city').group('city').order('city')
  end

  def set_csp
    # Set all restrictions for content security
    response.headers['Content-Security-Policy'] =
      "default-src 'none';" \
      "script-src 'self' js.stripe.com www.googletagmanager.com google-analytics.com www.google-analytics.com maps.googleapis.com connect.facebook.net cdnjs.cloudflare.com;" \
      "img-src 'self' www.gravatar.com maps.googleapis.com www.google-analytics.com maps.gstatic.com graph.facebook.com platform-lookaside.fbsbx.com www.facebook.com lookaside.facebook.com s3.eu-central-1.amazonaws.com;" \
      "style-src 'self' 'unsafe-inline' *.googleapis.com cdnjs.cloudflare.com;" \
      "font-src  'self' fonts.gstatic.com;"\
      "child-src 'self' js.stripe.com staticxx.facebook.com www.facebook.com;" \
      "connect-src 'self' api.stripe.com www.google-analytics.com;"\
      "frame-src 'self' js.stripe.com;" \
      "form-action 'self';"\
      "base-uri 'self'"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:fullname])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[fullname phone_number description language_id])
  end

  # Redirect after login
  def after_sign_in_path_for(_resource_or_scope)
    dashboard_path
  end

  private

  # sets the localizaton from request Header
  def set_locale
    if current_user.blank?
      I18n.locale = get_valid_language
      logger.debug "* Locale set to '#{I18n.locale}'"
    else
      I18n.locale = current_user.language_id
    end
  end

  # Returns a valid language ID. Fall back to a default
  def get_valid_language
    locale = extract_locale_from_accept_language_header
    logger.debug "* Extracted Locale ID: #{locale}"
    if !locale.blank? &&
      (locale == "de" ||
        locale == "en")
        locale
    else
      DEFAULT_LANGUAGE
    end
  end

  # extracts the accept-language header
  def extract_locale_from_accept_language_header
    accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
    logger.debug "* Accept-Language from header: #{accept_language}"
    return accept_language.scan(/^[a-z]{2}/).first if accept_language
  end
end