require 'sinatra'
require 'pry'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: "office_hours")
    yield(connection)
  ensure
    connection.close
  end
end

  # days = [ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
  # days.each do |day|
  #   db_connection { |conn| conn.exec("INSERT INTO days(day) VALUES ('#{day}')") }
  # end
  #
  # times = [ '1:00 - 1:20', '1:20 - 1:40', '1:40 - 2:00', '2:00 - 2:20', '2:20 - 2:40', '2:40 - 3:00', '3:00 - 3:20', '3:20 - 3:40', '3:40 - 4:00' ]
  # times.each do |time|
  #   db_connection { |conn| conn.exec("INSERT INTO times(time_slot) VALUES ('#{time}')") }
  # end
  #
  # users = [ ['LaMonte', 'Fields', 'Password1']]
  # users.each do |user|
  #   db_connection { |conn| conn.exec("INSERT INTO users(first_name, last_name, password) VALUES ('#{user[0]}', '#{user[1]}', '#{user[2]}')") }
  # end
  #
  # engineers = [ ['Alex', 'Jarvis', 'AsBucknuttyAsIWannaBe'], ]
  # engineers.each do |ee|
  #   db_connection { |conn| conn.exec("INSERT INTO engineers(first_name, last_name, password) VALUES ('#{ee[0]}', '#{ee[1]}', '#{ee[2]}')") }
  # end

  # Works db_connection { |conn| conn.exec("SELECT first_name, last_name, password FROM users WHERE id = 1") }

def days_of_the_week
   db_connection { |conn| conn.exec("SELECT * FROM days") }
end

def time_slots
   db_connection { |conn| conn.exec("SELECT * FROM times") }
end

def users
  first = params[:user_first]
  last = params[:user_last]
  password = params[:user_pass]
  if
    db_connection { |conn| conn.exec_params("SELECT users(first_name, last_name) VALUES ($1, $2)", [first, last]) }
  else
    db_connection { |conn| conn.exec_params("INSERT INTO engineers(first_name, last_name, password) VALUES ($1, $2, $3)", [first, last, password]) }
  end
end

def engineers
  first = params[:eng_first]
  last = params[:eng_name]
  password = params[:eng_pass]
  if
    db_connection { |conn| conn.exec_params("SELECT engineers(first_name, last_name) VALUES ($1, $2, $3)", [first, last]) }
  else
    db_connection { |conn| conn.exec_params("INSERT INTO engineers(first_name, last_name, password) VALUES ($1, $2, $3)", [first, last, password]) }
  end
end

def populate_schedule
  db_connection { |conn| conn.exec(
    "INSERT INTO time_slots (day_id, times_id)
    JOIN days ON time_slots.day_id = days.id
    JOIN times ON time_slots.time_id = times.id") }
end

get '/' do
  redirect '/sign_up'
end

get '/sign_up' do
  erb :sign_up
end

get '/office_hours' do
  #The name of the form tabs in this form is the day of the week followed by the time slot EX. name="Monday 1:00 - 1:20"
  erb :index, locals: { days: days_of_the_week, times: time_slots}
end

post '/users' do
  first = params[:user_first]
  last = params[:user_last]
  if
    db_connection { |conn| conn.exec("SELECT id FROM users WHERE users.first_name = '#{first}' AND users.last_name = '#{last}'") } == 1
    true
  else
    false
  end
  redirect '/office_hours'
end

post '/slots' do
  #binding.pry
  first = params[:user_first]
  last = params[:user_last]
  if
    db_connection { |conn| conn.exec("INSERT INTO first_name, last_name FROM users WHERE users.first_name = #{first} AND users.last_name = #{last}") }
    true
  else
    false
  end
  redirect '/office_hours'
end

=begin
add slots
interate throught the slots so that the populate correctly
get user id  from the  session data
and then update the slot with the user id
=end
