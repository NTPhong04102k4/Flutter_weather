> Nguồn: https://code.claude.com/docs/en/desktop-linux.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Claude Desktop trên Linux (beta)

> Cài đặt và cập nhật ứng dụng Claude desktop trên Ubuntu và Debian

<Note>
  Hỗ trợ Linux cho ứng dụng Claude desktop đang ở giai đoạn beta. Các tab Chat, Cowork, và Code đều có sẵn.
</Note>

Ứng dụng desktop trên Linux mang lại cho bạn cùng trải nghiệm Chat, Cowork, và Claude Code như trên macOS và Windows: phiên song song, xem xét diff trực quan, một terminal và editor tích hợp, và xem trước ứng dụng trực tiếp. Xem [Dùng Claude Code Desktop](/en/desktop) để biết tài liệu tham khảo đầy đủ về tính năng.

## Yêu cầu

* Ubuntu 22.04 trở lên, hoặc Debian 12 trở lên
* x86\_64 hoặc arm64

Các bản phân phối dựa trên Debian khác đáp ứng các yêu cầu này có thể hoạt động nhưng không được kiểm thử chính thức.

## Cài đặt

Cài đặt từ apt repository của Anthropic để các bản cập nhật đến qua các bản cập nhật gói thông thường của hệ thống bạn.

<Steps>
  <Step title="Thêm apt repository của Anthropic">
    Tải khóa ký (signing key) của Anthropic:

    ```bash theme={null}
    sudo curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc
    ```

    Đăng ký repository:

    ```bash theme={null}
    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | sudo tee /etc/apt/sources.list.d/claude-desktop.list
    ```
  </Step>

  <Step title="Cài đặt gói">
    ```bash theme={null}
    sudo apt update && sudo apt install claude-desktop
    ```
  </Step>

  <Step title="Khởi chạy và đăng nhập">
    Khởi chạy **Claude** từ trình khởi chạy ứng dụng của bạn, hoặc chạy `claude-desktop` từ terminal, và đăng nhập bằng tài khoản Anthropic của bạn.

    Ứng dụng Linux đăng nhập theo cùng cách như trên macOS và Windows: với một gói đăng ký claude.ai, hoặc thông qua SSO của tổ chức bạn. Desktop không chấp nhận một Claude Console API key trực tiếp; hãy dùng [CLI](/en/quickstart) để xác thực bằng API key. Đối với các triển khai doanh nghiệp định tuyến Desktop tới Agent Platform của Google Cloud hoặc một LLM gateway, xem [hướng dẫn cấu hình doanh nghiệp](https://support.claude.com/en/articles/12622667-enterprise-configuration) và [cấu hình mạng](/en/network-config).
  </Step>
</Steps>

<Accordion title="Xác minh khóa ký">
  Bạn có thể xác nhận khóa ký đã tải về thuộc về Anthropic:

  ```bash theme={null}
  gpg --show-keys /usr/share/keyrings/claude-desktop-archive-keyring.asc
  ```

  Vân tay (fingerprint) phải là `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`.
</Accordion>

### Cài đặt từ tệp đã tải về

Nếu bạn không thể dùng apt repository, hãy tải gói `.deb` cho kiến trúc của bạn (x64 hoặc arm64) từ [claude.com/download](https://claude.com/download), sau đó hoặc mở nó bằng trình cài đặt phần mềm của bạn hoặc chạy từ thư mục tải về:

```bash theme={null}
sudo apt install ./claude-desktop_*.deb
```

Một gói `.deb` được cài đặt theo cách này không nhận được các bản cập nhật. Để nhận cập nhật qua apt, hãy thêm repository như hiển thị ở trên, hoặc bỏ ghi chú dòng `deb` trong mục placeholder mà gói ghi vào `/etc/apt/sources.list.d/claude-desktop.list`.

## Cập nhật

Ứng dụng desktop không tự cập nhật trên Linux. Các bản cập nhật đến cùng với các bản cập nhật gói thông thường của hệ thống bạn:

```bash theme={null}
sudo apt update && sudo apt upgrade
```

Trình cập nhật phần mềm đồ họa của bản phân phối của bạn cũng sẽ nhận các phiên bản mới.

## Gỡ cài đặt

```bash theme={null}
sudo apt remove claude-desktop
```

Lệnh này gỡ khóa ký cùng với ứng dụng, nên nếu bạn đã thêm mục repository trong khi cài đặt, hãy gỡ nó luôn:

```bash theme={null}
sudo rm /etc/apt/sources.list.d/claude-desktop.list
```

## Những gì chưa có trong bản Linux beta

* **Computer Use**: [điều khiển ứng dụng và màn hình](/en/desktop#let-claude-use-your-computer) chưa có trên Linux.
* **Đọc chính tả (Dictation)**: nhập bằng giọng nói chưa có trong ứng dụng Linux desktop. Dùng [đọc chính tả bằng giọng nói](/en/voice-dictation) trong CLI thay thế.
* **Phím nóng toàn cục Quick Entry**: hoạt động trên X11. Trên Wayland gốc, nó yêu cầu portal GlobalShortcuts của môi trường desktop của bạn.
* **Fedora và RHEL**: chỉ các bản phân phối dựa trên Debian được hỗ trợ hiện nay. Hỗ trợ cho các bản phân phối khác đang được phát triển trong tương lai.

Đối với bất cứ điều gì chưa có trong ứng dụng desktop, [CLI](/en/quickstart) chạy cùng engine Claude Code và hỗ trợ một loạt các bản phân phối Linux rộng hơn; xem [yêu cầu hệ thống](/en/setup#system-requirements).
