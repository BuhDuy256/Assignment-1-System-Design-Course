# Design Pattern Architectural Checklist

> **Architect-Level Design Pattern Evaluation Framework**
>
> This checklist helps evaluate design patterns from a software architecture perspective, focusing on invariants, trade-offs, and long-term maintainability.

---

## 🧠 NHÓM 1 — Invariant & Business Rule Protection

_(Bảo vệ cái gì, ở cấp độ nào?)_

1. Pattern này đang bảo vệ **Invariant nào**?
2. Invariant này thuộc:
   - Object invariant?
   - Aggregate / Domain invariant?
   - Business rule invariant?
3. Invariant này **liên quan trực tiếp đến rule nào của business**?
4. Nếu hệ thống scale theo chiều **feature / team / use-case**, invariant này bị đe dọa ra sao?
5. Pattern này có giúp **giữ invariant trước thay đổi hợp pháp**, nhưng **chặn thay đổi nguy hiểm** không?

> 🔎 Liên hệ nguyên lý: **Encapsulation, Information Hiding**

---

## 🔗 NHÓM 2 — Semantic Dependency & Coupling

_(Cắt phụ thuộc nào, và vì sao phụ thuộc đó nguy hiểm?)_

6. Pattern này đang cắt **loại coupling nào**?
   - Structural
   - Temporal
   - Semantic
7. Nếu không dùng pattern, **ai sẽ biết quá nhiều về ai**?
8. Dependency này vi phạm nguyên lý nào?
   - SRP?
   - DIP?
9. Pattern có giúp **đổi phụ thuộc compile-time thành runtime** không?
10. Pattern có giúp **đổi phụ thuộc semantic thành dependency có kiểm soát** không?

> 🔎 Liên hệ nguyên lý: **DIP, Low Coupling**

---

## 🧩 NHÓM 3 — Encapsulation of Variation

_(Cái gì được phép thay đổi, cái gì bị khóa cứng?)_

11. Pattern này đang **đóng gói loại biến thiên nào**?
12. Biến thiên này là:
    - Business rule?
    - Algorithm?
    - Policy?
13. Nếu biến thiên tăng gấp đôi, cấu trúc có còn đứng vững không?
14. Pattern có thực sự tuân thủ **OCP (Open for extension, closed for modification)** không?
15. Có điểm mở rộng rõ ràng hay chỉ là "extension ngầm"?

> 🔎 Liên hệ nguyên lý: **OCP, Encapsulation of Variation**

---

## 🧱 NHÓM 4 — Architectural Placement & Boundary

_(Đặt ở đâu để không làm bẩn domain?)_

16. Pattern này nên nằm ở:
    - Domain?
    - Application?
    - Infrastructure?
17. Pattern có làm **leak technical concern vào business logic** không?
18. Nếu remove pattern, **domain model có bị tổn thương không**?
19. Pattern này có tạo ra **accidental complexity** cho domain không?
20. Pattern có đang che giấu design smell nào không?

> 🔎 Liên hệ nguyên lý: **Clean Architecture, Separation of Concerns**

---

## ⚠️ NHÓM 5 — Anti-pattern & Misuse

_(Khi nào pattern phản tác dụng?)_

21. Pattern này thường bị lạm dụng vì lý do gì?
22. Dấu hiệu sớm cho thấy pattern đang **over-engineered**?
23. Pattern này có khiến:
    - Code khó đọc hơn?
    - Onboarding chậm hơn?
24. Nếu business rule **không thay đổi**, pattern này có đáng tồn tại không?
25. Pattern này có đang giải quyết **vấn đề giả** không?

---

## 🧠 NHÓM 6 — Comparative Semantics

_(Vì sao là pattern này, không phải pattern khác?)_

26. Pattern này dễ bị nhầm với pattern nào nhất?
27. Hai pattern đó khác nhau **ở invariant nào**?
28. Nếu thay thế bằng pattern khác, **điều gì sẽ bị mất?**
29. Pattern này thường **phối hợp tốt với pattern nào**?
30. Có giải pháp **đơn giản hơn nhưng vẫn bảo vệ được invariant không?**

---

## 🧮 NHÓM 7 — Chi phí & Vận hành

_(Đánh giá chi phí thực tế khi vận hành)_

31. Pattern này làm tăng **Cognitive Load** cho người đọc code bao nhiêu?
32. Một dev mới cần bao lâu để hiểu đúng flow?
33. Debug flow qua pattern này dễ hay khó?
34. Có tạo stack trace phức tạp không?
35. Pattern này có ảnh hưởng tới:
    - Latency?
    - Memory?
    - Allocation?
36. Chi phí vận hành này **có tương xứng với invariant được bảo vệ không?**

---

## ⚙️ NHÓM 8 — Tính hiện đại & Ngôn ngữ

_(Pattern này còn cần thiết trong ngữ cảnh hiện đại?)_

37. Pattern này tồn tại vì **hạn chế của ngôn ngữ cũ** hay vì bản chất bài toán?
38. Ngôn ngữ hiện đại (lambda, higher-order function, composition…) có:
    - Giảm boilerplate không?
    - Hay thay thế hoàn toàn pattern?
39. Nếu thay bằng cách hiện đại hơn:
    - Invariant có còn được bảo vệ không?
    - Hay chỉ "ngắn code"?
40. Pattern này là **conceptual necessity** hay **historical artifact**?

---

## 🔥 CÂU HỎI TỐI THƯỢNG

> ❝ **Nếu loại bỏ pattern này, invariant hoặc business rule nào sẽ bị phá đầu tiên — và việc phá đó có chấp nhận được trong 6–12 tháng tới không?** ❞

💣 **Vì sao câu này "chạm tử huyệt":**

- Buộc bạn nghĩ:
  - _Thời gian_
  - _Scale_
  - _Chi phí tương lai_
- Không cho phép trả lời cảm tính

---

## 🏁 KẾT LUẬN

> Design Pattern không phải là best practice, mà là **cam kết đánh đổi** giữa **bảo vệ invariant** và **tăng độ phức tạp hệ thống**.
