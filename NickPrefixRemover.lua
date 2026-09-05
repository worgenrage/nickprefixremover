local ADDON_NAME, addon = ...
addon = addon or {}
addon.name = ADDON_NAME
addon.API = addon.API or {}

local API = addon.API

local defaults = {
    enabled = true,
    fastPrefixPrecheck = true,
    guild = true,
    officer = false,
    party = false,
    raid = false,
    instance = false,
    channel = false,
    say = false,
    yell = false,
    whisper = false,
    bnwhisper = false,
    communities = false,
}

local events = {
    guild = "CHAT_MSG_GUILD",
    officer = "CHAT_MSG_OFFICER",
    party = "CHAT_MSG_PARTY",
    raid = "CHAT_MSG_RAID",
    instance = "CHAT_MSG_INSTANCE_CHAT",
    channel = "CHAT_MSG_CHANNEL",
    say = "CHAT_MSG_SAY",
    yell = "CHAT_MSG_YELL",
    whisper = "CHAT_MSG_WHISPER",
    bnwhisper = "CHAT_MSG_BN_WHISPER",
    communities = "CHAT_MSG_COMMUNITIES_CHANNEL",
}

local eventSettings = {}
for setting, event in pairs(events) do
    eventSettings[event] = setting
end

local nicknamePatterns = {
    "^%s*%((.-)%)%s*:%s*(.*)$",
    "^%s*%[(.-)%]%s*:%s*(.*)$",
    "^%s*%{(.-)%}%s*:%s*(.*)$",
    "^%s*<(.-)>%s*:%s*(.*)$",
}

local nicknamePatternsByOpeningCharacter = {
    ["("] = nicknamePatterns[1],
    ["["] = nicknamePatterns[2],
    ["{"] = nicknamePatterns[3],
    ["<"] = nicknamePatterns[4],
}

local registered = {}

local function CopyDefaults(dst)
    for k, v in pairs(defaults) do
        if type(dst[k]) ~= type(v) then
            dst[k] = v
        end
    end
end

local function GetDB()
    if type(NickPrefixRemoverDB) ~= "table" then
        NickPrefixRemoverDB = {}
    end

    CopyDefaults(NickPrefixRemoverDB)
    return NickPrefixRemoverDB
end

local function MatchNicknamePrefix(msg, pattern)
    local nickname, rest = msg:match(pattern)
    if nickname then
        nickname = nickname:match("^%s*(.-)%s*$")
        if nickname ~= "" then
            return rest, true
        end
    end

    return msg, false
end

local function StripNicknamePrefix(msg, useFastPrecheck)
    if type(msg) ~= "string" or msg == "" then
        return msg, false
    end

    if useFastPrecheck then
        local openingCharacter = msg:match("^%s*(.)")
        local pattern = nicknamePatternsByOpeningCharacter[openingCharacter]

        if not pattern then
            return msg, false
        end

        return MatchNicknamePrefix(msg, pattern)
    end

    for _, pattern in ipairs(nicknamePatterns) do
        local newMsg, changed = MatchNicknamePrefix(msg, pattern)
        if changed then
            return newMsg, true
        end
    end

    return msg, false
end

local function ChatFilter(self, event, msg, author, ...)
    local db = NickPrefixRemoverDB
    if not db or not db.enabled then
        return
    end

    local key = eventSettings[event]
    if not key or not db[key] then
        return
    end

    local newMsg, changed = StripNicknamePrefix(msg, db.fastPrefixPrecheck)
    if changed then
        return false, newMsg, author, ...
    end
end

local function ApplyFilters()
    for _, event in pairs(events) do
        if not registered[event] then
            ChatFrame_AddMessageEventFilter(event, ChatFilter)
            registered[event] = true
        end
    end
end

API.GetDB = GetDB
API.ApplyFilters = ApplyFilters

local function Set(key, value)
    GetDB()[key] = value and true or false
    ApplyFilters()
end

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Nick Prefix Remover|r: " .. msg)
end

local function ShowStatus()
    local db = GetDB()
    Print("Enabled: " .. (db.enabled and "|cff00ff00ON|r" or "|cffff0000OFF|r"))

    local enabled = {}
    for key in pairs(events) do
        if db[key] then
            enabled[#enabled + 1] = key
        end
    end

    table.sort(enabled)
    Print("Channels: " .. (#enabled > 0 and table.concat(enabled, ", ") or "none"))
end

local function Toggle(key)
    Set(key, not GetDB()[key])
    Print(key .. ": " .. (GetDB()[key] and "ON" or "OFF"))
end

SLASH_NICKPREFIXREMOVER1 = "/npr"
SLASH_NICKPREFIXREMOVER2 = "/nickprefix"

SlashCmdList.NICKPREFIXREMOVER = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")

    if msg == "" or msg == "config" then
        if API.OpenOptions then
            API.OpenOptions()
        end
        return
    end

    if msg == "on" or msg == "enable" then
        Set("enabled", true)
        Print("Enabled.")
        return
    end

    if msg == "off" or msg == "disable" then
        Set("enabled", false)
        Print("Disabled.")
        return
    end

    if msg == "status" then
        ShowStatus()
        return
    end

    local aliases = {
        guild = "guild",
        officer = "officer",
        party = "party",
        raid = "raid",
        instance = "instance",
        channel = "channel",
        channels = "channel",
        say = "say",
        yell = "yell",
        whisper = "whisper",
        bnwhisper = "bnwhisper",
        communities = "communities",
    }

    local key = aliases[msg]
    if key then
        Toggle(key)
        return
    end

    Print("Usage: /npr config | on | off | status | guild | officer | party | raid | instance | channel | say | yell | whisper | bnwhisper | communities")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= ADDON_NAME then
        return
    end

    GetDB()
    ApplyFilters()
    self:UnregisterEvent("ADDON_LOADED")
end)