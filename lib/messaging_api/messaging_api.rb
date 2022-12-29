require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'securerandom'
require 'uri'
require 'net/http'
require 'base64'
require 'openssl'
require 'json'
require 'securerandom'
require "fileutils"
require "logger"

require "./lib/messaging_api/src/manage_messages"
require "./lib/messaging_api/src/gen_source"
require "./lib/messaging_api/src/gen_text_message"
require "./lib/messaging_api/src/gen_image_message"
require "./lib/messaging_api/src/save_image"
require "./lib/messaging_api/src/auth"

warn_level = $VERBOSE
$VERBOSE = nil

Line::Bot::API::DEFAULT_OAUTH_ENDPOINT = "https://chatbot-production-c38a.up.railway.app"
Line::Bot::API::DEFAULT_ENDPOINT = "https://chatbot-production-c38a.up.railway.app/v2"
Line::Bot::API::DEFAULT_BLOB_ENDPOINT = "https://chatbot-production-c38a.up.railway.app/api-data/v2"
Line::Bot::API::DEFAULT_LIFF_ENDPOINT = "https://chatbot-production-c38a.up.railway.app/liff/v1"

$VERBOSE = warn_level

# 画像データ保存用のディレクトリを作成
FileUtils.mkdir_p( "public/data/images" ) unless Dir.exist?("public/data/images")

# メッセージキャッシュを初期化する
$message_cache = []
# メッセージとファイルのリレーショナルテーブルを初期化する
$message_file_relation_cache = Hash.new

set :logging, false
set :protection, :except => :frame_options

# チャットアプリ
get '/' do
    erb :index
end

# メッセージアプリがメッセージを受けとる
get '/fetch' do
    # メッセージを取得する
    messages = fetchMessages(params["timestamp"].to_i)

    # メッセージを返す
    return messages.to_json
end

# API 本体
post '/api' do
    # 現在時刻を取得
    timestamp = (Time.now.to_f * 1000).to_i

    # BOT に送信する変数を定義
    content = {}

    # destination を定義
    content["destination"] = "destination"

    # events を定義
    content["events"] = []

    # 1 つのイベントを定義
    event = {}

    # 送るイベントの種類を "message" にする
    event["type"] = "message"

    # 送られてきた message を組み立てる
    # text メッセージの場合
    if params["contentType"] == "text"
        textMessage = GenTextMessage(params, false)
        event["message"] = textMessage

        # メッセージをサーバに保存
        textMessage["timestamp"] = timestamp
        writeMessage(textMessage)

    # image メッセージの場合
    elsif params["contentType"] == "image"
        imageMessage = GenImageMessage(params, false)
        event["message"] = imageMessage

        # 画像をサーバに保存
        saveImage(params, imageMessage["id"])

        # メッセージをサーバに保存
        imageMessage["timestamp"] = timestamp
        writeMessage(imageMessage)

    # それ以外の場合は 400 エラーを返す
    else
        status 400
    end

    # timestamp を生成
    event["timestamp"] = timestamp

    # source を作成
    event["source"] = GenSource(params)

    # reply のためのトークンを作成
    event["replyToken"] = SecureRandom.hex(16)

    # mode を active にする
    event["mode"] = "active"

    # events に event を追加
    content["events"].append(event)
    
    # BOT にリクエストを送信
    uri = URI.parse("https://chatbot-production-c38a.up.railway.app/callback")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    headers = { "X-Line-Signature" => Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), ENV["LINE_CHANNEL_SECRET"], content.to_json)).chomp }

    response = http.post(uri.path, content.to_json, headers)

    # エラーが発生した場合は 500 エラーを返す
    if response.code != "200"
        status 500
    end

    # 成功時は OK
    "OK"
end

# BOT からのメッセージを受け取る
post '/v2/bot/message/reply' do
    # 認証
    auth_token = request.env["HTTP_AUTHORIZATION"]
    unless authorization(auth_token)
        status 401
    end

    # BOT からの返信
    body = request.body.read # body を読み込む (json)
    body_hash = JSON.parse(body) # body を hash に変換

    # サーバにメッセージを保存
    timestamp = (Time.now.to_f * 1000).to_i # 現在時刻を取得
    messages = body_hash["messages"] # messages のみを取得
    messages.each do |message|
        # 乱数を作成
        randomNumber = format("%014d", SecureRandom.random_number(10**14)).to_i
        message["id"] = randomNumber # id を乱数に変更
        message["timestamp"] = timestamp # timestamp を追加
        message["isBot"] = true

        if message["type"] == "image"
            registerImage(message["id"], message["originalContentUrl"])
        end

        writeMessage(message) # メッセージをサーバに保存
    end
end

# メッセージのコンテンツを提供する
get '/api-data/v2/bot/message/:messageID/content' do
    # ファイルパスを取得
    filePath = $message_file_relation_cache[params["messageID"].to_i]

    # http から始まれば リダイレクト
    if filePath.start_with?("http")
        redirect filePath
    end

    # そうでなければファイルを返す
    send_file(filePath)
end
