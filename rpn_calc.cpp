#include <iostream>
#include <stack>
#include <string>
#include <sstream>
#include <cmath>
#include <stdexcept>
#include <vector>
#include <cctype>  // 添加这个头文件用于 isdigit

class RPNCalculator {
private:
    std::stack<double> stack;
    
public:
    // 压入数值到栈中
    void push(double value) {
        stack.push(value);
    }
    
    // 从栈中弹出数值
    double pop() {
        if (stack.empty()) {
            throw std::runtime_error("错误: 栈为空");
        }
        double value = stack.top();
        stack.pop();
        return value;
    }
    
    // 执行计算操作
    void calculate(const std::string& operation) {
        if (operation == "+") {
            double b = pop();
            double a = pop();
            push(a + b);
        } else if (operation == "-") {
            double b = pop();
            double a = pop();
            push(a - b);
        } else if (operation == "*") {
            double b = pop();
            double a = pop();
            push(a * b);
        } else if (operation == "/") {
            double b = pop();
            if (b == 0) {
                throw std::runtime_error("错误: 除零错误");
            }
            double a = pop();
            push(a / b);
        } else if (operation == "sqrt") {
            double a = pop();
            if (a < 0) {
                throw std::runtime_error("错误: 负数不能开平方根");
            }
            push(std::sqrt(a));
        } else if (operation == "^") {
            double b = pop();
            double a = pop();
            push(std::pow(a, b));
        } else if (operation == "fib") {
            int n = static_cast<int>(pop());
            if (n < 0) {
                throw std::runtime_error("错误: 斐波那契数列索引不能为负数");
            }
            push(fibonacci(n));
        } else {
            throw std::runtime_error("错误: 未知操作符 '" + operation + "'");
        }
    }
    
    // 获取栈大小
    size_t size() const {
        return stack.size();
    }
    
    // 获取栈顶元素（不弹出）
    double top() const {
        if (stack.empty()) {
            throw std::runtime_error("错误: 栈为空");
        }
        return stack.top();
    }
    
    // 清空栈
    void clear() {
        while (!stack.empty()) {
            stack.pop();
        }
    }
    
private:
    // 计算斐波那契数列
    double fibonacci(int n) {
        if (n == 0) return 0;
        if (n == 1) return 1;
        
        double a = 0, b = 1;
        for (int i = 2; i <= n; i++) {
            double temp = a + b;
            a = b;
            b = temp;
        }
        return b;
    }
};

// 检查字符串是否为数字
bool isNumber(const std::string& str) {
    if (str.empty()) return false;
    
    // 检查是否为负数
    size_t start = 0;
    if (str[0] == '-') {
        if (str.length() == 1) return false; // 只有负号不是数字
        start = 1;
    }
    
    bool hasDecimalPoint = false;
    for (size_t i = start; i < str.length(); i++) {
        if (str[i] == '.') {
            if (hasDecimalPoint) return false; // 多个小数点
            hasDecimalPoint = true;
        } else if (!isdigit(str[i])) {
            return false;
        }
    }
    return true;
}

// 解析并执行RPN表达式
double evaluateRPN(const std::string& expression, RPNCalculator& calc) {
    std::istringstream iss(expression);
    std::string token;
    
    while (iss >> token) {
        if (token == "q" || token == "quit") {
            return 0;
        }
        
        // 检查是否为数字
        if (isNumber(token)) {
            try {
                double value = std::stod(token);
                calc.push(value);
            } catch (const std::exception& e) {
                throw std::runtime_error("错误: 无效数字 '" + token + "'");
            }
        } else {
            // 如果是操作符
            calc.calculate(token);
        }
    }
    
    if (calc.size() != 1) {
        throw std::runtime_error("错误: 表达式不完整");
    }
    
    return calc.top();
}

int main() {
    RPNCalculator calculator;
    std::string input;
    
    std::cout << "C++ RPN 计算器" << std::endl;
    std::cout << "支持的操作: +, -, *, /, ^ (幂), sqrt, fib (斐波那契)" << std::endl;
    std::cout << "输入表达式 (例如: '5 5 +'), 或 'q' 退出" << std::endl;
    
    while (true) {
        std::cout << "> ";
        std::getline(std::cin, input);
        
        if (input == "q" || input == "quit") {
            break;
        }
        
        if (input.empty()) {
            continue;
        }
        
        try {
            calculator.clear();
            double result = evaluateRPN(input, calculator);
            std::cout << "结果: " << result << std::endl;
        } catch (const std::exception& e) {
            std::cout << e.what() << std::endl;
        }
    }
    
    return 0;
}
