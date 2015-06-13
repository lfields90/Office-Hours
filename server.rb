require 'sinatra'
require 'pry'
require 'pg'

use Rack::Session::Cookie, {
  secret: "officer_of_office_hours"
}

def db_connection
  begin
    connection = PG.connect(dbname: "office_hours")
    yield(connection)
  ensure
    connection.close
  end
end

def populate_days_table
  days = [ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
  days.each do |day|
    db_connection { |conn| conn.exec("INSERT INTO days(day) VALUES ('#{day}')") }
  end
end

def populate_times_table
  times = [ '1:00 - 1:20', '1:20 - 1:40', '1:40 - 2:00', '2:00 - 2:20', '2:20 - 2:40', '2:40 - 3:00' ]
  times.each do |time|
    db_connection { |conn| conn.exec("INSERT INTO times(time_slot) VALUES ('#{time}')") }
  end
end

def populate_users_table
  users = [ ['Twelvy', 'LaMonte', 'Fields', 'Password1']]
  users.each do |user|
    db_connection { |conn| conn.exec("INSERT INTO users(user_name, first_name, last_name, password) VALUES ('#{user[0]}', '#{user[1]}', '#{user[2]}', '#{user[3]}')") }
  end
end

def populate_engineers_table
  engineers = [ ['Bucknutty', 'Alex', 'Jarvis', 'AsBucknuttyAsIWannaBe'], ]
  engineers.each do |ee|
    db_connection { |conn| conn.exec("INSERT INTO engineers(user_name, first_name, last_name, password) VALUES ('#{ee[0]}', '#{ee[1]}', '#{ee[2]}', '#{ee[3]}')") }
  end
end

def times
   db_connection { |conn| conn.exec("SELECT * FROM times") }
end

def users
   db_connection { |conn| conn.exec("SELECT * FROM users") }
end

def engineers
   db_connection { |conn| conn.exec("SELECT * FROM engineers") }
end

def days_of_the_week
   db_connection { |conn| conn.exec("SELECT * FROM days") }
end

def time_slots
   db_connection { |conn| conn.exec("SELECT * FROM time_slots") }
end

def populate_schedule
  days_of_the_week.each do |day|
    times.each do |time|
      db_connection { |conn| conn.exec(
        "INSERT INTO time_slots (day_id, times_id) VALUES (#{day['id']}, #{time['id']})") }
    end
  end
end

def time_slot_available?(day, time)
  flag = false
  time_slots.each do |time_slot|
    if time_slot["day_id"] == day["id"] && time_slot["times_id"] == time["id"]
      if time_slot["user_id"].nil?
        flag = true
      end
    end
  end
  flag
end

def select_user(day, time)
  user_id = 0
  string = ""
  time_slots.each do |time_slot|
    if time_slot["day_id"] == day["id"] && time_slot["times_id"] == time["id"]
      user_id += time_slot['user_id'].to_i
        name = db_connection { |conn| conn.exec("SELECT first_name FROM users WHERE id = #{user_id}") }.to_a[0]
        string += "#{name['first_name']}"
    end
  end
  string
end

def this_is_your_slot(user, day, time)
  time_slots.each do |time_slot|
    if time_slot["day_id"] == day && time_slot["times_id"] == time
      if time_slot["user_id"].to_i == user
        return true
      else
        return false
      end
    end
  end
end

def user_signed_up?(id)
  time_slots.each do |time_slot|
    if time_slot["user_id"].to_i == id
      return true
    end
  end
  false
end

def user_exists?(user_name, pass)
  flag = false
  users.each do |user|
    if user['user_name'] == user_name && user['password'] == pass
      flag = true
    end
  end
  flag
end

def eng_exists?(user_name, pass)
  flag = false
  engineers.each do |eng|
    if eng['user_name'] == user_name && eng['password'] == pass
      flag = true
    end
  end
  flag
end

def clear_all_tables
  populate_days_table
  populate_times_table
  populate_users_table
  populate_engineers_table
  populate_schedule
end

#Works db_connection { |conn| conn.exec("SELECT first_name, last_name, password FROM users WHERE id = 1") }

get '/' do
  redirect '/sign_in'
  erb :landing
end

get '/sign_in' do
  erb :sign_in
end

get '/office_hours' do
  erb :index, locals: { days: days_of_the_week, times: times}
end

get '/sign_up' do
  erb :sign_up
end

post '/users/sign_in' do
  user_name = params[:user_name]
  pass = params[:user_pass]
  if user_exists?(user_name, pass)
    me = db_connection { |conn| conn.exec("SELECT id FROM users WHERE user_name = '#{user_name}'") }
    session[:user_id] = me[0]['id'].to_i
    redirect '/office_hours'
  else
    redirect '/sign_up'
  end
end

post '/users/sign_up' do
  first = params[:user_first]
  last = params[:user_last]
  user_name = params[:user_name]
  pass = params[:user_pass]
  if
    user_exists?(user_name, pass)
  else
    db_connection { |conn| conn.exec("
      INSERT INTO users(user_name, first_name, last_name, password)
      VALUES ($1, $2, $3, $4)",
      [user_name, first, last, pass]) }
  end
  redirect '/sign_in'
end

post '/engineers/sign_in' do
  user_name = params[:eng_name]
  pass = params[:eng_pass]
  binding.pry
  if
    eng_exists?(user_name, pass)
    redirect '/office_hours'
  else
    redirect '/sign_up'
  end
end

post '/engineers/sign_up' do
  first = params[:eng_first]
  last = params[:eng_last]
  user_name = params[:eng_name]
  pass = params[:eng_pass]
  if
    user_exists?(user_name, pass)
    redirect '/sign_in'
  else
    db_connection { |conn| conn.exec("
      INSERT INTO engineers(user_name, first_name, last_name, password)
      VALUES ($1, $2, $3, $4)",
      [user_name, first, last, pass]) }
  end
end

post '/office_hours' do
  user_id = session[:user_id]
  day_id = params.keys.first
  time_id = params.keys.last
   unless user_signed_up?(user_id)
    db_connection { |conn| conn.exec("
      UPDATE time_slots
      SET user_id = #{user_id}
      WHERE day_id = #{day_id}
      AND times_id = #{time_id}
      ") }
   end
  redirect '/office_hours'
end

post '/deselect' do
  user_id = session[:user_id]
  day_id = params.keys.first
  time_id = params.keys.last

  if this_is_your_slot(user_id, day_id, time_id)
    db_connection { |conn| conn.exec("
      UPDATE time_slots
      SET user_id = NULL
      WHERE day_id = #{day_id}
      AND times_id = #{time_id}
      ") }
    else
  end
  redirect '/office_hours'
end

post '/logout' do
  session[:user_id] = nil
  redirect '/sign_in'
end
