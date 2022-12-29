// 定数
const USER_ID = "42151500350573"; // ユーザ ID の指定
let sending = false;

window.addEventListener("DOMContentLoaded", () => {
  const submitButton = document.querySelector("#submitButton");
  const messageForm = document.querySelector("#messageForm");
  const imageForm = document.querySelector("#imageForm");

  // 送信ボタンを押したときの処理
  submitButton.addEventListener("click", () => {
    send();
  });
  
  // Enterキーを押下したときの処理
	messageForm.addEventListener("keydown", e => {
		if(e.repeat) return e.preventDefault();
		if(e.keyCode == 13) {
			e.preventDefault();
      send();
		}
	})
	
	async function send() {
	  if (sending) return;
	  sending = true;
    if (messageForm.value == "") {
      if (!imageForm.files[0]) return; // 画像がなければ何もしない
      await sendMessage(imageForm.files[0], "image");
    } else {
      await sendMessage(messageForm.value, "text");
    }
    messageForm.value = "";
    imageForm.value = "";
    
		$('#messageForm').attr('placeholder', 'Aa');
		$('#messageForm').prop('disabled', false);
		sending = false;
	}

  // メッセージの送信
  // type = "text" or "image"
  async function sendMessage(body, type) {
    // 送信データの準備
    const formData = new FormData();
    formData.append('id', USER_ID);
    formData.append('contentType', type);
    
    switch (type) {
      case "image": formData.append('image', body); break;
      default: formData.append('body', body); break;
    }
  
    // 送信
    await fetch("/api", {
      method: "POST",
      body: formData
    });
  }
});
