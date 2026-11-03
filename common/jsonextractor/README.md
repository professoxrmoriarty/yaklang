# JSON Extractor

JSON Extractor 是 YakLang 中强大的流式 JSON 解析器，提供高效、灵活的 JSON 数据提取和处理能力。它不仅能处理标准 JSON 格式，还能容错处理各种非标准的类 JSON 数据。

## 核心特性

### 流式处理能力
- **内存高效**: 不需要一次性加载整个 JSON 数据到内存中
- **实时处理**: 边解析边处理，支持处理大文件和网络流
- **低延迟**: 即时响应，无需等待完整数据解析完成
- **字符级流式**: 支持字符级的实时数据流输出

### 灵活的回调机制
- **多种回调类型**: 支持对象、数组、键值对等不同粒度的回调处理
- **条件回调**: 基于特定条件触发的智能回调机制
- **字段流式处理**: 为特定字段提供实时流式数据处理能力
- **模式匹配**: 支持正则表达式和 Glob 模式进行字段匹配

### 强大的容错能力
- **格式兼容**: 能处理包含语法错误或格式不规范的 JSON 数据
- **边界情况**: 妥善处理各种边界情况和异常数据
- **渐进式解析**: 在遇到问题时仍能继续解析有效数据

## API 文档

### 核心函数

#### ExtractStructuredJSON

```go
func ExtractStructuredJSON(jsonString string, options ...CallbackOption) error
```

从字符串解析 JSON 数据的主入口函数。

**参数说明：**
- `jsonString string`: 要解析的 JSON 字符串
- `options ...CallbackOption`: 可变参数，支持多种回调选项配置

**返回值：**
- `error`: 解析过程中发生的错误，成功时返回 nil

**使用场景：**
- 处理内存中已有的 JSON 字符串
- 小到中等大小的 JSON 数据
- 需要完整解析整个 JSON 结构的场景

#### ExtractStructuredJSONFromStream

```go
func ExtractStructuredJSONFromStream(reader io.Reader, options ...CallbackOption) error
```

从数据流中解析 JSON 数据的核心函数。

**参数说明：**
- `reader io.Reader`: 实现了 io.Reader 接口的数据源
- `options ...CallbackOption`: 可变参数，支持多种回调选项配置

**返回值：**
- `error`: 解析过程中发生的错误，成功时返回 nil

**使用场景：**
- 处理大文件或网络流数据
- 实时数据流处理
- 内存受限的环境
- 需要边读取边处理数据的场景

### 回调选项

#### 基础回调选项

##### WithObjectCallback

```go
func WithObjectCallback(callback func(data map[string]any)) CallbackOption
```

监听对象完成解析，当整个 JSON 对象解析完成时触发。

**参数说明：**
- `callback func(data map[string]any)`: 对象解析完成后的回调函数
  - `data map[string]any`: 解析完成的 JSON 对象

**触发时机：**
- 当解析器完成一个完整的 JSON 对象时
- 适用于需要处理完整对象结构的场景

##### WithArrayCallback

```go
func WithArrayCallback(callback func(data []any)) CallbackOption
```

监听数组完成解析，当整个 JSON 数组解析完成时触发。

**参数说明：**
- `callback func(data []any)`: 数组解析完成后的回调函数
  - `data []any`: 解析完成的 JSON 数组

**触发时机：**
- 当解析器完成一个完整的 JSON 数组时
- 适用于需要处理完整数组数据的场景

##### WithRawKeyValueCallback

```go
func WithRawKeyValueCallback(callback func(key, data any)) CallbackOption
```

监听原始的键值对，包含未处理的原始字符串数据。

**参数说明：**
- `callback func(key, data any)`: 键值对解析时的回调函数
  - `key any`: 字段键（通常为字符串）
  - `data any`: 字段值（可能是字符串、数字、布尔值等）

**触发时机：**
- 当解析器遇到每个键值对时立即触发
- 适用于需要实时处理每个字段的场景

#### 流式处理回调选项

##### WithRegisterFieldStreamHandler

```go
func WithRegisterFieldStreamHandler(fieldName string, handler func(key string, reader io.Reader, parents []string)) CallbackOption
```

为指定字段注册流式处理器，提供字符级的实时数据流处理能力。

**参数说明：**
- `fieldName string`: 要监听的字段名称
- `handler func(key string, reader io.Reader, parents []string)`: 流式处理函数
  - `key string`: 字段名称
  - `reader io.Reader`: 数据流读取器
  - `parents []string`: 父级路径数组

**特性：**
- **实时流式**: 解析过程中逐字符写入，无需等待字段完成
- **内存高效**: 不缓存字段内容，直接流式传输
- **并发安全**: 支持多个字段同时流式处理
- **路径追踪**: 提供完整的嵌套路径信息

##### WithRegisterMultiFieldStreamHandler

```go
func WithRegisterMultiFieldStreamHandler(fieldNames []string, handler func(key string, reader io.Reader, parents []string)) CallbackOption
```

为多个字段注册统一的流式处理器。

**参数说明：**
- `fieldNames []string`: 要监听的字段名称列表
- `handler func(key string, reader io.Reader, parents []string)`: 统一的流式处理函数

**使用场景：**
- 多个字段需要相同的处理逻辑
- 减少重复代码，提高维护性

##### WithRegisterRegexpFieldStreamHandler

```go
func WithRegisterRegexpFieldStreamHandler(pattern string, handler func(key string, reader io.Reader, parents []string)) CallbackOption
```

使用正则表达式匹配字段，为匹配的字段注册流式处理器。

**参数说明：**
- `pattern string`: 正则表达式模式
- `handler func(key string, reader io.Reader, parents []string)`: 流式处理函数

**使用场景：**
- 批量处理具有相似名称的字段
- 动态字段匹配和处理

##### WithRegisterGlobFieldStreamHandler

```go
func WithRegisterGlobFieldStreamHandler(pattern string, handler func(key string, reader io.Reader, parents []string)) CallbackOption
```

使用 Glob 模式匹配字段，为匹配的字段注册流式处理器。

**参数说明：**
- `pattern string`: Glob 模式（如 `user_*`、`config_*`）
- `handler func(key string, reader io.Reader, parents []string)`: 流式处理函数

**使用场景：**
- 文件名模式匹配
- 简单通配符匹配

#### 条件回调选项

##### WithRegisterConditionalObjectCallback

```go
func WithRegisterConditionalObjectCallback(keys []string, callback func(data map[string]any)) CallbackOption
```

条件回调，只有当对象包含指定的所有键时才触发。

**参数说明：**
- `keys []string`: 必须包含的键列表
- `callback func(data map[string]any)`: 条件满足时的回调函数

**触发条件：**
- 对象必须同时包含 `keys` 中列出的所有键
- 只有完全匹配时才会触发回调

#### 其他回调选项

##### WithObjectKeyValue

```go
func WithObjectKeyValue(callback func(key string, data any)) CallbackOption
```

监听对象键值对的处理过程。

##### WithRootMapCallback

```go
func WithRootMapCallback(callback func(data map[string]any)) CallbackOption
```

监听根级对象的解析完成，专门用于处理顶级 JSON 对象。

## 快速开始

### 安装和导入

在你的 Go 项目中导入包：

```go
import "github.com/yaklang/yaklang/common/jsonextractor"
```

### 环境要求

- Go 1.18 或更高版本
- 支持的操作系统：Linux, macOS, Windows

## 使用示例

### 1. 基础用法

最简单的使用方式，处理完整的 JSON 对象和数组：

```go
jsonData := `{
    "name": "Alice",
    "age": 30,
    "skills": ["Go", "Python"],
    "profile": {
        "title": "Engineer",
        "department": "Development"
    }
}`

err := jsonextractor.ExtractStructuredJSON(jsonData,
    jsonextractor.WithObjectCallback(func(data map[string]any) {
        fmt.Printf("解析到对象: %+v\n", data)
    }),
    jsonextractor.WithArrayCallback(func(data []any) {
        fmt.Printf("解析到数组: %+v\n", data)
    }),
)

if err != nil {
    log.Printf("解析失败: %v", err)
}
```

### 2. 实时键值对处理

监听每个键值对的解析过程：

```go
jsonData := `{"name": "Bob", "age": 25, "active": true}`

err := jsonextractor.ExtractStructuredJSON(jsonData,
    jsonextractor.WithRawKeyValueCallback(func(key, value any) {
        fmt.Printf("字段 %v = %v\n", key, value)
    }),
)
```

### 3. 流式处理大字段

当遇到大字段时，使用流式处理器避免内存溢出：

```go
largeJSON := `{
    "id": 123,
    "title": "Large Document",
    "content": "` + strings.Repeat("Very long content ", 1000) + `",
    "metadata": {"size": "large"}
}`

err := jsonextractor.ExtractStructuredJSON(largeJSON,
    jsonextractor.WithRegisterFieldStreamHandler("content", func(key string, reader io.Reader, parents []string) {
        fmt.Printf("开始处理字段: %s\n", key)

        buffer := make([]byte, 1024)
        totalSize := 0

        for {
            n, err := reader.Read(buffer)
            if err == io.EOF {
                break
            }
            if err != nil {
                log.Printf("读取错误: %v", err)
                return
            }

            totalSize += n
            // 实时处理数据块...
            processChunk(buffer[:n])
        }

        fmt.Printf("字段 %s 处理完成，总大小: %d 字节\n", key, totalSize)
    }),
)
```

### 4. 从数据流解析

处理网络流或大文件：

```go
// 从文件流读取
file, err := os.Open("large_data.json")
if err != nil {
    return err
}
defer file.Close()

err = jsonextractor.ExtractStructuredJSONFromStream(file,
    jsonextractor.WithObjectCallback(func(data map[string]any) {
        // 处理每个对象
        processObject(data)
    }),
)
```

### 5. 多字段并发处理

同时处理多个大字段：

```go
jsonData := `{
    "data1": "` + strings.Repeat("A", 5000) + `",
    "data2": "` + strings.Repeat("B", 3000) + `",
    "data3": "` + strings.Repeat("C", 4000) + `"
}`

var wg sync.WaitGroup
results := make(map[string]int)
var mu sync.Mutex

err := jsonextractor.ExtractStructuredJSON(jsonData,
    jsonextractor.WithRegisterFieldStreamHandler("data1", func(key string, reader io.Reader, parents []string) {
        defer wg.Done()
        size := streamToSize(reader)
        mu.Lock()
        results[key] = size
        mu.Unlock()
    }),
    jsonextractor.WithRegisterFieldStreamHandler("data2", func(key string, reader io.Reader, parents []string) {
        defer wg.Done()
        size := streamToSize(reader)
        mu.Lock()
        results[key] = size
        mu.Unlock()
    }),
    jsonextractor.WithRegisterFieldStreamHandler("data3", func(key string, reader io.Reader, parents []string) {
        defer wg.Done()
        size := streamToSize(reader)
        mu.Lock()
        results[key] = size
        mu.Unlock()
    }),
)

wg.Add(3)
wg.Wait()

fmt.Printf("处理结果: %+v\n", results)
```

### 6. 模式匹配处理

使用正则表达式或 Glob 模式批量处理字段：

```go
jsonData := `{
    "user_name": "alice",
    "user_email": "alice@example.com",
    "user_age": 25,
    "admin_role": "manager",
    "config_host": "localhost",
    "config_port": 8080
}`

// 使用正则表达式匹配所有以 user_ 开头的字段
err := jsonextractor.ExtractStructuredJSON(jsonData,
    jsonextractor.WithRegisterRegexpFieldStreamHandler("^user_.*", func(key string, reader io.Reader, parents []string) {
        data, _ := io.ReadAll(reader)
        fmt.Printf("用户字段 %s: %s\n", key, string(data))
    }),
)

// 使用 Glob 模式匹配所有以 config_ 开头的字段
err = jsonextractor.ExtractStructuredJSON(jsonData,
    jsonextractor.WithRegisterGlobFieldStreamHandler("config_*", func(key string, reader io.Reader, parents []string) {
        data, _ := io.ReadAll(reader)
        fmt.Printf("配置字段 %s: %s\n", key, string(data))
    }),
)
```

### 7. 条件回调处理

只有当对象满足特定条件时才触发回调：

```go
jsonData := `{
    "user": {
        "name": "Alice",
        "email": "alice@example.com",
        "role": "admin"
    },
    "product": {
        "id": 123,
        "name": "Widget",
        "price": 99.99
    },
    "profile": {
        "name": "Alice",
        "age": 30,
        "city": "New York"
    }
}`

// 只有包含 name 和 email 的对象才会触发
err := jsonextractor.ExtractStructuredJSON(jsonData,
    jsonextractor.WithRegisterConditionalObjectCallback(
        []string{"name", "email"},
        func(data map[string]any) {
            fmt.Printf("发现用户: %s (%s)\n", data["name"], data["email"])
        },
    ),
    // 只有包含 name 和 age 的对象才会触发
    jsonextractor.WithRegisterConditionalObjectCallback(
        []string{"name", "age"},
        func(data map[string]any) {
            fmt.Printf("发现档案: %s, 年龄 %v\n", data["name"], data["age"])
        },
    ),
)
```

### 8. 嵌套路径追踪

处理复杂的嵌套结构并追踪字段路径：

```go
jsonData := `{
    "company": {
        "departments": {
            "engineering": {
                "teams": {
                    "backend": {
                        "members": [
                            {"name": "Alice", "role": "Senior Engineer"},
                            {"name": "Bob", "role": "Engineer"}
                        ]
                    }
                }
            }
        }
    }
}`

err := jsonextractor.ExtractStructuredJSON(jsonData,
    jsonextractor.WithRegisterFieldStreamHandler("name", func(key string, reader io.Reader, parents []string) {
        data, _ := io.ReadAll(reader)
        fmt.Printf("字段路径: %s -> 值: %s\n", strings.Join(parents, " -> "), string(data))
    }),
)
```

### 9. 容错处理

处理格式不规范的 JSON 数据：

```go
malformedJSON := `{
    "name": "Test",
    "data": "malformed"in"json",
    "array": [1, 2, 3,],
    "object": {
        "key": "value",
    },
    "number": 123.45e10
}`

// 即使 JSON 格式有问题，仍能解析有效部分
err := jsonextractor.ExtractStructuredJSON(malformedJSON,
    jsonextractor.WithObjectCallback(func(data map[string]any) {
        fmt.Printf("成功解析对象: %+v\n", data)
    }),
)

if err != nil {
    // 对于格式问题，可以选择记录日志而不是直接失败
    log.Printf("解析过程中遇到问题: %v", err)
}
```

## 核心概念

### 流式处理机制

JSON Extractor 的核心优势在于其流式处理能力：

1. **边解析边处理**: 数据不需要完全加载到内存中，而是边读取边解析
2. **实时响应**: 解析过程中即可开始处理数据，无需等待完整解析
3. **内存效率**: 对于大文件，内存占用保持在常量级别
4. **字符级流式**: 支持字符级别的实时数据流输出

### 回调机制

提供了多种粒度的回调选项：

- **结构级回调**: `WithObjectCallback`, `WithArrayCallback` - 处理完整的对象或数组
- **字段级回调**: `WithRawKeyValueCallback` - 处理每个键值对
- **流式回调**: `WithRegisterFieldStreamHandler` - 实时处理特定字段
- **条件回调**: `WithRegisterConditionalObjectCallback` - 基于条件触发的回调

### 字段匹配模式

支持多种字段匹配方式：

- **精确匹配**: 直接匹配字段名
- **正则匹配**: 使用正则表达式匹配字段模式
- **Glob匹配**: 使用通配符模式匹配字段
- **多字段匹配**: 同时匹配多个指定字段

## 高级特性

### 容错解析能力

JSON Extractor 能处理各种格式不规范的 JSON 数据：

```go
// 处理各种格式问题的JSON
testCases := []string{
    `{"name": "test", "data": "malformed"in"json"}`,     // 引号问题
    `{"array": [1, 2, 3,], "object": {"key": "value",}}`, // 多余逗号
    `{"number": .123, "scientific": 1e10}`,             // 数字格式问题
    `{"nested": {"incomplete": true, "missing": `,      // 截断的嵌套结构
}

for _, malformedJSON := range testCases {
    err := jsonextractor.ExtractStructuredJSON(malformedJSON,
        jsonextractor.WithObjectCallback(func(data map[string]any) {
            fmt.Printf("成功解析有效部分: %+v\n", data)
        }),
    )
    // 即使遇到格式错误，仍能解析有效数据
    if err != nil {
        log.Printf("解析完成，但遇到格式问题: %v", err)
    }
}
```

### 并发处理

支持多个字段的同时流式处理：

```go
var wg sync.WaitGroup
var results sync.Map

err := jsonextractor.ExtractStructuredJSON(largeJSON,
    jsonextractor.WithRegisterFieldStreamHandler("field1", func(key string, reader io.Reader, parents []string) {
        defer wg.Done()
        go processFieldAsync(key, reader, &results)
    }),
    jsonextractor.WithRegisterFieldStreamHandler("field2", func(key string, reader io.Reader, parents []string) {
        defer wg.Done()
        go processFieldAsync(key, reader, &results)
    }),
)

wg.Add(2)
wg.Wait()
```

### 路径追踪

支持嵌套结构的路径追踪：

```go
jsonData := `{
    "company": {
        "departments": {
            "engineering": {
                "teams": {
                    "backend": {
                        "lead": "Alice",
                        "members": ["Bob", "Charlie"]
                    }
                }
            }
        }
    }
}`

err := jsonextractor.ExtractStructuredJSON(jsonData,
    jsonextractor.WithRegisterFieldStreamHandler("lead", func(key string, reader io.Reader, parents []string) {
        data, _ := io.ReadAll(reader)
        fmt.Printf("路径追踪: %s -> %s = %s\n",
            strings.Join(parents, " -> "), key, string(data))
        // 输出: 路径追踪: company -> departments -> engineering -> teams -> backend -> lead = "Alice"
    }),
)
```

## 📊 性能对比

| 场景 | 传统JSON解析 | StreamExtractor |
|------|-------------|-----------------|
| 小文件 (< 1MB) | 快速 | 快速 |
| 大文件 (> 100MB) | 内存溢出风险 | 稳定的常量内存使用 |
| 选择性字段解析 | 解析全部后筛选 | 只解析目标字段 |
| 实时数据处理 | 需要等待完整解析 | 边解析边处理 |
| 内存占用 | O(n) 完整加载 | O(1) 流式处理 |
| 处理延迟 | 高（需要等待完整解析） | 低（即时响应） |
| 格式容错 | 严格要求标准格式 | 容错处理多种格式问题 |

## 最佳实践

### 错误处理

妥善处理各种错误情况：

```go
err := jsonextractor.ExtractStructuredJSON(data, callbacks...)
if err != nil {
    switch {
    case errors.Is(err, io.EOF):
        // 正常结束，可能还有部分数据被处理
        log.Println("数据流处理完成")
    case errors.Is(err, io.ErrUnexpectedEOF):
        // 数据截断，但可能已经处理了有效部分
        log.Printf("数据流意外结束，可能已处理部分数据: %v", err)
    default:
        // 其他解析错误
        log.Printf("JSON解析错误: %v", err)
    }
}
```

### 资源管理

确保资源的正确释放：

```go
jsonextractor.WithRegisterFieldStreamHandler("fileData", func(key string, reader io.Reader, parents []string) {
    file, err := os.CreateTemp("", "json_field_*")
    if err != nil {
        log.Printf("创建临时文件失败: %v", err)
        return
    }
    defer func() {
        if closeErr := file.Close(); closeErr != nil {
            log.Printf("关闭文件失败: %v", closeErr)
        }
    }()

    // 使用完后文件会被自动关闭
    _, err = io.Copy(file, reader)
    if err != nil {
        log.Printf("写入文件失败: %v", err)
        return
    }

    // 处理完成后可以重命名或移动文件
    finalPath := fmt.Sprintf("/processed/%s.data", key)
    if err := os.Rename(file.Name(), finalPath); err != nil {
        log.Printf("重命名文件失败: %v", err)
    }
})
```

### 并发安全

正确处理共享资源的并发访问：

```go
type Processor struct {
    mu      sync.RWMutex
    results map[string]ProcessedData
}

func (p *Processor) ProcessJSON(jsonData string) error {
    return jsonextractor.ExtractStructuredJSON(jsonData,
        jsonextractor.WithRegisterFieldStreamHandler("data", func(key string, reader io.Reader, parents []string) {
            processed := processField(reader)

            p.mu.Lock()
            p.results[key] = processed
            p.mu.Unlock()
        }),
    )
}

func (p *Processor) GetResults() map[string]ProcessedData {
    p.mu.RLock()
    defer p.mu.RUnlock()

    results := make(map[string]ProcessedData)
    for k, v := range p.results {
        results[k] = v
    }
    return results
}
```

### 组合使用模式

根据使用场景选择合适的回调组合：

```go
// 场景1: 大文件处理，关注特定字段
func processLargeFile(reader io.Reader) error {
    return jsonextractor.ExtractStructuredJSONFromStream(reader,
        jsonextractor.WithRegisterFieldStreamHandler("content", handleLargeContent),
        jsonextractor.WithRegisterRegexpFieldStreamHandler("^metadata_.*", handleMetadata),
    )
}

// 场景2: 实时监控，处理所有结构
func monitorJSONStream(reader io.Reader) error {
    return jsonextractor.ExtractStructuredJSONFromStream(reader,
        jsonextractor.WithObjectCallback(logObject),
        jsonextractor.WithArrayCallback(logArray),
        jsonextractor.WithRawKeyValueCallback(logKeyValue),
    )
}

// 场景3: 条件处理，只关注特定类型的数据
func processSpecificData(jsonData string) error {
    return jsonextractor.ExtractStructuredJSON(jsonData,
        jsonextractor.WithRegisterConditionalObjectCallback(
            []string{"type", "id"},
            func(data map[string]any) {
                if data["type"] == "user" {
                    processUser(data)
                } else if data["type"] == "product" {
                    processProduct(data)
                }
            },
        ),
    )
}
```

## 总结

JSON Extractor 提供了从简单数据提取到复杂实时流处理的完整解决方案：

- **基础使用**: `ExtractStructuredJSON` + 基础回调
- **大文件处理**: `ExtractStructuredJSONFromStream` + 流式处理器
- **高效处理**: 条件回调 + 模式匹配
- **并发处理**: 多字段同时流式处理
- **容错处理**: 自动处理格式问题，继续解析有效数据

通过合理选择和组合这些特性，可以满足各种 JSON 数据处理需求，同时保证性能和可靠性。

---

*本文档基于测试案例全面分析，为用户提供循序渐进的学习路径和实际使用指南。*
