--[===[

    Made by superyu'#7167

    How it works:
    We will loop through the entity list and check for packet choking, desync is done by choking and thus a desyncing player will choke packets.
    If a player chokes packets the Simtime won't update, if we check if the simtime is equal to the last ticks simtime then the entity is choking packets.
    We will use this information to enable/disable the resolver.

--]===]

--- Gui Stuff
local pos = gui.Reference("RAGE", "MAIN", "Extra")
local enabled = gui.Checkbox(pos, "rbot_autoresolver", "Automatic Resolver", 0)
local listEnabled = gui.Checkbox(pos, "rbot_autoresolver_list", "Desyncing Player List", 0)

--- Tables.
local isDesyncing = {};
local isLegit = {};
local lastSimtime = {};
local desyncCooldown = {};

--- Variables
local lastTick = 0;
local pLocal = entities.GetLocalPlayer();
local resolverTextCount = 0;
local sampleTextWidth, sampleTextHeight

--- Hooks
local function drawHook()
    pLocal = entities.GetLocalPlayer();

    if listEnabled:GetValue() then

        if engine.GetMapName() ~= "" then
            draw.Text(2, 400, gui.GetValue("rbot_resolver") and "Desyncing Players - Resolver: On" or "Desyncing Players - Resolver:  Off")
        end
        sampleTextWidth, sampleTextHeight = draw.GetTextSize("Sample Text")
    end

    if enabled:GetValue() then
        resolverTextCount = 0;
            for pEntityIndex, pEntity in pairs(entities.FindByClass("CCSPlayer")) do
                if pEntity:GetTeamNumber() ~= pLocal:GetTeamNumber() then
                    if globals.TickCount() > lastTick then
                        if lastSimtime[pEntityIndex] ~= nil then
                            if pEntity:GetProp("m_flSimulationTime") == lastSimtime[pEntityIndex] then
                                isDesyncing[pEntityIndex] = true;
                                isLegit[pEntityIndex] = false
                                desyncCooldown[pEntityIndex] = globals.TickCount();
                            else
                                if desyncCooldown[pEntityIndex] ~= nil then
                                    if desyncCooldown[pEntityIndex] < globals.TickCount() - 128 then
                                        isDesyncing[pEntityIndex] = false;
                                        isLegit[pEntityIndex] = true
                                    end
                                else
                                    isDesyncing[pEntityIndex] = false;
                                    isLegit[pEntityIndex] = true
                                end
                            end
                        end
                        lastSimtime[pEntityIndex] = pEntity:GetProp("m_flSimulationTime")
                    end

                if listEnabled:GetValue() then
                    if engine.GetMapName() ~= "" then
                        resolverTextCount = resolverTextCount+1
                        if isDesyncing[pEntityIndex] then
                            local pos = 407 + (sampleTextHeight/2 * resolverTextCount)
                            draw.Text(2, pos, pEntity:GetName())
                            resolverTextCount = resolverTextCount+1
                        end
                    end
                end
            end
        end
        lastTick = globals.TickCount();
    end
end

local function aimbotTargetHook(pEntity)
    if enabled:GetValue() then

        if isLegit[pEntity:GetIndex()] == true then
            gui.SetValue("rbot_resolver", 0);
        else
            gui.SetValue("rbot_resolver", 1);
        end
    end
end

--- Callbacks
callbacks.Register("Draw", drawHook)
callbacks.Register("AimbotTarget", aimbotTargetHook)