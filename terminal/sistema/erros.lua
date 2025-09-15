-- Error Formatting Plugin for Linux Terminal
-- Place this in StarterPlayerScripts.terminal.sistema as "erros" (ModuleScript)

local ErrosPlugin = {}

-- Plugin initialization
function ErrosPlugin.init(terminalSystem)
    print("[Plugin Erros] Error highlighting plugin initialized")
end

-- Format error messages with red highlighting
function ErrosPlugin.formatError(errorText)
    if not errorText then return errorText end
    
    -- Add red color formatting (using rich text)
    local formattedError = "<font color=\"rgb(255,100,100)\">" .. errorText .. "</font>"
    
    -- Add error icon
    formattedError = "❌ " .. formattedError
    
    -- Add timestamp
    local timestamp = os.date("[%H:%M:%S]")
    formattedError = timestamp .. " " .. formattedError
    
    return formattedError
end

-- Process results to highlight any error keywords
function ErrosPlugin.processResult(result, command, args, context)
    if not result or type(result) ~= "string" then
        return result
    end
    
    -- Keywords that indicate errors
    local errorKeywords = {
        "error", "Error", "ERROR",
        "failed", "Failed", "FAILED",
        "exception", "Exception", "EXCEPTION",
        "warning", "Warning", "WARNING",
        "not found", "Not found", "NOT FOUND",
        "invalid", "Invalid", "INVALID",
        "denied", "Denied", "DENIED",
        "timeout", "Timeout", "TIMEOUT"
    }
    
    local processedResult = result
    
    -- Highlight error keywords in red
    for _, keyword in ipairs(errorKeywords) do
        local pattern = keyword:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
        processedResult = processedResult:gsub(pattern, "<font color=\"rgb(255,150,150)\">" .. keyword .. "</font>")
    end
    
    -- If the result contains error indicators, add warning emoji
    if processedResult ~= result then
        processedResult = "⚠️ " .. processedResult
    end
    
    return processedResult
end

-- Plugin information
ErrosPlugin.name = "erros"
ErrosPlugin.version = "1.0"
ErrosPlugin.description = "Highlights errors and warnings in red text"
ErrosPlugin.author = "Terminal System"

return ErrosPlugin