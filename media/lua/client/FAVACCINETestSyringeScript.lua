-- Function to handle the consumption of an Empty Syringe
function OnTakeEmptySyringe(item, player)
    -- Ensure the item is valid and is an Empty Syringe
    if item and item:getType() == "TestSyringe" then
        -- Get the player's body damage
        local bodyDamage = player:getBodyDamage()

        if bodyDamage then
            -- Check if the player is currently infected
            local isInfected = bodyDamage:IsInfected()

            -- Create the message to display based on infection status
            local message
            if isInfected then
                message = "I'm currently infected."
            else
                message = "I'm not infected."
            end

            -- Display the message to the player in the chat
            player:Say(message)
	end
    end
    -- Add a Dirty Syringe to the player's inventory
    player:getInventory():AddItem('FAVACCINE.DirtySyringe')
end

-- Function to handle the consumption of a Syringe With Water
function OnTakeWaterSyringe(item, player)
    -- Ensure the item is valid and is a Syringe With Water
    if item and item:getType() == "WaterSyringe" then
        local mod_data = player:getModData()

        -- Initialize an empty table to hold failed vaccines
        local failedVaccines = {}

        -- Check if failed_vaccines exists in mod_data
        if mod_data.failed_vaccines then
            -- Iterate through the failed_vaccines table
            for vaccineName, hasFailed in pairs(mod_data.failed_vaccines) do
                if hasFailed then
                    -- Add failed vaccine names to the list
                    table.insert(failedVaccines, vaccineName)
                end
            end
        end

        -- Prepare the message to display in the custom panel
        local message
        if #failedVaccines > 0 then
            message = "Failed vaccines:\n"
            for _, vaccine in ipairs(failedVaccines) do
                message = message .. "- " .. vaccine .. "\n"
            end
        else
            message = "No vaccines have failed."
        end

        -- Create and show the custom panel with the vaccine information
        local panel = VaccineInfoPanel:new(100, 100, 300, 200)
        panel.vaccineInfo = message
        panel:addToUIManager()
        panel:setVisible(true)

        -- Optionally: Register the panel so it can be closed later if needed
        -- table.insert(UIManager.windows, panel)

        -- Add a Dirty Syringe to the player's inventory
        player:getInventory():AddItem('FAVACCINE.DirtySyringe')
    end
end
