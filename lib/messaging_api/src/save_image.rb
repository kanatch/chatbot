
require 'open-uri'
require 'fileutils'

# saveImage | 画像を保存する関数
def saveImage(params, messageID)
    # Base64 画像を取得
    tempfile = params["image"]["tempfile"]
    extension = File.extname(params["image"]["filename"])
    
    FileUtils.cp(tempfile, "public/data/images/#{messageID}#{extension}")

    registerImage(messageID, "public/data/images/#{messageID}#{extension}")
end

# registerImage(messageID, imagePath) | 画像をメッセージとファイルのリレーショナルテーブルに登録する
def registerImage(messageID, imagePath)
    $message_file_relation_cache[messageID] = imagePath
end