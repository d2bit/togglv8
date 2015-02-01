require 'rubygems'
require 'logger'
require 'faraday'
require 'json'

require 'awesome_print' # for debug output

module TogglConn
  URL_APIS = { 'TogglV8' => 'https://www.toggl.com/api/v8',
               'TogglReports' => 'https://toggl.com/reports/api/v2' }

  def initialize(username = nil, password = 'api_token', debug = nil)
    debug_on(debug) if debug
    if (password.to_s == 'api_token' && username.to_s == '')
      toggl_api_file = "#{ ENV['HOME'] }/.toggl"
      if FileTest.exist?(toggl_api_file) then
        username = IO.read(toggl_api_file).strip
      else
        raise SystemCallError, "Expecting api_token in file ~/.toggl or parameters (api_token) or (username, password)"
      end
    end

    @api_url = URL_APIS[self.class.to_s]
    @conn = connection(username, password)
  end

  def connection(username, password)
    Faraday.new(url: @api_url) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger, Logger.new('faraday.log')
      faraday.adapter Faraday.default_adapter
      faraday.headers = { "Content-Type" => "application/json" }
      faraday.basic_auth username, password
    end
  end

  def debug_on(debug=true)
    puts "debugging is %s" % [debug ? "ON" : "OFF"]
    @debug = debug
  end

  private

  def get(resource)
    puts "GET #{ resource }" if @debug
    full_res = @conn.get(resource)
    # ap full_res.env if @debug
    res = JSON.parse(full_res.env[:body])
    res.is_a?(Array) || res['data'].nil? ? res : res['data']
  end

  def post(resource, data)
    puts "POST #{ resource } / #{ data }" if @debug
    full_res = @conn.post(resource, JSON.generate(data))
    ap full_res.env if @debug
    if (200 == full_res.env[:status]) then
      res = JSON.parse(full_res.env[:body])
      res['data'].nil? ? res : res['data']
    else
      eval(full_res.env[:body])
    end
  end

  def put(resource, data)
    puts "PUT #{ resource } / #{ data }" if @debug
    full_res = @conn.put(resource, JSON.generate(data))
    # ap full_res.env if @debug
    res = JSON.parse(full_res.env[:body])
    res['data'].nil? ? res : res['data']
  end

  def delete(resource)
    puts "DELETE #{ resource }" if @debug
    full_res = @conn.delete(resource)
    # ap full_res.env if @debug
    (200 == full_res.env[:status]) ? "" : eval(full_res.env[:body])
  end
end
