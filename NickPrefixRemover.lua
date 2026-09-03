local ADDON_NAME, addon = ...
addon = addon or {}
addon.name = ADDON_NAME
addon.API = addon.API or {}

local API = addon.API

local defaults = {
    enabled = true,
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

-- Keep these patterns outside the chat filter. The filter runs for every
-- displayed message, so it should not allocate a new table each time.
local nicknamePatterns = {
    "^%s*%((.-)%)%s*:%s*(.*)$",
    "^%s*%[(.-)%]%s*:%s*(.*)$",
    "^%s*%{(.-)%}%s*:%s*(.*)$",
    "^%s*<(.-)>%s*:%s*(.*)$",
}

local registered = {}

local function CopyDefaults(dst)
    for k, v in pairs(defaults) do
        -- SavedVariables can survive addon upgrades and manual edits. Restore
        -- an invalid value as well as a missing one, so boolean settings never
        -- become truthy strings or incompatible values.
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

-- Recognises the formats used by common nickname-prefix addons:
--   (Nickname): message
--   [Nickname]: message
--   {Nickname}: message
--   <Nickname>: message
--
-- The match is intentionally anchored at the beginning. We do not touch
-- bracketed text appearing later in a normal message.
local function StripNicknamePrefix(msg)
    if type(msg) ~= "string" or msg == "" then
        return msg, false
    end

    -- Name2Chat and Incognito-style addons prepend the nickname to the
    -- message, for example: "(krix): hello".  Be liberal about whitespace
    -- inside and around the brackets: "( krix ) : hello" is also valid.
    -- The leading whitespace is intentional; it covers chat implementations
    -- that insert one before the addon prefix without matching later text.
    for _, pattern in ipairs(nicknamePatterns) do
        local nickname, rest = msg:match(pattern)
        if nickname then
            -- Do not remove an empty bracket pair or a prefix containing only
            -- whitespace; those are ordinary user messages, not nicknames.
            nickname = nickname:match("^%s*(.-)%s*$")
            if nickname ~= "" then
                return rest, true
            end
        end
    end

    return msg, false
end

local function ChatFilter(self, event, msg, author, ...)
    -- Filters are added only after GetDB() has initialised this table.
    -- Reading it directly avoids copying defaults for every chat line.
    local db = NickPrefixRemoverDB
    if not db or not db.enabled then
        return
    end

    local key = eventSettings[event]

    if not key or not db[key] then
        return
    end

    local newMsg, changed = StripNicknamePrefix(msg)
    if changed then
        return false, newMsg, author, ...
    end
end

local function ApplyFilters()
    -- Keep registration order stable when users toggle a channel. Other chat
    -- addons can also use message filters, and removing/re-adding ours would
    -- otherwise move it to a different position in their filter chain.
    for _, event in pairs(events) do
        if not registered[event] then
            ChatFrame_AddMessageEventFilter(event, ChatFilter)
            registered[event] = true
        end
    end
end

-- Internal addon API shared through the private table passed to each file by
-- the TOC loader. This avoids publishing implementation details in _G.
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
    for key, event in pairs(events) do
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
frame:SetScript("OnEvent", function(self, event, addon)
    if addon ~= ADDON_NAME then
        return
    end

    GetDB()
    ApplyFilters()
    self:UnregisterEvent("ADDON_LOADED")
end)
