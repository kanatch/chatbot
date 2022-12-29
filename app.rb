require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require "fileutils"
require './models/chatdatas.rb'

# もし開発環境であれば MessagingAPI も実行する
if development?
  require './lib/messaging_api/messaging_api'
end

# .env ファイルを読み込む
Dotenv.load

# 画像データ保存用のディレクトリを作成
FileUtils.mkdir_p( "data" ) unless Dir.exist?("data")

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    logger.warn("400")
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  
  events.each do |event|
    
    array = ["https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200467/IMG_2645_yghc3f.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200467/IMG_2643_ab0yej.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200467/IMG_2644_kf809e.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200467/IMG_2642_bqxol3.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200467/IMG_2647_fpwczb.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200467/IMG_2646_uy9j5c.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200467/IMG_2649_yyglto.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200468/IMG_2632_dkk2uq.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200467/IMG_2634_jqwbsj.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200468/IMG_2633_zwzg3s.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200467/IMG_2648_nkzujs.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200468/IMG_2650_jqx56j.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200468/IMG_2640_seb4zn.jpg","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200469/IMG_2651_wdprg6.png","https://res.cloudinary.com/dt0eln0vx/image/upload/v1672200469/IMG_2637_k4bnaq.png"]
    array.shuffle
    imag = array[0]
    pass = Chatdatas.find_by(keyword: event.message['text'])
    
    
    if pass
    
     message = {
      type: 'text',
      text: pass.replytext
    }
    
    elsif event.message['text'] == "ゆーとらぶ"
      
      message = {
        type: 'image',
        originalContentUrl: array[rand(array.length)],
        previewImageUrl: array[rand(array.length)]
      }
      
    else
      
     message = {
      type: 'text',
      text: event.message['text']
    }
    
    end
    client.reply_message(event['replyToken'], message)
  end

  "OK"
end


get '/admin' do
  erb :admin
end

post '/admin' do
  Chatdatas.all
  data = Chatdatas.create(replytext: params[:text], keyword: params[:keyword])
  if data
    puts 1111111111111111111111111
    puts 1111111111111111111111111
    puts 1111111111111111111111111
    puts 1111111111111111111111111
    puts 1111111111111111111111111
  end
  redirect '/'
end