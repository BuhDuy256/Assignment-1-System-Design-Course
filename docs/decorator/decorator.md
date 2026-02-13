# Decorator Pattern — Kiến trúc & Phân tích Sâu

> **Đánh giá pattern Decorator theo góc nhìn kiến trúc hệ thống**
>
> Tài liệu phân tích dựa trên Design Pattern Architectural Checklist

---

## 🧠 NHÓM 1 — Invariant & Business Rule Protection

### 1. Pattern này đang bảo vệ **Invariant nào**?

Decorator Pattern bảo vệ các invariant sau:

- **Tính bất biến của component gốc**: Component ban đầu không bị thay đổi hay mở rộng trực tiếp
- **Tính đơn trách nhiệm (Single Responsibility)**: Mỗi decorator chỉ có một lý do để thay đổi
- **Interface contract**: Decorator phải tuân thủ cùng interface với component gốc
- **Composition consistency**: Các decorator có thể stack lên nhau mà không phá vỡ hành vi

**Ví dụ thực tế:**

```java
// Component gốc giữ nguyên bản chất
Coffee coffee = new SimpleCoffee(); // Giá: 10k

// Decorator không làm thay đổi component gốc
Coffee withMilk = new MilkDecorator(coffee); // Giá: 10k + 5k = 15k
Coffee withMilkAndSugar = new SugarDecorator(withMilk); // Giá: 15k + 2k = 17k

// SimpleCoffee vẫn hoạt động độc lập
Coffee another = new SimpleCoffee(); // Vẫn là 10k
```

### 2. Invariant này thuộc loại nào?

**Object invariant** và **Domain invariant**:

- **Object invariant**: Mỗi decorator phải duy trì interface contract của component
- **Domain invariant**: Quy tắc nghiệp vụ về cách thức tính giá, mô tả sản phẩm phải nhất quán

**Không phải Business rule invariant** ở mức hệ thống vì Decorator tập trung vào cấu trúc đối tượng, không phải luồng nghiệp vụ.

### 3. Invariant này **liên quan trực tiếp đến rule nào của business**?

Trong domain cà phê:

- **Pricing rule**: Giá cuối cùng = giá cơ bản + tổng topping
- **Composition rule**: Khách hàng có thể tùy chỉnh đồ uống mà không tạo class mới
- **Menu flexibility**: Thêm topping mới không làm thay đổi sản phẩm cơ bản

Trong domain I/O Stream:

- **Stream processing rule**: Dữ liệu qua nhiều lớp biến đổi (buffering → compression → encryption)
- **Resource management**: Mỗi decorator chịu trách nhiệm cleanup riêng của mình

### 4. Nếu hệ thống scale theo chiều **feature / team / use-case**, invariant này bị đe dọa ra sao?

**Rủi ro khi scale:**

- **Explosion số lượng decorator**: Với 5 topping, có thể có 2^5 = 32 tổ hợp
- **Ordering dependency**: Thứ tự decorator ảnh hưởng kết quả (BufferedStream → EncryptedStream ≠ EncryptedStream → BufferedStream)
- **Conflicting decorators**: Hai decorator có thể xung đột (VND Formatter vs USD Formatter)
- **Performance degradation**: Mỗi decorator thêm một layer indirection

**Giải pháp:**

- Dùng **Composite Pattern** nếu cần nhóm decorator
- Validate thứ tự decorator qua **Chain of Responsibility**
- Document dependencies rõ ràng

### 5. Pattern này có giúp **giữ invariant trước thay đổi hợp pháp**, nhưng **chặn thay đổi nguy hiểm** không?

**CÓ**, nhờ vào:

✅ **Thay đổi hợp pháp được phép:**

- Thêm decorator mới mà không sửa code cũ (OCP)
- Kết hợp decorator theo nhu cầu

❌ **Thay đổi nguy hiểm bị chặn:**

- Không thể modify component gốc thông qua decorator
- Không thể break interface contract (type-safe)
- Không thể skip decorator layer trong stack

**Ví dụ chặn thay đổi nguy hiểm:**

```java
// Không thể làm điều này vì decorator wrap component
Coffee coffee = new SimpleCoffee();
MilkDecorator decorated = new MilkDecorator(coffee);

// ❌ KHÔNG thể access trực tiếp SimpleCoffee để modify
// decorated.getWrappedCoffee().changePrice(20); // Không có method này

// ✅ CHỈ có thể tương tác qua interface
decorated.getCost(); // Type-safe
```

---

## 🔗 NHÓM 2 — Semantic Dependency & Coupling

### 6. Pattern này đang cắt **loại coupling nào**?

**Structural Coupling** và **Semantic Coupling**:

**Trước khi dùng Decorator** (tight coupling):

```java
class CoffeeWithMilk { }
class CoffeeWithMilkAndSugar { }
class CoffeeWithSugarAndWhippedCream { }
// → Phải tạo class mới cho mỗi tổ hợp (N factorial classes)
```

**Sau khi dùng Decorator** (loose coupling):

```java
Coffee coffee = new SimpleCoffee();
coffee = new MilkDecorator(coffee);
coffee = new SugarDecorator(coffee);
// → Component không biết nó đang được decorate
```

### 7. Nếu không dùng pattern, **ai sẽ biết quá nhiều về ai**?

**Vấn đề:**

- **Client** biết quá nhiều về cấu trúc nội bộ của các tổ hợp
- **Component** phải biết về tất cả features có thể thêm vào
- **Business logic** bị phân tán vào nhiều class cụ thể

**Ví dụ không dùng Decorator:**

```java
// ❌ Client phải biết chi tiết implementation
class OrderService {
    public double calculatePrice(String coffeeType, boolean hasMilk,
                                 boolean hasSugar, boolean hasWhip) {
        double price = 10;
        if (coffeeType.equals("Espresso")) price = 15;
        if (hasMilk) price += 5;
        if (hasSugar) price += 2;
        if (hasWhip) price += 7;
        return price;
        // → Mỗi lần thêm topping phải sửa tất cả if-else
    }
}
```

### 8. Dependency này vi phạm nguyên lý nào?

**Vi phạm cả SRP và DIP:**

**Vi phạm SRP:**

- Class có nhiều lý do để thay đổi (thêm topping, đổi giá cơ bản, đổi cách tính thuế...)

**Vi phạm DIP:**

- Client phụ thuộc vào concrete implementation thay vì abstraction
- High-level policy (tính giá) phụ thuộc vào low-level details (loại topping)

### 9. Pattern có giúp **đổi phụ thuộc compile-time thành runtime** không?

**CÓ**:

```java
// Compile-time: Chỉ phụ thuộc vào interface
Coffee coffee; // Abstract type

// Runtime: Composition được quyết định
coffee = new SimpleCoffee();
if (customer.wantsMilk()) {
    coffee = new MilkDecorator(coffee);
}
if (customer.wantsSugar()) {
    coffee = new SugarDecorator(coffee);
}
```

**Lợi ích:**

- Dependency injection dễ dàng hơn
- Unit testing dễ mock
- Configuration-driven behavior

### 10. Pattern có giúp **đổi phụ thuộc semantic thành dependency có kiểm soát** không?

**CÓ**, thông qua **interface**:

**Trước:**

```java
// Phụ thuộc semantic: "Biết" phải gọi method theo thứ tự nào
order.addMilk();
order.addSugar();
order.calculateTotal(); // Phải nhớ gọi cuối cùng
```

**Sau:**

```java
// Dependency có kiểm soát: Interface Coffee đảm bảo contract
Coffee coffee = new SugarDecorator(
    new MilkDecorator(
        new SimpleCoffee()
    )
);
coffee.getCost(); // Luôn đúng, không cần biết internal logic
```

---

## 🧩 NHÓM 3 — Encapsulation of Variation

### 11. Pattern này đang **đóng gói loại biến thiên nào**?

**Responsibilities và Features**:

- **Responsibility variation**: Mỗi decorator thêm một trách nhiệm cụ thể (pricing, logging, formatting...)
- **Feature variation**: Thêm tính năng mới mà không sửa core

**Ví dụ:**

```java
// Biến thiên về pricing strategy
Coffee coffee = new SimpleCoffee();           // Base price
coffee = new HolidayDiscountDecorator(coffee); // -10%
coffee = new LoyaltyPointsDecorator(coffee);  // +points cashback

// Biến thiên về I/O behavior
InputStream stream = new FileInputStream("data.txt");
stream = new BufferedInputStream(stream);    // Add buffering
stream = new GZIPInputStream(stream);        // Add decompression
```

### 12. Biến thiên này là loại nào?

**Policy** và một phần **Algorithm**:

- **Policy**: Luật quyết định tính năng nào được áp dụng (discount, tax, formatting...)
- **Algorithm**: Cách tính giá, mã hóa dữ liệu...

**Không phải Business rule thuần túy** vì chỉ là cách thức thực thi, không phải quy tắc nghiệp vụ cốt lõi.

### 13. Nếu biến thiên tăng gấp đôi, cấu trúc có còn đứng vững không?

**Phụ thuộc vào trường hợp:**

**✅ Đứng vững nếu:**

- Các decorator độc lập, không phụ thuộc nhau
- Có strategy để validate ordering

**❌ Gặp vấn đề nếu:**

- Số combination quá lớn (10 decorators = 1024 tổ hợp)
- Decorators có dependencies ẩn (phải A trước B)
- Performance issue do quá nhiều layers

**Giải pháp:**

- Giới hạn số lượng decorator cho phép
- Dùng **Builder Pattern** để kiểm soát composition
- Cache kết quả nếu cần

### 14. Pattern có thực sự tuân thủ **OCP** không?

**CÓ nhưng có điều kiện:**

✅ **Open for extension:**

```java
// Thêm decorator mới mà không sửa code cũ
class CinnamonDecorator extends CoffeeDecorator {
    public double getCost() {
        return super.getCost() + 3;
    }
}
```

⚠️ **Closed for modification — có ngoại lệ:**

- Nếu thêm method vào interface `Coffee`, TẤT CẢ decorator phải update
- Nếu thay đổi signature của `getCost()`, phải sửa tất cả

**Kết luận:** OCP được tuân thủ ở **cấp độ feature**, nhưng không phải **cấp độ interface**.

### 15. Có điểm mở rộng rõ ràng hay chỉ là "extension ngầm"?

**RÕ RÀNG** thông qua:

1. **Abstract base class**: `CoffeeDecorator extends Coffee`
2. **Interface contract**: `Coffee` interface
3. **Composition point**: Constructor `CoffeeDecorator(Coffee coffee)`

```java
// Extension point rõ ràng
public abstract class CoffeeDecorator implements Coffee {
    protected Coffee coffee; // Điểm mở rộng

    public CoffeeDecorator(Coffee coffee) {
        this.coffee = coffee;
    }
}
```

---

## 🧱 NHÓM 4 — Architectural Placement & Boundary

### 16. Pattern này nên nằm ở layer nào?

**Phụ thuộc use case:**

**Domain Layer:**

```java
// Decorator thể hiện business concept (pricing, discounting...)
interface Order { double getTotal(); }
class HolidayDiscountDecorator implements Order { }
```

**Application Layer:**

```java
// Decorator thêm cross-cutting concerns (logging, caching...)
class LoggingOrderDecorator implements Order {
    public double getTotal() {
        logger.info("Calculating total...");
        return order.getTotal();
    }
}
```

**Infrastructure Layer:**

```java
// Decorator cho technical concerns
class EncryptedStream extends InputStream { }
class BufferedStream extends InputStream { }
```

**Quy tắc:** Decorator nằm ở cùng layer với abstraction nó decorate.

### 17. Pattern có làm **leak technical concern vào business logic** không?

**CÓ THỂ** nếu không cẩn thận:

❌ **Ví dụ leak:**

```java
// Domain decorator bị trộn lẫn technical concern
class CoffeeDecorator {
    public double getCost() {
        // ❌ Technical concern (caching) trong domain logic
        if (cache.contains(coffee.getId())) {
            return cache.get(coffee.getId());
        }
        double cost = super.getCost();
        cache.put(coffee.getId(), cost);
        return cost;
    }
}
```

✅ **Tách riêng đúng cách:**

```java
// Domain decorator thuần túy
class MilkDecorator extends CoffeeDecorator {
    public double getCost() {
        return super.getCost() + 5; // Chỉ business logic
    }
}

// Technical decorator riêng biệt
class CachingDecorator extends CoffeeDecorator {
    public double getCost() {
        // Caching logic ở layer khác
    }
}
```

### 18. Nếu remove pattern, **domain model có bị tổn thương không**?

**KHÔNG** nếu decorator chỉ thêm feature:

```java
// Remove decorator, quay về base implementation
Coffee coffee = new SimpleCoffee(); // Vẫn hoạt động
```

**CÓ** nếu decorator là core business logic:

```java
// Nếu discount là bắt buộc trong business rule
Order order = new DiscountDecorator(new BaseOrder());
// → Remove DiscountDecorator → Giá sai → Domain bị phá
```

**Nguyên tắc:** Decorator nên là **optional enhancement**, không phải **mandatory logic**.

### 19. Pattern này có tạo ra **accidental complexity** cho domain không?

**CÓ THỂ** trong các tình huống:

❌ **Accidental complexity:**

```java
// Over-engineering cho use case đơn giản
Coffee coffee = new SimpleCoffee();
coffee = new MilkDecorator(coffee);
coffee = new SugarDecorator(coffee);
// → Chỉ 2 options, có thể dùng if-else đơn giản
```

✅ **Essential complexity:**

```java
// Hệ thống có 20+ toppings, decorator là hợp lý
InputStream stream = new FileInputStream("file.txt");
stream = new BufferedInputStream(stream);
stream = new GZIPInputStream(stream);
stream = new EncryptedInputStream(stream);
stream = new MetricsInputStream(stream);
// → Complexity là cần thiết, decorator giúp modular
```

### 20. Pattern có đang che giấu design smell nào không?

**CÓ THỂ che giấu:**

1. **God Object**: Component gốc có quá nhiều responsibility
2. **Feature envy**: Decorator biết quá nhiều về component
3. **Temporal coupling**: Phải decorate theo thứ tự cụ thể

**Ví dụ:**

```java
// ❌ Design smell: Decorator phụ thuộc nhau
class TaxDecorator {
    // Yêu cầu DiscountDecorator phải chạy trước
    public double getCost() {
        if (!(coffee instanceof DiscountDecorator)) {
            throw new IllegalStateException("Discount must be applied first");
        }
        return super.getCost() * 1.1;
    }
}
```

**Fix:** Dùng **Pipeline Pattern** hoặc tách responsibility ra service riêng.

---

## ⚠️ NHÓM 5 — Anti-pattern & Misuse

### 21. Pattern này thường bị lạm dụng vì lý do gì?

**Top 3 lý do:**

1. **"Open/Closed Principle" dogma**: Nghĩ rằng mọi extension đều phải dùng decorator
2. **Premature optimization**: Thêm decorator "phòng hờ sau này cần"
3. **Inheritance avoidance**: Sợ inheritance nên abuse decorator

**Ví dụ lạm dụng:**

```java
// ❌ Chỉ 1 feature đơn giản, không cần decorator
class UpperCaseStringDecorator {
    private String str;
    public String getValue() {
        return str.toUpperCase();
    }
}
// ✅ Dùng method đơn giản hơn
str.toUpperCase();
```

### 22. Dấu hiệu sớm cho thấy pattern đang **over-engineered**?

🚩 **Red flags:**

- Chỉ có 1-2 decorators trong codebase
- Không ai stack decorators (luôn dùng riêng lẻ)
- Decorator có nhiều dependencies hơn component gốc
- Team mới không hiểu mục đích của decorators
- Unit test phải setup 5+ decorators

**Litmus test:**

> Nếu remove decorator, chuyển thành simple method call, code có dễ đọc hơn không?

### 23. Pattern này có khiến code khó đọc / onboarding chậm hơn không?

**CÓ** nếu:

❌ **Khó đọc:**

```java
// Nested decorators khó trace
Coffee coffee = new WhippedCreamDecorator(
    new MochaDecorator(
        new SoyMilkDecorator(
            new SugarDecorator(
                new SimpleCoffee()
            )
        )
    )
);
// → Phải đọc từ trong ra ngoài
```

✅ **Dễ đọc hơn với Builder:**

```java
Coffee coffee = new CoffeeBuilder()
    .base(SimpleCoffee.class)
    .addSugar()
    .addSoyMilk()
    .addMocha()
    .addWhippedCream()
    .build();
```

**Onboarding:**

- Junior dev cần 2-3 ngày hiểu decorator pattern
- Phải document ordering dependencies
- Debugger khó trace qua nhiều layers

### 24. Nếu business rule **không thay đổi**, pattern này có đáng tồn tại không?

**KHÔNG** trong hầu hết trường hợp:

**Nếu rule cố định:**

```java
// ❌ Không cần decorator nếu luôn là "coffee + milk + sugar"
Coffee coffee = new CoffeeWithMilkAndSugar(); // Đơn giản hơn
```

**Nếu rule có thể thay đổi:**

```java
// ✅ Cần decorator vì customer tùy chỉnh
Coffee coffee = new SimpleCoffee();
if (customer.preferences.hasMilk) {
    coffee = new MilkDecorator(coffee);
}
```

**Nguyên tắc:** Pattern phải mang lại giá trị **ngay bây giờ hoặc tương lai gần**, không phải "có thể hữu ích sau 5 năm".

### 25. Pattern này có đang giải quyết **vấn đề giả** không?

**Câu hỏi kiểm tra:**

1. ❓ Có thực sự cần runtime composition không?
   - Nếu configuration có thể compile-time → Không cần decorator
2. ❓ Có nhiều hơn 3 variations không?
   - Nếu chỉ 2-3 → Simple inheritance đủ
3. ❓ Client có thực sự cần API giống nhau không?
   - Nếu behavior khác biệt nhiều → Không nên dùng decorator

**Ví dụ vấn đề giả:**

```java
// ❌ Không cần decorator vì chỉ 2 loại
interface Logger { }
class ConsoleLogger implements Logger { }
class FileLoggerDecorator extends Logger { }
// → Chỉ cần 2 implementations riêng
```

---

## 🧠 NHÓM 6 — Comparative Semantics

### 26. Pattern này dễ bị nhầm với pattern nào nhất?

**Top confusions:**

| Pattern       | Giống Decorator          | Khác Decorator                                               |
| ------------- | ------------------------ | ------------------------------------------------------------ |
| **Proxy**     | Cùng implement interface | Proxy kiểm soát **access**, không thêm **responsibility**    |
| **Adapter**   | Wrap object khác         | Adapter đổi **interface**, decorator giữ nguyên              |
| **Composite** | Cùng dùng composition    | Composite tạo **tree structure**, decorator tạo **chain**    |
| **Strategy**  | Thay đổi behavior        | Strategy **thay thế** algorithm, decorator **thêm** behavior |

### 27. Hai pattern khác nhau **ở invariant nào**?

**Decorator vs Proxy:**

```java
// Decorator: Thêm behavior
class LoggingDecorator implements Service {
    public void execute() {
        log("Starting...");
        service.execute();   // ← Gọi wrapped object
        log("Finished");
    }
}

// Proxy: Kiểm soát access
class ProtectionProxy implements Service {
    public void execute() {
        if (!user.hasPermission()) {
            throw new SecurityException();
        }
        service.execute();   // ← Có thể không gọi
    }
}
```

**Invariant khác nhau:**

- **Decorator**: Luôn delegate tới wrapped object
- **Proxy**: Có thể chặn hoặc thay thế call

### 28. Nếu thay thế bằng pattern khác, **điều gì sẽ bị mất?**

**Thay Decorator → Strategy:**

❌ **Mất:**

- Khả năng stack nhiều behaviors
- Composition tại runtime
- Progressive enhancement

```java
// Decorator: Stack được
Coffee c = new MilkDecorator(new SugarDecorator(new SimpleCoffee()));

// Strategy: Chỉ chọn 1
Coffee c = new Coffee(new MilkStrategy()); // Không thể thêm sugar
```

**Thay Decorator → Inheritance:**

❌ **Mất:**

- Flexibility (phải tạo class mới cho mỗi tổ hợp)
- Runtime composition
- Single inheritance limitation

### 29. Pattern này thường **phối hợp tốt với pattern nào**?

**Top combinations:**

1. **Builder Pattern**: Tạo decorator chain dễ đọc

```java
Coffee coffee = new CoffeeBuilder()
    .base(Espresso.class)
    .decorate(MilkDecorator.class)
    .decorate(SugarDecorator.class)
    .build();
```

2. **Factory Pattern**: Tạo decorators theo configuration

```java
CoffeeFactory.createCoffee(type: "LATTE");
// → Tự động tạo Espresso + MilkDecorator + FoamDecorator
```

3. **Composite Pattern**: Nhóm decorators

```java
CompositeDecorator premium = new CompositeDecorator(
    new MilkDecorator(),
    new WhipDecorator(),
    new CaramelDecorator()
);
```

### 30. Có giải pháp **đơn giản hơn nhưng vẫn bảo vệ được invariant không?**

**CÓ** trong nhiều trường hợp:

**Alternative 1: Higher-order functions (functional languages)**

```java
// Thay vì decorator
Function<Coffee, Coffee> addMilk = c -> c.withCost(c.getCost() + 5);
Function<Coffee, Coffee> addSugar = c -> c.withCost(c.getCost() + 2);

Coffee coffee = addSugar.apply(addMilk.apply(new SimpleCoffee()));
```

**Alternative 2: Aspect-Oriented Programming**

```java
@Logging
@Caching
@Transactional
public void processOrder() { }
// → Decorators được apply tự động
```

**Alternative 3: Configuration objects**

```java
Coffee coffee = new Coffee(new CoffeeConfig()
    .withMilk(true)
    .withSugar(true)
);
```

**Khi nào dùng alternative:**

- Nếu decorators không có state phức tạp
- Nếu language support higher-order function tốt
- Nếu framework đã có AOP built-in

---

## 🧮 NHÓM 7 — Chi phí & Vận hành

### 31. Pattern này làm tăng **Cognitive Load** bao nhiêu?

**Trung bình đến Cao** (6-7/10):

**Yêu cầu hiểu:**

- Interface contract
- Delegation chain
- Ordering dependencies (nếu có)
- Base vs decorated object lifecycle

**So với alternatives:**

- Simple if-else: 2/10
- Strategy pattern: 5/10
- Decorator: 7/10
- Visitor pattern: 9/10

### 32. Một dev mới cần bao lâu để hiểu đúng flow?

**Timeline:**

- **30 phút**: Hiểu concept cơ bản
- **2 giờ**: Trace qua debugger
- **1 ngày**: Tự implement decorator đơn giản
- **3-5 ngày**: Hiểu ordering dependencies và edge cases
- **2 tuần**: Quyết định được khi nào nên/không nên dùng

**Accelerators:**

- Có diagram rõ ràng
- Unit tests tốt
- Documentation về ordering

### 33. Debug flow qua pattern này dễ hay khó?

**KHÓ** vì:

❌ **Challenges:**

```
Call stack với 5 decorators:
TaxDecorator.getCost()
  → DiscountDecorator.getCost()
    → LoyaltyDecorator.getCost()
      → MilkDecorator.getCost()
        → SugarDecorator.getCost()
          → SimpleCoffee.getCost()
```

✅ **Giải pháp:**

- Logging ở mỗi decorator
- Debugger với conditional breakpoints
- toString() methods rõ ràng

### 34. Có tạo stack trace phức tạp không?

**CÓ**:

```
Exception in thread "main" java.lang.IllegalStateException
    at TaxDecorator.getCost(TaxDecorator.java:12)
    at DiscountDecorator.getCost(DiscountDecorator.java:8)
    at LoyaltyDecorator.getCost(LoyaltyDecorator.java:15)
    at MilkDecorator.getCost(MilkDecorator.java:6)
    at SimpleCoffee.getCost(SimpleCoffee.java:4)
    at OrderService.processOrder(OrderService.java:45)
```

**Mitigation:**

- Decorator nên bắt và wrap exceptions
- Thêm context vào error messages

### 35. Pattern này ảnh hưởng performance như thế nào?

**Impact:**

**Latency:**

- +1-2ms per decorator (method call overhead)
- Có thể cache kết quả nếu idempotent

**Memory:**

- Mỗi decorator = 1 object allocation
- Chain 10 decorators = 10x memory

**Allocation:**

- GC pressure nếu tạo decorators thường xuyên
- Nên pool decorators nếu có thể

**Benchmark example:**

```
SimpleCalculation: 0.1ms
With 5 decorators: 0.5ms (5x overhead)
With 10 decorators: 1.2ms (12x overhead)
```

### 36. Chi phí vận hành có **tương xứng với invariant được bảo vệ** không?

**Câu hỏi quyết định:**

| Scenario        | Complexity Added | Invariant Protected       | Verdict            |
| --------------- | ---------------- | ------------------------- | ------------------ |
| I/O Streams     | Cao              | Critical (data integrity) | ✅ Xứng đáng       |
| UI Components   | Trung bình       | Important (modularity)    | ✅ Xứng đáng       |
| Simple pricing  | Cao              | Minor (2-3 options)       | ❌ Không xứng đáng |
| Logging wrapper | Thấp             | Cross-cutting concern     | ✅ Xứng đáng       |

**Rule of thumb:**

- Nếu invariant là **domain-critical** → Chấp nhận complexity
- Nếu chỉ **nice-to-have** → Tìm giải pháp đơn giản hơn

---

## ⚙️ NHÓM 8 — Tính hiện đại & Ngôn ngữ

### 37. Pattern này tồn tại vì **hạn chế của ngôn ngữ cũ** hay bản chất bài toán?

**Cả hai:**

**Hạn chế ngôn ngữ (Java cũ):**

- Không có higher-order functions → Phải dùng objects
- Không có extension methods → Phải wrap

**Bản chất bài toán:**

- Cần composition tại runtime (không phải compile-time)
- Cần maintain interface contract
- Cần stack behaviors

**So sánh:**

```java
// Java (cần decorator)
InputStream stream = new GZIPInputStream(
    new BufferedInputStream(
        new FileInputStream("file.txt")
    )
);

// Kotlin (có extension functions)
val stream = FileInputStream("file.txt")
    .buffered()
    .gzip()
// → Decorator ẩn sau extension methods
```

### 38. Ngôn ngữ hiện đại có giảm boilerplate không?

**CÓ**:

**Java modern (Java 8+):**

```java
// Functional decorator
Function<Double, Double> addTax = price -> price * 1.1;
Function<Double, Double> addDiscount = price -> price * 0.9;

double finalPrice = addTax.andThen(addDiscount).apply(basePrice);
```

**Kotlin:**

```java
// Extension functions thay decorator
fun Coffee.withMilk(): Coffee = MilkDecorator(this)
fun Coffee.withSugar(): Coffee = SugarDecorator(this)

val coffee = SimpleCoffee().withMilk().withSugar()
```

**Python:**

```python
# Decorator syntax ngắn gọn
@cache
@log
@validate
def process_order(order):
    pass
```

### 39. Nếu thay bằng cách hiện đại hơn, invariant có còn được bảo vệ không?

**Phụ thuộc implementation:**

✅ **Vẫn bảo vệ được:**

```kotlin
// Extension function vẫn giữ type-safety
fun Coffee.addMilk(): Coffee {
    return MilkDecorator(this) // Type-safe
}
```

❌ **Có thể mất:**

```python
# Dynamic typing mất type-safety
def add_milk(coffee):
    coffee.cost += 5  # Mutate trực tiếp
    return coffee
```

**Kết luận:** Modern syntax giúp **concise hơn**, nhưng invariant protection phụ thuộc **type system** của ngôn ngữ.

### 40. Pattern này là **conceptual necessity** hay **historical artifact**?

**Conceptual Necessity** với điều kiện:

**Vẫn cần thiết khi:**

- Runtime composition là required
- Phải maintain strict interface contract
- Cần stack nhiều layers (I/O streams, middleware)

**Có thể thay thế khi:**

- Language có higher-order functions tốt
- Aspect-Oriented Programming available
- Chỉ cần compile-time composition

**Verdict:**

> Decorator là **conceptual necessity** cho **runtime composition**, nhưng **syntax** có thể được replaced bởi modern language features như extension methods, higher-order functions, và decorators (Python-style).

---

## 🔥 CÂU HỎI TỐI THƯỢNG

> ❝ **Nếu loại bỏ pattern này, invariant hoặc business rule nào sẽ bị phá đầu tiên — và việc phá đó có chấp nhận được trong 6–12 tháng tới không?** ❞

### Phân tích theo domain:

**1. I/O Streams (Java):**

- **Invariant bị phá:** Buffering, compression, encryption bị gộp chung vào một class
- **Chấp nhận được không:** ❌ KHÔNG — Sẽ tạo class explosion và unmaintainable code
- **Kết luận:** Decorator là **bắt buộc**

**2. Web Middleware (Express.js, ASP.NET):**

- **Invariant bị phá:** Request processing pipeline bị hardcode
- **Chấp nhận được không:** ❌ KHÔNG — Mỗi thêm feature phải sửa core framework
- **Kết luận:** Decorator (middleware pattern) là **cốt lõi**

**3. Simple pricing trong app nhỏ:**

- **Invariant bị phá:** Tính giá có thể sai nếu dùng if-else
- **Chấp nhận được không:** ✅ CÓ — Với 3-5 topping, if-else đủ rồi
- **Kết luận:** Decorator là **over-engineering**

**4. UI Component libraries:**

- **Invariant bị phá:** Component không thể compose
- **Chấp nhận được không:** ⚠️ TÙY — Nếu app đơn giản thì chấp nhận được, nếu scale lớn thì không
- **Kết luận:** Decorator tùy **quy mô hệ thống**

---

## 🏁 KẾT LUẬN

### Khi nào NÊN dùng Decorator Pattern:

✅ **Runtime composition** là yêu cầu
✅ **Nhiều variations** có thể combine (>5 options)
✅ **Interface contract** phải giữ nguyên
✅ **OCP** là critical (thêm feature không sửa code cũ)

### Khi nào KHÔNG NÊN dùng:

❌ Chỉ có 2-3 variations
❌ Behavior khác biệt căn bản (nên dùng Strategy)
❌ Compile-time composition đủ
❌ Team nhỏ, app đơn giản

### Trade-offs quan trọng:

| Lợi ích                | Chi phí                 |
| ---------------------- | ----------------------- |
| ✅ Flexibility cao     | ❌ Cognitive load cao   |
| ✅ OCP compliance      | ❌ Debugging khó        |
| ✅ Runtime composition | ❌ Performance overhead |
| ✅ Dễ test từng layer  | ❌ Stack trace phức tạp |

### Câu hỏi cuối cùng trước khi apply:

> **"6 tháng sau, khi có junior dev join, họ có hiểu được tại sao code này phức tạp như vậy không?"**

Nếu câu trả lời là **KHÔNG** → Tìm giải pháp đơn giản hơn.

---

**📚 Tài liệu tham khảo:**

- Gang of Four - Design Patterns (1994)
- Head First Design Patterns
- Refactoring Guru - Decorator Pattern
- Martin Fowler - Patterns of Enterprise Application Architecture
