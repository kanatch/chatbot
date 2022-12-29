# メッセージをポーリングで取得できるようにします

# writeMessage() | $message_cache にメッセージを追加します
def writeMessage(message)
    $message_cache.push(message)
end

# fetchMessages() | timestamp 以降のメッセージを取得します
def fetchMessages(timestamp)
    messages = []
    $message_cache.each do |message|
        if message["timestamp"] > timestamp
            messages.push(message)
        end
    end
    return messages
end

