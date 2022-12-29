# GenImageMessage | Image 形式の message を返す関数
def GenImageMessage(params, is_bot)
    # 乱数を作成
    randomNumber = format("%014d", SecureRandom.random_number(10**14)).to_i

    # message を定義
    message = {
        # message の種類を image にする
        "type" => "image",
        # メッセージの ID を乱数にする
        "id" => randomNumber
    }

    # contentProvider を定義, type は "line" 固定?
    message["contentProvider"] = {
        "type" => "line"
    }

    message["isBot"] = is_bot

    return message
end