const express = require("express");
const multer = require("multer");
const fs = require("fs");
const { execSync } = require("child_process");
const axios = require("axios");

const app = express();
const upload = multer({ dest: "uploads/" });

const PORT = 3000;

// ⚠️ sửa đúng tên cert của bạn
const CERT_NAME = "Apple Distribution";
const CERT_PASS = "123456";

// 📦 SIGN FILE LOCAL
app.post("/sign", upload.single("ipa"), async (req, res) => {
  try {
    const input = req.file.path;
    const out = `signed-${Date.now()}.ipa`;

    fs.rmSync("work", { recursive: true, force: true });

    execSync(`unzip -q ${input} -d work`);

    const appPath = execSync(`find work/Payload -name "*.app"`).toString().trim();

    execSync(`cp profile.mobileprovision ${appPath}/embedded.mobileprovision`);

    execSync(`codesign -f -s "${CERT_NAME}" ${appPath}`);

    execSync(`cd work && zip -qr ../${out} Payload`);

    res.json({
      success: true,
      ipa: out,
      manifest: `/manifest?ipa=${out}`
    });

  } catch (e) {
    res.json({ success: false, error: e.toString() });
  }
});

// 🌐 SIGN FROM URL (DECRYPT)
app.get("/sign-from-url", async (req, res) => {
  try {
    const url = req.query.ipa;
    const file = `downloads-${Date.now()}.ipa`;

    const response = await axios({
      method: "GET",
      url,
      responseType: "stream"
    });

    const writer = fs.createWriteStream(file);
    response.data.pipe(writer);

    writer.on("finish", async () => {
      const form = new FormData();
      form.append("ipa", fs.createReadStream(file));

      // gọi lại API sign
      res.redirect(`/sign-local?file=${file}`);
    });

  } catch (e) {
    res.json({ success: false });
  }
});

// 📲 MANIFEST
app.get("/manifest", (req, res) => {
  const ipa = req.query.ipa;

  res.set("Content-Type", "application/xml");

  res.send(`
  <plist version="1.0">
  <dict>
    <items>
      <dict>
        <assets>
          <array>
            <dict>
              <key>kind</key>
              <string>software-package</string>
              <key>url</key>
              <string>https://YOUR_DOMAIN/${ipa}</string>
            </dict>
          </array>
        </assets>
        <metadata>
          <dict>
            <key>bundle-identifier</key>
            <string>com.dynamic.app</string>
            <key>bundle-version</key>
            <string>1.0</string>
            <key>kind</key>
            <string>software</string>
            <key>title</key>
            <string>Signed App</string>
          </dict>
        </metadata>
      </dict>
    </items>
  </dict>
  </plist>
  `);
});

// serve
app.use(express.static("public"));
app.use(express.static("."));

app.listen(PORT, () => console.log("🚀 Running on", PORT));
