# Repo Cydia https://2kgt.github.io/repo/
# Repo Ésign https://2kgt.github.io/repo/apps.json

# Repo 2kgt
Một mẫu kho lưu trữ Cydia. Mẫu này chứa mẫu về cách bạn có thể dễ dàng tạo các trang mô tả mà không cần sao chép các trang html của mình. Các trang được tạo kiểu bằng cách sử dụng Bootsrap thực sự dễ sử dụng. Bạn có thể xem nó trông như thế nào bằng cách truy cập repo mẫu này trên máy tính để bàn hoặc điện thoại di động của bạn.

Hầu hết dữ liệu cho repo này được lưu trữ trên các tệp XML và được tải tự động trên trang mô tả. Xem hướng dẫn bên dưới về cách thiết lập nó. Lưu ý rằng hướng dẫn này không bao gồm việc tạo các tệp .deb nhưng sẽ bao gồm ngắn gọn các mô tả phân loại.

Cách sử dụng mẫu này

1. Tải xuống

Nếu bạn không lưu trữ repo của mình trên Github Pages, bạn có thể tải xuống tệp zip tại đây và giải nén vào thư mục con trên trang web của mình.

Có 2 lựa chọn cho những người sử dụng Github Pages.

A. If you want to use your root username.github.io as your repo, fork this repo and rename it to username.github.io. So when adding it in Cydia, use https://username.github.io.

B. If you want to use a subfolder for your existing username.github.io as your repo (example username.github.io/repo), fork this repo and rename it to repo. So when adding it in Cydia, use https://username.github.io/repo.

You can change repo to anything you want, like cydia for example. So your repo url would be https://username.github.io/cydia.

2. Cá nhân hóa

Tập tin phát hành

Chỉnh sửa tệp Release. Sửa đổi các mục được chỉ định bởi<--

Origin: Reposi3  <--
Label: Reposi3   <--
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm
Components: main
Description: Reposi3 - a cydia repo template  <--
Xây dựng thương hiệu

Open index.html and look at lines 18 and 19. Change line 18 into your own brand and line 19 to have your own URL. Line2 27-44 contains the list of featured packages. You can edit those too or remove them totally.

Thay thế CydiaIcon.png.

Chân trang

This data are the links that appear at the bottom of every depication. The data is stored in repo.xml at the root folder of your repo.

<repo>
    <footerlinks>
        <link>
            <name>Follow me on Twitter</name>
            <url>https://twitter.com/reposi3</url>
            <iconclass>glyphicon glyphicon-user</iconclass>
        </link>
        <link>
            <name>I want this depiction template</name>
            <url>https://github.com/supermamon/Reposi3</url>
            <iconclass>glyphicon glyphicon-thumbs-up</iconclass>
        </link>
    </footerlinks>
</repo>
3. Repo của bạn gần như đã sẵn sàng.

Tại thời điểm này, kho lưu kho của bạn về cơ bản đã sẵn sàng để được thêm vào Cydia. Bạn cũng có thể truy cập trang chủ của repo bằng cách truy cập https://username.github.io/repo/. Nó sẽ đi kèm với 2 gói mẫu, Gói Cũ và Gói Mới. Mỗi gói có một liên kết trên trang này trỏ đến các mô tả của chúng. Hướng dẫn tiếp theo sẽ chỉ cho bạn cách gán và tùy chỉnh các trang mô tả của bạn.

Thêm gói gói đầu tiên vào kho lưu hàng của bạn

1. Thêm một trang mô tả đơn giản

Go to the depictions folder and duplicate the folder com.supermamon.oldpackage. Rename the duplicate with the same name as your package name. There are 2 files inside the folder - info.xml and changelog.xml. Update the 2 files with information regading your package. The tags are pretty much self-explanatory. Contact @reposi3 or @supermamon for questions.

info.xml.

<package>
    <id>com.supermamon.oldpackage</id>
    <name>Old Package</name>
    <version>1.0.0-1</version>
    <compatibility>
        <firmware>
            <miniOS>5.0</miniOS>
            <maxiOS>7.0</maxiOS>
            <otherVersions>unsupported</otherVersions>
            <!--
            for otherVersions, you can put either unsupported or unconfirmed
            -->
        </firmware>
    </compatibility>
    <dependencies></dependencies>
    <descriptionlist>
        <description>This is an old package. Requires iOS 7 and below..</description>
    </descriptionlist>
    <screenshots></screenshots>
    <changelog>
        <change>Initial release</change>
    </changelog>
    <links></links>
</package>
changelog.xml.

<changelog>
    <changes>
        <version>1.0.0-1</version>
        <change>Initial release</change>
    </changes>
</changelog>
2. Link the depiction page your tweak's control file

You can add the depictions url at the end of your package's control file before compiling it. The depiction line should look like this:

Depiction: https://username.github.io/repo/depictions/?p=[idhere]
Replace [idhere] with your actual package name.

Depiction: https://username.github.io/repo/depictions/?p=com.supermamon.oldpackage
3. Xây dựng lại tệp Packages

With your updated control file, build your tweak. Store the resulting .deb. file into the /debs/ folder of your repo. Build your Packages file and compress with bzip2.

user:~/ $ cd repo
user:~/repo $ dpkg-scanpackages -m ./debs > Packages
user:~/repo $ bzip2 Packages
Người dùng Windows, xem dpkg-scanpackages-py hoặc scanpkg.

5. Cydia cuối cùng!

Nếu bạn chưa hoàn thành, hãy tiếp tục và thêm repo của bạn vào Cydia. Bây giờ bạn có thể cài đặt tinh chỉnh của mình vào repo của riêng bạn.

Dọn dẹp

Chỉ cần một bước dọn dẹp, xóa các debs đi kèm với mẫu này và chạy lại các lệnh ở bước 3. Bạn có thể giữ các mô tả mẫu để tham khảo vì chúng không cần thiết cho repo của 
