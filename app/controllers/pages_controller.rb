# frozen_string_literal: true

require 'simpleLocation'

##
# Top level class
class PagesController < ApplicationController
  # Show only unrestriced locations on main Page
  def home

    @locations = random_locations
    @cities = cities.sample(4)
    @recent_locations = Location.where(active: true, isRestricted: false)
                                .order(:created_at)
                                .reverse_order
                                .limit(3)
  end

  def random_locations
    sql = 'SELECT * from LOCATIONS WHERE active = true AND "isRestricted" = false ORDER BY Random() LIMIT 3'
    Location.find_by_sql(sql)
  end

  def search
    if params[:search].present? && params[:search].strip != ''
      session[:loc_search] = params[:search]
    end

    if session[:loc_search] && session[:loc_search] != ''
      logger.debug " * Location query on geocordinates with #{session[:loc_search]}"
      locations = Location.where(active: true)
                          .near(session[:loc_search], 15, order: 'distance')
      # logger.debug " Found in geocordinates: #{locations.count(:all)}"
    end

    if locations.blank?
      logger.debug ' * Location query with like on name'
      locations = Location.where('active = true and listing_name ilike ?', "%#{session[:loc_search]}%")
      # logger.debug " Found in names: #{locations.count(:all)}"
    end

    if locations.blank?
      # Show "No found page"
      # Redirect is handled in View'
    end

    # Step 3 - Ransack filters in memory other data (Ameni)
    #          maybe too much data in future!
    @search = locations.ransack(params[:q])
    @locations = @search.result
    @simple_locations = create_simple_locations(@locations)
  end

  def cities
    cities_ = [{ query: 'search?utf8=✓&search=Dortmund+-+Germany',
                 name: 'Dortmund',
                 folderName: 'dortmund',
                 imageName: 'dortmund.jpg' },
               { query: 'search?utf8=✓&search=Berlin+-+Germany',
                 name: 'Berlin',
                 folderName: 'berlin',
                 imageName: 'berlin.jpg' },
               { query: 'search?utf8=✓&search=bochum+-+Germany',
                 name: 'Bochum',
                 folderName: 'bochum',
                 imageName: 'bochum.jpg' },
               { query: 'search?utf8=✓&search=Dresden+-+Germany',
                 name: 'Dresden',
                 folderName: 'dresden',
                 imageName: 'dresden.jpg' },
               { query: 'search?utf8=✓&search=düsseldorf+-+Germany',
                 name: 'Düsseldorf',
                 folderName: 'duesseldorf',
                 imageName: 'duesseldorf.jpg' },
               { query: 'search?utf8=✓&search=Freiburg+-+Germany',
                 name: 'Freiburg',
                 folderName: 'freiburg',
                 imageName: 'freiburg.jpg' },
               { query: 'search?utf8=✓&search=Heidelberg+-+Germany',
                 name: 'Heidelberg',
                 folderName: 'heidelberg',
                 imageName: 'heidelberg.jpg' },
               { query: 'search?utf8=✓&search=Heidelberg+-+Germany',
                 name: 'Heidelberg',
                 folderName: 'heidelberg',
                 imageName: 'heidelberg1.jpg' },
               { query: 'search?utf8=✓&search=Köln+-+Germany',
                 name: 'Köln',
                 folderName: 'koeln',
                 imageName: 'koeln.jpg' },
               { query: 'search?utf8=✓&search=Lauffen+am+Neckar%2C+Germany',
                 name: 'Lauffen am Neckar',
                 folderName: 'laufen_am_neckar',
                 imageName: 'laufen_am_neckar.jpg' },
               { query: 'search?utf8=✓&search=München+-+Germany',
                 name: 'München',
                 folderName: 'muenchen',
                 imageName: 'muenchen.jpg' },
               { query: 'search?utf8=✓&search=Warstein+-+Germany',
                 name: 'Warstein',
                 folderName: 'warstein',
                 imageName: 'warstein.jpg' },
               { query: 'search?utf8=✓&search=Zandvoort%2C+Netherlands',
                 name: 'Zandvoort',
                 folderName: 'zandvoort',
                 imageName: 'zandvoort.jpg' }]

    cities_
  end

  # from this folder - pic a image
  def pic_a_file(folderName); end
end
