local test_decl = {}

local function assertEqual(prefix, name, want, got)
    if type(want) ~= type(got) then
        error(string.format("%s: type(%s): expected %s, got %s", prefix or ".", name, type(want), type(got)))
    end

    if type(want) ~= "table" then
        if want ~= got then
            error(string.format("%s: %s: expected %q, got %q", prefix or ".", name, want, got))
        end
        return
    end

    for key in pairs(want) do
        local child = string.format("%s[%q]", name, key)
        assertEqual(prefix, child, want[key], got[key])
    end
    for key in pairs(got) do
        local child = string.format("%s[%q]", name, key)
        assertEqual(prefix, child, want[key], got[key])
    end
end

function test_decl.testOnCustomCommandOther(t)
    t:reset()
    t.fn()

    t.env.onCreate(false)
    t.env.onCustomCommand("", 0, false, false, "?other")
    t.env.onCustomCommand("", -1, false, false, "?widget")
    assertEqual(nil, "server._announce_log", {}, t.env.server._announce_log)
end

function test_decl.testOnCustomCommandWidgetHelp(t)
    local tests = {
        {
            "nocmd",
            0,
            {},
            {
                {
                    name = "[???]",
                    message = "" ..
                        "?widget on\n" ..
                        "?widget off\n" ..
                        "?widget spdofs HOFS VOFS\n" ..
                        "?widget altofs HOFS VOFS\n" ..
                        "?widget spdunit UNIT\n" ..
                        "?widget altunit UNIT\n" ..
                        "?widget help\n" ..
                        "?widget version",
                    peer_id = 0,
                },
            },
        },
        {
            "nocmd_extra",
            0,
            {""},
            {
                {
                    name = "[???]",
                    message = "" ..
                        "?widget on\n" ..
                        "?widget off\n" ..
                        "?widget spdofs HOFS VOFS\n" ..
                        "?widget altofs HOFS VOFS\n" ..
                        "?widget spdunit UNIT\n" ..
                        "?widget altunit UNIT\n" ..
                        "?widget help\n" ..
                        "?widget version",
                    peer_id = 0,
                },
            },
        },
        {
            "helpcmd",
            0,
            {"help"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        "?widget on\n" ..
                        "?widget off\n" ..
                        "?widget spdofs HOFS VOFS\n" ..
                        "?widget altofs HOFS VOFS\n" ..
                        "?widget spdunit UNIT\n" ..
                        "?widget altunit UNIT\n" ..
                        "?widget help\n" ..
                        "?widget version",
                    peer_id = 0,
                },
            },
        },
        {
            "helpcmd_extra",
            0,
            {"help", ""},
            {
                {
                    name = "[???]",
                    message = "" ..
                        "?widget on\n" ..
                        "?widget off\n" ..
                        "?widget spdofs HOFS VOFS\n" ..
                        "?widget altofs HOFS VOFS\n" ..
                        "?widget spdunit UNIT\n" ..
                        "?widget altunit UNIT\n" ..
                        "?widget help\n" ..
                        "?widget version",
                    peer_id = 0,
                },
            },
        },
        {
            "guest",
            1,
            {},
            {
                {
                    name = "[???]",
                    message = "" ..
                        "?widget on\n" ..
                        "?widget off\n" ..
                        "?widget spdofs HOFS VOFS\n" ..
                        "?widget altofs HOFS VOFS\n" ..
                        "?widget spdunit UNIT\n" ..
                        "?widget altunit UNIT\n" ..
                        "?widget help\n" ..
                        "?widget version",
                    peer_id = 1,
                },
            },
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_user_peer_id = tt[2]
        local in_args = tt[3]
        local want_announce_log = tt[4]
        t:reset()
        t.fn()

        t.env.server._player_list = {
            { id = 0 },
            { id = 1 },
        }

        t.env.onCreate(false)
        t.env.syncPlayers()
        t.env.onCustomCommand("", in_user_peer_id, false, false, "?widget", table.unpack(in_args))
        assertEqual(prefix, "server._announce_log", want_announce_log, t.env.server._announce_log)
    end
end

function test_decl.testOnCustomCommandWidgetVersion(t)
    local tt = {
        {
            prefix = "host",
            in_user_peer_id = 0,
            in_args = {"version"},
            want_announce_log = {
                {
                    name = "[???]",
                    message = "v0.1.0",
                    peer_id = 0,
                },
            },
        },
        {
            prefix = "host_extraspace",
            in_user_peer_id = 0,
            in_args = {"version", ""},
            want_announce_log = {
                {
                    name = "[???]",
                    message = "v0.1.0",
                    peer_id = 0,
                },
            },
        },
        {
            prefix = "host_extraarg",
            in_user_peer_id = 0,
            in_args = {"version", "extra"},
            want_announce_log = {
                {
                    name = "[???]",
                    message = "error: extra arguments",
                    peer_id = 0,
                },
            },
        },
        {
            prefix = "guest",
            in_user_peer_id = 1,
            in_args = {"version"},
            want_announce_log = {
                {
                    name = "[???]",
                    message = "v0.1.0",
                    peer_id = 1,
                },
            },
        },
        {
            prefix = "guest_extraarg",
            in_user_peer_id = 1,
            in_args = {"version", "extra"},
            want_announce_log = {
                {
                    name = "[???]",
                    message = "error: extra arguments",
                    peer_id = 1,
                },
            },
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.fn()

        t.env.server._player_list = {
            { id = 0 },
            { id = 1 },
        }

        t.env.onCreate(false)
        t.env.syncPlayers()
        t.env.onCustomCommand("", tc.in_user_peer_id, false, false, "?widget", table.unpack(tc.in_args))
        assertEqual(tc.prefix, "server._announce_log", tc.want_announce_log, t.env.server._announce_log)
    end
end

function test_decl.testOnCustomCommandWidgetOn(t)
    local tests = {
        {
            "host",
            0,
            {"on"},
            {
                {
                    name = "[???]",
                    message = "widgets are now enabled",
                    peer_id = 0,
                },
            },
            true,
            false,
        },
        {
            "host_extraspace",
            0,
            {"on", ""},
            {
                {
                    name = "[???]",
                    message = "widgets are now enabled",
                    peer_id = 0,
                },
            },
            true,
            false,
        },
        {
            "host_extraarg",
            0,
            {"on", "extra"},
            {
                {
                    name = "[???]",
                    message = "error: extra arguments",
                    peer_id = 0,
                },
            },
            false,
            false,
        },
        {
            "guest",
            1,
            {"on"},
            {
                {
                    name = "[???]",
                    message = "widgets are now enabled",
                    peer_id = 1,
                },
            },
            false,
            true,
        },
        {
            "guest_extraarg",
            1,
            {"on", "extra"},
            {
                {
                    name = "[???]",
                    message = "error: extra arguments",
                    peer_id = 1,
                },
            },
            false,
            false,
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_user_peer_id = tt[2]
        local in_args = tt[3]
        local want_announce_log = tt[4]
        local want_enabled_0 = tt[5]
        local want_enabled_1 = tt[6]
        t:reset()
        t.fn()

        t.env.server._player_list = {
            { id = 0 },
            { id = 1 },
        }

        t.env.onCreate(false)
        t.env.syncPlayers()

        t.env.g_userdata[0].enabled = false
        t.env.g_userdata[1].enabled = false
        t.env.saveAddon()

        t.env.onCustomCommand("", in_user_peer_id, false, false, "?widget", table.unpack(in_args))
        assertEqual(prefix, "server._announce_log", want_announce_log, t.env.server._announce_log)
        assertEqual(prefix, "g_userdata[0].enabled", want_enabled_0, t.env.g_userdata[0].enabled)
        assertEqual(prefix, "g_userdata[1].enabled", want_enabled_1, t.env.g_userdata[1].enabled)
        assertEqual(prefix, "g_savedata.hostdata.enabled", want_enabled_0, t.env.g_savedata.hostdata.enabled)
    end
end

function test_decl.testOnCustomCommandWidgetOff(t)
    local tests = {
        {
            "host",
            0,
            {"off"},
            {
                {
                    name = "[???]",
                    message = "widgets are now disabled",
                    peer_id = 0,
                },
            },
            false,
            true,
        },
        {
            "host_extraspace",
            0,
            {"off", ""},
            {
                {
                    name = "[???]",
                    message = "widgets are now disabled",
                    peer_id = 0,
                },
            },
            false,
            true,
        },
        {
            "host_extraarg",
            0,
            {"off", "extra"},
            {
                {
                    name = "[???]",
                    message = "error: extra arguments",
                    peer_id = 0,
                },
            },
            true,
            true,
        },
        {
            "guest",
            1,
            {"off"},
            {
                {
                    name = "[???]",
                    message = "widgets are now disabled",
                    peer_id = 1,
                },
            },
            true,
            false,
        },
        {
            "guest_extraarg",
            1,
            {"off", "extra"},
            {
                {
                    name = "[???]",
                    message = "error: extra arguments",
                    peer_id = 1,
                },
            },
            true,
            true,
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_user_peer_id = tt[2]
        local in_args = tt[3]
        local want_announce_log = tt[4]
        local want_enabled_0 = tt[5]
        local want_enabled_1 = tt[6]
        t:reset()
        t.fn()

        t.env.server._player_list = {
            { id = 0 },
            { id = 1 },
        }

        t.env.onCreate(false)
        t.env.syncPlayers()

        t.env.g_userdata[0].enabled = true
        t.env.g_userdata[1].enabled = true
        t.env.saveAddon()

        t.env.onCustomCommand("", in_user_peer_id, false, false, "?widget", table.unpack(in_args))
        assertEqual(prefix, "server._announce_log", want_announce_log, t.env.server._announce_log)
        assertEqual(prefix, "g_userdata[0].enabled", want_enabled_0, t.env.g_userdata[0].enabled)
        assertEqual(prefix, "g_userdata[1].enabled", want_enabled_1, t.env.g_userdata[1].enabled)
        assertEqual(prefix, "g_savedata.hostdata.enabled", want_enabled_0, t.env.g_savedata.hostdata.enabled)
    end
end

function test_decl.testOnCustomCommandWidgetSpdOfs(t)
    local tests = {
        {
            "host_get",
            0,
            {"spdofs"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        "current spdofs is (0.100000, 0.200000)\n" ..
                        'use "?widget spdofs HOFS VOFS" to configure',
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set",
            0,
            {"spdofs", "0.5", "0.6"},
            {
                {
                    name = "[???]",
                    message = "spdofs is now set to (0.500000, 0.600000)",
                    peer_id = 0,
                },
            },
            0.5,
            0.6,
            0.3,
            0.4,
        },
        {
            "host_set_min",
            0,
            {"spdofs", "-1", "-1"},
            {
                {
                    name = "[???]",
                    message = "spdofs is now set to (-1.000000, -1.000000)",
                    peer_id = 0,
                },
            },
            -1,
            -1,
            0.3,
            0.4,
        },
        {
            "host_set_max",
            0,
            {"spdofs", "1", "1"},
            {
                {
                    name = "[???]",
                    message = "spdofs is now set to (1.000000, 1.000000)",
                    peer_id = 0,
                },
            },
            1,
            1,
            0.3,
            0.4,
        },
        {
            "host_set_extraspace",
            0,
            {"spdofs", "0.5", "0.6", ""},
            {
                {
                    name = "[???]",
                    message = "spdofs is now set to (0.500000, 0.600000)",
                    peer_id = 0,
                },
            },
            0.5,
            0.6,
            0.3,
            0.4,
        },
        {
            "host_set_extraarg",
            0,
            {"spdofs", "0.5", "0.6", "0.7"},
            {
                {
                    name = "[???]",
                    message = "error: wrong number of arguments",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_missingarg",
            0,
            {"spdofs", "0.5"},
            {
                {
                    name = "[???]",
                    message = "error: wrong number of arguments",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_ynan",
            0,
            {"spdofs", "0.5", "nan"},
            {
                {
                    name = "[???]",
                    message = 'error: got invalid number "nan"',
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_xnan",
            0,
            {"spdofs", "nan", "0.6"},
            {
                {
                    name = "[???]",
                    message = 'error: got invalid number "nan"',
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_yminerr",
            0,
            {"spdofs", "0.5", "-1.1"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_ymaxerr",
            0,
            {"spdofs", "0.5", "1.1"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_xminerr",
            0,
            {"spdofs", "-1.1", "0.6"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_xmaxerr",
            0,
            {"spdofs", "1.1", "0.6"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_get",
            1,
            {"spdofs"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        "current spdofs is (0.300000, 0.400000)\n" ..
                        'use "?widget spdofs HOFS VOFS" to configure',
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set",
            1,
            {"spdofs", "0.5", "0.6"},
            {
                {
                    name = "[???]",
                    message = "spdofs is now set to (0.500000, 0.600000)",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.5,
            0.6,
        },
        {
            "guest_set_min",
            1,
            {"spdofs", "-1", "-1"},
            {
                {
                    name = "[???]",
                    message = "spdofs is now set to (-1.000000, -1.000000)",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            -1,
            -1,
        },
        {
            "guest_set_max",
            1,
            {"spdofs", "1", "1"},
            {
                {
                    name = "[???]",
                    message = "spdofs is now set to (1.000000, 1.000000)",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            1,
            1,
        },
        {
            "guest_set_extraspace",
            1,
            {"spdofs", "0.5", "0.6", ""},
            {
                {
                    name = "[???]",
                    message = "spdofs is now set to (0.500000, 0.600000)",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.5,
            0.6,
        },
        {
            "guest_set_extraarg",
            1,
            {"spdofs", "0.5", "0.6", "0.7"},
            {
                {
                    name = "[???]",
                    message = "error: wrong number of arguments",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_missingarg",
            1,
            {"spdofs", "0.5"},
            {
                {
                    name = "[???]",
                    message = "error: wrong number of arguments",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_ynan",
            1,
            {"spdofs", "0.5", "nan"},
            {
                {
                    name = "[???]",
                    message = 'error: got invalid number "nan"',
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_xnan",
            1,
            {"spdofs", "nan", "0.6"},
            {
                {
                    name = "[???]",
                    message = 'error: got invalid number "nan"',
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_yminerr",
            1,
            {"spdofs", "0.5", "-1.1"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_ymaxerr",
            1,
            {"spdofs", "0.5", "1.1"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_xminerr",
            1,
            {"spdofs", "-1.1", "0.6"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_xmaxerr",
            1,
            {"spdofs", "1.1", "0.6"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_user_peer_id = tt[2]
        local in_args = tt[3]
        local want_announce_log = tt[4]
        local want_host_spd_hofs = tt[5]
        local want_host_spd_vofs = tt[6]
        local want_guest_spd_hofs = tt[7]
        local want_guest_spd_vofs = tt[8]
        t:reset()
        t.fn()

        t.env.server._player_list = {
            { id = 0 },
            { id = 1 },
        }

        t.env.onCreate(false)
        t.env.syncPlayers()

        t.env.g_userdata[0].spd_hofs = 0.1
        t.env.g_userdata[0].spd_vofs = 0.2
        t.env.g_userdata[1].spd_hofs = 0.3
        t.env.g_userdata[1].spd_vofs = 0.4
        t.env.saveAddon()

        t.env.onCustomCommand("", in_user_peer_id, false, false, "?widget", table.unpack(in_args))
        assertEqual(prefix, "server._announce_log", want_announce_log, t.env.server._announce_log)
        assertEqual(prefix, "g_userdata[0].spd_hofs", want_host_spd_hofs, t.env.g_userdata[0].spd_hofs)
        assertEqual(prefix, "g_userdata[0].spd_vofs", want_host_spd_vofs, t.env.g_userdata[0].spd_vofs)
        assertEqual(prefix, "g_userdata[1].spd_hofs", want_guest_spd_hofs, t.env.g_userdata[1].spd_hofs)
        assertEqual(prefix, "g_userdata[1].spd_vofs", want_guest_spd_vofs, t.env.g_userdata[1].spd_vofs)
        assertEqual(prefix, "g_savedata.hostdata.spd_hofs", want_host_spd_hofs, t.env.g_savedata.hostdata.spd_hofs)
        assertEqual(prefix, "g_savedata.hostdata.spd_vofs", want_host_spd_vofs, t.env.g_savedata.hostdata.spd_vofs)
    end
end

function test_decl.testOnCustomCommandWidgetAltOfs(t)
    local tests = {
        {
            "host_get",
            0,
            {"altofs"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        "current altofs is (0.100000, 0.200000)\n" ..
                        'use "?widget altofs HOFS VOFS" to configure',
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set",
            0,
            {"altofs", "0.5", "0.6"},
            {
                {
                    name = "[???]",
                    message = "altofs is now set to (0.500000, 0.600000)",
                    peer_id = 0,
                },
            },
            0.5,
            0.6,
            0.3,
            0.4,
        },
        {
            "host_set_min",
            0,
            {"altofs", "-1", "-1"},
            {
                {
                    name = "[???]",
                    message = "altofs is now set to (-1.000000, -1.000000)",
                    peer_id = 0,
                },
            },
            -1,
            -1,
            0.3,
            0.4,
        },
        {
            "host_set_max",
            0,
            {"altofs", "1", "1"},
            {
                {
                    name = "[???]",
                    message = "altofs is now set to (1.000000, 1.000000)",
                    peer_id = 0,
                },
            },
            1,
            1,
            0.3,
            0.4,
        },
        {
            "host_set_extraspace",
            0,
            {"altofs", "0.5", "0.6", ""},
            {
                {
                    name = "[???]",
                    message = "altofs is now set to (0.500000, 0.600000)",
                    peer_id = 0,
                },
            },
            0.5,
            0.6,
            0.3,
            0.4,
        },
        {
            "host_set_extraarg",
            0,
            {"altofs", "0.5", "0.6", "0.7"},
            {
                {
                    name = "[???]",
                    message = "error: wrong number of arguments",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_missingarg",
            0,
            {"altofs", "0.5"},
            {
                {
                    name = "[???]",
                    message = "error: wrong number of arguments",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_ynan",
            0,
            {"altofs", "0.5", "nan"},
            {
                {
                    name = "[???]",
                    message = 'error: got invalid number "nan"',
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_xnan",
            0,
            {"altofs", "nan", "0.6"},
            {
                {
                    name = "[???]",
                    message = 'error: got invalid number "nan"',
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_yminerr",
            0,
            {"altofs", "0.5", "-1.1"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_ymaxerr",
            0,
            {"altofs", "0.5", "1.1"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_xminerr",
            0,
            {"altofs", "-1.1", "0.6"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "host_set_xmaxerr",
            0,
            {"altofs", "1.1", "0.6"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 0,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_get",
            1,
            {"altofs"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        "current altofs is (0.300000, 0.400000)\n" ..
                        'use "?widget altofs HOFS VOFS" to configure',
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set",
            1,
            {"altofs", "0.5", "0.6"},
            {
                {
                    name = "[???]",
                    message = "altofs is now set to (0.500000, 0.600000)",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.5,
            0.6,
        },
        {
            "guest_set_min",
            1,
            {"altofs", "-1", "-1"},
            {
                {
                    name = "[???]",
                    message = "altofs is now set to (-1.000000, -1.000000)",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            -1,
            -1,
        },
        {
            "guest_set_max",
            1,
            {"altofs", "1", "1"},
            {
                {
                    name = "[???]",
                    message = "altofs is now set to (1.000000, 1.000000)",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            1,
            1,
        },
        {
            "guest_set_extraspace",
            1,
            {"altofs", "0.5", "0.6", ""},
            {
                {
                    name = "[???]",
                    message = "altofs is now set to (0.500000, 0.600000)",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.5,
            0.6,
        },
        {
            "guest_set_extraarg",
            1,
            {"altofs", "0.5", "0.6", "0.7"},
            {
                {
                    name = "[???]",
                    message = "error: wrong number of arguments",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_missingarg",
            1,
            {"altofs", "0.5"},
            {
                {
                    name = "[???]",
                    message = "error: wrong number of arguments",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_ynan",
            1,
            {"altofs", "0.5", "nan"},
            {
                {
                    name = "[???]",
                    message = 'error: got invalid number "nan"',
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_xnan",
            1,
            {"altofs", "nan", "0.6"},
            {
                {
                    name = "[???]",
                    message = 'error: got invalid number "nan"',
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_yminerr",
            1,
            {"altofs", "0.5", "-1.1"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_ymaxerr",
            1,
            {"altofs", "0.5", "1.1"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_xminerr",
            1,
            {"altofs", "-1.1", "0.6"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
        {
            "guest_set_xmaxerr",
            1,
            {"altofs", "1.1", "0.6"},
            {
                {
                    name = "[???]",
                    message = "error: offset must be within the range -1 to 1",
                    peer_id = 1,
                },
            },
            0.1,
            0.2,
            0.3,
            0.4,
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_user_peer_id = tt[2]
        local in_args = tt[3]
        local want_announce_log = tt[4]
        local want_host_alt_hofs = tt[5]
        local want_host_alt_vofs = tt[6]
        local want_guest_alt_hofs = tt[7]
        local want_guest_alt_vofs = tt[8]
        t:reset()
        t.fn()

        t.env.server._player_list = {
            { id = 0 },
            { id = 1 },
        }

        t.env.onCreate(false)
        t.env.syncPlayers()

        t.env.g_userdata[0].alt_hofs = 0.1
        t.env.g_userdata[0].alt_vofs = 0.2
        t.env.g_userdata[1].alt_hofs = 0.3
        t.env.g_userdata[1].alt_vofs = 0.4
        t.env.saveAddon()

        t.env.onCustomCommand("", in_user_peer_id, false, false, "?widget", table.unpack(in_args))
        assertEqual(prefix, "server._announce_log", want_announce_log, t.env.server._announce_log)
        assertEqual(prefix, "g_userdata[0].alt_hofs", want_host_alt_hofs, t.env.g_userdata[0].alt_hofs)
        assertEqual(prefix, "g_userdata[0].alt_vofs", want_host_alt_vofs, t.env.g_userdata[0].alt_vofs)
        assertEqual(prefix, "g_userdata[1].alt_hofs", want_guest_alt_hofs, t.env.g_userdata[1].alt_hofs)
        assertEqual(prefix, "g_userdata[1].alt_vofs", want_guest_alt_vofs, t.env.g_userdata[1].alt_vofs)
        assertEqual(prefix, "g_savedata.hostdata.alt_hofs", want_host_alt_hofs, t.env.g_savedata.hostdata.alt_hofs)
        assertEqual(prefix, "g_savedata.hostdata.alt_vofs", want_host_alt_vofs, t.env.g_savedata.hostdata.alt_vofs)
    end
end

function test_decl.testOnCustomCommandWidgetSpdUnit(t)
    local tests = {
        {
            "host_get",
            0,
            {"spdunit"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'current spdunit is "km/h"\n' ..
                        'use "?widget spdunit UNIT" to configure\n' ..
                        'available units are "km/h", "m/s", "mph", "kt"',
                    peer_id = 0,
                },
            },
            "km/h",
            "kmph",
        },
        {
            "host_set",
            0,
            {"spdunit", "m/s"},
            {
                {
                    name = "[???]",
                    message = 'spdunit is now set to "m/s"',
                    peer_id = 0,
                },
            },
            "m/s",
            "kmph",
        },
        {
            "host_set_extraspace",
            0,
            {"spdunit", "m/s", ""},
            {
                {
                    name = "[???]",
                    message = 'spdunit is now set to "m/s"',
                    peer_id = 0,
                },
            },
            "m/s",
            "kmph",
        },
        {
            "host_set_extraarg",
            0,
            {"spdunit", "m/s", "m/s"},
            {
                {
                    name = "[???]",
                    message = "error: too many arguments",
                    peer_id = 0,
                },
            },
            "km/h",
            "kmph",
        },
        {
            "host_set_invalid",
            0,
            {"spdunit", "m/h"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'error: got undefined unit "m/h"\n' ..
                        'available units are "km/h", "m/s", "mph", "kt"',
                    peer_id = 0,
                },
            },
            "km/h",
            "kmph",
        },
        {
            "guest_get",
            1,
            {"spdunit"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'current spdunit is "kmph"\n' ..
                        'use "?widget spdunit UNIT" to configure\n' ..
                        'available units are "km/h", "m/s", "mph", "kt"',
                    peer_id = 1,
                },
            },
            "km/h",
            "kmph",
        },
        {
            "guest_set",
            1,
            {"spdunit", "m/s"},
            {
                {
                    name = "[???]",
                    message = 'spdunit is now set to "m/s"',
                    peer_id = 1,
                },
            },
            "km/h",
            "m/s",
        },
        {
            "guest_set_extraspace",
            1,
            {"spdunit", "m/s", ""},
            {
                {
                    name = "[???]",
                    message = 'spdunit is now set to "m/s"',
                    peer_id = 1,
                },
            },
            "km/h",
            "m/s",
        },
        {
            "guest_set_extraarg",
            1,
            {"spdunit", "m/s", "m/s"},
            {
                {
                    name = "[???]",
                    message = "error: too many arguments",
                    peer_id = 1,
                },
            },
            "km/h",
            "kmph",
        },
        {
            "guest_set_invalid",
            1,
            {"spdunit", "m/h"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'error: got undefined unit "m/h"\n' ..
                        'available units are "km/h", "m/s", "mph", "kt"',
                    peer_id = 1,
                },
            },
            "km/h",
            "kmph",
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_user_peer_id = tt[2]
        local in_args = tt[3]
        local want_announce_log = tt[4]
        local want_spd_unit_0 = tt[5]
        local want_spd_unit_1 = tt[6]
        t:reset()
        t.fn()

        t.env.server._player_list = {
            { id = 0 },
            { id = 1 },
        }

        t.env.onCreate(false)
        t.env.syncPlayers()

        t.env.g_userdata[0].spd_unit = "km/h"
        t.env.g_userdata[1].spd_unit = "kmph"
        t.env.saveAddon()

        t.env.onCustomCommand("", in_user_peer_id, false, false, "?widget", table.unpack(in_args))
        assertEqual(prefix, "server._announce_log", want_announce_log, t.env.server._announce_log)
        assertEqual(prefix, "g_userdata[0].spd_unit", want_spd_unit_0, t.env.g_userdata[0].spd_unit)
        assertEqual(prefix, "g_userdata[1].spd_unit", want_spd_unit_1, t.env.g_userdata[1].spd_unit)
        assertEqual(prefix, "g_savedata.hostdata.spd_unit",want_spd_unit_0, t.env.g_savedata.hostdata.spd_unit)
    end
end

function test_decl.testOnCustomCommandWidgetAltUnit(t)
    local tests = {
        {
            "host_get",
            0,
            {"altunit"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'current altunit is "m"\n' ..
                        'use "?widget altunit UNIT" to configure\n' ..
                        'available units are "m", "ft"',
                    peer_id = 0,
                },
            },
            "m",
            "ft",
        },
        {
            "host_set",
            0,
            {"altunit", "ft"},
            {
                {
                    name = "[???]",
                    message = 'altunit is now set to "ft"',
                    peer_id = 0,
                },
            },
            "ft",
            "ft",
        },
        {
            "host_set_extraspace",
            0,
            {"altunit", "ft", ""},
            {
                {
                    name = "[???]",
                    message = 'altunit is now set to "ft"',
                    peer_id = 0,
                },
            },
            "ft",
            "ft",
        },
        {
            "host_set_extraarg",
            0,
            {"altunit", "ft", "ft"},
            {
                {
                    name = "[???]",
                    message = "error: too many arguments",
                    peer_id = 0,
                },
            },
            "m",
            "ft",
        },
        {
            "host_set_invalid",
            0,
            {"altunit", "kt"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'error: got undefined unit "kt"\n' ..
                        'available units are "m", "ft"',
                    peer_id = 0,
                },
            },
            "m",
            "ft",
        },
        {
            "guest_get",
            1,
            {"altunit"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'current altunit is "ft"\n' ..
                        'use "?widget altunit UNIT" to configure\n' ..
                        'available units are "m", "ft"',
                    peer_id = 1,
                },
            },
            "m",
            "ft",
        },
        {
            "guest_set",
            1,
            {"altunit", "m"},
            {
                {
                    name = "[???]",
                    message = 'altunit is now set to "m"',
                    peer_id = 1,
                },
            },
            "m",
            "m",
        },
        {
            "guest_set_extraspace",
            1,
            {"altunit", "m", ""},
            {
                {
                    name = "[???]",
                    message = 'altunit is now set to "m"',
                    peer_id = 1,
                },
            },
            "m",
            "m",
        },
        {
            "guest_set_extraarg",
            1,
            {"altunit", "m", "m"},
            {
                {
                    name = "[???]",
                    message = "error: too many arguments",
                    peer_id = 1,
                },
            },
            "m",
            "ft",
        },
        {
            "guest_set_invalid",
            1,
            {"altunit", "m/s"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'error: got undefined unit "m/s"\n' ..
                        'available units are "m", "ft"',
                    peer_id = 1,
                },
            },
            "m",
            "ft",
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_user_peer_id = tt[2]
        local in_args = tt[3]
        local want_announce_log = tt[4]
        local want_alt_unit_0 = tt[5]
        local want_alt_unit_1 = tt[6]
        t:reset()
        t.fn()

        t.env.server._player_list = {
            { id = 0 },
            { id = 1 },
        }

        t.env.onCreate(false)
        t.env.syncPlayers()

        t.env.g_userdata[0].alt_unit = "m"
        t.env.g_userdata[1].alt_unit = "ft"
        t.env.saveAddon()

        t.env.onCustomCommand("", in_user_peer_id, false, false, "?widget", table.unpack(in_args))
        assertEqual(prefix, "server._announce_log", want_announce_log, t.env.server._announce_log)
        assertEqual(prefix, "g_userdata[0].alt_unit", want_alt_unit_0, t.env.g_userdata[0].alt_unit)
        assertEqual(prefix, "g_userdata[1].alt_unit", want_alt_unit_1, t.env.g_userdata[1].alt_unit)
        assertEqual(prefix, "g_savedata.hostdata.alt_unit", want_alt_unit_0, t.env.g_savedata.hostdata.alt_unit)
    end
end

function test_decl.testOnCustomCommandWidgetUndefined(t)
    local tests = {
        {
            "host_undefined",
            0,
            {"undefined"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'error: undefined subcommand "undefined"\n' ..
                        'see "?widget help" for list of subcommands',
                    peer_id = 0,
                },
            },
        },
        {
            "host_invalid",
            0,
            {"invalid"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'error: undefined subcommand "invalid"\n' ..
                        'see "?widget help" for list of subcommands',
                    peer_id = 0,
                },
            },
        },
        {
            "guest_undefined",
            1,
            {"undefined"},
            {
                {
                    name = "[???]",
                    message = "" ..
                        'error: undefined subcommand "undefined"\n' ..
                        'see "?widget help" for list of subcommands',
                    peer_id = 1,
                },
            },
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_user_peer_id = tt[2]
        local in_args = tt[3]
        local want_announce_log = tt[4]
        t:reset()
        t.fn()

        t.env.server._player_list = {
            { id = 0 },
            { id = 1 },
        }

        t.env.onCreate(false)
        t.env.syncPlayers()
        t.env.onCustomCommand("", in_user_peer_id, false, false, "?widget", table.unpack(in_args))
        assertEqual(prefix, "server._announce_log", want_announce_log, t.env.server._announce_log)
    end
end

function test_decl.testOnTick(t)
    local tests = {
        {
            "normal",
            {},
            {},
            {
                [8] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.1, 0, 1,
                },
                [9] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.1, 0, 1,
                },
            },
            {},
            {
                [8] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.2, 0, 1,
                },
                [9] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.3, 0, 1,
                },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "m/s",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "mps",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            {
                [string.pack("jj", 0, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n---",
                    horizontal_offset = 0.1,
                    vertical_offset = -0.1,
                },
                [string.pack("jj", 0, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n1.10m",
                    horizontal_offset = 0.2,
                    vertical_offset = -0.2,
                },
                [string.pack("jj", 1, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n---",
                    horizontal_offset = 0.3,
                    vertical_offset = -0.3,
                },
                [string.pack("jj", 1, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n6.89ft",
                    horizontal_offset = 0.4,
                    vertical_offset = -0.4,
                },
            },
            {
                [string.pack("jj", 0, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n6.00m/s",
                    horizontal_offset = 0.1,
                    vertical_offset = -0.1,
                },
                [string.pack("jj", 0, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n1.20m",
                    horizontal_offset = 0.2,
                    vertical_offset = -0.2,
                },
                [string.pack("jj", 1, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n12.00mps",
                    horizontal_offset = 0.3,
                    vertical_offset = -0.3,
                },
                [string.pack("jj", 1, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n7.55ft",
                    horizontal_offset = 0.4,
                    vertical_offset = -0.4,
                },
            },
        },
        {
            "disable_host",
            {},
            {},
            {
                [8] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.1, 0, 1,
                },
                [9] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.1, 0, 1,
                },
            },
            {},
            {
                [8] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.2, 0, 1,
                },
                [9] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.3, 0, 1,
                },
            },
            {
                [0] = {
                    enabled = false,    -- !
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "m/s",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "mps",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            {
                [string.pack("jj", 1, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n---",
                    horizontal_offset = 0.3,
                    vertical_offset = -0.3,
                },
                [string.pack("jj", 1, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n6.89ft",
                    horizontal_offset = 0.4,
                    vertical_offset = -0.4,
                },
            },
            {
                [string.pack("jj", 1, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n12.00mps",
                    horizontal_offset = 0.3,
                    vertical_offset = -0.3,
                },
                [string.pack("jj", 1, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n7.55ft",
                    horizontal_offset = 0.4,
                    vertical_offset = -0.4,
                },
            },
        },
        {
            "disable_guest",
            {},
            {},
            {
                [8] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.1, 0, 1,
                },
                [9] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.1, 0, 1,
                },
            },
            {},
            {
                [8] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.2, 0, 1,
                },
                [9] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.3, 0, 1,
                },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "m/s",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = false,    -- !
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "mps",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            {
                [string.pack("jj", 0, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n---",
                    horizontal_offset = 0.1,
                    vertical_offset = -0.1,
                },
                [string.pack("jj", 0, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n1.10m",
                    horizontal_offset = 0.2,
                    vertical_offset = -0.2,
                },
            },
            {
                [string.pack("jj", 0, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n6.00m/s",
                    horizontal_offset = 0.1,
                    vertical_offset = -0.1,
                },
                [string.pack("jj", 0, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n1.20m",
                    horizontal_offset = 0.2,
                    vertical_offset = -0.2,
                },
            },
        },
        {
            "vehicle_host",
            { [8] = 16 },   -- !
            {
                [16] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.1, 0, 1,
                },
            },
            {
                [9] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.1, 0, 1,
                },
            },
            {
                [16] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.2, 0, 1,
                },
            },
            {
                [9] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.3, 0, 1,
                },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "m/s",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "mps",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            {
                [string.pack("jj", 0, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n---",
                    horizontal_offset = 0.1,
                    vertical_offset = -0.1,
                },
                [string.pack("jj", 0, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n1.10m",
                    horizontal_offset = 0.2,
                    vertical_offset = -0.2,
                },
                [string.pack("jj", 1, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n---",
                    horizontal_offset = 0.3,
                    vertical_offset = -0.3,
                },
                [string.pack("jj", 1, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n6.89ft",
                    horizontal_offset = 0.4,
                    vertical_offset = -0.4,
                },
            },
            {
                [string.pack("jj", 0, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n6.00m/s",
                    horizontal_offset = 0.1,
                    vertical_offset = -0.1,
                },
                [string.pack("jj", 0, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n1.20m",
                    horizontal_offset = 0.2,
                    vertical_offset = -0.2,
                },
                [string.pack("jj", 1, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n12.00mps",
                    horizontal_offset = 0.3,
                    vertical_offset = -0.3,
                },
                [string.pack("jj", 1, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n7.55ft",
                    horizontal_offset = 0.4,
                    vertical_offset = -0.4,
                },
            },
        },
        {
            "vehicle_guest",
            { [9] = 17 },   -- !
            {
                [17] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.1, 0, 1,
                },
            },
            {
                [8] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.1, 0, 1,
                },
            },
            {
                [17] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 2.3, 0, 1,
                },
            },
            {
                [8] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 1.2, 0, 1,
                },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "m/s",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "mps",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            {
                [string.pack("jj", 0, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n---",
                    horizontal_offset = 0.1,
                    vertical_offset = -0.1,
                },
                [string.pack("jj", 0, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n1.10m",
                    horizontal_offset = 0.2,
                    vertical_offset = -0.2,
                },
                [string.pack("jj", 1, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n---",
                    horizontal_offset = 0.3,
                    vertical_offset = -0.3,
                },
                [string.pack("jj", 1, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n6.89ft",
                    horizontal_offset = 0.4,
                    vertical_offset = -0.4,
                },
            },
            {
                [string.pack("jj", 0, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n6.00m/s",
                    horizontal_offset = 0.1,
                    vertical_offset = -0.1,
                },
                [string.pack("jj", 0, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n1.20m",
                    horizontal_offset = 0.2,
                    vertical_offset = -0.2,
                },
                [string.pack("jj", 1, 256)] = {
                    name = "",
                    is_show = true,
                    text = "SPD\n12.00mps",
                    horizontal_offset = 0.3,
                    vertical_offset = -0.3,
                },
                [string.pack("jj", 1, 257)] = {
                    name = "",
                    is_show = true,
                    text = "ALT\n7.55ft",
                    horizontal_offset = 0.4,
                    vertical_offset = -0.4,
                },
            },
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_character_vehicle_tbl = tt[2]
        local in_vehicle_pos_tbl_1 = tt[3]
        local in_object_pos_tbl_1 = tt[4]
        local in_vehicle_pos_tbl_2 = tt[5]
        local in_object_pos_tbl_2 = tt[6]
        local in_userdata = tt[7]
        local want_popup_1 = tt[8]
        local want_popup_2 = tt[9]
        t:reset()
        t.fn()

        t.env.server._ui_id_cnt = 256
        t.env.onCreate()
        t.env.server._player_list = { { id = 1 } }
        t.env.server._player_character_tbl = { [0] = 8, [1] = 9 }
        t.env.server._character_vehicle_tbl = in_character_vehicle_tbl
        t.env.server._vehicle_pos_tbl = in_vehicle_pos_tbl_1
        t.env.server._object_pos_tbl = in_object_pos_tbl_1
        t.env.g_userdata = in_userdata
        t.env.onTick(1)
        assertEqual(prefix, "server._popup", want_popup_1, t.env.server._popup)
        t.env.server._vehicle_pos_tbl = in_vehicle_pos_tbl_2
        t.env.server._object_pos_tbl = in_object_pos_tbl_2
        t.env.onTick(1)
        assertEqual(prefix, "server._popup", want_popup_2, t.env.server._popup)
    end
end

function test_decl.testOnCreate(t)
    local tests = {
        {
            "normal",
            {
                version = 1,
                spd_ui_id = 1,
                alt_ui_id = 2,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                }
            },
            1,
            2,
            {
                version = 1,
                spd_ui_id = 1,
                alt_ui_id = 2,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                },
            },
            10,
            {
                [string.pack("jj", -1, 10)] = {},
                [string.pack("jj", -1, 11)] = {},
            },
        },
        {
            "newspduiid",
            {
                version = 1,
                spd_ui_id = nil,    -- !
                alt_ui_id = 2,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                }
            },
            10,
            2,
            {
                version = 1,
                spd_ui_id = 10,
                alt_ui_id = 2,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                },
            },
            11,
            {
                [string.pack("jj", -1, 1)] = {},
                [string.pack("jj", -1, 11)] = {},
            },
        },
        {
            "newaltuiid",
            {
                version = 1,
                spd_ui_id = 1,
                alt_ui_id = nil,    -- !
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                }
            },
            1,
            10,
            {
                version = 1,
                spd_ui_id = 1,
                alt_ui_id = 10,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                },
            },
            11,
            {
                [string.pack("jj", -1, 2)] = {},
                [string.pack("jj", -1, 11)] = {},
            },
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_savedata = tt[2]
        local want_userdata = tt[3]
        local want_spd_ui_id = tt[4]
        local want_alt_ui_id = tt[5]
        local want_savedata = tt[6]
        local want_ui_id_cnt = tt[7]
        local want_popup = tt[8]
        t:reset()
        t.fn()

        t.env.server._ui_id_cnt = 10
        t.env.server._popup = {
            [string.pack("jj", -1, 1)] = {},
            [string.pack("jj", -1, 2)] = {},
            [string.pack("jj", -1, 10)] = {},
            [string.pack("jj", -1, 11)] = {},
        }
        t.env.g_savedata = in_savedata
        t.env.onCreate(false)
        assertEqual(prefix, "g_userdata", want_userdata, t.env.g_userdata)
        assertEqual(prefix, "g_spd_ui_id", want_spd_ui_id, t.env.g_spd_ui_id)
        assertEqual(prefix, "g_alt_ui_id", want_alt_ui_id, t.env.g_alt_ui_id)
        assertEqual(prefix, "g_savedata", want_savedata, t.env.g_savedata)
        assertEqual(prefix, "server._ui_id_cnt", want_ui_id_cnt, t.env.server._ui_id_cnt)
        assertEqual(prefix, "server._popup", want_popup, t.env.server._popup)
        assertEqual(prefix, "server._popup_update_cnt", 2, t.env.server._popup_update_cnt)
    end
end

function test_decl.testSyncPlayers(t)
    local tests = {
        {
            "add_guest",
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
            },
            {
                { id = 0 },
                { id = 1 },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 0.8,
                    spd_vofs = -0.9,
                    spd_unit = "km/h",
                    alt_hofs = 0.9,
                    alt_vofs = -0.8,
                    alt_unit = "m",
                },
            },
        },
        {
            "add_host",
            {},
            {},
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0.8,
                    spd_vofs = -0.9,
                    spd_unit = "km/h",
                    alt_hofs = 0.9,
                    alt_vofs = -0.8,
                    alt_unit = "m",
                },
            },
        },
        {
            "add_multi",
            {},
            {
                { id = 1 },
                { id = 2 },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0.8,
                    spd_vofs = -0.9,
                    spd_unit = "km/h",
                    alt_hofs = 0.9,
                    alt_vofs = -0.8,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 0.8,
                    spd_vofs = -0.9,
                    spd_unit = "km/h",
                    alt_hofs = 0.9,
                    alt_vofs = -0.8,
                    alt_unit = "m",
                },
                [2] = {
                    enabled = true,
                    spd_hofs = 0.8,
                    spd_vofs = -0.9,
                    spd_unit = "km/h",
                    alt_hofs = 0.9,
                    alt_vofs = -0.8,
                    alt_unit = "m",
                },
            },
        },
        {
            "remove_guest",
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 1,
                    spd_vofs = 1,
                    spd_unit = "km/h",
                    alt_hofs = 1,
                    alt_vofs = 1,
                    alt_unit = "m",
                },
            },
            {
                { id = 0 },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
            },
        },
        {
            "remove_host",
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
            },
            {},
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
            },
        },
        {
            "remove_multi",
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 1,
                    spd_vofs = 1,
                    spd_unit = "km/h",
                    alt_hofs = 1,
                    alt_vofs = 1,
                    alt_unit = "m",
                },
                [2] = {
                    enabled = true,
                    spd_hofs = 2,
                    spd_vofs = 2,
                    spd_unit = "km/h",
                    alt_hofs = 2,
                    alt_vofs = 2,
                    alt_unit = "m",
                },
            },
            {},
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
            },
        },
        {
            "keep",
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 1,
                    spd_vofs = 1,
                    spd_unit = "km/h",
                    alt_hofs = 1,
                    alt_vofs = 1,
                    alt_unit = "m",
                },
            },
            {
                { id = 0 },
                { id = 1 },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 1,
                    spd_vofs = 1,
                    spd_unit = "km/h",
                    alt_hofs = 1,
                    alt_vofs = 1,
                    alt_unit = "m",
                },
            },
        },
        {
            "mix",
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 1,
                    spd_vofs = 1,
                    spd_unit = "km/h",
                    alt_hofs = 1,
                    alt_vofs = 1,
                    alt_unit = "m",
                },
                [2] = {
                    enabled = true,
                    spd_hofs = 2,
                    spd_vofs = 2,
                    spd_unit = "km/h",
                    alt_hofs = 2,
                    alt_vofs = 2,
                    alt_unit = "m",
                },
            },
            {
                { id = 1 },
                { id = 3 },
            },
            {
                [0] = {
                    enabled = true,
                    spd_hofs = 0,
                    spd_vofs = 0,
                    spd_unit = "km/h",
                    alt_hofs = 0,
                    alt_vofs = 0,
                    alt_unit = "m",
                },
                [1] = {
                    enabled = true,
                    spd_hofs = 1,
                    spd_vofs = 1,
                    spd_unit = "km/h",
                    alt_hofs = 1,
                    alt_vofs = 1,
                    alt_unit = "m",
                },
                [3] = {
                    enabled = true,
                    spd_hofs = 0.8,
                    spd_vofs = -0.9,
                    spd_unit = "km/h",
                    alt_hofs = 0.9,
                    alt_vofs = -0.8,
                    alt_unit = "m",
                },
            },
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_userdata = tt[2]
        local in_player_list = tt[3]
        local want_userdata = tt[4]
        t:reset()
        t.fn()

        t.env.g_userdata = in_userdata
        t.env.server._player_list = in_player_list
        t.env.syncPlayers()
        assertEqual(prefix, "g_userdata", want_userdata, t.env.g_userdata)
    end
end

function test_decl.testFormatSpd(t)
    local tests = {
        {"invalid_spd", nil, "km/h", "SPD\n---"},
        {"invalid_unit_nil", 0, nil, "SPD\n---"},
        {"invalid_unit_unknown", 0, "invalid", "SPD\n---"},
        {"normal_kmph", 1.5/216, "km/h", "SPD\n1.50km/h"},
        {"normal_mps", 1.5/60, "m/s", "SPD\n1.50m/s"},
        {"normal_mph", 1.5/(216000.0/1609.344), "mph", "SPD\n1.50mph"},
        {"normal_kt", 1.5/(216000.0/1852.0), "kt", "SPD\n1.50kt"},
        {"exc_nan", 0.0/0.0, "km/h", "SPD\nnankm/h"},
        {"exc_pinf", 1.0/0.0, "km/h", "SPD\ninfkm/h"},
        {"exc_ninf", -1.0/0.0, "km/h", "SPD\n-infkm/h"},
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_spd = tt[2]
        local in_spd_unit = tt[3]
        local want_txt = tt[4]
        t:reset()
        t.fn()

        local got_txt = t.env.formatSpd(in_spd, in_spd_unit)
        assertEqual(prefix, "txt", want_txt, got_txt)
    end
end

function test_decl.testFormatAlt(t)
    local tests = {
        {"invalid_spd", nil, "m", "ALT\n---"},
        {"invalid_unit_nil", 0, nil, "ALT\n---"},
        {"invalid_unit_unknown", 0, "invalid", "ALT\n---"},
        {"normal_m", 1.5, "m", "ALT\n1.50m"},
        {"normal_ft", 1.5/(1.0/0.3048), "ft", "ALT\n1.50ft"},
        {"exc_nan", 0.0/0.0, "m", "ALT\nnanm"},
        {"exc_pinf", 1.0/0.0, "m", "ALT\ninfm"},
        {"exc_ninf", -1.0/0.0, "m", "ALT\n-infm"},
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_alt = tt[2]
        local in_alt_unit = tt[3]
        local want_txt = tt[4]
        t:reset()
        t.fn()

        local got_txt = t.env.formatAlt(in_alt, in_alt_unit)
        assertEqual(prefix, "txt", want_txt, got_txt)
    end
end

function test_decl.testLoadAddon(t)
    local tests = {
        {
            "normal",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "normal_nohostdata",
            2,
            3,
            nil,    -- !
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            nil,
        },
        {
            "normal_min",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = -1,      -- min
                    spd_vofs = -1,      -- min
                    spd_unit = "kph",
                    alt_hofs = -1,      -- min
                    alt_vofs = -1,      -- min
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = -1,
                spd_vofs = -1,
                spd_unit = "kph",
                alt_hofs = -1,
                alt_vofs = -1,
                alt_unit = "ft",
            },
        },
        {
            "normal_max",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 1,       -- max
                    spd_vofs = 1,       -- max
                    spd_unit = "kph",
                    alt_hofs = 1,       -- max
                    alt_vofs = 1,       -- max
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 1,
                spd_vofs = 1,
                spd_unit = "kph",
                alt_hofs = 1,
                alt_vofs = 1,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_nosavedata",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            nil,    -- !
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
        },
        {
            "abnormal_version",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 2,    -- !
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
        },
        {
            "abnormal_spduiid_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = nil,    -- !
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            2,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spduiid_float",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4.1,    -- !
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            2,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "anbormal_spduiid_nan",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 0.0/0.0,    -- !
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            2,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spduiid_ninf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = -1.0/0.0,   -- !
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            2,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spduiid_pinf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 1.0/0.0,    -- !
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            2,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altuiid_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = nil,    -- !
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            3,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altuiid_float",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5.1,    -- !
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            3,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altuiid_nan",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 0.0/0.0,    -- !
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            3,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altuiid_ninf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = -1.0/0.0,   -- !
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            3,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altuiid_pinf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 1.0/0.0,    -- !
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            3,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_hostdata_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = nil, -- !
            },
            4,
            5,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
        },
        {
            "abnormal_enabled_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = nil,  -- !
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = false,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdhofs_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = nil, -- !
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.1,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdhofs_min",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = -1.1,    -- !
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.1,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdhofs_max",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 1.1, -- !
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.1,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdhofs_nan",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.0/0.0, -- !
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.1,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdhofs_ninf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = -1.0/0.0,    -- !
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.1,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdhofs_pinf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 1.0/0.0, -- !
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.1,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdvofs_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = nil, -- !
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.1,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdvofs_min",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -1.1,    -- !
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.1,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdvofs_max",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = 1.1, -- !
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.1,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdvofs_nan",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = 0.0/0.0, -- !
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.1,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdvofs_ninf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -1.0/0.0,    -- !
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.1,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdvofs_pinf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = 1.0/0.0, -- !
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.1,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdunit_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = nil, -- !
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "km/h",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_spdunit_invalid",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "invalid",   -- !
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "km/h",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_althofs_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = nil, -- !
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.2,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_althofs_min",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = -1.1,    -- !
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.2,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_althofs_max",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 1.1, -- !
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.2,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_althofs_nan",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.0/0.0, -- !
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.2,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_althofs_ninf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = -1.0/0.0,    -- !
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.2,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_althofs_pinf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 1.0/0.0, -- !
                    alt_vofs = -0.4,
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.2,
                alt_vofs = -0.4,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altvofs_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = nil, -- !
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.2,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altvofs_min",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -1.1,    -- !
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.2,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altvofs_max",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = 1.1, -- !
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.2,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altvofs_nan",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = 0.0/0.0, -- !
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.2,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altvofs_ninf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -1.0/0.0,    -- !
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.2,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altvofs_pinf",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = 1.0/0.0, -- !
                    alt_unit = "ft",
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.2,
                alt_unit = "ft",
            },
        },
        {
            "abnormal_altunit_nil",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = nil, -- !
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "m",
            },
        },
        {
            "abnormal_altunit_invalid",
            2,
            3,
            {
                enabled = false,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "km/h",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "m",
            },
            {
                version = 1,
                spd_ui_id = 4,
                alt_ui_id = 5,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.3,
                    spd_vofs = -0.3,
                    spd_unit = "kph",
                    alt_hofs = 0.4,
                    alt_vofs = -0.4,
                    alt_unit = "invalid",   -- !
                },
            },
            4,
            5,
            {
                enabled = true,
                spd_hofs = 0.3,
                spd_vofs = -0.3,
                spd_unit = "kph",
                alt_hofs = 0.4,
                alt_vofs = -0.4,
                alt_unit = "m",
            },
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_spd_ui_id = tt[2]
        local in_alt_ui_id = tt[3]
        local in_hostdata = tt[4]
        local in_savedata = tt[5]
        local want_spd_ui_id = tt[6]
        local want_alt_ui_id = tt[7]
        local want_hostdata = tt[8]
        t:reset()
        t.fn()

        t.env.g_spd_ui_id = in_spd_ui_id
        t.env.g_alt_ui_id = in_alt_ui_id
        t.env.g_userdata = { [0] = in_hostdata }
        t.env.g_savedata = in_savedata
        t.env.loadAddon()
        assertEqual(prefix, "g_spd_ui_id", want_spd_ui_id, t.env.g_spd_ui_id)
        assertEqual(prefix, "g_alt_ui_id", want_alt_ui_id, t.env.g_alt_ui_id)
        assertEqual(prefix, "g_userdata[0]", want_hostdata, t.env.g_userdata[0])
    end
end

function test_decl.testSaveAddon(t)
    local tests = {
        {
            "nohostdata",
            2,
            3,
            nil,
            {
                version = 1,
                spd_ui_id = 2,
                alt_ui_id = 3,
                hostdata = nil,
            },
        },
        {
            "normal",
            2,
            3,
            {
                enabled = true,
                spd_hofs = 0.1,
                spd_vofs = -0.1,
                spd_unit = "kph",
                alt_hofs = 0.2,
                alt_vofs = -0.2,
                alt_unit = "ft",
            },
            {
                version = 1,
                spd_ui_id = 2,
                alt_ui_id = 3,
                hostdata = {
                    enabled = true,
                    spd_hofs = 0.1,
                    spd_vofs = -0.1,
                    spd_unit = "kph",
                    alt_hofs = 0.2,
                    alt_vofs = -0.2,
                    alt_unit = "ft",
                },
            },
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_spd_ui_id = tt[2]
        local in_alt_ui_id = tt[3]
        local in_hostdata = tt[4]
        local want_savedata = tt[5]
        t:reset()
        t.fn()

        t.env.g_spd_ui_id = in_spd_ui_id
        t.env.g_alt_ui_id = in_alt_ui_id
        t.env.g_userdata = { [0] = in_hostdata }
        t.env.saveAddon()
        assertEqual(prefix, "g_savedata", want_savedata, t.env.g_savedata)
    end
end

function test_decl.testTrackerUserGet(t)
    local tests = {
        {
            "vehicle",
            { [1] = 2 },
            8,
            4,
        },
        {
            "player",
            {},
            9,
            5,
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_character_vehicle_tbl = tt[2]
        local want_spd = tt[3]
        local want_alt = tt[4]
        t:reset()
        t.fn()

        t.env.server._player_character_tbl = { [0] = 1 }
        t.env.server._character_vehicle_tbl = in_character_vehicle_tbl
        t.env.server._vehicle_pos_tbl = {
            [2] = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 4, 0, 1,
            },
        }
        t.env.server._object_pos_tbl = {
            [1] = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 5, 0, 1,
            },
        }

        local tracker = t.env.buildTracker()
        tracker:getUserSpdAlt(0)

        t.env.server._vehicle_pos_tbl = {
            [2] = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                8, 4, 0, 1,
            },
        }
        t.env.server._object_pos_tbl = {
            [1] = {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                9, 5, 0, 1,
            },
        }

        tracker:tick()
        local got_spd, got_alt = tracker:getUserSpdAlt(0)
        assertEqual(prefix, "spd", want_spd, got_spd)
        assertEqual(prefix, "alt", want_alt, got_alt)
    end
end

function test_decl.testTrackerPlayerGet(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
end

function test_decl.testTrackerPlayerCache(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = nil

    spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
end

function test_decl.testTrackerPlayerCacheExpiry(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = nil

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", nil, alt)
end

function test_decl.testTrackerPlayerCacheMulti(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }
    t.env.server._player_character_tbl[11] = 6
    t.env.server._object_pos_tbl[6] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        7, 8, 9, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
    spd, alt = tracker:getPlayerSpdAlt(11)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 8, alt)

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = nil
    t.env.server._player_character_tbl[11] = 6
    t.env.server._object_pos_tbl[6] = nil

    spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
    spd, alt = tracker:getPlayerSpdAlt(11)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 8, alt)
end

function test_decl.testTrackerPlayerFail(t)
    t:reset()
    t.fn()

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", nil, alt)
end

function test_decl.testTrackerPlayerFailCache(t)
    t:reset()
    t.fn()

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", nil, alt)

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
end

function test_decl.testTrackerPlayerFailTrack(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = nil

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", nil, alt)

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        6, 7, 8, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 7, alt)
end

function test_decl.testTrackerPlayerTrack(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        5, 8, 9, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", 6, spd)
    assertEqual(nil, "alt", 8, alt)
end

function test_decl.testTrackerPlayerTrackExpiry(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        5, 8, 9, 1,
    }

    tracker:tickPlayer()
    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 8, alt)
end

function test_decl.testTrackerPlayerTrackMulti(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 3, 0, 1,
    }
    t.env.server._player_character_tbl[11] = 4
    t.env.server._object_pos_tbl[4] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 5, 0, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 3, alt)
    spd, alt = tracker:getPlayerSpdAlt(11)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 5, alt)

    t.env.server._player_character_tbl[10] = 2
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 6, 0, 1,
    }
    t.env.server._player_character_tbl[11] = 4
    t.env.server._object_pos_tbl[4] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 7, 0, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(10)
    assertEqual(nil, "spd", 3, spd)
    assertEqual(nil, "alt", 6, alt)
    spd, alt = tracker:getPlayerSpdAlt(11)
    assertEqual(nil, "spd", 2, spd)
    assertEqual(nil, "alt", 7, alt)
end

function test_decl.testTrackerVehicleGet(t)
    t:reset()
    t.fn()

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
end

function test_decl.testTrackerVehicleCache(t)
    t:reset()
    t.fn()

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._vehicle_pos_tbl[2] = nil

    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
end

function test_decl.testTrackerVehicleCacheExpiry(t)
    t:reset()
    t.fn()

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._vehicle_pos_tbl[2] = nil

    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", nil, alt)
end

function test_decl.testTrackerVehicleCacheMulti(t)
    t:reset()
    t.fn()

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }
    t.env.server._vehicle_pos_tbl[6] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        7, 8, 9, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
    spd, alt = tracker:getVehicleSpdAlt(6)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 8, alt)

    t.env.server._vehicle_pos_tbl[2] = nil
    t.env.server._vehicle_pos_tbl[6] = nil

    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
    spd, alt = tracker:getVehicleSpdAlt(6)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 8, alt)
end

function test_decl.testTrackerVehicleFail(t)
    t:reset()
    t.fn()

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", nil, alt)
end

function test_decl.testTrackerVehicleFailCache(t)
    t:reset()
    t.fn()

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", nil, alt)

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)
end

function test_decl.testTrackerVehicleFailTrack(t)
    t:reset()
    t.fn()

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._vehicle_pos_tbl[2] = nil

    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", nil, alt)

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        6, 7, 8, 1,
    }

    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 7, alt)
end

function test_decl.testTrackerVehicleTrack(t)
    t:reset()
    t.fn()

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        5, 8, 9, 1,
    }

    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", 6, spd)
    assertEqual(nil, "alt", 8, alt)
end

function test_decl.testTrackerVehicleTrackExpiry(t)
    t:reset()
    t.fn()

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 4, alt)

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        5, 8, 9, 1,
    }

    tracker:tickVehicle()
    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 8, alt)
end

function test_decl.testTrackerVehicleTrackMulti(t)
    t:reset()
    t.fn()

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 3, 0, 1,
    }
    t.env.server._vehicle_pos_tbl[4] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 5, 0, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 3, alt)
    spd, alt = tracker:getVehicleSpdAlt(4)
    assertEqual(nil, "spd", nil, spd)
    assertEqual(nil, "alt", 5, alt)

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 6, 0, 1,
    }
    t.env.server._vehicle_pos_tbl[4] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 7, 0, 1,
    }

    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, "spd", 3, spd)
    assertEqual(nil, "alt", 6, alt)
    spd, alt = tracker:getVehicleSpdAlt(4)
    assertEqual(nil, "spd", 2, spd)
    assertEqual(nil, "alt", 7, alt)
end

function test_decl.testUIMPopupEmpty(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:flushPopup()
    assertEqual(nil, "server._popup_update_cnt", 0, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupAddAll(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(-1, 0, "name", true, "text", 0, 0)
    uim:flushPopup()
    assertEqual(nil, "server._popup_update_cnt", 0, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupAdd(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name", true, "text", 0.1, 0.2)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name",
            is_show = true,
            text = "text",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 1, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupKeep(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name", true, "text", 0.1, 0.2)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name",
            is_show = true,
            text = "text",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 1, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "name", true, "text", 0.1, 0.2)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name",
            is_show = true,
            text = "text",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 1, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupUpdate(t)
    local tests = {
        {"name",              "name2", true, "text1", 0.1, 0.2},
        {"is_show",           "name1", false, "text1", 0.1, 0.2},
        {"text",              "name1", true, "text2", 0.1, 0.2},
        {"horizontal_offset", "name1", true, "text1", 0.3, 0.2},
        {"vertical_offset",   "name1", true, "text1", 0.1, 0.4},
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_name = tt[2]
        local in_is_show = tt[3]
        local in_text = tt[4]
        local in_horizontal_offset = tt[5]
        local in_vertical_offset = tt[6]
        t:reset()
        t.fn()

        local uim = t.env.buildUIManager()

        uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
        uim:flushPopup()
        assertEqual(prefix, "server._popup", {
            [string.pack("jj", 0, 1)] = {
                name = "name1",
                is_show = true,
                text = "text1",
                horizontal_offset = 0.1,
                vertical_offset = 0.2,
            },
        }, t.env.server._popup)
        assertEqual(prefix, "server._popup_update_cnt", 1, t.env.server._popup_update_cnt)

        uim:setPopupScreen(0, 1, in_name, in_is_show, in_text, in_horizontal_offset, in_vertical_offset)
        uim:flushPopup()
        assertEqual(prefix, "server._popup", {
            [string.pack("jj", 0, 1)] = {
                name = in_name,
                is_show = in_is_show,
                text = in_text,
                horizontal_offset = in_horizontal_offset,
                vertical_offset = in_vertical_offset,
            },
        }, t.env.server._popup)
        assertEqual(prefix, "server._popup_update_cnt", 2, t.env.server._popup_update_cnt)
    end
end

function test_decl.testUIMPopupRemove(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name", true, "text", 0.1, 0.2)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name",
            is_show = true,
            text = "text",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 1, t.env.server._popup_update_cnt)

    uim:flushPopup()
    assertEqual(nil, "server._popup", {}, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 2, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupOverrideAdd(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
    uim:setPopupScreen(0, 1, "name2", false, "text2", 0.3, 0.4)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name2",
            is_show = false,
            text = "text2",
            horizontal_offset = 0.3,
            vertical_offset = 0.4,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 1, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupOverrideKeep(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name1",
            is_show = true,
            text = "text1",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 1, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "name2", false, "text2", 0.3, 0.4)
    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name1",
            is_show = true,
            text = "text1",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 1, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupOverrideUpdate(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name1",
            is_show = true,
            text = "text1",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 1, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "name2", false, "text2", 0.3, 0.4)
    uim:setPopupScreen(0, 1, "name3", true, "text3", 0.5, 0.6)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name3",
            is_show = true,
            text = "text3",
            horizontal_offset = 0.5,
            vertical_offset = 0.6,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 2, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupKey(t)
    local tests = {
        {"peer_id", 2, 1},
        {"ui_id", 0, 2},
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_peer_id = tt[2]
        local in_ui_id = tt[3]
        t:reset()
        t.fn()

        local uim = t.env.buildUIManager()
        uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
        uim:setPopupScreen(in_peer_id, in_ui_id, "name2", false, "text2", 0.3, 0.4)
        uim:flushPopup()
        assertEqual(prefix, "server._popup", {
            [string.pack("jj", 0, 1)] = {
                name = "name1",
                is_show = true,
                text = "text1",
                horizontal_offset = 0.1,
                vertical_offset = 0.2,
            },
            [string.pack("jj", in_peer_id, in_ui_id)] = {
                name = "name2",
                is_show = false,
                text = "text2",
                horizontal_offset = 0.3,
                vertical_offset = 0.4,
            },
        }, t.env.server._popup)
        assertEqual(prefix, "server._popup_update_cnt", 2, t.env.server._popup_update_cnt)
    end
end

function test_decl.testUIMPopupMix(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 3, "keep1", true, "text31", 0.31, 0.32)
    uim:setPopupScreen(0, 4, "keep2", false, "text41", 0.41, 0.42)
    uim:setPopupScreen(0, 5, "update1", true, "text51", 0.51, 0.52)
    uim:setPopupScreen(0, 6, "update2", false, "text61", 0.61, 0.62)
    uim:setPopupScreen(0, 7, "remove1", true, "text71", 0.71, 0.72)
    uim:setPopupScreen(0, 8, "remove2", false, "text81", 0.81, 0.82)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 3)] = {
            name = "keep1",
            is_show = true,
            text = "text31",
            horizontal_offset = 0.31,
            vertical_offset = 0.32,
        },
        [string.pack("jj", 0, 4)] = {
            name = "keep2",
            is_show = false,
            text = "text41",
            horizontal_offset = 0.41,
            vertical_offset = 0.42,
        },
        [string.pack("jj", 0, 5)] = {
            name = "update1",
            is_show = true,
            text = "text51",
            horizontal_offset = 0.51,
            vertical_offset = 0.52,
        },
        [string.pack("jj", 0, 6)] = {
            name = "update2",
            is_show = false,
            text = "text61",
            horizontal_offset = 0.61,
            vertical_offset = 0.62,
        },
        [string.pack("jj", 0, 7)] = {
            name = "remove1",
            is_show = true,
            text = "text71",
            horizontal_offset = 0.71,
            vertical_offset = 0.72,
        },
        [string.pack("jj", 0, 8)] = {
            name = "remove2",
            is_show = false,
            text = "text81",
            horizontal_offset = 0.81,
            vertical_offset = 0.82,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 6, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "add1", true, "text11", 0.11, 0.12)
    uim:setPopupScreen(0, 2, "add2", false, "text21", 0.21, 0.22)
    uim:setPopupScreen(0, 3, "keep1", true, "text31", 0.31, 0.32)
    uim:setPopupScreen(0, 4, "keep2", false, "text41", 0.41, 0.42)
    uim:setPopupScreen(0, 5, "update1!", false, "text52", 0.53, 0.54)
    uim:setPopupScreen(0, 6, "update2!", true, "text62", 0.63, 0.64)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "add1",
            is_show = true,
            text = "text11",
            horizontal_offset = 0.11,
            vertical_offset = 0.12,
        },
        [string.pack("jj", 0, 2)] = {
            name = "add2",
            is_show = false,
            text = "text21",
            horizontal_offset = 0.21,
            vertical_offset = 0.22,
        },
        [string.pack("jj", 0, 3)] = {
            name = "keep1",
            is_show = true,
            text = "text31",
            horizontal_offset = 0.31,
            vertical_offset = 0.32,
        },
        [string.pack("jj", 0, 4)] = {
            name = "keep2",
            is_show = false,
            text = "text41",
            horizontal_offset = 0.41,
            vertical_offset = 0.42,
        },
        [string.pack("jj", 0, 5)] = {
            name = "update1!",
            is_show = false,
            text = "text52",
            horizontal_offset = 0.53,
            vertical_offset = 0.54,
        },
        [string.pack("jj", 0, 6)] = {
            name = "update2!",
            is_show = true,
            text = "text62",
            horizontal_offset = 0.63,
            vertical_offset = 0.64,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 12, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupJoin(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.11, 0.12)
    uim:setPopupScreen(0, 2, "name2", false, "text2", 0.21, 0.22)
    uim:setPopupScreen(1, 1, "name3", true, "text3", 0.31, 0.32)
    uim:setPopupScreen(1, 2, "name4", false, "text4", 0.41, 0.42)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name1",
            is_show = true,
            text = "text1",
            horizontal_offset = 0.11,
            vertical_offset = 0.12,
        },
        [string.pack("jj", 0, 2)] = {
            name = "name2",
            is_show = false,
            text = "text2",
            horizontal_offset = 0.21,
            vertical_offset = 0.22,
        },
        [string.pack("jj", 1, 1)] = {
            name = "name3",
            is_show = true,
            text = "text3",
            horizontal_offset = 0.31,
            vertical_offset = 0.32,
        },
        [string.pack("jj", 1, 2)] = {
            name = "name4",
            is_show = false,
            text = "text4",
            horizontal_offset = 0.41,
            vertical_offset = 0.42,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 4, t.env.server._popup_update_cnt)

    uim:onPlayerJoin(0, "name", 1, false, false)
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name1",
            is_show = true,
            text = "text1",
            horizontal_offset = 0.11,
            vertical_offset = 0.12,
        },
        [string.pack("jj", 0, 2)] = {
            name = "name2",
            is_show = false,
            text = "text2",
            horizontal_offset = 0.21,
            vertical_offset = 0.22,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 6, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.11, 0.12)
    uim:setPopupScreen(0, 2, "name2", false, "text2", 0.21, 0.22)
    uim:setPopupScreen(1, 1, "name3", true, "text3", 0.31, 0.32)
    uim:setPopupScreen(1, 2, "name4", false, "text4", 0.41, 0.42)
    uim:flushPopup()
    assertEqual(nil, "server._popup", {
        [string.pack("jj", 0, 1)] = {
            name = "name1",
            is_show = true,
            text = "text1",
            horizontal_offset = 0.11,
            vertical_offset = 0.12,
        },
        [string.pack("jj", 0, 2)] = {
            name = "name2",
            is_show = false,
            text = "text2",
            horizontal_offset = 0.21,
            vertical_offset = 0.22,
        },
        [string.pack("jj", 1, 1)] = {
            name = "name3",
            is_show = true,
            text = "text3",
            horizontal_offset = 0.31,
            vertical_offset = 0.32,
        },
        [string.pack("jj", 1, 2)] = {
            name = "name4",
            is_show = false,
            text = "text4",
            horizontal_offset = 0.41,
            vertical_offset = 0.42,
        },
    }, t.env.server._popup)
    assertEqual(nil, "server._popup_update_cnt", 8, t.env.server._popup_update_cnt)
end

function test_decl.testGetPlayerPos(t)
    local tests = {
        {
            "normal",
            {[0] = 1},
            {
                [1] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    2, 3, 4, 1,
                },
            },
            0,
            {
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                2, 3, 4, 1,
            },
            true,
        },
        {
            "abnormal_nocharacter",
            {},
            {
                [1] = {
                    1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    2, 3, 4, 1,
                },
            },
            0,
            nil,
            false,
        },
        {
            "abnormal_nopos",
            {[0] = 1},
            {},
            0,
            nil,
            false,
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_player_character_tbl = tt[2]
        local in_object_pos_tbl = tt[3]
        local in_peer_id = tt[4]
        local want_object_pos = tt[5]
        local want_is_success = tt[6]
        t:reset()
        t.fn()
        t.env.server._player_character_tbl = in_player_character_tbl
        t.env.server._object_pos_tbl = in_object_pos_tbl

        local got_object_pos, got_is_success = t.env.getPlayerPos(in_peer_id)
        assertEqual(prefix, "object_pos", want_object_pos, got_object_pos)
        assertEqual(prefix, "is_success", want_is_success, got_is_success)
    end
end

function test_decl.testGetAddonName(t)
    local tests = {
        {"abnormal_noidx", 0, false, {}, "???"},
        {"abnormal_nodata", 0, true, {}, "???"},
        {
            "normal",
            0,
            true,
            {
                [0] = {
                    name = "name",
                    path_id = "folder_path",
                    file_store = "is_app_data",
                    location_count = "location_count",
                },
            },
            "name"
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_addon_idx = tt[2]
        local in_addon_idx_exists = tt[3]
        local in_addon_tbl = tt[4]
        local want_addon_name = tt[5]
        t:reset()
        t.env.server._addon_idx = in_addon_idx
        t.env.server._addon_idx_exists = in_addon_idx_exists
        t.env.server._addon_tbl = in_addon_tbl
        t.fn()

        local got_addon_name = t.env.getAddonName()
        assertEqual(prefix, "addon_name", want_addon_name, got_addon_name)
    end
end

function test_decl.testGetAnnounceName(t)
    t:reset()
    t.env.server._addon_idx = 0
    t.env.server._addon_idx_exists = true
    t.env.server._addon_tbl = {
        [0] = {
            name = "name",
            path_id = "folder_path",
            file_store = "is_app_data",
            location_count = "location_count",
        },
    }
    t.fn()

    local announce_name = t.env.getAnnounceName()
    assertEqual(nil, "announce_name", "[name]", announce_name)
end

function test_decl.testGetPlayerVehicle(t)
    local tests = {
        {"abnormal_nocharacter", {}, {}, 0, false},
        {
            "abnormal_novehicle",
            {[1] = 2},
            {},
            0,
            false,
        },
        {
            "normal",
            {[1] = 2},
            {[2] = 3},
            3,
            true,
        },
    }

    for i, tt in ipairs(tests) do
        local prefix = tt[1]
        local in_player_character_tbl = tt[2]
        local in_character_vehicle_tbl = tt[3]
        local want_vehicle_id = tt[4]
        local want_is_success = tt[5]
        t:reset()
        t.env.server._player_character_tbl = in_player_character_tbl
        t.env.server._character_vehicle_tbl = in_character_vehicle_tbl
        t.fn()

        local got_vehicle_id, got_is_success = t.env.getPlayerVehicle(1)
        assertEqual(prefix, "vehicle_id", want_vehicle_id, got_vehicle_id)
        assertEqual(prefix, "is_success", want_is_success, got_is_success)
    end
end

local function buildMockMatrix()
    local matrix = {}

    function matrix.position(matrix1)
        return matrix1[13], matrix1[14], matrix1[15]
    end

    function matrix.distance(matrix1, matrix2)
        local x1, y1, z1 = matrix.position(matrix1)
        local x2, y2, z2 = matrix.position(matrix2)
        return ((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)^0.5
    end

    return matrix
end

local function buildMockServer()
    local server = {
        _addon_idx = 0,
        _addon_idx_exists = false,
        _addon_tbl = {},
        _announce_log = {},
        _ui_id_cnt = 0,
        _popup = {},
        _popup_update_cnt = 0,
        _player_list = {},
        _player_character_tbl = {},
        _character_vehicle_tbl = {},
        _object_pos_tbl = {},
        _vehicle_pos_tbl = {},
    }

    function server.getAddonIndex(name)
        if name ~= nil then
            error()
        end
        return server._addon_idx, server._addon_idx_exists
    end

    function server.getAddonData(addon_index)
        return server._addon_tbl[addon_index]
    end

    function server.announce(name, message, peer_id)
        table.insert(server._announce_log, {
            name = name,
            message = message,
            peer_id = peer_id,
        })
    end

    function server.getMapID()
        local ui_id = server._ui_id_cnt
        server._ui_id_cnt = server._ui_id_cnt + 1
        return ui_id
    end

    function server.setPopupScreen(peer_id, ui_id, name, is_show, text, horizontal_offset, vertical_offset)
        local key = string.pack("jj", peer_id, ui_id)
        server._popup[key] = {
            name = name,
            is_show = is_show,
            text = text,
            horizontal_offset = horizontal_offset,
            vertical_offset = vertical_offset,
        }
        server._popup_update_cnt = server._popup_update_cnt + 1
    end

    function server.removePopup(peer_id, ui_id)
        local key = string.pack("jj", peer_id, ui_id)
        server._popup[key] = nil
        server._popup_update_cnt = server._popup_update_cnt + 1
    end

    function server.getPlayers()
        return server._player_list
    end

    function server.getPlayerCharacterID(peer_id)
        local object_id = server._player_character_tbl[peer_id]
        if object_id == nil then
            return 0, false
        end
        return object_id, true
    end

    function server.getCharacterVehicle(object_id)
        local vehicle_id = server._character_vehicle_tbl[object_id]
        if vehicle_id == nil then
            return 0, false
        end
        return vehicle_id, true
    end

    function server.getObjectPos(object_id)
        local object_pos = server._object_pos_tbl[object_id]
        return object_pos, object_pos ~= nil
    end

    function server.getVehiclePos(vehicle_id, voxel_x, voxel_y, voxel_z)
        if voxel_x ~= nil or voxel_y ~= nil or voxel_z ~= nil then
            error()
        end

        local vehicle_pos = server._vehicle_pos_tbl[vehicle_id]
        return vehicle_pos, vehicle_pos ~= nil
    end

    return server
end

local function buildT()
    local env = {}
    local fn, err = loadfile("script.lua", "t", env)
    if fn == nil then
        error(err)
    end

    local t = {
        env = env,
        fn = fn,
        reset = function(self)
            for k, _ in pairs(self.env) do
                self.env[k] = nil
            end
            self.env.pairs = pairs
            self.env.ipairs = ipairs
            self.env.next = next
            self.env.tostring = tostring
            self.env.tonumber = tonumber
            self.env.type = type
            self.env.math = math
            self.env.table = table
            self.env.string = string
            self.env.matrix = buildMockMatrix()
            self.env.server = buildMockServer()
        end,
    }
    t:reset()
    return t
end

local function test()
    local test_tbl = {}
    for test_name, test_fn in pairs(test_decl) do
        table.insert(test_tbl, {test_name, test_fn})
    end
    table.sort(test_tbl, function(x, y)
        return x[1] < y[1]
    end)

    local function msgh(err)
        return {
            err = err,
            traceback = debug.traceback(),
        }
    end

    local t = buildT()
    local s = "PASS"
    for _, test_entry in ipairs(test_tbl) do
        local test_name, test_fn = table.unpack(test_entry)

        t:reset()
        local is_success, err = xpcall(test_fn, msgh, t)
        if is_success then
            io.write(string.format("PASS %s\n", test_name))
        else
            io.write(string.format("FAIL %s\n", test_name))
            io.write(string.format("%s\n", err.err))
            io.write(string.format("%s\n", err.traceback))
            s = "FAIL"
        end
    end
    io.write(string.format("%s\n", s))
end

test()
