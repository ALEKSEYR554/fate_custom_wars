#include <iostream>
#include <sstream>
#include <vector>
#include <string>

int main() {
    std::string input;
    std::cout << "";
    std::getline(std::cin, input);

    std::stringstream ss(input);
    std::string token;
    std::vector<std::string> traits;

    while (std::getline(ss, token, ',')) {
        size_t start = token.find_first_not_of(" \t");
        size_t end = token.find_last_not_of(" \t");
        if (start != std::string::npos && end != std::string::npos) {
            traits.push_back("\"" + token.substr(start, end - start + 1) + "\"");
        }
    }

    std::cout << "";
    for (size_t i = 0; i < traits.size(); ++i) {
        std::cout << traits[i];
        if (i != traits.size() - 1) std::cout << ", ";
    }
    std::cout << std::endl;

    return 0;
}
