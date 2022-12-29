// 変数
let lastMessageTimestamp = 0; // 最新のメッセージの timestamp

// メッセージ受信用の socket
window.addEventListener("DOMContentLoaded", () => {
  // 0.5s おきにメッセージを取得する
  setInterval(async () => {
    // /fetch にリクエストを送信
    const result = await fetch(`/fetch?timestamp=${lastMessageTimestamp}`);
    showMessage(await result.json());
  }, 500);
});

// メッセージを表示
function showMessage(messages) {
  // メッセージがなければ何もしない
  if (messages.length == 0) return;
  console.log(messages)

  // メッセージを表示
  messages.forEach(message => {
    const user = message.isBot ? "you" : "me"
    switch (message["type"]) {
      case 'text':
        return $("#msgs").append(`<div class="message ${user} text">${message.text}</div>`);
      case 'image':
        return $("#msgs").append(`<div class="message ${user} img"><img src="/api-data/v2/bot/message/${message.id}/content" /></div>`);
    }
  })
  
  
  const scroll = document.querySelector("#msgs").scrollTop;
	var position = $('.message').last().offset().top;
	var bottom = scroll + position;
  console.log(scroll, position, bottom)
	$("#msgs").animate({
    scrollTop : bottom
  }, {
    queue : false
  });

  // 最新のメッセージの timestamp を更新
  lastMessageTimestamp = messages[messages.length - 1]["timestamp"];
}