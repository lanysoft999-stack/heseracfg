local URL = "https://roblox.veroid.fun/api/loader"

local ok, source = pcall(function()
    return game:HttpGet(URL)
end)

if not ok then
    warn("[HeseraCfg] Ошибка соединения: " .. tostring(source))
    return
end

if type(source) ~= "string" or #source < 100 then
    warn("[HeseraCfg] Сервер вернул неправильный ответ")
    return
end

local fn, err = loadstring(source)

if not fn then
    warn("[HeseraCfg] Ошибка загрузки: " .. tostring(err))
    return
end

local success, runErr = pcall(fn)

if not success then
    warn("[HeseraCfg] Ошибка запуска: " .. tostring(runErr))
end
