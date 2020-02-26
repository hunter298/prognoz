require 'rexml/document'
require 'net/http'
require 'rexml/xpath'
require 'uri'


class ForecastInfo

  @@CLOUD = {-1 => 'Сиреневый туман', 0 => 'Ясно понятно',
             1 => 'Хули тут так малооблачно', 2 => 'Облачно белогриволошадочно',
             3 => 'Илья Пасмурномец'}

  @@DAYTIME = {1 => "Сегодня ночью", 2 => "Сегодня утром", 3 => "Сегодня днем",
               4 => "Сегодня вечером", 5 => "Завтра ночью", 6 => "Завтра утром",
               7 => "Завтра днем"}

  def initialize params

    @time = Time.now
    @min_temp = params[:mint]
    @max_temp = params[:maxt]
    @max_wind = params[:maxw]
    @cloudiness = params[:cloud]
    @town_name = params[:town]

  end

  def self.get_forecast index

    uri = URI.parse("https://xml.meteoservice.ru/export/gismeteo/point/2933.xml")
    response = Net::HTTP.get_response uri
    doc = REXML::Document.new(response.body)

    town_name = URI::DEFAULT_PARSER.unescape(doc.root.elements["REPORT/TOWN"].attributes['sname'])

    forecast = REXML::XPath.each(doc, "//FORECAST").to_a[index]
    min_temp = forecast.elements['TEMPERATURE'].attributes['min']
    max_temp = forecast.elements['TEMPERATURE'].attributes['max']
    max_wind = forecast.elements['WIND'].attributes['max']
    cloudiness = forecast.elements['PHENOMENA'].attributes['cloudiness']


    return self.new(town: town_name, mint: min_temp, maxt: max_temp,
                    maxw: max_wind, cloud: cloudiness)
  end

  def to_s
    puts "погода в городе #{@town_name.split(',')[0]}:"
    puts "\u2600 Максимальная температура: #{@max_temp}\u00B0C"
    puts "\u2746 Минимальная температура: #{@min_temp}\u00B0C"
    puts "\u2691 Ветер - до #{@max_wind} м/с"
    puts "\u2601 " + @@CLOUD[@cloudiness.to_i] + '.'
  end

  def self.forecast_return daytime
    daytime.each_with_index do |time, ind|
      print @@DAYTIME[time] + ' '
      puts get_forecast(ind).to_s
      puts
    end
  end

  def self.daytime
    hour = Time.now.to_a[2]
    time_int = case hour
               when 0..5
                 1
               when 6..11
                 2
               when 12..17
                 3
               when 18..23
                 4
               end
    return [time_int, (time_int + 1), (time_int + 2), (time_int + 3)]

  end

end