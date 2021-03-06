require 'sinatra'
require 'sinatra/flash'
require 'pg'

  use Rack::Session::Cookie, {
    secret: "officer_of_office_hours"
  }

  configure :development do
    require 'pry'
    set :db_config, { dbname: "office_hours" }
  end

  configure :production do
    uri = URI.parse(ENV["DATABASE_URL"])
    set :db_config, {
      host: uri.host,
      port: uri.port,
      dbname: uri.path.delete('/'),
      user: uri.user,
      password: uri.password
    }
  end

  def db_connection
    begin
      connection = PG.connect(settings.db_config)
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
     db_connection { |conn| conn.exec("SELECT * FROM time_slots ORDER BY id") }
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
    time_slots.each do |time_slot|
      if time_slot["day_id"] == day["id"] && time_slot["times_id"] == time["id"]
        return true if time_slot["user_id"].nil?
      end
    end
    false
  end

  def select_user(day, time)
    user_id = 0
    time_slots.each do |time_slot|
      if time_slot["day_id"] == day["id"] && time_slot["times_id"] == time["id"]
        user_id += time_slot['user_id'].to_i
          name = db_connection { |conn| conn.exec("SELECT first_name FROM users WHERE id = #{user_id}") }.to_a[0]
          return "#{name['first_name']}"
      end
    end
  end

  def this_is_your_slot(user, day, time)
    time_slots.each do |time_slot|
      if time_slot["day_id"] == day && time_slot["times_id"] == time
        if time_slot["user_id"].to_i == user
          return true
        end
      end
    end
    false
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

  def set_current_user(user)
    session[:user_id] = user[0]['id'].to_i
  end

  def signed_in?
    return false if session[:user_id].nil?
    true
  end

  def authenticate!
    unless signed_in?
      flash[:notice] = 'You need to sign in if you want to do that!'
      redirect '/'
    end
  end

  def current_user
    id = session[:user_id]
    db_connection { |conn| conn.exec("SELECT first_name FROM users WHERE id = #{id}") }.to_a[0]['first_name']
  end

  def clear_all_tables
    populate_days_table
    populate_times_table
    populate_schedule
  end

  get '/' do
    redirect '/log_in'
  end

  get '/log_in' do
    erb :log_in
  end

  get '/sign_up' do
    erb :sign_up
  end

  get '/office_hours' do
    authenticate!
    erb :index, locals: { days: days_of_the_week, times: times}
  end

  get '/temp' do
    erb :landing
  end

  post '/users/log_in' do
    user_name = params[:user_name]
    pass = params[:user_pass]
    if user_exists?(user_name, pass)
      user = db_connection { |conn| conn.exec("SELECT id FROM users WHERE user_name = '#{user_name}'") }
      set_current_user(user)
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
    redirect '/log_in'
  end

=begin
  post '/engineers/log_in' do
    user_name = params[:eng_name]
    pass = params[:eng_pass]

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
      redirect '/log_in'
    else
      db_connection { |conn| conn.exec("
        INSERT INTO engineers(user_name, first_name, last_name, password)
        VALUES ($1, $2, $3, $4)",
        [user_name, first, last, pass]) }
    end
  end
=end

  post '/office_hours' do
    user_id = session[:user_id]
    day_id = params.keys.first
    time_id = params.keys.last

    if user_id == nil
      redirect '/log_in'
    end

     unless user_signed_up?(user_id)
       db_connection { |conn| conn.exec("
         UPDATE time_slots SET user_id = #{user_id}
         WHERE day_id = #{day_id}
         AND times_id = #{time_id}") }
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
        AND times_id = #{time_id}") }
      else
    end
    redirect '/office_hours'
  end

  get '/logout' do
    session[:user_id] = nil
    redirect '/'
  end
