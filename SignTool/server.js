const express = require("express");
const multer = require("multer");
const fs = require("fs");
const { execSync } = require("child_process");
const path = require("path");

const app = express();
const upload = multer({ dest: "uploads/" });

// 🔥 PORT cho Render
const PORT = process.env.PORT || 3000;

// ⚠️ sửa đúng tên cert của bạn
const CERT_NAME = "Apple Distribution";

// 📦 SIGN FILE
app.post("/sign", upload.single("ipa"), (req, res) => {
  try {
    if (!req.file) {
      return res.json({ success: false, error: "No file" });
    }

    const input = req.file.path;
    const out = `signed-${Date.now()}.ipa`;

    // dọn folder
    fs.rmSync("work", { recursive: true, force: true });

    // unzip
    execSync(`unzip -q ${input} -d work`);

    // tìm app
    const appPath = execSync(`find work/Payload -name "*.app"`).toString().trim();

    // inject profile
    execSync(`cp profile.mobileprovision ${appPath}/embedded.mobileprovision`);

    // sign
    execSync(`codesign -f -s "${CERT_NAME}" ${appPath}`);

    // zip lại
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

// 📲 manifest
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
              <string>https://${req.headers.host}/${ipa}</string>
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

// serve static
app.use(express.static(path.join(__dirname, "public")));
app.use(express.static(__dirname));

// 🚀 START SERVER
app.listen(PORT, "0.0.0.0", () => {
  console.log("🚀 Server running on port", PORT);
});
