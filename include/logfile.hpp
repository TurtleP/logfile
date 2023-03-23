#pragma once

#include <source_location>
#include <string>

#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>

class Log
{
  public:
    static inline const char* FILENAME = "debug.log";

    static Log& Instance()
    {
        static Log instance;
        return instance;
    }

    ~Log()
    {
        fclose(this->file);
    }

    void Write(std::source_location location, const char* format, ...)
    {
        static_assert(m_enabled, "Debugging not enabled. Please remove all LOG calls.");

        va_list args;
        char buffer[BUFFER_LIMIT] { '\0' };

        va_start(args, format);
        vsnprintf(buffer, sizeof(buffer), format, args);
        va_end(args);

        const auto path     = std::string(location.file_name());
        const auto filename = path.substr(path.find_last_of('/') + 1);

        const auto line     = (uint32_t)location.line();
        const auto column   = (uint32_t)location.column();
        const auto funcname = location.function_name();

        fprintf(this->file, Log::FORMAT, filename.c_str(), line, column, funcname, buffer);
        fflush(this->file);
    }

  private:
    Log() : file(nullptr)
    {
        if (m_enabled)
            this->file = fopen(FILENAME, "w");
    }

    static constexpr const char* FORMAT  = "%s(%u:%u): `%s`:\n%s\n\n";
    static constexpr size_t BUFFER_LIMIT = 0x200;

    FILE* file;
    static constexpr bool m_enabled = (__DEBUG__);
};

#define LOG(format, ...) \
    Log::Instance().Write(std::source_location::current(), format, ##__VA_ARGS__);
