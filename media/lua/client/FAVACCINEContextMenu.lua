local FAVExtract = {}
local FAVCorpse = {}

-- Define tool categories in the most inefficient way ever
local extractionTools = {"KitchenKnife", "HuntingKnife", "Scissors", "MeatCleaver", "ObsidianBlade", "PrepperKnifeKnock", "PrepperKnifeStab", "PrepperKnifeSwing", "StalkerKnife", "SurvivalKnife"}
local properExtractionTools = {"Scalpel", nil}
local slowExtractionTools = {"AntiqueKatana", "Flintknife", "BreadKnife", "ButterKnife", "CheapSurvivalKnife", "GlassShiv", "HandAxe", "HandScythe", "Katana", "Machete", "KukriMachete", "RancherMachete", "SalvagedBlade", "SalvagedMachete", "SalvagedShiv", "SalvagedShivO", "ScrapBlade", "ScrapMachete", "ScrapShiv", "ScrapSword"}

-- Function to check if a value exists in a table
local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- Check if an item is an extraction tool
function FAVExtract.IsExtractionTool(item)
    return has_value(extractionTools, item:getType())
end

-- Check if an item is a proper extraction tool
function FAVExtract.IsProperTool(item)
    return has_value(properExtractionTools, item:getType())
end

-- Check if an item is a slow extraction tool
function FAVExtract.IsSlowExtractionTool(item)
    return has_value(slowExtractionTools, item:getType())
end

-- Check if the tool's condition is good
function FAVExtract.ToolConditionGood(item)
    if item:getCondition() > 0 then
        return true
    else
        return false
    end
end

-- Find an extraction tool that is in good condition
function FAVExtract.FindExtractionTool(item)
    return FAVExtract.IsExtractionTool(item) and FAVExtract.ToolConditionGood(item)
end

-- Find a slow extraction tool that is in good condition
function FAVExtract.FindSlowExtractionTool(item)
    return FAVExtract.IsSlowExtractionTool(item) and FAVExtract.ToolConditionGood(item)
end

-- Damage the tool if it is not a proper extraction tool
function FAVExtract.DamageTool(item, player)
    if not FAVExtract.IsProperTool(item) then
        item:setCondition(item:getCondition() - 0.01)
    end
end

-- Menu option to extract
FAVExtract.doMenu = function(player, context, worldobjects, test)
    local corpse = IsoObjectPicker.Instance:PickCorpse(getMouseX(), getMouseY())
    if not corpse then return end
    FAVCorpse.corpse = corpse

    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()

    local extractionTool = nil

    -- Check for proper extraction tool first
    local proper_extraction_tool = playerInv:getFirstEvalRecurse(FAVExtract.IsProperTool)
    if proper_extraction_tool and FAVExtract.ToolConditionGood(proper_extraction_tool) then
        extractionTool = proper_extraction_tool
    end

    -- If no proper tool found, check for a regular extraction tool
    if not extractionTool then
        extractionTool = playerInv:getFirstEvalRecurse(FAVExtract.FindExtractionTool)
    end

    -- If still no tool found, check for a slow extraction tool
    if not extractionTool then
        extractionTool = playerInv:getFirstEvalRecurse(FAVExtract.FindSlowExtractionTool)
    end

    if extractionTool then
        context:addOption(getText("UI_FAV_Extract"), worldobjects, FAVExtract.doAction, player)
    end
    return
end

-- Perform extraction action
FAVExtract.doAction = function(worldobjects, player)
    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()
    local equipped = playerObj:getPrimaryHandItem()

    local extractionTool = nil

    -- Check for proper extraction tool first
    local proper_extraction_tool = playerInv:getFirstEvalRecurse(FAVExtract.IsProperTool)
    if proper_extraction_tool and FAVExtract.ToolConditionGood(proper_extraction_tool) then
        extractionTool = proper_extraction_tool
    end

    -- If no proper tool found, check for a regular extraction tool
    if not extractionTool then
        extractionTool = playerInv:getFirstEvalRecurse(FAVExtract.FindExtractionTool)
    end

    -- If still no tool found, check for a slow extraction tool
    if not extractionTool then
        extractionTool = playerInv:getFirstEvalRecurse(FAVExtract.FindSlowExtractionTool)
    end

    if FAVCorpse.corpse:getSquare() and extractionTool and luautils.walkAdj(playerObj, FAVCorpse.corpse:getSquare()) then
        ISInventoryPaneContextMenu.equipWeapon(extractionTool, true, false, playerObj:getPlayerNum())
        ISTimedActionQueue.add(FAVExtractTimedAction:new(playerObj, extractionTool, FAVCorpse.corpse))
    end
end

Events.OnFillWorldObjectContextMenu.Add(FAVExtract.doMenu)