#pragma once

#include <source_location>
#include <string>

#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>

class Log
{
  public:
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
        if (!m_enabled)
            return;

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

        fprintf(this->file, BUFFER_FORMAT, filename.c_str(), line, column, funcname, buffer);
        fflush(this->file);
    }

  private:
    static inline const char* FILENAME = "debug.log";

    static constexpr const char* BUFFER_FORMAT = "%s(%u:%u): `%s`:\n%s\n\n";
    static constexpr size_t BUFFER_LIMIT       = 0x200;

    Log() : file(nullptr)
    {
        if (m_enabled)
            this->file = fopen(FILENAME, "w");
    }

    FILE* file;
    static constexpr bool m_enabled = (__DEBUG__);
};

#define LOG(format, ...)                                                                 \
    {                                                                                    \
        static_assert(__DEBUG__, "Debugging not enabled. Please remove all LOG calls."); \
        Log::Instance().Write(std::source_location::current(), format, ##__VA_ARGS__);   \
    }
