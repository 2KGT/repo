export default {
  async fetch(request, env) {
    if (request.method === "POST") {
      try {
        const update = await request.json();
        if (update.message) {
          await handleMessage(update.message, env);
        }
      } catch (e) {
        console.error("Lỗi xử lý:", e);
      }
      return new Response("OK");
    }
    return new Response("2KGT Bot is Running!");
  }
};

async function handleMessage(message, env) {
  const text = message.text || "";
  const chatId = message.chat.id;

  // Lệnh kiểm tra chứng chỉ
  if (text === "/checkcert") {
    await env.BOT_KV.put(`state_${chatId}`, "WAITING_P12");
    await sendTelegram(chatId, "📥 Vui lòng gửi tệp `.p12` để kiểm tra.", env);
    return;
  }

  // Xử lý tệp tin người dùng gửi lên
  if (message.document) {
    const state = await env.BOT_KV.get(`state_${chatId}`);
    if (state === "WAITING_P12") {
      const fileId = message.document.file_id;
      const fileName = message.document.file_name;

      if (fileName.endsWith(".p12")) {
        const fileUrl = await getTelegramFileUrl(fileId, env);
        await env.BOT_KV.put(`temp_p12_${chatId}`, fileUrl);
        await env.BOT_KV.put(`state_${chatId}`, "WAITING_PASSWORD");
        await sendTelegram(chatId, "🔑 Đã nhận P12. Vui lòng nhập mật khẩu chứng chỉ:", env);
      } else {
        await sendTelegram(chatId, "❌ Sai định dạng. Hãy gửi file .p12", env);
      }
      return;
    }
  }

  // Xử lý mật khẩu và kích hoạt GitHub Actions
  const state = await env.BOT_KV.get(`state_${chatId}`);
  if (state === "WAITING_PASSWORD" && text !== "") {
    const p12Url = await env.BOT_KV.get(`temp_p12_${chatId}`);
    
    // Gọi GitHub Actions (repository_dispatch)
    const success = await triggerGitHub(env, "check_cert", {
      telegram_id: chatId.toString(),
      p12_url: p12Url,
      password: text
    });

    if (success) {
      await sendTelegram(chatId, "🚀 Đã gửi yêu cầu sang GitHub Actions. Vui lòng chờ kết quả...", env);
    } else {
      await sendTelegram(chatId, "❌ Lỗi kết nối GitHub API.", env);
    }
    await env.BOT_KV.delete(`state_${chatId}`);
  }
}

async function triggerGitHub(env, eventType, payload) {
  const url = `https://api.github.com/repos/${env.GH_REPO}/dispatches`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${env.GITHUB_PAT}`,
      "Accept": "application/vnd.github.v3+json",
      "User-Agent": "2KGT-Cloudflare-Worker",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ event_type: eventType, client_payload: payload })
  });
  return res.status === 204;
}

async function sendTelegram(chatId, text, env) {
  const url = `https://api.telegram.org/bot${env.TELEGRAM_TOKEN}/sendMessage`;
  await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ chat_id: chatId, text: text, parse_mode: "Markdown" })
  });
}

async function getTelegramFileUrl(fileId, env) {
  const res = await fetch(`https://api.telegram.org/bot${env.TELEGRAM_TOKEN}/getFile?file_id=${fileId}`);
  const data = await res.json();
  return `https://api.telegram.org/file/bot${env.TELEGRAM_TOKEN}/${data.result.file_path}`;
}
