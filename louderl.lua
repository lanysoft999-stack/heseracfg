-- ClumsyCfg loader
-- Public file: this file may be placed on GitHub.
-- Your existing bot main.py is NOT involved.

local API_URL = "https://clumsycfg.playmc.tech/api/ClumsyCfg_7F4K9X2M"

local ok, source = pcall(function()
    return game:HttpGet(API_URL)
end)

if not ok then
    warn("[ClumsyCfg] API request failed:", source)
    return
end

if type(source) ~= "string" or #source < 10 then
    warn("[ClumsyCfg] API returned an empty/invalid script")
    return
end

local fn, compileError = loadstring(source)
if not fn then
    warn("[ClumsyCfg] Script compile error:", compileError)
    return
end

local ran, runtimeError = pcall(fn)
if not ran then
    warn("[ClumsyCfg] Script runtime error:", runtimeError)
end
