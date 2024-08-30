--require "XpSystem/XpUpdate"

FAVUtils = {}
--local syringeVaccines = {"KitchenKnife", "HuntingKnife", "Scalpel", "FlintKnife"}

vaccine_increment_amt = 0.0001

function FAVUtils.VaccineFunction(player)
    FAVUtils.InitializeTable(player)
    local mod_data = player:getModData()

    -- Get sandbox options
    local instantInfectionOff = SandboxVars.SimpleVaccinesPlus.InstantInfectionOff

    local effectiveVaccinePower = mod_data.vaccine_power

    -- Update vaccine level
    if mod_data.vac_increasing == 1 then
        -- Prevent immunity buildup if vaccine has failed
        if not mod_data.failed_vaccines[vaccineName] then
            mod_data.current_vaccine_level = mod_data.current_vaccine_level + (effectiveVaccinePower / 168)
        end
    elseif mod_data.current_vaccine_level > 0 then
        mod_data.current_vaccine_level = mod_data.current_vaccine_level - (effectiveVaccinePower / 576)
    else
        mod_data.current_vaccine_level = 0
    end

    -- Check if vaccine level exceeds power
    if mod_data.current_vaccine_level > effectiveVaccinePower then
        mod_data.vac_increasing = 0
    end

    local bodyDamage = player:getBodyDamage()
    if bodyDamage:IsInfected() then
        local random_number = ZombRand(101)

        -- Immunity cure block
        if (mod_data.current_vaccine_level > random_number) and (mod_data.cure_attempted == 0.0) then
            -- Successful cure: remove infection from the player
            bodyDamage:setInfected(false)
            bodyDamage:setInfectionMortalityDuration(-1)
            bodyDamage:setInfectionTime(-1)
            bodyDamage:setInfectionLevel(0)

            -- Remove infection from all body parts
            local bodyParts = bodyDamage:getBodyParts()
            for i = bodyParts:size() - 1, 0, -1 do
                local bodyPart = bodyParts:get(i)
                bodyPart:SetInfected(false)
            end

            -- Reset vaccine levels and failed vaccines since the infection is cured
            mod_data.current_vaccine_level = 0
            mod_data.vac_increasing = 0
            mod_data.failed_vaccines = {}
            
            -- player:Say("I feel great, the vaccine worked.") -- Use the successful cure message
        else
            -- Cure attempt failed
            mod_data.cure_attempted = 1.0
            if mod_data.current_vaccine_level > 0 then
		mod_data.current_vaccine_level = 0
            	mod_data.vac_increasing = 0
		-- Reset zombie timer
		bodyDamage:setInfectionMortalityDuration(-1)
                bodyDamage:setInfectionTime(-1)

                -- player:Say("Immunity failed fighting off the infection.") -- Use the unsuccessful cure message

            end
        end
    else
        -- Reset cure attempt if not infected
        mod_data.cure_attempted = 0.0
    end
end

function FAVUtils.getSingleVsOnlinePlayer(func)
    local players = getOnlinePlayers()

    if players then
        for i = 0, players:size() - 1 do
            func(players:get(i))
        end
    else
        func(getSpecificPlayer(0))
    end
end

function FAVUtils.IncrementVaccine()
    FAVUtils.getSingleVsOnlinePlayer(FAVUtils.VaccineFunction)
end

function SetVaccine(player, items)
    FAVUtils.InitializeTable(player)
    local mod_data = player:getModData()
    local vaccineName = items:getName()
    local bodyDamage = player:getBodyDamage()
    local playerStats = player:getStats() -- Correct method to get player stats

    -- Check if this vaccine has already failed (for vaccines taken after infection)
    if mod_data.failed_vaccines[vaccineName] and bodyDamage:IsInfected() then

        -- player:Say("wrong choice, my body rejects this vaccine.") -- Use the message for being unable to use the vaccine

    -- Set negative effects using the same vaccine
	bodyDamage:setFoodSicknessLevel(bodyDamage:getFoodSicknessLevel() + 50)
	playerStats:setPanic(100) -- Correct method to set panic level
        playerStats:setThirst(playerStats:getThirst() + 0.5) -- Correctly adjust thirst level
        playerStats:setHunger(playerStats:getHunger() + 0.5) -- Correctly adjust hunger level

	    if vaccineName == 'Crude Zombie Vaccine' or vaccineName == 'Simple Zombie Vaccine' or vaccineName == 'Perfect Zombie Vaccine' then
                player:getInventory():AddItem('FAVACCINE.DirtySyringe') -- Add DirtySyringe to inventory
            end

        return
    end

    -- Get sandbox options
    local instantInfectionOff = SandboxVars.SimpleVaccinesPlus.InstantInfectionOff

    -- Set vaccine power
    local basePower = 0
    local givesDirtySyringe = false -- New flag to track if DirtySyringe should be given

    if vaccineName == 'Boiled Zombie Cells' then
        basePower = SandboxVars.SimpleVaccinesPlus.BoiledZombieCellsEffectiveness
    elseif vaccineName == 'Crude Zombie Vaccine' then
        basePower = SandboxVars.SimpleVaccinesPlus.CrudeVaccineEffectiveness
        givesDirtySyringe = true
    elseif vaccineName == 'Simple Zombie Vaccine' then
        basePower = SandboxVars.SimpleVaccinesPlus.SimpleVaccineEffectiveness
        givesDirtySyringe = true
    elseif vaccineName == 'Perfect Zombie Vaccine' then
        basePower = SandboxVars.SimpleVaccinesPlus.PerfectVaccineEffectiveness
        givesDirtySyringe = true
    end

    mod_data.vaccine_power = basePower

    -- Attempt to cure the infection if basePower is higher than 1
    if basePower >= 1 then
        if bodyDamage:IsInfected() then
            if not instantInfectionOff then
                local cureChance = mod_data.vaccine_power
                local random_number = ZombRand(100)

                if random_number < cureChance then
                    -- Instant cure successful: remove infection only
                    bodyDamage:setInfected(false)
                    bodyDamage:setInfectionMortalityDuration(-1)
                    bodyDamage:setInfectionTime(-1)
                    bodyDamage:setInfectionLevel(0)

                    -- Remove infection from all body parts
                    local bodyParts = bodyDamage:getBodyParts()
                    for i = bodyParts:size() - 1, 0, -1 do
                        local bodyPart = bodyParts:get(i)
                        bodyPart:SetInfected(false)
                    end

                    -- Reset vaccine levels and failed vaccines since the infection is cured immediately
                    mod_data.current_vaccine_level = 0
                    mod_data.vac_increasing = 0
                    mod_data.failed_vaccines = {}

                    -- player:Say("I feel great, the vaccine worked.") -- Use the successful cure message
                else
                    -- Cure attempt failed
                    mod_data.failed_vaccines[vaccineName] = true
		    -- Reset zombie timer
		    bodyDamage:setInfectionMortalityDuration(-1)
                    bodyDamage:setInfectionTime(-1)

                    -- player:Say("I'm going to be sick again. This didn't work.") -- Use the unsuccessful cure message
                end
            end
        else
            -- If the player is not infected, build up immunity
            if mod_data.current_vaccine_level < mod_data.vaccine_power then
                mod_data.vac_increasing = 1
            end
        end
    else
        -- If basePower is not higher than 1, just build up immunity
        if mod_data.current_vaccine_level < mod_data.vaccine_power then
            mod_data.vac_increasing = 1
        end
    end

    -- Always give a DirtySyringe back if applicable
    if givesDirtySyringe then
        player:getInventory():AddItem('FAVACCINE.DirtySyringe')
    end

    if isMoodleFrameWorkEnabled then
        FAVVaccineMoodleFunction(player)
    end
end

function FAVUtils.InitializeTable(player)
    local mod_data = player:getModData()

    if not mod_data.vac_increasing then
        mod_data.vac_increasing = 0
    end

    if not mod_data.vaccine_power then
        mod_data.vaccine_power = 0.0
    end

    if not mod_data.current_vaccine_level then
        mod_data.current_vaccine_level = 0.0
    end

    if not mod_data.cure_attempted then
        mod_data.cure_attempted = 0.0
    end

    if not mod_data.failed_vaccines then
        mod_data.failed_vaccines = {}
    end
end

function ConsumeVaccine(items, player, result)
    SetVaccine(player, items)
end

function FavGiveXP(item, recipe, player)
    player:getXp():AddXP(Perks.Doctor, 9)
end

function PrintStuff()
    print("------ CONNECTED MESSAGE -----")
end

function PrintAllFunctions()
    for n in pairs(_G) do print(n) end
end

-- Register events
Events.EveryHours.Add(FAVUtils.IncrementVaccine)

