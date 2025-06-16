--[[
  Script: LimitHeroArmySlots.lua
  Ziel: Maximal 4 verschiedene Kreaturtypen pro Held zulassen
  Effekt: Warnung bei Überschreitung, automatische Löschung bei Rundenbeginn oder Kampfbeginn
--]]

-- Konfiguration
local MAX_CREATURE_SLOTS = 4

-- Hilfsfunktion: Zähle unterschiedliche Einheiten
function GetHeroArmySlotCount(heroName)
    local count = 0
    local slotList = {}
    for i = 0, 6 do
        local creature, quantity = GetHeroCreature(heroName, i)
        if quantity > 0 then
            count = count + 1
            table.insert(slotList, {slot = i, creature = creature, quantity = quantity})
        end
    end
    return count, slotList
end

-- Warnung, wenn zu viele Slots
function WarnIfTooManyUnits(heroName)
    local count = GetHeroArmySlotCount(heroName)
    if count > MAX_CREATURE_SLOTS then
        MessageBox(heroName, "Achtung: Du darfst nur 4 verschiedene Kreaturentypen führen!")
    end
end

-- Entferne zufällig überzählige Einheiten
function EnforceSlotLimit(heroName)
    local count, slotList = GetHeroArmySlotCount(heroName)
    if count <= MAX_CREATURE_SLOTS then return end

    -- Mische Reihenfolge
    while count > MAX_CREATURE_SLOTS do
        local idx = RandTableIndex(slotList)
        local entry = table.remove(slotList, idx)
        RemoveHeroCreatures(heroName, entry.creature, entry.quantity)
        count = count - 1
    end
end

-- Hilfsfunktion: Zufälliger Index aus Tabelle
function RandTableIndex(tbl)
    local size = #tbl
    if size == 0 then return nil end
    return GetRand(1, size)
end

-- Hauptüberwachung: Warnung während Spiel
function MonitorHeroes()
    for player = PLAYER_1, PLAYER_8 do
        if IsHuman(player) then
            local heroes = GetPlayerHeroes(player)
            for _, hero in heroes do
                if IsHeroAlive(hero) then
                    WarnIfTooManyUnits(hero)
                end
            end
        end
    end
    sleep(10) -- alle 10 Sekunden erneut prüfen
    startThread(MonitorHeroes)
end

-- Tägliche Prüfung zu Beginn eines Tages
function NewDayTrigger(day)
    for player = PLAYER_1, PLAYER_8 do
        local heroes = GetPlayerHeroes(player)
        for _, hero in heroes do
            if IsHeroAlive(hero) then
                EnforceSlotLimit(hero)
            end
        end
    end
end

-- Bei Kampfbeginn: Einheiten direkt prüfen
function CombatStartTrigger(heroName)
    EnforceSlotLimit(heroName)
end

-- Trigger-Registrierung
function SetupSlotEnforcement()
    Trigger(NEW_DAY_TRIGGER, "NewDayTrigger")
    -- Hinweis: Combat-Trigger muss ggf. manuell aus dem Editor gerufen werden
end

-- Initialisierung
startThread(MonitorHeroes)
SetupSlotEnforcement()
