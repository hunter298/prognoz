require_relative 'forecast_info'

puts "Выберите город:"
cities = {1 => ['2933', 'Крменчуг'], 2 => ['9049', 'Горишние плавни'],3 => ['9087', 'Знаменка']}
cities.each do |key, val|
  puts key.to_s + '. ' + val[1]
end
print '>> '
input = STDIN.gets.chomp.to_i
city = cities[input][0]
vremia = ForecastInfo.daytime

puts
puts ForecastInfo.forecast_return vremia, city



