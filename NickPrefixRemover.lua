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

-- Each setting covers every event its chat type can arrive on. Messages sent by
-- the party, raid or instance leader arrive on the *_LEADER events.
local events = {
    guild = { "CHAT_MSG_GUILD" },
    officer = { "CHAT_MSG_OFFICER" },
    party = { "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER" },
    raid = { "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER" },
    instance = { "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER" },
    channel = { "CHAT_MSG_CHANNEL" },
    say = { "CHAT_MSG_SAY" },
    yell = { "CHAT_MSG_YELL" },
    whisper = { "CHAT_MSG_WHISPER" },
    bnwhisper = { "CHAT_MSG_BN_WHISPER" },
    communities = { "CHAT_MSG_COMMUNITIES_CHANNEL" },
}

local eventSettings = {}
for setting, settingEvents in pairs(events) do
    for _, event in ipairs(settingEvents) do
        eventSettings[event] = setting
    end
end

-- Name2Chat writes "(Name): " and Incognito writes "<open>Name<close>: " with
-- (), [], {} or <> brackets. The nickname may contain spaces (WoW Forever
-- first and last names) but no brackets or colons; ": " must follow it and
-- the remaining message must not be empty.
local NICKNAME = "([^%(%)%[%]{}<>:]+)"
local REST = "%s*:%s+(%S.*)$"

local nicknamePatterns = {
    "^%s*%(" .. NICKNAME .. "%)" .. REST,
    "^%s*%[" .. NICKNAME .. "%]" .. REST,
    "^%s*{" .. NICKNAME .. "}" .. REST,
    "^%s*<" .. NICKNAME .. ">" .. REST,
}

local MAX_NICKNAME_BYTES = 50

-- Common trade-chat tags that look like a bracketed nickname.
local tradeTags = {
    wts = true,
    wtb = true,
    wtt = true,
    lfm = true,
    lfg = true,
    lf = true,
    lfw = true,
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

local function IsNickname(rawNickname)
    -- Hyperlinks, textures and Battle.net name escapes are never nicknames.
    if rawNickname:find("|[HhTtKk]") then
        return false
    end

    -- Incognito can colour the nickname with the sender's class colour.
    local nickname = rawNickname:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    nickname = nickname:match("^%s*(.-)%s*$")

    if nickname == "" or #nickname > MAX_NICKNAME_BYTES then
        return false
    end

    -- Numbered lists such as "(1): first point".
    if nickname:find("^%d+$") then
        return false
    end

    local lowerNickname = nickname:lower()

    -- Raid target markers such as "{star}: tank here" or "(skull): kill first",
    -- including their localised names.
    if ICON_TAG_LIST and ICON_TAG_LIST[lowerNickname] then
        return false
    end

    if tradeTags[lowerNickname] then
        return false
    end

    return true
end

local function MatchNicknamePrefix(msg, pattern)
    local nickname, rest = msg:match(pattern)
    if nickname and IsNickname(nickname) then
        return rest, true
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

    -- WoW Forever can deliver secret chat values; they cannot be inspected.
    if issecretvalue and issecretvalue(msg) then
        return
    end

    local newMsg, changed = StripNicknamePrefix(msg, db.fastPrefixPrecheck)
    if changed then
        return false, newMsg, author, ...
    end
end

-- Classic Era 1.15.9, TBC Anniversary and WoW Forever provide
-- ChatFrameUtil.AddMessageEventFilter and keep ChatFrame_AddMessageEventFilter
-- only as a deprecated fallback. Classic Era 1.15.8 already has a ChatFrameUtil
-- table without this function, so check the function, not the table.
local function AddMessageEventFilter(event, filter)
    if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
        ChatFrameUtil.AddMessageEventFilter(event, filter)
        return true
    end

    if ChatFrame_AddMessageEventFilter then
        ChatFrame_AddMessageEventFilter(event, filter)
        return true
    end

    return false
end

local missingFilterApiReported = false

local function ApplyFilters()
    for _, settingEvents in pairs(events) do
        for _, event in ipairs(settingEvents) do
            if not registered[event] then
                if AddMessageEventFilter(event, ChatFilter) then
                    registered[event] = true
                elseif not missingFilterApiReported then
                    missingFilterApiReported = true
                    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Nick Prefix Remover|r: chat filter API not available on this client.")
                end
            end
        end
    end
end

API.GetDB = GetDB
API.ApplyFilters = ApplyFilters

local function Set(key, value)
    GetDB()[key] = value and true or false
    ApplyFilters()

    -- Keep an open options window in sync with slash-command changes.
    if API.RefreshOptions then
        API.RefreshOptions()
    end
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

    if msg == "options" or msg == "settings" then
        if API.OpenSettings then
            API.OpenSettings()
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

    Print("Usage: /npr config | options | on | off | status | guild | officer | party | raid | instance | channel | say | yell | whisper | bnwhisper | communities")
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