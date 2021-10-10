 
local LibStub = _G.LibStub
local PTRIssueHide = LibStub("AceAddon-3.0"):NewAddon("PTRIssueHide", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigCmd = LibStub("AceConfigCmd-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local default = {profile = {reporter = true, luaErrors = true}}

function PTRIssueHide:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("PTRIssueHideDB", default)
    local DB = self.db.profile
    local general = {
        type = "group",
        name = "PTR Issue Hide",
        args = {
                options = {
                    type = "group",
                    name = "Options",
                    args = {
                            reporter = {
                                name = "PTR Issue Frame",
                                order = 1,
                                desc = "Toggle PTR Issue Reporter Frame",
                                type = "toggle",
                                set = function(info, val) self:FrameToggle(val, PTR_IssueReporter, "PTR_IssueReporter"); DB.reporter = not DB.reporter end,
                                get = function(info) return DB.reporter end
                                       },
                            luaErrors = {
                                name = "Lua Errors Frame",
                                order = 2,
                                desc = "Toggle Lua Error Frames",
                                type = "toggle",
                                set = function(info, val) self:FrameToggle(val, ScriptErrorsFrame, "ScriptErrorsFrame"); DB.luaErrors = not DB.luaErrors end,
                                get = function(info) return DB.luaErrors end
                            }
                    }
                }
        }
    }
    AceConfig:RegisterOptionsTable("PTRIssueHide", general)
    AceConfigDialog:AddToBlizOptions("PTRIssueHide", "PTRIssueHide")
    self:RegisterEvent("VARIABLES_LOADED")
    SLASH_PTRISSUEHIDE1 = "/pih"
    SLASH_PTRISSUEHIDE2 = "/ptrissuehide"
    SlashCmdList["PTRISSUEHIDE"] = function(msg) self:ChatCommands(msg) end
end

function PTRIssueHide:OnEnable()
    local timeElapsed = 0
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetScript("OnUpdate", function(self, elapsed)
                timeElapsed = timeElapsed + elapsed
                if timeElapsed > 0.1 then
                    timeElapsed = 0
                    PTRIssueHide:FrameOnShow()
               end
               end)
end

function PTRIssueHide:FrameOnShow()
    local DB = self.db.profile
    if not DB.reporter and PTRIssueReporterAlertFrame ~= nil then
        PTRIssueReporterAlertFrame:Hide()
    end
    if not DB.luaErrors and ScriptErrorsFrame ~= nil then
        ScriptErrorsFrame:Hide()
    end
end

function PTRIssueHide:VARIABLES_LOADED()
    local DB = self.db.profile
    self:FrameToggle(DB.reporter, PTR_IssueReporter, "PTR_IssueReporter")
    if not DB.luaErrors then self:FrameToggle(DB.reporter, ScriptErrorsFrame, "ScriptErrorsFrame") end
    self:Print("loaded !")
    self:Print("Use |cff00ff00/pih help|r or |cff00ff00/ptrissuehide help|r for commands")
end

function PTRIssueHide:FrameToggle(value, frame, frameName)
    if not value then
        frame:Hide()
        self:Print(frameName.." is |cffff0000Hidden|r")
    else
        frame:Show()
        self:Print(frameName.." is |cff00ff00Shown|r")
    end
end

function PTRIssueHide:ChatCommands(msg)
    local DB = self.db.profile
    msg = string.lower(msg);
	local args = {};
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(args, word);
	end
    if args[1] == nil then
        AceConfigDialog:Open("PTRIssueHide")
    elseif args[1] == "help" then
        self:Print("Use |cff00ff00/pih|r or |cff00ff00/ptrissuehide|r as prefix command, also it open options frame without arguments")
        self:Print("|cffffff00toggleissue|r - Toggle Issue Reporter and Issue Reporter Alert frames")
        self:Print("|cffffff00togglelua|r - Toggle Lua Error frames")
    elseif args[1] == "toggleissue" then
        DB.reporter = not DB.reporter
        self:FrameToggle(DB.reporter, PTR_IssueReporter, "PTR_IssueReporter")
    elseif args[1] == "togglelua" then
        DB.luaErrors = not DB.luaErrors
        self:FrameToggle(DB.luaErrors, ScriptErrorsFrame, "ScriptErrorsFrame")
    else
        return
    end
end
