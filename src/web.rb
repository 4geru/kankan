
helpers do
  def protect!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    username = ENV['BASIC_AUTH_USERNAME']
    password = ENV['BASIC_AUTH_PASSWORD']
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
  end
end

logger = Logger.new(STDOUT)

get '/' do
  'ok'
end

get '/protect' do
  protect!
  'アクセス制限あり'
end

get '/api/:department/:grade/:month/:day' do
  protect!
  msg = op(params[:department], params[:grade], params[:month], params[:day])
end

get '/room/:room/:dept/:grade' do
  protect!
  room = Room.where(channel_id: params[:room])[0]

  if not room
    room = Room.create({
      channel_id: params[:room],
      department: params[:dept],
      grade: params[:grade]
    })
  else
    room.update!({
      department: params[:dept],
      grade: params[:grade]
    })
  end
end

get '/exams/:department/:grade/:month/:day' do
  protect!
  getExams(params[:department], params[:grade], params[:month], params[:day])
end

get '/exam/:department/:grade/:title' do
  protect!
  getExamsTitle(params[:department], params[:grade], params[:title].split('の')[0])
end

get '/weekday/:department/:grade/:word' do
  protect!
  getWeekName(params[:department], params[:grade], params[:word])
end

get '/weekday/time/:department/:grade/:word' do
  protect!
  getEndWeekName(params[:department], params[:grade], params[:word])
end

get '/time/:department/:grade/:month/:day' do
  protect!
  getEndTime(params[:department], params[:grade], params[:month], params[:day])
end
