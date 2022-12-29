# GenTextMessage | Text 形式の message を返す関数
def GenTextMessage(params, is_bot)
    # message を定義
    message = {}

    # message の種類を image にする
    message["type"] = "text"

    # 乱数を作成
    randomNumber = format("%014d", SecureRandom.random_number(10**14)).to_i
    # メッセージの ID を乱数にする
    message["id"] = randomNumber
    
    message["isBot"] = is_bot

    # メッセージ本文を params から取得する
    message["text"] = params["body"]

    return message
end