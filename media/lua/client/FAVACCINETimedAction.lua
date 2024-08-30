require("TimedActions/ISBaseTimedAction")
require("XpSystem/XpUpdate")

local Utils = {}

-- Define tool categories in the most inefficient way ever
local extractionTools = {"KitchenKnife", "HuntingKnife", "Scissors", "MeatCleaver", "ObsidianBlade", "PrepperKnifeKnock", "PrepperKnifeStab", "PrepperKnifeSwing", "StalkerKnife", "SurvivalKnife"}
local properExtractionTools = {"Scalpel", nil}
local slowExtractionTools = {"AntiqueKatana", "Flintknife", "BreadKnife", "ButterKnife", "CheapSurvivalKnife", "GlassShiv", "HandAxe", "HandScythe", "Katana", "Machete", "KukriMachete", "RancherMachete", "SalvagedBlade", "SalvagedMachete", "SalvagedShiv", "SalvagedShivO", "ScrapBlade", "ScrapMachete", "ScrapShiv", "ScrapSword"}

-- Function to check if a value exists in a table
function Utils.has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

-- Check if an item is an extraction tool
function Utils.IsExtractionTool(item)
    return Utils.has_value(extractionTools, item:getType())
end

-- Check if an item is a proper extraction tool
function Utils.IsProperTool(item)
    return Utils.has_value(properExtractionTools, item:getType())
end

-- Check if an item is a slow extraction tool
function Utils.IsSlowExtractionTool(item)
    return Utils.has_value(slowExtractionTools, item:getType())
end

-- Function to damage a tool
function Utils.DamageTool(item, player)
    if not Utils.IsProperTool(item) then
        item:setCondition(item:getCondition() - 0.001)
    end
end

-- Define the timed action class
FAVExtractTimedAction = ISBaseTimedAction:derive("FAVExtractTimedAction")

function FAVExtractTimedAction:isValid()
    return true
end

function FAVExtractTimedAction:update()
end

function FAVExtractTimedAction:waitToStart()
    return false
end

function FAVExtractTimedAction:start()
    self:setActionAnim("RipSheets")
end

function FAVExtractTimedAction:stop()
    ISBaseTimedAction.stop(self)
end

function FAVExtractTimedAction:perform()
    self.character:getXp():AddXP(Perks.Doctor, (2 + ZombRand(5)))

    -- Base probability for Loose Zombie Cells extraction
    local baseProbability = 15

    -- Increase probability if using a proper extraction tool
    if Utils.IsProperTool(self.extractionTool) then
        baseProbability = baseProbability + 15 -- Increase probability by 15% for proper tools
    end

    if Utils.IsExtractionTool(self.extractionTool) then
	baseProbability = baseProbability + 5 --increase probability by 5% for slow tools
    end

    if Utils.IsSlowExtractionTool(self.extractionTool) then
	baseProbability = baseProbability - 5 --Decrease probability by 5% for slow tools
    end

    -- Probability check for Loose Zombie Cells
    if ZombRand(100) < baseProbability + (self.character:getPerkLevel(Perks.Doctor) * 2) then
        self.character:getInventory():AddItem('FAVACCINE.LooseZombieCells')
	self.character:Say("I might synthesize these cells.")
    else
        self.character:Say("Nothing useful here.")
    end

    -- Tool damage
    if not Utils.IsProperTool(self.extractionTool) then
        if self.character:getPerkLevel(Perks.Maintenance) / 2 + 94 < ZombRand(100) then
            Utils.DamageTool(self.extractionTool, self.character)
        end
    end

    self.corpse:getSquare():removeCorpse(self.corpse, false)
    ISBaseTimedAction.perform(self)
end

function FAVExtractTimedAction:new(character, extractionTool, corpse)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.extractionTool = extractionTool
    o.corpse = corpse
    o.stopOnWalk = true
    o.stopOnRun = true
    o.stopOnAim = true

    -- Default action time
    o.maxTime = 200

    -- Adjust action time if using a slow extraction tool
    if Utils.IsSlowExtractionTool(extractionTool) then
        o.maxTime = o.maxTime * 4 -- Make the action four times slower
    end

    -- Adjust action time if using a normal extraction tool
    if Utils.IsExtractionTool(extractionTool) then
        o.maxTime = o.maxTime * 2 -- Make the action four times slower
    end

    if o.character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end