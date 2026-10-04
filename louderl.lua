-- ClumsyScript GitHub Loader
-- Replace USERNAME/REPOSITORY with your GitHub repository.

local URL = "https://raw.githubusercontent.com/USERNAME/REPOSITORY/main/main.lua"

local ok, source = pcall(function()
    return game:HttpGet(URL)
end)

if not ok or type(source) ~= "string" or #source == 0 then
    warn("[ClumsyScript] Failed to download main.lua")
    return
end

local chunk, err = loadstring(source)
if not chunk then
    warn("[ClumsyScript] Failed to compile main.lua:", err)
    return
end

local ran, runErr = pcall(chunk)
if not ran then
    warn("[ClumsyScript] main.lua error:", runErr)
end
