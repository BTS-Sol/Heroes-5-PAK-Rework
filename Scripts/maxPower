local MAX_POWER = 500  -- z. B. eine Armee mit Powerwert 500 maximal

local CreaturePower = {
    [1] = 1, [2] = 2, [3] = 3, -- Peasant, Conscript, Archer, ...
    [13] = 80, [14] = 100,     -- Angel, Archangel
    [27] = 90, [28] = 110,     -- Devil, Archdevil
    [35] = 25, [36] = 40,      -- Vampire, Vampire Lord
    -- <== Diese Liste müsstest du für deine Map vervollständigen!
}

function GetHeroArmyPower(heroName)
    local totalPower = 0
    local army = {}
    for i = 0, 6 do
        local creature, qty = GetHeroCreature(heroName, i)
        if qty > 0 then
            local power = CreaturePower[creature] or 10 -- fallback
            totalPower = totalPower + (qty * power)
            table.insert(army, {slot = i, creature = creature, quantity = qty, power = power})
        end
    end
    return totalPower, army
end

function EnforcePowerLimit(heroName)
    local total, army = GetHeroArmyPower(heroName)
    if total <= MAX_POWER then return end

    -- Sortiere: schwächste Einheiten zuerst löschen
    table.sort(army, function(a, b)
        return (a.power < b.power)
    end)

    local overflow = total - MAX_POWER

    for _, entry in ipairs(army) do
        if overflow <= 0 then break end

        local unitPower = entry.power
        local qtyToRemove = math.ceil(overflow / unitPower)
        qtyToRemove = math.min(qtyToRemove, entry.quantity)

        RemoveHeroCreatures(heroName, entry.creature, qtyToRemove)
        overflow = overflow - (qtyToRemove * unitPower)
    end

    MessageBox(heroName, "Deine Armee war zu stark. Überzählige Einheiten wurden entfernt.")
end

function DailyPowerEnforcement()
    for player = PLAYER_1, PLAYER_8 do
        local heroes = GetPlayerHeroes(player)
        for _, hero in heroes do
            if IsHeroAlive(hero) then
                EnforcePowerLimit(hero)
            end
        end
    end
end

function SetupPowerEnforcement()
    Trigger(NEW_DAY_TRIGGER, "DailyPowerEnforcement")
end

-- Initialisierung
SetupPowerEnforcement()
startThread(function()
    while 1 do
        DailyPowerEnforcement()
        sleep(20)
    end
end)
