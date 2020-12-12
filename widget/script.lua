g_cmd = '?widget'
g_spd_unit_tbl = {
    ['km/h'] = 216,
    ['kph'] = 216,
    ['kmph'] = 216,
    ['km/hr'] = 216,

    ['m/s'] = 60,
    ['mps'] = 60,

    ['kn'] = 216000.0/1852.0,
    ['kt'] = 216000.0/1852.0,

    ['mph'] = 60.0/0.44704,
    ['mi/h'] = 60.0/0.44704,
}
g_alt_unit_tbl = {
    ['m'] = 1,
    ['ft'] = 1.0/0.3048,
}
g_userdata = {}
g_userhist = {}

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, cmd, ...)
    local args = {...}
    if #args > 0 and args[#args] == '' then
        table.remove(args, #args)
    end

    if cmd == g_cmd then
        if #args <= 0 or args[1] == 'help' then
            execHelp(user_peer_id, is_admin, is_auth, args)
        elseif args[1] == 'on' then
            execOn(user_peer_id, is_admin, is_auth, args)
        elseif args[1] == 'off' then
            execOff(user_peer_id, is_admin, is_auth, args)
        elseif args[1] == 'spdofs' or args[1] == 'altofs' then
            execSetOfs(user_peer_id, is_admin, is_auth, args)
        elseif args[1] == 'spdunit' or args[1] == 'altunit' then
            execSetUnit(user_peer_id, is_admin, is_auth, args)
        else
            server.announce(
                getAnnounceName(),
                string.format(
                    (
                        'error: undefined subcommand "%s"\n' ..
                        'see "%s help" for list of subcommands'
                    ),
                    args[1],
                    g_cmd
                ),
                user_peer_id
            )
        end
    end
end

function execHelp(user_peer_id, is_admin, is_auth, args)
    server.announce(
        getAnnounceName(),
        (
            g_cmd .. ' on\n' ..
            g_cmd .. ' off\n' ..
            g_cmd .. ' spdofs HOFS VOFS\n' ..
            g_cmd .. ' altofs HOFS VOFS\n' ..
            g_cmd .. ' spdunit UNIT\n' ..
            g_cmd .. ' altunit UNIT\n' ..
            g_cmd .. ' help'
        ),
        user_peer_id
    )
end

function execOn(user_peer_id, is_admin, is_auth, args)
    if #args > 1 then
        server.announce(
            getAnnounceName(),
            'error: extra arguments',
            user_peer_id
        )
        return
    end
    g_userdata[user_peer_id]['enabled'] = true
    server.announce(
        getAnnounceName(),
        'widgets enabled',
        user_peer_id
    )
end

function execOff(user_peer_id, is_admin, is_auth, args)
    if #args > 1 then
        server.announce(
            getAnnounceName(),
            'error: extra arguments',
            user_peer_id
        )
        return
    end
    g_userdata[user_peer_id]['enabled'] = false
    server.announce(
        getAnnounceName(),
        'widgets disabled',
        user_peer_id
    )
end

function execSetOfs(user_peer_id, is_admin, is_auth, args)
    local name
    local hofs_key
    local vofs_key
    if args[1] == 'spdofs' then
        name = 'spdofs'
        hofs_key = 'spd_hofs'
        vofs_key = 'spd_vofs'
    elseif args[1] == 'altofs' then
        name = 'altofs'
        hofs_key = 'alt_hofs'
        vofs_key = 'alt_vofs'
    end

    if #args == 1 then
        server.announce(
            getAnnounceName(),
            string.format(
                (
                    'current %s is (%f, %f)\n' ..
                    'use "%s %s HOFS VOFS" to configure'
                ),
                name,
                g_userdata[user_peer_id][hofs_key],
                g_userdata[user_peer_id][vofs_key],
                g_cmd,
                args[1]
            ),
            user_peer_id
        )
        return
    elseif #args ~= 3 then
        server.announce(
            getAnnounceName(),
            'error: wrong number of arguments',
            user_peer_id
        )
        return
    end

    local hofs = tonumber(args[2])
    local vofs = tonumber(args[3])
    if hofs == fail then
        server.announce(
            getAnnounceName(),
            string.format('error: got invalid number "%s"', args[2]),
            user_peer_id
        )
        return
    elseif vofs == fail then
        server.announce(
            getAnnounceName(),
            string.format('error: got invalid number "%s"', args[3]),
            user_peer_id
        )
        return
    elseif hofs < -1 or 1 < hofs or vofs < -1 or 1 < vofs then
        server.announce(
            getAnnounceName(),
            'error: offset must be within the range -1 to 1',
            user_peer_id
        )
        return
    end
    g_userdata[user_peer_id][hofs_key] = hofs
    g_userdata[user_peer_id][vofs_key] = vofs
    server.announce(
        getAnnounceName(),
        string.format('set %s to (%f, %f)', name, hofs, vofs),
        user_peer_id
    )
end

function execSetUnit(user_peer_id, is_admin, is_auth, args)
    local name
    local key
    local tbl
    local choices_txt
    if args[1] == 'spdunit' then
        name = 'spdunit'
        key = 'spd_unit'
        tbl = g_spd_unit_tbl
        choices_txt = 'available units are "km/h", "m/s", "kn", "mph"'
    elseif args[1] == 'altunit' then
        name = 'altunit'
        key = 'alt_unit'
        tbl = g_alt_unit_tbl
        choices_txt = 'available units are "m", "ft"'
    end

    if #args < 2 then
        server.announce(
            getAnnounceName(),
            string.format(
                (
                    'current %s is "%s"\n' ..
                    'use "%s %s UNIT" to configure'
                ),
                name,
                g_userdata[user_peer_id][key],
                g_cmd,
                args[1]
            ),
            user_peer_id
        )
        return
    end
    if #args > 2 then
        server.announce(
            getAnnounceName(),
            'error: too many arguments',
            user_peer_id
        )
        return
    end

    local unit = args[2]
    if tbl[unit] == nil then
        server.announce(
            getAnnounceName(),
            string.format(
                (
                    'error: got undefined unit "%s"\n' ..
                    choices_txt
                ),
                unit
            ),
            user_peer_id
        )
        return
    end
    g_userdata[user_peer_id][key] = unit
    server.announce(
        getAnnounceName(),
        string.format('set %s to "%s"', name, unit),
        user_peer_id
    )
end

function onTick(game_ticks)
    local player_tbl = getPlayerTable()
    for _, player in pairs(player_tbl) do
        if g_userdata[player['id']] == nil then
            g_userdata[player['id']] = {
                ['enabled'] = true,
                ['spd_hofs'] = 0.8,
                ['spd_vofs'] = -0.9,
                ['spd_unit'] = 'km/h',
                ['alt_hofs'] = 0.9,
                ['alt_vofs'] = -0.8,
                ['alt_unit'] = 'm',
            }
        end
    end
    for peer_id, _ in pairs(g_userdata) do
        if player_tbl[peer_id] == nil then
            g_userdata[peer_id] = nil
        end
    end
    for _, player in pairs(player_tbl) do
        if g_userhist[player['id']] == nil then
            g_userhist[player['id']] = {}
        end
    end
    for peer_id, _ in pairs(g_userhist) do
        if player_tbl[peer_id] == nil then
            g_userhist[peer_id] = nil
        end
    end

    for peer_id, _ in pairs(g_userdata) do
        local userdata = g_userdata[peer_id]
        local userhist = g_userhist[peer_id]

        if userdata['enabled'] then
            local spd
            local alt

            player_matrix, is_success = server.getPlayerPos(peer_id)
            if is_success then
                local _
                _, alt, _ = matrix.position(player_matrix)

                local num = (peer_id == 0) and 2 or 61
                table.insert(userhist, player_matrix)
                while #userhist > num do
                    table.remove(userhist, 1)
                end
                if #userhist >= num then
                    spd = matrix.distance(userhist[1], userhist[num]) / (num - 1)
                end
            else
                userhist = {}
            end

            local spdtxt
            local alttxt
            if spd ~= nil then
                spdtxt = string.format(
                    'SPD\n%.2f%s',
                    spd*g_spd_unit_tbl[userdata['spd_unit']],
                    userdata['spd_unit']
                )
            else
                spdtxt = string.format(
                    'SPD\n---%s',
                    userdata['spd_unit']
                )
            end
            if alt ~= nil then
                alttxt = string.format(
                    'ALT\n%.2f%s',
                    alt*g_alt_unit_tbl[userdata['alt_unit']],
                    userdata['alt_unit']
                )
            else
                alttxt = string.format(
                    'ALT\n---%s',
                    userdata['alt_unit']
                )
            end
            server.setPopupScreen(peer_id, g_savedata['spd_ui_id'], getAnnounceName(), true, spdtxt, userdata['spd_hofs'], userdata['spd_vofs'])
            server.setPopupScreen(peer_id, g_savedata['alt_ui_id'], getAnnounceName(), true, alttxt, userdata['alt_hofs'], userdata['alt_vofs'])
        else
            userhist = {}
            server.removePopup(peer_id, g_savedata['spd_ui_id'])
            server.removePopup(peer_id, g_savedata['alt_ui_id'])
        end

        g_userdata[peer_id] = userdata
        g_userhist[peer_id] = userhist
    end

    if g_userdata[0] ~= nil then
        g_savedata['hostdata'] = g_userdata[0]
    end
end

function onCreate(is_world_create)
    local version = 1
    if g_savedata['version'] ~= version then
        g_savedata = {
            ['version'] = version,
            ['spd_ui_id'] = server.getMapID(),
            ['alt_ui_id'] = server.getMapID(),
            ['hostdata'] = nil,
        }
    end
    if g_savedata['hostdata'] ~= nil then
        g_userdata[0] = g_savedata['hostdata']
    end
end

function getPlaylistName()
    local playlist_index = server.getPlaylistIndexCurrent()
    local playlist_data = server.getPlaylistData(playlist_index)
    return playlist_data['name']
end

function getAnnounceName()
    return string.format('[%s]', getPlaylistName())
end

function getPlayerTable()
    local player_tbl = {}
    for _, player in pairs(server.getPlayers()) do
        player_tbl[player['id']] = player
    end
    return player_tbl
end
