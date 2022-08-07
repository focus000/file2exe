#ifndef EMBED_JSON
#include <fstream>
#include <filesystem>
#else
#include <JsonRC.h>
#endif
#include <iostream>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

// ...
int main() {
#ifndef EMBED_JSON
    std::cout << std::filesystem::absolute("example.json") << std::endl;
    std::ifstream f;
    std::ios_base::iostate exceptionMask = f.exceptions() | std::ios::failbit;
    f.exceptions(exceptionMask);
    try
    {
        f.open("example.json");

    }
    catch (std::ios_base::failure& e)
    {
        std::cerr << e.what() << '\n';
    }
    if (!f.is_open()) {
        std::cout << "open json file faild" << std::endl;
        return 0;
    }
    auto data = json::parse(f);
#else
    auto data = json::parse(json_rc::g_jstr);
#endif
    std::cout << data.dump() << std::endl;
    return 0;
}