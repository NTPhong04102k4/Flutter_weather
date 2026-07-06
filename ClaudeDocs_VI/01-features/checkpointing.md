> Nguồn: https://code.claude.com/docs/en/checkpointing.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Checkpointing

> Theo dõi, tua ngược và tóm tắt các chỉnh sửa cũng như cuộc hội thoại của Claude để quản lý trạng thái phiên làm việc.

Claude Code tự động theo dõi các chỉnh sửa file của Claude trong khi bạn làm việc, cho phép bạn nhanh chóng hoàn tác các thay đổi và tua ngược về các trạng thái trước đó nếu có gì đó đi chệch hướng.

## Checkpoint hoạt động như thế nào

Khi bạn làm việc với Claude, checkpointing tự động ghi lại trạng thái mã của bạn trước mỗi lần chỉnh sửa. Tấm lưới an toàn này cho phép bạn theo đuổi những tác vụ đầy tham vọng, quy mô lớn với sự yên tâm rằng bạn luôn có thể quay về một trạng thái mã trước đó.

### Theo dõi tự động

Claude Code theo dõi tất cả các thay đổi được thực hiện bởi các công cụ chỉnh sửa file của nó:

* Mỗi prompt của người dùng tạo ra một checkpoint mới
* Các checkpoint được duy trì xuyên suốt các phiên làm việc, nên bạn có thể truy cập chúng trong các cuộc hội thoại được tiếp tục (resumed)
* Được tự động dọn dẹp cùng với các phiên sau 30 ngày (có thể cấu hình)

### Tua ngược và tóm tắt

Chạy `/rewind`, hoặc nhấn `Esc` hai lần khi ô nhập prompt đang trống, để mở menu tua ngược.

<Note>
  Nếu ô nhập prompt có chứa văn bản, việc nhấn `Esc` hai lần sẽ xóa văn bản đó thay vì mở menu. Văn bản đã xóa được lưu vào lịch sử nhập liệu của bạn, nên hãy nhấn `Up` để gọi lại nó sau khi bạn hoàn tất trong menu tua ngược.
</Note>

Menu tua ngược liệt kê từng prompt bạn đã gửi trong phiên làm việc. Chọn thời điểm bạn muốn thao tác, rồi chọn một hành động:

* **Restore code and conversation**: khôi phục cả mã và cuộc hội thoại về thời điểm đó
* **Restore conversation**: tua ngược về tin nhắn đó trong khi giữ nguyên mã hiện tại
* **Restore code**: hoàn tác các thay đổi file trong khi giữ nguyên cuộc hội thoại
* **Summarize from here**: nén cuộc hội thoại từ điểm này trở về sau thành một bản tóm tắt, giải phóng dung lượng context window (cửa sổ ngữ cảnh)
* **Summarize up to here**: nén cuộc hội thoại trước điểm này thành một bản tóm tắt, giữ nguyên các tin nhắn phía sau
* **Never mind**: quay lại danh sách tin nhắn mà không thực hiện thay đổi nào

Sau khi khôi phục cuộc hội thoại hoặc chọn Summarize from here, prompt gốc từ tin nhắn được chọn sẽ được khôi phục vào ô nhập liệu để bạn có thể gửi lại hoặc chỉnh sửa.

Chọn Summarize up to here sẽ để bạn ở cuối cuộc hội thoại với ô nhập liệu trống.

#### Tua ngược qua một cuộc hội thoại đã bị xóa

Nếu bạn đã chạy `/clear` trước đó trong cùng một tiến trình Claude Code, menu tua ngược sẽ hiển thị thêm một mục ở đầu danh sách có nhãn `/resume <session-id> (previous session)`. Chọn nó để tiếp tục cuộc hội thoại đang hoạt động trước khi `/clear` chạy. Mục này khả dụng cho đến khi bạn thoát Claude Code hoặc tiếp tục một phiên khác, và yêu cầu Claude Code phiên bản v2.1.191 trở lên. Trên các phiên bản cũ hơn, hãy chạy `/resume` và chọn phiên trước đó từ danh sách.

#### Restore và summarize

Các tùy chọn restore sẽ hoàn nguyên trạng thái: chúng hoàn tác các thay đổi mã, lịch sử hội thoại, hoặc cả hai. Các tùy chọn summarize sẽ nén một phần cuộc hội thoại thành một bản tóm tắt do AI tạo ra mà không thay đổi các file trên đĩa:

* **Summarize from here**: các tin nhắn trước tin nhắn được chọn vẫn giữ nguyên. Tin nhắn được chọn và mọi thứ sau nó được thay thế bằng một bản tóm tắt. Dùng cách này để loại bỏ một cuộc thảo luận phụ trong khi giữ nguyên đầy đủ chi tiết ngữ cảnh ban đầu.
* **Summarize up to here**: các tin nhắn trước tin nhắn được chọn được thay thế bằng một bản tóm tắt. Tin nhắn được chọn và mọi thứ sau nó vẫn giữ nguyên, và bạn vẫn ở cuối cuộc hội thoại. Dùng cách này để nén phần thảo luận thiết lập ban đầu trong khi giữ nguyên đầy đủ chi tiết công việc gần đây.

Trong cả hai trường hợp, các tin nhắn gốc đều được bảo toàn trong bản ghi (transcript) của phiên, nên Claude có thể tham chiếu lại các chi tiết nếu cần. Bạn có thể gõ các hướng dẫn tùy chọn để định hướng nội dung mà bản tóm tắt sẽ tập trung vào. Cách này tương tự `/compact`, nhưng có mục tiêu cụ thể: thay vì tóm tắt toàn bộ cuộc hội thoại, bạn chọn phía nào của tin nhắn được chọn để nén.

<Note>
  Summarize giữ bạn trong cùng một phiên và nén ngữ cảnh. Nếu bạn muốn rẽ nhánh và thử một hướng tiếp cận khác trong khi vẫn giữ nguyên vẹn phiên gốc, hãy dùng [fork](/en/sessions#branch-a-session) thay thế (`claude --continue --fork-session`).
</Note>

## Các trường hợp sử dụng phổ biến

Checkpoint đặc biệt hữu ích khi:

* **Khám phá các phương án thay thế**: thử các hướng triển khai khác nhau mà không mất đi điểm khởi đầu của bạn
* **Phục hồi sau lỗi**: nhanh chóng hoàn tác các thay đổi đã gây ra lỗi hoặc phá vỡ chức năng
* **Lặp lại trên các tính năng**: thử nghiệm các biến thể với sự yên tâm rằng bạn có thể quay về các trạng thái hoạt động được
* **Giải phóng dung lượng ngữ cảnh**: tóm tắt một phiên gỡ lỗi (debugging) dài dòng từ điểm giữa trở về sau, giữ nguyên các hướng dẫn ban đầu của bạn

## Giới hạn

### Các thay đổi từ lệnh bash không được theo dõi

Checkpointing không theo dõi các file bị chỉnh sửa bởi các lệnh bash. Ví dụ, nếu Claude Code chạy:

```bash theme={null}
rm file.txt
mv old.txt new.txt
cp source.txt dest.txt
```

Các thay đổi file này không thể được hoàn tác thông qua rewind. Chỉ những chỉnh sửa file trực tiếp được thực hiện qua các công cụ chỉnh sửa file của Claude mới được theo dõi.

### Các thay đổi bên ngoài không được theo dõi

Checkpointing chỉ theo dõi các file đã được chỉnh sửa trong phiên hiện tại. Các thay đổi thủ công mà bạn thực hiện trên các file bên ngoài Claude Code và các chỉnh sửa từ các phiên đồng thời khác thường không được ghi lại, trừ khi chúng tình cờ sửa đổi cùng các file với phiên hiện tại.

### Không phải là sự thay thế cho hệ thống quản lý phiên bản

Checkpoint được thiết kế cho việc phục hồi nhanh ở cấp độ phiên làm việc. Đối với lịch sử phiên bản lâu dài và cộng tác:

* Tiếp tục sử dụng hệ thống quản lý phiên bản (ví dụ Git) cho các commit, nhánh (branch) và lịch sử dài hạn
* Checkpoint bổ trợ nhưng không thay thế hệ thống quản lý phiên bản đúng nghĩa
* Hãy coi checkpoint như "hoàn tác cục bộ" (local undo) và Git như "lịch sử vĩnh viễn" (permanent history)

## Xem thêm

* [Interactive mode](/en/interactive-mode) - Các phím tắt và điều khiển phiên làm việc
* [Commands](/en/commands) - Truy cập checkpoint bằng `/rewind`
* [CLI reference](/en/cli-reference) - Các tùy chọn dòng lệnh
