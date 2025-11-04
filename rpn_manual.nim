# rpn_calculator_doc.nim
# ===============================================
# 《C++ 逆波兰计算器教程（Nimib 文档版）》
# -----------------------------------------------
# 作者：vito（基于 GPT-5 深度生成）
# 使用 Nimib 生成教学文档
# ===============================================

import std/strutils
import nimib

# ============= 样式初始化 =====================
template initCodeTheme* =
  nb.context["stylesheet"] = """
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/water.css">"""
  nb.context["highlight"] = """
<link rel="stylesheet" media="(prefers-color-scheme: dark)"
  href="https://cdn.jsdelivr.net/gh/highlightjs/highlight.js/src/styles/night-owl.css">
<link rel="stylesheet" media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)"
  href="https://cdn.jsdelivr.net/gh/highlightjs/highlight.js/src/styles/atom-one-light.css">"""

  nbRawHtml: """
<style>
pre code { border-radius: 4px 4px 0 0; }
pre { border: 1px solid #809eb7; border-radius: 4px 4px 0 0; margin-bottom: 0; }
pre.nb-output { border: 1px solid #809eb7; border-radius: 0 0 8px 8px; border-top: none;
  padding: 0.8em; margin-top: 0; overflow-x: auto; }
blockquote { border-left: 4px solid #4e89c7; padding-left: 10px; color: #555; }
</style>"""

# ============= 文档目录模板 =====================
var nbToc: NbBlock

template addToc =
  newNbBlock("nbText", false, nb, nbToc, ""):
    nbToc.output = "## 目录\n\n"

template nbNewSection(name:string) =
  let anchorName = name.toLower.replace(" ", "-")
  nbText "<a name=\"" & anchorName & "\"></a>\n<br>\n### " & name & "\n\n---"
  nbToc.output.add "1. <a href=\"#" & anchorName & "\">" & name & "</a>\n"

template nbSubSection(name:string) =
  let anchorName = name.toLower.replace(" ", "-")
  nbText "<a name=\"" & anchorName & "\"></a>\n<br>\n#### " & name & "\n\n---"
  nbToc.output.add "    * <a href=\"#" & anchorName & "\">" & name & "</a>\n"

template nbQuoteBlock(code: untyped) =
  nbText "<blockquote>"
  code
  nbText "</blockquote>"

# ===================== 文档内容 =====================
nbInit
initCodeTheme()

nbText: """
# 《C++ 逆波兰计算器教程》

---

- **作者**：vito  
- **语言**：C++17  
- **框架**：标准模板库（STL）  
- **工具**：Nimib 文档系统  
- **版本**：1.0  

---

> “编程是一种思维艺术 —— 计算机只是忠实的画布。”
"""

addToc()

# ------------------ 第一章 ------------------
nbNewSection "1. 项目介绍"

nbText: """
本教程将带你一步步实现一个**功能完整的逆波兰表达式（RPN）计算器**。  
逆波兰表示法（Reverse Polish Notation）是一种**后缀表达式**，它不需要括号即可表达复杂的算术逻辑。  
例如：

| 中缀表达式 | 逆波兰形式 | 结果 |
|-------------|-------------|-------|
| 5 + 2 | 5 2 + | 7 |
| (3 + 4) × 5 | 3 4 + 5 * | 35 |
| (5 - 3) ^ 2 | 5 3 - 2 ^ | 4 |

该程序支持：
- 基本四则运算（`+ - * /`）
- 开方运算 `sqrt`
- 幂运算 `^`
- 斐波那契序列 `fib`
- 命令退出（`q` / `quit`）

同时，它还具备异常处理机制和输入验证，保证交互安全。
"""

nbQuoteBlock:
  nbText "RPN 表达式的最大优点是**无需括号且计算顺序明确**，这使得它在解释器与虚拟机中广泛使用（如 Forth、PostScript、JVM 栈帧计算模型等）。"

# ------------------ 第二章 ------------------
nbNewSection "2. 项目结构设计"

nbText: """
程序的核心组件由以下几个部分组成：

1. **RPNCalculator 类**：  
   实现栈操作、算术逻辑、异常检查。

2. **isNumber 函数**：  
   用于判断字符串是否为合法数字（含小数点和负号）。

3. **evaluateRPN 函数**：  
   将输入的字符串解析为 token 并执行计算。

4. **main 函数**：  
   实现交互式命令行界面。

---

结构图如下：
"""

nbCodeSkip:
  # 结构伪图
  echo """
  RPNCalculator
  ├── push()
  ├── pop()
  ├── calculate()
  │    ├── + - * / ^ sqrt fib
  │    └── 内部调用 fibonacci()
  ├── top()
  ├── clear()
  └── size()
  """

# ------------------ 第三章 ------------------
nbNewSection "3. RPNCalculator 类实现"

nbSubSection "3.1 栈封装与基本方法"

nbText: "我们使用 `std::stack<double>` 作为计算的核心容器。"

nbCodeSkip:
  echo """
class RPNCalculator {
private:
    std::stack<double> stack;

public:
    void push(double value) { stack.push(value); }

    double pop() {
        if (stack.empty()) throw std::runtime_error("错误: 栈为空");
        double v = stack.top();
        stack.pop();
        return v;
    }

    double top() const {
        if (stack.empty()) throw std::runtime_error("错误: 栈为空");
        return stack.top();
    }

    void clear() { while (!stack.empty()) stack.pop(); }

    size_t size() const { return stack.size(); }
};
  """

nbQuoteBlock:
  nbText "这部分代码封装了一个安全的栈操作接口，避免了直接访问 STL 容器带来的错误风险。"

nbSubSection "3.2 运算实现"

nbText: "通过 `calculate()` 方法，我们支持多种运算类型，包括四则运算、平方根、幂运算及斐波那契。"

nbCodeSkip:
  echo """
void calculate(const std::string& op) {
    if (op == "+") { push(pop() + pop()); }
    else if (op == "-") { double b = pop(); push(pop() - b); }
    else if (op == "*") { push(pop() * pop()); }
    else if (op == "/") {
        double b = pop();
        if (b == 0) throw std::runtime_error("错误: 除零错误");
        push(pop() / b);
    }
    else if (op == "sqrt") {
        double a = pop();
        if (a < 0) throw std::runtime_error("错误: 负数不能开平方根");
        push(std::sqrt(a));
    }
    else if (op == "^") { double b = pop(); push(std::pow(pop(), b)); }
    else if (op == "fib") {
        int n = static_cast<int>(pop());
        if (n < 0) throw std::runtime_error("错误: 斐波那契数列索引不能为负");
        push(fibonacci(n));
    }
    else throw std::runtime_error("错误: 未知操作符 '" + op + "'");
}
  """

nbQuoteBlock:
  nbText "注意：`fib` 采用迭代实现，以避免递归栈溢出。"

# ------------------ 第四章 ------------------
nbNewSection "4. 表达式解析与执行"

nbText: """
RPN 表达式的解析逻辑非常直接：

1. 使用 `std::istringstream` 分词；
2. 依次判断每个 token 是数字还是操作符；
3. 若为数字，压入栈；
4. 若为操作符，调用 `calculate()`；
5. 最后检查栈中是否只剩一个结果。
"""

nbCodeSkip:
  echo """
double evaluateRPN(const std::string& expr, RPNCalculator& calc) {
    std::istringstream iss(expr);
    std::string token;

    while (iss >> token) {
        if (isNumber(token)) calc.push(std::stod(token));
        else calc.calculate(token);
    }

    if (calc.size() != 1)
        throw std::runtime_error("错误: 表达式不完整");

    return calc.top();
}
  """

# ------------------ 第五章 ------------------
nbNewSection "5. 主程序与交互界面"

nbText: """
最终，我们在 `main()` 函数中实现交互式命令行输入，支持用户连续输入表达式并显示结果。
"""

nbCodeSkip:
  echo """
int main() {
    RPNCalculator calculator;
    std::string input;

    std::cout << "C++ RPN 计算器" << std::endl;
    std::cout << "支持操作: + - * / ^ sqrt fib" << std::endl;

    while (true) {
        std::cout << "> ";
        std::getline(std::cin, input);
        if (input == "q" || input == "quit") break;

        try {
            calculator.clear();
            double result = evaluateRPN(input, calculator);
            std::cout << "结果: " << result << std::endl;
        } catch (const std::exception& e) {
            std::cout << e.what() << std::endl;
        }
    }
}
  """

nbQuoteBlock:
  nbText "这是一个完整的可运行终端程序，能够处理输入错误、数学异常、空栈访问等多种情况。"

# ------------------ 第六章 ------------------
nbNewSection "6. 测试样例"

nbText: "以下是一些运行测试："

nbCodeSkip:
  echo """
输入: 3 4 +        输出: 7
输入: 9 sqrt       输出: 3
输入: 5 3 - 2 ^    输出: 4
输入: 10 fib       输出: 55
输入: 5 0 /        输出: 错误: 除零错误
  """

nbQuoteBlock:
  nbText "程序在错误情况下能正确抛出异常信息，而不会崩溃。"

# ------------------ 第七章 ------------------
nbNewSection "7. 扩展与优化建议"

nbText: """
未来可扩展功能包括：

- 增加变量绑定与存储（如 `let x = 5`）
- 增加常用函数库（`sin`, `cos`, `log`）
- 实现历史命令记录与撤销（基于 vector 记录）
- 增加脚本执行模式：从文件中批量读取表达式
- 支持多精度浮点运算（如使用 GMP / Boost Multiprecision）
"""

nbQuoteBlock:
  nbText "通过这些扩展，你的 RPN 计算器将逐步演化为一个完整的解释型计算语言内核。"

# ------------------ 尾部 ------------------
nbText """
---

## 结语

通过本教程，我们从 C++ 基础出发，构建了一个安全、模块化的逆波兰计算器。  
在这个过程中，你学会了：

- 使用 **栈** 结构组织计算；
- 使用 **异常机制** 处理错误；
- 结合 **字符串流解析表达式**；
- 构建 **交互式命令行程序**。

这不仅是一个计算器，更是对 **语言设计、解析器构建与软件架构思维** 的一次训练。

> “能将一个概念转化为运行的程序，便已是创造者的荣耀。”
"""

nbSave

