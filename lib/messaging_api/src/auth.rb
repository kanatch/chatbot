# authorization | トークンを認証する
def authorization(token)
    # 認証に失敗したら false を返す
    if token != "Bearer #{ENV["LINE_CHANNEL_TOKEN"]}"
        return false
    end

    return true
end