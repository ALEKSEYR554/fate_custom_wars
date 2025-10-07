//g++ -std=c++17 -o converter converter.cpp



#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <fstream>
#include <sstream>
#include <filesystem> 


#include "json.hpp"

// Для удобства используем псевдонимы
namespace fs = std::filesystem;
using json = nlohmann::json;

// Вспомогательная функция для экранирования символов новой строки в строках для CSV
// В Ruby это делалось с помощью .gsub("\n","\\n")
std::string escape_for_csv(const std::string& input) {
    std::string output;
    output.reserve(input.length()); // Оптимизация: заранее выделяем память
    for (char c : input) {
        if (c == '\n') {
            output += "\\n"; // Заменяем \n на \\n
        } else {
            output += c;
        }
    }
    return output;
}

int main() {
    // Карта для хранения всех переводов. Ключ - код языка ("en", "de"), значение - JSON-объект.
    std::map<std::string, json> translations;
    // Вектор для сохранения порядка языков, как в оригинальном скрипте
    std::vector<std::string> lang_codes;

    // Эквивалент Dir.glob("*.{json}")
    try {
        for (const auto& entry : fs::directory_iterator(".")) {
            if (entry.is_regular_file() && entry.path().extension() == ".json") {
                std::string filename = entry.path().filename().string();
                if (filename.length() < 2) continue; // Пропускаем слишком короткие имена файлов

                // Получаем код языка из первых двух символов имени файла
                std::string lang_code = filename.substr(0, 2);
                lang_codes.push_back(lang_code);

                // Читаем и парсим JSON файл
                std::ifstream file_stream(entry.path());
                if (!file_stream.is_open()) {
                    std::cerr << "Ошибка: не удалось открыть файл " << filename << std::endl;
                    continue;
                }
                
                // Эквивалент JSON.parse(File.read(translation_file))
                json data = json::parse(file_stream);
                translations[lang_code] = data;

                std::cout << "Найден и обработан файл: " << filename << std::endl;
            }
        }
    } catch (const fs::filesystem_error& e) {
        std::cerr << "Ошибка файловой системы: " << e.what() << std::endl;
        return 1;
    }

    if (translations.empty()) {
        std::cout << "Не найдено ни одного .json файла в текущей директории." << std::endl;
        return 0;
    }

    // Используем stringstream для эффективного построения CSV строки
    std::stringstream csv_output;
    const std::string separator = ",";

    // 1. Создаем заголовок CSV
    // out = "id"
    csv_output << "id";
    // out+= separator+translation_file.to_s[0..1]
    for (const auto& lang : lang_codes) {
        csv_output << separator << lang;
    }
    csv_output << "\n";

    // 2. Добавляем строки с данными
    // Ruby-скрипт использует "en" как эталонный язык для получения списка ключей.
    // Добавим проверку, существует ли он.
    std::string reference_lang = "en";
    if (translations.find(reference_lang) == translations.end()) {
        std::cerr << "Ошибка: Эталонный файл 'en.json' не найден. Невозможно сгенерировать CSV." << std::endl;
        return 1;
    }

    // for key in transl["en"].keys()
    for (auto const& [key, val] : translations[reference_lang].items()) {
        // out+="#{key}"
        csv_output << key;

        // for lang in transl.keys()
        for (const auto& lang : lang_codes) {
            std::string translated_text = "";
            // Проверяем, существует ли ключ в данном языке
            if (translations[lang].contains(key) && translations[lang][key].is_string()) {
                // out+=separator+"\"#{(transl[lang][key].gsub("\n","\\n"))}\""
                translated_text = translations[lang][key].get<std::string>();
            }
            // Всегда добавляем кавычки и экранируем
            csv_output << separator << "\"" << escape_for_csv(translated_text) << "\"";
        }
        csv_output << "\n";
    }

    // 3. Записываем результат в файл
    // File.write("default\\output.csv",out)
    try {
        fs::path output_dir = "default";
        // Создаем директорию, если она не существует
        fs::create_directories(output_dir); 
        
        fs::path output_file_path = output_dir / "output.csv";

        std::ofstream out_file(output_file_path);
        if (!out_file.is_open()) {
            std::cerr << "Ошибка: не удалось создать или открыть файл " << output_file_path << std::endl;
            return 1;
        }

        out_file << csv_output.str();
        out_file.close();

        std::cout << "\nФайл успешно создан: " << output_file_path << std::endl;

    } catch (const fs::filesystem_error& e) {
        std::cerr << "Ошибка при записи файла: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}