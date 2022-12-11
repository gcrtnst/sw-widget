c_cmd = "?widget"
c_spd_unit_tbl = {
    ["km/h"] = 216,
    ["kph"] = 216,
    ["kmph"] = 216,
    ["km/hr"] = 216,

    ["m/s"] = 60,
    ["mps"] = 60,

    ["kt"] = 216000.0/1852.0,
    ["kn"] = 216000.0/1852.0,
}
c_alt_unit_tbl = {
    ["m"] = 1,
    ["ft"] = 1.0/0.3048,
}
g_userdata = {}
g_usertemp = {}
g_spd_ui_id = nil
g_alt_ui_id = nil
g_uim = nil

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, cmd, ...)
    if cmd ~= c_cmd then
        return
    end

    local args = {}
    for _, s in ipairs({...}) do
        if s ~= "" then
            table.insert(args, s)
        end
    end

    if #args <= 0 or args[1] == "help" then
        execHelp(user_peer_id, is_admin, is_auth, args)
    elseif args[1] == "on" then
        execOn(user_peer_id, is_admin, is_auth, args)
    elseif args[1] == "off" then
        execOff(user_peer_id, is_admin, is_auth, args)
    elseif args[1] == "spdofs" then
        execSpdOfs(user_peer_id, is_admin, is_auth, args)
    elseif args[1] == "altofs" then
        execAltOfs(user_peer_id, is_admin, is_auth, args)
    elseif args[1] == "spdunit" then
        execSpdUnit(user_peer_id, is_admin, is_auth, args)
    elseif args[1] == "altunit" then
        execAltUnit(user_peer_id, is_admin, is_auth, args)
    else
        server.announce(
            getAnnounceName(),
            string.format(
                (
                    'error: undefined subcommand "%s"\n' ..
                    'see "%s help" for list of subcommands'
                ),
                args[1],
                c_cmd
            ),
            user_peer_id
        )
    end
end

function execHelp(user_peer_id, is_admin, is_auth, args)
    server.announce(
        getAnnounceName(),
        (
            c_cmd .. " on\n" ..
            c_cmd .. " off\n" ..
            c_cmd .. " spdofs HOFS VOFS\n" ..
            c_cmd .. " altofs HOFS VOFS\n" ..
            c_cmd .. " spdunit UNIT\n" ..
            c_cmd .. " altunit UNIT\n" ..
            c_cmd .. " help"
        ),
        user_peer_id
    )
end

function execOn(user_peer_id, is_admin, is_auth, args)
    if #args > 1 then
        server.announce(getAnnounceName(), "error: extra arguments", user_peer_id)
        return
    end
    g_userdata[user_peer_id].enabled = true
    server.announce(getAnnounceName(), "widgets are now enabled", user_peer_id)
end

function execOff(user_peer_id, is_admin, is_auth, args)
    if #args > 1 then
        server.announce(getAnnounceName(), "error: extra arguments", user_peer_id)
        return
    end
    g_userdata[user_peer_id].enabled = false
    server.announce(getAnnounceName(), "widgets are now disabled", user_peer_id)
end

function execSpdOfs(user_peer_id, is_admin, is_auth, args)
    return execSetOfs(user_peer_id, is_admin, is_auth, args, "spdofs", "spd_hofs", "spd_vofs")
end

function execAltOfs(user_peer_id, is_admin, is_auth, args)
    return execSetOfs(user_peer_id, is_admin, is_auth, args, "altofs", "alt_hofs", "alt_vofs")
end

function execSetOfs(user_peer_id, is_admin, is_auth, args, param_name, param_key_hofs, param_key_vofs)
    if #args == 1 then
        server.announce(
            getAnnounceName(),
            string.format(
                (
                    "current %s is (%f, %f)\n" ..
                    'use "%s %s HOFS VOFS" to configure'
                ),
                param_name,
                g_userdata[user_peer_id][param_key_hofs],
                g_userdata[user_peer_id][param_key_vofs],
                c_cmd,
                args[1]
            ),
            user_peer_id
        )
        return
    elseif #args ~= 3 then
        server.announce(getAnnounceName(), "error: wrong number of arguments", user_peer_id)
        return
    end

    local hofs_txt = args[2]
    local vofs_txt = args[3]
    local hofs = tonumber(hofs_txt)
    local vofs = tonumber(vofs_txt)
    if not hofs then
        server.announce(
            getAnnounceName(),
            string.format('error: got invalid number "%s"', hofs_txt),
            user_peer_id
        )
        return
    elseif not vofs then
        server.announce(
            getAnnounceName(),
            string.format('error: got invalid number "%s"', vofs_txt),
            user_peer_id
        )
        return
    elseif hofs < -1 or 1 < hofs or vofs < -1 or 1 < vofs then
        server.announce(getAnnounceName(), "error: offset must be within the range -1 to 1", user_peer_id)
        return
    end

    g_userdata[user_peer_id][param_key_hofs] = hofs
    g_userdata[user_peer_id][param_key_vofs] = vofs
    server.announce(
        getAnnounceName(),
        string.format("%s is now set to (%f, %f)", param_name, hofs, vofs),
        user_peer_id
    )
end

function execSpdUnit(user_peer_id, is_admin, is_auth, args)
    return execSetUnit(
        user_peer_id,
        is_admin,
        is_auth,
        args,
        "spdunit",
        "spd_unit",
        c_spd_unit_tbl,
        'available units are "km/h", "m/s", "kt"'
    )
end

function execAltUnit(user_peer_id, is_admin, is_auth, args)
    return execSetUnit(
        user_peer_id,
        is_admin,
        is_auth,
        args,
        "altunit",
        "alt_unit",
        c_alt_unit_tbl,
        'available units are "m", "ft"'
    )
end

function execSetUnit(user_peer_id, is_admin, is_auth, args, param_name, param_key, param_tbl, param_choices)
    if #args < 2 then
        server.announce(
            getAnnounceName(),
            string.format(
                (
                    'current %s is "%s"\n' ..
                    'use "%s %s UNIT" to configure\n' ..
                    "%s"
                ),
                param_name,
                g_userdata[user_peer_id][param_key],
                c_cmd,
                args[1],
                param_choices
            ),
            user_peer_id
        )
        return
    end
    if #args > 2 then
        server.announce(getAnnounceName(), "error: too many arguments", user_peer_id)
        return
    end

    local unit = args[2]
    if param_tbl[unit] == nil then
        server.announce(
            getAnnounceName(),
            string.format('error: got undefined unit "%s"\n%s', unit, param_choices),
            user_peer_id
        )
        return
    end
    g_userdata[user_peer_id][param_key] = unit
    server.announce(
        getAnnounceName(),
        string.format('%s is now set to "%s"', param_name, unit),
        user_peer_id
    )
end

function onTick(game_ticks)
    local player_tbl = getPlayerTable()
    for _, player in pairs(player_tbl) do
        if g_userdata[player.id] == nil then
            g_userdata[player.id] = newUserData()
        end
    end
    for peer_id, _ in pairs(g_userdata) do
        if player_tbl[peer_id] == nil then
            g_userdata[peer_id] = nil
        end
    end
    for _, player in pairs(player_tbl) do
        if g_usertemp[player.id] == nil then
            g_usertemp[player.id] = {}
        end
    end
    for peer_id, _ in pairs(g_usertemp) do
        if player_tbl[peer_id] == nil then
            g_usertemp[peer_id] = nil
        end
    end

    for peer_id, _ in pairs(g_userdata) do
        if not g_userdata[peer_id].enabled then
            g_usertemp[peer_id] = {}
            goto continue
        end

        local vehicle_id, is_success = getPlayerVehicle(peer_id)
        if not is_success then
            vehicle_id = nil
        end
        if vehicle_id ~= g_usertemp[peer_id].vehicle_id then
            g_usertemp[peer_id] = {
                vehicle_id = vehicle_id,
            }
        end

        if vehicle_id ~= nil then
            local vehicle_pos, is_success = server.getVehiclePos(vehicle_id)
            if not is_success then
                g_usertemp[peer_id] = {}
                goto continue
            end

            if g_usertemp[peer_id].vehicle_pos ~= nil then
                g_usertemp[peer_id].spd = matrix.distance(vehicle_pos, g_usertemp[peer_id].vehicle_pos)
            end
            g_usertemp[peer_id].alt = table.pack(matrix.position(vehicle_pos))[2]
            g_usertemp[peer_id].vehicle_pos = vehicle_pos
        else
            local player_pos_ring = g_usertemp[peer_id].player_pos_ring
            if player_pos_ring == nil then
                player_pos_ring = ringNew(peer_id == 0 and 2 or 61)
            end

            local player_object_id, is_success = server.getPlayerCharacterID(peer_id)
            if not is_success then
                g_usertemp[peer_id] = {}
                goto continue
            end
            local player_new_pos, is_success = server.getObjectPos(player_object_id)
            if not is_success then
                g_usertemp[peer_id] = {}
                goto continue
            end
            ringSet(player_pos_ring, player_new_pos)

            if player_pos_ring.len > 1 then
                local player_old_pos = ringGet(player_pos_ring, 1)
                g_usertemp[peer_id].spd = matrix.distance(player_old_pos, player_new_pos)/(player_pos_ring.len - 1)
            end
            g_usertemp[peer_id].alt = table.pack(matrix.position(player_new_pos))[2]
            g_usertemp[peer_id].player_pos_ring = player_pos_ring
        end
        ::continue::
    end

    for peer_id, _ in pairs(g_userdata) do
        local userdata = g_userdata[peer_id]
        local usertemp = g_usertemp[peer_id]
        if not userdata.enabled then
            goto continue
        end

        local spdtxt = "SPD\n---"
        if usertemp.spd ~= nil then
            spdtxt = string.format(
                "SPD\n%.2f%s",
                usertemp.spd*c_spd_unit_tbl[userdata.spd_unit],
                userdata.spd_unit
            )
        end

        local alttxt = "ALT\n---"
        if usertemp.alt ~= nil then
            alttxt = string.format(
                "ALT\n%.2f%s",
                usertemp.alt*c_alt_unit_tbl[userdata.alt_unit],
                userdata.alt_unit
            )
        end

        g_uim:setPopupScreen(peer_id, g_spd_ui_id, getAnnounceName(), true, spdtxt, userdata.spd_hofs, userdata.spd_vofs)
        g_uim:setPopupScreen(peer_id, g_alt_ui_id, getAnnounceName(), true, alttxt, userdata.alt_hofs, userdata.alt_vofs)
        ::continue::
    end
    g_uim:flushPopup()

    saveAddon()
end

function onCreate(is_world_create)
    local version = 1
    if g_savedata.version ~= version then
        g_savedata = {
            version = version,
            spd_ui_id = server.getMapID(),
            alt_ui_id = server.getMapID(),
            hostdata = nil,
        }
    end

    g_spd_ui_id = g_savedata.spd_ui_id
    g_alt_ui_id = g_savedata.alt_ui_id
    if g_savedata.hostdata ~= nil then
        g_userdata[0] = deepcopy(g_savedata.hostdata)
    end

    g_uim = buildUIManager()
    server.removePopup(-1, g_spd_ui_id)
    server.removePopup(-1, g_alt_ui_id)
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
    g_uim:onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
end

function newUserData()
    return {
        enabled = true,
        spd_hofs = 0.8,
        spd_vofs = -0.9,
        spd_unit = "km/h",
        alt_hofs = 0.9,
        alt_vofs = -0.8,
        alt_unit = "m",
    }
end

function loadAddon()
    if type(g_savedata) == "table" and g_savedata.version == 1 then
        if type(g_savedata.spd_ui_id) == "number" then
            g_spd_ui_id = g_savedata.spd_ui_id
        end
        if type(g_savedata.alt_ui_id) == "number" then
            g_alt_ui_id = g_savedata.alt_ui_id
        end
        if type(g_savedata.hostdata) == "table" and g_userdata[0] ~= nil then
            if type(g_savedata.hostdata.enabled) == "boolean" then
                g_userdata[0].enabled = g_savedata.hostdata.enabled
            end
            if type(g_savedata.hostdata.spd_hofs) == "number" and -1 <= g_savedata.hostdata.spd_hofs and g_savedata.hostdata.spd_hofs <= 1 then
                g_userdata[0].spd_hofs = g_savedata.hostdata.spd_hofs
            end
            if type(g_savedata.hostdata.spd_vofs) == "number" and -1 <= g_savedata.hostdata.spd_vofs and g_savedata.hostdata.spd_vofs <= 1 then
                g_userdata[0].spd_vofs = g_savedata.hostdata.spd_vofs
            end
            if type(g_savedata.hostdata.spd_unit) == "string" and c_spd_unit_tbl[g_savedata.hostdata.spd_unit] ~= nil then
                g_userdata[0].spd_unit = g_savedata.hostdata.spd_unit
            end
            if type(g_savedata.hostdata.alt_hofs) == "number" and -1 <= g_savedata.hostdata.alt_hofs and g_savedata.hostdata.alt_hofs <= 1 then
                g_userdata[0].alt_hofs = g_savedata.hostdata.alt_hofs
            end
            if type(g_savedata.hostdata.alt_vofs) == "number" and -1 <= g_savedata.hostdata.alt_vofs and g_savedata.hostdata.alt_vofs <= 1 then
                g_userdata[0].alt_vofs = g_savedata.hostdata.alt_vofs
            end
            if type(g_savedata.hostdata.alt_unit) == "string" and c_alt_unit_tbl[g_savedata.hostdata.alt_unit] ~= nil then
                g_userdata[0].alt_unit = g_savedata.hostdata.alt_unit
            end
        end
    end
end

function saveAddon()
    local savedata = {
        version = 1,
        spd_ui_id = g_spd_ui_id,
        alt_ui_id = g_alt_ui_id,
        hostdata = nil,
    }

    if g_userdata[0] ~= nil then
        savedata.hostdata = {
            enabled = g_userdata[0].enabled,
            spd_hofs = g_userdata[0].spd_hofs,
            spd_vofs = g_userdata[0].spd_vofs,
            spd_unit = g_userdata[0].spd_unit,
            alt_hofs = g_userdata[0].alt_hofs,
            alt_vofs = g_userdata[0].alt_vofs,
            alt_unit = g_userdata[0].alt_unit,
        }
    end

    g_savedata = savedata
end

function buildUIManager()
    local uim = {
        _popup_old = {},
        _popup_new = {},
    }

    function uim:setPopupScreen(peer_id, ui_id, name, is_show, text, horizontal_offset, vertical_offset)
        if peer_id < 0 then
            -- peer_id=-1 is not supported
            return
        end

        local key = string.pack("jj", peer_id, ui_id)
        self._popup_new[key] = {
            peer_id = peer_id,
            ui_id = ui_id,
            name = name,
            is_show = is_show,
            text = text,
            horizontal_offset = horizontal_offset,
            vertical_offset = vertical_offset,
        }
    end

    function uim:flushPopup()
        for key, popup in pairs(self._popup_old) do
            if self._popup_new[key] == nil then
                server.removePopup(popup.peer_id, popup.ui_id)
            end
        end

        for key, popup_new in pairs(self._popup_new) do
            local popup_old = self._popup_old[key]
            if popup_old == nil or
                popup_new.name ~= popup_old.name or
                popup_new.is_show ~= popup_old.is_show or
                popup_new.text ~= popup_old.text or
                popup_new.horizontal_offset ~= popup_old.horizontal_offset or
                popup_new.vertical_offset ~= popup_old.vertical_offset then
                server.setPopupScreen(
                    popup_new.peer_id,
                    popup_new.ui_id,
                    popup_new.name,
                    popup_new.is_show,
                    popup_new.text,
                    popup_new.horizontal_offset,
                    popup_new.vertical_offset
                )
            end
        end

        self._popup_old = self._popup_new
        self._popup_new = {}
    end

    function uim:onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
        for key, popup in pairs(self._popup_old) do
            if popup.peer_id == peer_id then
                server.removePopup(popup.peer_id, popup.ui_id)
                self._popup_old[key] = nil
            end
        end
    end

    return uim
end

function getAddonName()
    local addon_index, is_success = server.getAddonIndex()
    if not is_success then
        return "???"
    end

    local addon_data = server.getAddonData(addon_index)
    if addon_data == nil then
        return "???"
    end

    return addon_data.name
end

function getAnnounceName()
    return string.format("[%s]", getAddonName())
end

function getPlayerTable()
    local player_tbl = {}
    for _, player in pairs(server.getPlayers()) do
        player_tbl[player.id] = player
    end
    return player_tbl
end

function getPlayerVehicle(peer_id)
    local object_id, is_success = server.getPlayerCharacterID(peer_id)
    if not is_success then
        return 0, false
    end
    return server.getCharacterVehicle(object_id)
end

function deepcopy(v)
    if type(v) ~= "table" then
        return v
    end

    local tbl = {}
    for key, val in pairs(v) do
        key = deepcopy(key)
        val = deepcopy(val)
        tbl[key] = val
    end
    return tbl
end

function ringNew(cap)
    if math.type(cap) ~= "integer" or cap <= 0 then
        return nil
    end

    return {
        buf = {},
        idx = 1,
        len = 0,
        cap = cap,
    }
end

function ringSet(ring, item)
    if ring.len < ring.cap then
        ring.idx = 1
        ring.len = ring.len + 1
        ring.buf[ring.len] = item
    else
        ring.idx = ring.idx%ring.cap + 1
        ring.len = ring.cap
        ring.buf[(ring.idx - 2)%ring.cap + 1] = item
    end
end

function ringGet(ring, idx)
    if math.type(idx) ~= "integer" or idx < 1 or ring.len < idx then
        return nil
    end

    return ring.buf[(ring.idx + idx - 2)%ring.cap + 1]
end
