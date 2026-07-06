> Nguồn: https://code.claude.com/docs/en/ultrareview.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Tìm lỗi với ultrareview

> Chạy một cuộc review code đa agent, sâu, trên đám mây bằng /code-review ultra để tìm và xác minh các lỗi trước khi bạn merge.

<Note>
  Ultrareview là một tính năng research preview khả dụng trong Claude Code v2.1.86 trở lên. Tính năng, giá cả và tính khả dụng có thể thay đổi dựa trên phản hồi. Lệnh này giờ được gọi là `/code-review ultra`, và `/ultrareview` vẫn còn tồn tại như một bí danh (alias).
</Note>

Ultrareview là một cuộc review code sâu chạy trên hạ tầng Claude Code trên web. Khi bạn chạy `/code-review ultra`, Claude Code khởi chạy một đội các agent reviewer trong một sandbox từ xa để tìm lỗi trong nhánh hoặc pull request của bạn.

So với một `/code-review` cục bộ hoặc `/review`, ultrareview mang lại:

* **Tín hiệu cao hơn**: mọi phát hiện được báo cáo đều được tái hiện và xác minh độc lập, nên kết quả tập trung vào các lỗi thực sự thay vì các đề xuất về phong cách
* **Phạm vi bao phủ rộng hơn**: một đội reviewer agent lớn hơn khám phá thay đổi song song, giúp phát hiện các vấn đề mà một review cục bộ ở mức nỗ lực trung bình có thể bỏ sót
* **Không dùng tài nguyên cục bộ**: review chạy hoàn toàn trong một sandbox từ xa, nên terminal của bạn vẫn rảnh cho công việc khác trong khi nó chạy

Ultrareview yêu cầu xác thực bằng một tài khoản Claude.ai vì nó chạy trên hạ tầng Claude Code trên web. Nếu bạn đăng nhập chỉ bằng một API key, chạy `/login` và xác thực bằng Claude.ai trước. Ultrareview không khả dụng khi dùng Claude Code với Amazon Bedrock, Agent Platform của Google Cloud, hoặc Microsoft Foundry, và nó không khả dụng cho các tổ chức đã bật Zero Data Retention.

## Chạy ultrareview từ CLI

Bắt đầu một review từ bất kỳ repository git nào trong Claude Code CLI.

```text theme={null}
/code-review ultra
```

Không có tham số, ultrareview review diff giữa nhánh hiện tại của bạn và nhánh mặc định, bao gồm bất kỳ thay đổi chưa commit và đã staged nào trong cây làm việc (working tree) của bạn. Claude Code đóng gói trạng thái repository và tải nó lên một sandbox từ xa để review.

Để review một pull request GitHub thay vào đó, truyền số PR.

```text theme={null}
/code-review ultra 1234
```

Ở chế độ PR, sandbox từ xa clone pull request trực tiếp từ host thay vì đóng gói cây làm việc cục bộ của bạn. Chế độ PR hoạt động với các repository trên `github.com` và trên các instance [GitHub Enterprise Server](/en/github-enterprise-server) mà một Owner đã kết nối với Claude Code.

<Tip>
  Nếu repository của bạn quá lớn để đóng gói, Claude Code nhắc bạn dùng chế độ PR thay thế. Push nhánh của bạn và mở một PR nháp, sau đó chạy `/code-review ultra <PR-number>`.

  Nếu diff của pull request quá lớn, Claude Code từ chối review với một gợi ý về phạm vi trước khi bất kỳ công việc review nào chạy.
</Tip>

Trước khi khởi chạy, Claude Code hiển thị một hộp thoại xác nhận với phạm vi review (bao gồm số file và số dòng khi review một nhánh), số lần chạy miễn phí còn lại của bạn, và chi phí ước tính. Sau khi bạn xác nhận, review tiếp tục ở nền và bạn có thể tiếp tục dùng phiên của mình. Lệnh này chỉ chạy khi bạn gọi nó bằng `/code-review ultra`; Claude không tự khởi động một ultrareview.

## Giá cả và các lần chạy miễn phí

Ultrareview là một tính năng cao cấp tính phí vào usage credits thay vì mức sử dụng bao gồm trong gói của bạn.

| Gói                 | Số lần chạy miễn phí bao gồm | Sau khi hết lần chạy miễn phí                                                                                |
| ------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Pro                 | 3 lần chạy miễn phí          | tính phí dưới dạng [usage credits](https://support.claude.com/en/articles/12429409-extra-usage-for-paid-claude-plans) |
| Max                 | 3 lần chạy miễn phí          | tính phí dưới dạng [usage credits](https://support.claude.com/en/articles/12429409-extra-usage-for-paid-claude-plans) |
| Team và Enterprise  | không có                     | tính phí dưới dạng [usage credits](https://support.claude.com/en/articles/12429409-extra-usage-for-paid-claude-plans) |

Người đăng ký Pro và Max nhận ba lần chạy ultrareview miễn phí để dùng thử tính năng. Ba lần chạy này là một phần cấp phát một lần cho mỗi tài khoản và không làm mới lại. Sau khi bạn dùng hết cả ba, hoặc sau khi thời gian chạy miễn phí kết thúc, mỗi review được tính vào usage credits và thường tốn \$5 đến \$20 tùy vào kích thước của thay đổi. Một lần chạy được tính khi phiên đám mây bắt đầu, nên một review mà bạn dừng sớm hoặc thất bại không hoàn thành vẫn dùng một lần chạy miễn phí. Đối với một review có tính phí, usage credits chỉ được tính cho phần đã chạy.

Vì ultrareview luôn tính phí dưới dạng usage credits ngoài các lần chạy miễn phí, tài khoản hoặc tổ chức của bạn phải bật usage credits trước khi bạn có thể khởi chạy một review có tính phí. Nếu usage credits không được bật, Claude Code chặn việc khởi chạy và liên kết bạn đến cài đặt thanh toán nơi bạn có thể bật chúng. Bạn cũng có thể chạy `/usage-credits` để kiểm tra hoặc thay đổi cài đặt hiện tại của bạn.

## Theo dõi một review đang chạy

Một review thường mất 5 đến 10 phút. Review chạy như một tác vụ nền, nên bạn có thể tiếp tục làm việc trong phiên của mình, khởi động các lệnh khác, hoặc đóng terminal hoàn toàn.

Dùng `/tasks` để xem các review đang chạy và đã hoàn thành, mở khung xem chi tiết cho một review, hoặc dừng một review đang tiến hành. Việc dừng một review sẽ lưu trữ (archive) phiên đám mây, và các phát hiện một phần không được trả về. Khi review hoàn thành, các phát hiện đã xác minh xuất hiện dưới dạng một thông báo trong phiên của bạn. Mỗi phát hiện bao gồm vị trí file và một lời giải thích về vấn đề để bạn có thể yêu cầu Claude sửa nó trực tiếp.

## Chạy ultrareview ở chế độ không tương tác

Dùng lệnh con `claude ultrareview` để khởi động một ultrareview từ CI hoặc một script mà không cần một phiên tương tác. Lệnh con khởi chạy cùng một review như `/code-review ultra`, chặn cho đến khi review từ xa hoàn thành, in các phát hiện ra stdout, và thoát với mã 0 khi thành công hoặc 1 khi thất bại.

```bash theme={null}
claude ultrareview
claude ultrareview 1234
claude ultrareview origin/main
```

Không có tham số, lệnh con review diff giữa nhánh hiện tại của bạn và nhánh mặc định. Truyền một số PR để review một pull request, hoặc truyền một nhánh cơ sở (base branch) để review diff đối chiếu với nhánh đó thay vào đó. Việc gọi lệnh con được tính là sự đồng thuận cho lời nhắc về thanh toán và điều khoản mà lệnh tương tác hiển thị.

Các thông báo tiến trình và URL phiên trực tiếp đi ra stderr nên stdout vẫn có thể phân tích được. Dùng các cờ này để kiểm soát đầu ra và thời gian chờ (timeout):

| Cờ                    | Mô tả                                                                |
| --------------------- | ------------------------------------------------------------------- |
| `--json`              | In payload `bugs.json` thô thay vì các phát hiện đã được định dạng   |
| `--timeout <minutes>` | Số phút tối đa chờ review hoàn thành. Mặc định là 30                 |

Chạy `claude ultrareview` yêu cầu cùng cấu hình xác thực và usage credit như `/code-review ultra`. Lệnh con thoát với mã 0 khi review hoàn thành có hoặc không có phát hiện, mã 1 khi review không khởi chạy được, phiên đám mây lỗi, hoặc timeout trôi qua, và mã 130 khi bị ngắt bằng Ctrl-C. Review từ xa vẫn tiếp tục chạy nếu bạn ngắt lệnh con; theo dõi URL phiên được in ra stderr để xem nó trong trình duyệt.

Để có các review tự động trên các pull request GitHub, [Code Review](/en/code-review) tích hợp trực tiếp với repository của bạn và đăng các phát hiện dưới dạng bình luận PR inline mà không cần một bước CLI.

## So sánh ultrareview với /code-review và /review

Cả ba lệnh đều review code, nhưng chúng nhắm vào các giai đoạn khác nhau trong quy trình làm việc của bạn.

|          | `/code-review`                  | `/review <pr>`                             | `/code-review ultra`                                            |
| -------- | ------------------------------- | ------------------------------------------ | --------------------------------------------------------------- |
| Mục tiêu | diff làm việc của bạn           | một pull request GitHub                    | diff làm việc của bạn hoặc một pull request                     |
| Chạy     | cục bộ trong phiên của bạn      | cục bộ trong phiên của bạn                 | từ xa trong một sandbox đám mây                                 |
| Độ sâu   | tỉ lệ theo tham số effort       | engine `/code-review` mức trung bình       | đội đa agent với xác minh độc lập                              |
| Thời lượng | vài giây đến vài phút          | vài phút                                   | khoảng 5 đến 10 phút                                            |
| Chi phí  | tính vào mức sử dụng thông thường | tính vào mức sử dụng thông thường          | các lần chạy miễn phí, rồi khoảng \$5 đến \$20 mỗi review dưới dạng usage credits |
| Phù hợp nhất | phản hồi nhanh khi đang lặp | review PR của đồng đội trước khi phê duyệt  | sự tự tin trước khi merge với các thay đổi đáng kể              |

Dùng `/code-review` để có phản hồi nhanh khi bạn làm việc. Dùng `/review <pr>` để xem qua một pull request theo cách bạn làm trước khi phê duyệt. Dùng `/code-review ultra` trước khi merge một thay đổi đáng kể khi bạn muốn một lượt kiểm tra sâu hơn nhằm bắt các vấn đề mà một review cục bộ có thể bỏ sót.

## Tài nguyên liên quan

* [Claude Code trên web](/en/claude-code-on-the-web): tìm hiểu cách các phiên đám mây và sandbox đám mây hoạt động
* [Lập kế hoạch cho các thay đổi phức tạp với ultraplan](/en/ultraplan): đối tác lập kế hoạch của ultrareview cho công việc thiết kế từ đầu
* [Quản lý chi phí hiệu quả](/en/costs): theo dõi mức sử dụng và đặt giới hạn chi tiêu
