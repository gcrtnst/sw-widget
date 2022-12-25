local test_decl = {}

local function deepEqual(x, y)
    if type(x) ~= type(y) then
        return false
    end
    if type(x) ~= "table" then
        return x == y
    end
    for k in pairs(x) do
        if not deepEqual(x[k], y[k]) then
            return false
        end
    end
    for k in pairs(y) do
        if x[k] == nil then
            return false
        end
    end
    return true
end

local function assertEqual(want, got)
    if not deepEqual(got, want) then
        error(string.format("expected `%s`, got `%s`", want, got))
    end
end

function test_decl.testFormatSpd(t)
    local tests = {
        {nil, "km/h", "SPD\n---"},
        {0, nil, "SPD\n---"},
        {0, "invalid", "SPD\n---"},
        {1.5/216, "km/h", "SPD\n1.50km/h"},
        {1.5/60, "m/s", "SPD\n1.50m/s"},
        {1.5/(216000.0/1852.0), "kt", "SPD\n1.50kt"},
        {0.0/0.0, "km/h", "SPD\nnankm/h"},
        {1.0/0.0, "km/h", "SPD\ninfkm/h"},
        {-1.0/0.0, "km/h", "SPD\n-infkm/h"},
    }

    for i, tt in ipairs(tests) do
        local in_spd, in_spd_unit, want_txt = table.unpack(tt)
        t:reset()
        t.fn()

        local got_txt = t.env.formatSpd(in_spd, in_spd_unit)
        assertEqual(want_txt, got_txt)
    end
end

function test_decl.testFormatAlt(t)
    local tests = {
        {nil, "m", "ALT\n---"},
        {0, nil, "ALT\n---"},
        {0, "invalid", "ALT\n---"},
        {1.5, "m", "ALT\n1.50m"},
        {1.5/(1.0/0.3048), "ft", "ALT\n1.50ft"},
        {0.0/0.0, "m", "ALT\nnanm"},
        {1.0/0.0, "m", "ALT\ninfm"},
        {-1.0/0.0, "m", "ALT\n-infm"},
    }

    for i, tt in ipairs(tests) do
        local in_alt, in_alt_unit, want_txt = table.unpack(tt)
        t:reset()
        t.fn()

        local got_txt = t.env.formatAlt(in_alt, in_alt_unit)
        assertEqual(want_txt, got_txt)
    end
end

function test_decl.testTrackerPlayerGet(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[0] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 3, 4, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(3, alt)
end

function test_decl.testTrackerPlayerCache(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[0] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 3, 4, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(3, alt)

    t.env.server._object_pos_tbl[1] = nil

    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(3, alt)
end

function test_decl.testTrackerPlayerCacheExpiry(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[0] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 3, 4, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(3, alt)

    t.env.server._object_pos_tbl[1] = nil

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(nil, alt)
end

function test_decl.testTrackerPlayerCacheMulti(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[1] = 2
    t.env.server._player_character_tbl[3] = 4
    t.env.server._object_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        5, 6, 7, 1,
    }
    t.env.server._object_pos_tbl[4] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        8, 9, 10, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(1)
    assertEqual(nil, spd)
    assertEqual(6, alt)
    spd, alt = tracker:getPlayerSpdAlt(3)
    assertEqual(nil, spd)
    assertEqual(9, alt)

    t.env.server._object_pos_tbl[2] = nil
    t.env.server._object_pos_tbl[4] = nil

    spd, alt = tracker:getPlayerSpdAlt(1)
    assertEqual(nil, spd)
    assertEqual(6, alt)
    spd, alt = tracker:getPlayerSpdAlt(3)
    assertEqual(nil, spd)
    assertEqual(9, alt)
end

function test_decl.testTrackerPlayerFail(t)
    t:reset()
    t.fn()

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(nil, alt)
end

function test_decl.testTrackerPlayerFailCache(t)
    t:reset()
    t.fn()

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(nil, alt)

    t.env.server._player_character_tbl[0] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 3, 4, 1,
    }

    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(3, alt)
end

function test_decl.testTrackerPlayerFailTrackContinue(t)
    t:reset()
    t.fn()

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(nil, alt)

    t.env.server._player_character_tbl[0] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 3, 4, 1,
    }

    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(3, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 8, 4, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(5, spd)
    assertEqual(8, alt)
end

function test_decl.testTrackerPlayerFailTrackStopHost(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[0] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 3, 4, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(3, alt)

    t.env.server._object_pos_tbl[1] = nil

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(nil, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 8, 4, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(8, alt)
end

function test_decl.testTrackerPlayerFailTrackStopGuest(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[9] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 3, 4, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(9)
    assertEqual(nil, spd)
    assertEqual(3, alt)

    t.env.server._object_pos_tbl[1] = nil

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(9)
    assertEqual(nil, spd)
    assertEqual(nil, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 8, 4, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(9)
    assertEqual(nil, spd)
    assertEqual(8, alt)
end

function test_decl.testTrackerPlayerTrackHost(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[0] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 3, 4, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(3, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        2, 8, 4, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(5, spd)
    assertEqual(8, alt)
end

function test_decl.testTrackerPlayerTrackHostExpiry(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[0] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 2, 0, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(nil, spd)
    assertEqual(2, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 3, 0, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(1, spd)
    assertEqual(3, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 5, 0, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(0)
    assertEqual(2, spd)
    assertEqual(5, alt)
end

function test_decl.testTrackerPlayerTrackGuest(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[2] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 3, 0, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(3, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    }

    for i = 2, 60 do
        tracker:tickPlayer()
        tracker:getPlayerSpdAlt(2)
    end

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 63, 0, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(2)
    assertEqual(1, spd)
    assertEqual(63, alt)
end

function test_decl.testTrackerPlayerTrackGuestExpiry(t)
    t:reset()
    t.fn()

    t.env.server._player_character_tbl[2] = 1
    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 3, 0, 1,
    }

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getPlayerSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(3, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 4, 0, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(2)
    assertEqual(1, spd)
    assertEqual(4, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    }

    for i = 3, 60 do
        tracker:tickPlayer()
        tracker:getPlayerSpdAlt(2)
    end

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 63, 0, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(2)
    assertEqual(1, spd)
    assertEqual(63, alt)

    t.env.server._object_pos_tbl[1] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 124, 0, 1,
    }

    tracker:tickPlayer()
    spd, alt = tracker:getPlayerSpdAlt(2)
    assertEqual(2, spd)
    assertEqual(124, alt)
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
    assertEqual(nil, spd)
    assertEqual(4, alt)
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
    assertEqual(nil, spd)
    assertEqual(4, alt)

    t.env.server._vehicle_pos_tbl[2] = nil

    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(4, alt)
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
    assertEqual(nil, spd)
    assertEqual(4, alt)

    t.env.server._vehicle_pos_tbl[2] = nil

    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(nil, alt)
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
    assertEqual(nil, spd)
    assertEqual(4, alt)
    spd, alt = tracker:getVehicleSpdAlt(6)
    assertEqual(nil, spd)
    assertEqual(8, alt)

    t.env.server._vehicle_pos_tbl[2] = nil
    t.env.server._vehicle_pos_tbl[6] = nil

    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(4, alt)
    spd, alt = tracker:getVehicleSpdAlt(6)
    assertEqual(nil, spd)
    assertEqual(8, alt)
end

function test_decl.testTrackerVehicleFail(t)
    t:reset()
    t.fn()

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(nil, alt)
end

function test_decl.testTrackerVehicleFailCache(t)
    t:reset()
    t.fn()

    local tracker = t.env.buildTracker()
    local spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(nil, alt)

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        3, 4, 5, 1,
    }

    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(4, alt)
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
    assertEqual(nil, spd)
    assertEqual(4, alt)

    t.env.server._vehicle_pos_tbl[2] = nil

    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(nil, alt)

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        6, 7, 8, 1,
    }

    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(7, alt)
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
    assertEqual(nil, spd)
    assertEqual(4, alt)

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        5, 8, 9, 1,
    }

    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(6, spd)
    assertEqual(8, alt)
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
    assertEqual(nil, spd)
    assertEqual(4, alt)

    t.env.server._vehicle_pos_tbl[2] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        5, 8, 9, 1,
    }

    tracker:tickVehicle()
    tracker:tickVehicle()
    spd, alt = tracker:getVehicleSpdAlt(2)
    assertEqual(nil, spd)
    assertEqual(8, alt)
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
    assertEqual(nil, spd)
    assertEqual(3, alt)
    spd, alt = tracker:getVehicleSpdAlt(4)
    assertEqual(nil, spd)
    assertEqual(5, alt)

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
    assertEqual(3, spd)
    assertEqual(6, alt)
    spd, alt = tracker:getVehicleSpdAlt(4)
    assertEqual(2, spd)
    assertEqual(7, alt)
end

function test_decl.testUIMPopupEmpty(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:flushPopup()
    assertEqual(0, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupAddAll(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(-1, 0, "name", true, "text", 0, 0)
    uim:flushPopup()
    assertEqual(0, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupAdd(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name", true, "text", 0.1, 0.2)
    uim:flushPopup()
    assertEqual({
        [string.pack("jj", 0, 1)] = {
            name = "name",
            is_show = true,
            text = "text",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(1, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupKeep(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name", true, "text", 0.1, 0.2)
    uim:flushPopup()
    assertEqual({
        [string.pack("jj", 0, 1)] = {
            name = "name",
            is_show = true,
            text = "text",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(1, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "name", true, "text", 0.1, 0.2)
    uim:flushPopup()
    assertEqual({
        [string.pack("jj", 0, 1)] = {
            name = "name",
            is_show = true,
            text = "text",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(1, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupUpdate(t)
    local tests = {
        {"name2", true, "text1", 0.1, 0.2},     -- name
        {"name1", false, "text1", 0.1, 0.2},    -- is_show
        {"name1", true, "text2", 0.1, 0.2},     -- text
        {"name1", true, "text1", 0.3, 0.2},     -- horizontal_offset
        {"name1", true, "text1", 0.1, 0.4},     -- vertical_offset
    }

    for i, tt in ipairs(tests) do
        local in_name, in_is_show, in_text, in_horizontal_offset, in_vertical_offset = table.unpack(tt)
        t:reset()
        t.fn()

        local uim = t.env.buildUIManager()

        uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
        uim:flushPopup()
        assertEqual({
            [string.pack("jj", 0, 1)] = {
                name = "name1",
                is_show = true,
                text = "text1",
                horizontal_offset = 0.1,
                vertical_offset = 0.2,
            },
        }, t.env.server._popup)
        assertEqual(1, t.env.server._popup_update_cnt)

        uim:setPopupScreen(0, 1, in_name, in_is_show, in_text, in_horizontal_offset, in_vertical_offset)
        uim:flushPopup()
        assertEqual({
            [string.pack("jj", 0, 1)] = {
                name = in_name,
                is_show = in_is_show,
                text = in_text,
                horizontal_offset = in_horizontal_offset,
                vertical_offset = in_vertical_offset,
            },
        }, t.env.server._popup)
        assertEqual(2, t.env.server._popup_update_cnt)
    end
end

function test_decl.testUIMPopupRemove(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name", true, "text", 0.1, 0.2)
    uim:flushPopup()
    assertEqual({
        [string.pack("jj", 0, 1)] = {
            name = "name",
            is_show = true,
            text = "text",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(1, t.env.server._popup_update_cnt)

    uim:flushPopup()
    assertEqual({}, t.env.server._popup)
    assertEqual(2, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupOverrideAdd(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
    uim:setPopupScreen(0, 1, "name2", false, "text2", 0.3, 0.4)
    uim:flushPopup()
    assertEqual({
        [string.pack("jj", 0, 1)] = {
            name = "name2",
            is_show = false,
            text = "text2",
            horizontal_offset = 0.3,
            vertical_offset = 0.4,
        },
    }, t.env.server._popup)
    assertEqual(1, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupOverrideKeep(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
    uim:flushPopup()
    assertEqual({
        [string.pack("jj", 0, 1)] = {
            name = "name1",
            is_show = true,
            text = "text1",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(1, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "name2", false, "text2", 0.3, 0.4)
    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
    uim:flushPopup()
    assertEqual({
        [string.pack("jj", 0, 1)] = {
            name = "name1",
            is_show = true,
            text = "text1",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(1, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupOverrideUpdate(t)
    t:reset()
    t.fn()

    local uim = t.env.buildUIManager()
    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
    uim:flushPopup()
    assertEqual({
        [string.pack("jj", 0, 1)] = {
            name = "name1",
            is_show = true,
            text = "text1",
            horizontal_offset = 0.1,
            vertical_offset = 0.2,
        },
    }, t.env.server._popup)
    assertEqual(1, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "name2", false, "text2", 0.3, 0.4)
    uim:setPopupScreen(0, 1, "name3", true, "text3", 0.5, 0.6)
    uim:flushPopup()
    assertEqual({
        [string.pack("jj", 0, 1)] = {
            name = "name3",
            is_show = true,
            text = "text3",
            horizontal_offset = 0.5,
            vertical_offset = 0.6,
        },
    }, t.env.server._popup)
    assertEqual(2, t.env.server._popup_update_cnt)
end

function test_decl.testUIMPopupKey(t)
    local tests = {
        {2, 1}, -- peer_id
        {0, 2}, -- ui_id
    }

    for i, tt in ipairs(tests) do
        local in_peer_id, in_ui_id = table.unpack(tt)
        t:reset()
        t.fn()

        local uim = t.env.buildUIManager()
        uim:setPopupScreen(0, 1, "name1", true, "text1", 0.1, 0.2)
        uim:setPopupScreen(in_peer_id, in_ui_id, "name2", false, "text2", 0.3, 0.4)
        uim:flushPopup()
        assertEqual({
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
        assertEqual(2, t.env.server._popup_update_cnt)
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
    assertEqual({
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
    assertEqual(6, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "add1", true, "text11", 0.11, 0.12)
    uim:setPopupScreen(0, 2, "add2", false, "text21", 0.21, 0.22)
    uim:setPopupScreen(0, 3, "keep1", true, "text31", 0.31, 0.32)
    uim:setPopupScreen(0, 4, "keep2", false, "text41", 0.41, 0.42)
    uim:setPopupScreen(0, 5, "update1!", false, "text52", 0.53, 0.54)
    uim:setPopupScreen(0, 6, "update2!", true, "text62", 0.63, 0.64)
    uim:flushPopup()
    assertEqual({
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
    assertEqual(12, t.env.server._popup_update_cnt)
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
    assertEqual({
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
    assertEqual(4, t.env.server._popup_update_cnt)

    uim:onPlayerJoin(0, "name", 1, false, false)
    assertEqual({
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
    assertEqual(6, t.env.server._popup_update_cnt)

    uim:setPopupScreen(0, 1, "name1", true, "text1", 0.11, 0.12)
    uim:setPopupScreen(0, 2, "name2", false, "text2", 0.21, 0.22)
    uim:setPopupScreen(1, 1, "name3", true, "text3", 0.31, 0.32)
    uim:setPopupScreen(1, 2, "name4", false, "text4", 0.41, 0.42)
    uim:flushPopup()
    assertEqual({
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
    assertEqual(8, t.env.server._popup_update_cnt)
end

function test_decl.testGetPlayerPos(t)
    local tests = {
        {
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
            {[0] = 1},
            {},
            0,
            nil,
            false,
        },
    }

    for i, tt in ipairs(tests) do
        local in_player_character_tbl, in_object_pos_tbl, in_peer_id, want_object_pos, want_is_success = table.unpack(tt)
        t:reset()
        t.fn()
        t.env.server._player_character_tbl = in_player_character_tbl
        t.env.server._object_pos_tbl = in_object_pos_tbl

        local got_object_pos, got_is_success = t.env.getPlayerPos(in_peer_id)
        assertEqual(want_object_pos, got_object_pos)
        assertEqual(want_is_success, got_is_success)
    end
end

function test_decl.testGetAddonName(t)
    local tests = {
        {0, false, {}, "???"},
        {0, true, {}, "???"},
        {
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
        local in_addon_idx, in_addon_idx_exists, in_addon_tbl, want_addon_name = table.unpack(tt)
        t:reset()
        t.env.server._addon_idx = in_addon_idx
        t.env.server._addon_idx_exists = in_addon_idx_exists
        t.env.server._addon_tbl = in_addon_tbl
        t.fn()

        local got_addon_name = t.env.getAddonName()
        assertEqual(got_addon_name, want_addon_name)
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
    assertEqual("[name]", announce_name)
end

function test_decl.testGetPlayerTable(t)
    local tests = {
        {{}, {}},
        {
            {
                [0] = {
                    id = 2,
                    name = "name0",
                    admin = false,
                    auth = false,
                    steam_id = 70000000000000000,
                },
                [1] = {
                    id = 3,
                    name = "name1",
                    admin = true,
                    auth = true,
                    steam_id = 70000000000000001,
                },
            },
            {
                [2] = {
                    id = 2,
                    name = "name0",
                    admin = false,
                    auth = false,
                    steam_id = 70000000000000000,
                },
                [3] = {
                    id = 3,
                    name = "name1",
                    admin = true,
                    auth = true,
                    steam_id = 70000000000000001,
                },
            },
        },
    }

    for i, tt in ipairs(tests) do
        local in_player_list, want_player_tbl = table.unpack(tt)
        t:reset()
        t.env.server._player_list = in_player_list
        t.fn()

        local got_player_tbl = t.env.getPlayerTable()
        assertEqual(want_player_tbl, got_player_tbl)
    end
end

function test_decl.testGetPlayerVehicle(t)
    local tests = {
        {{}, {}, 0, false},
        {
            {[1] = 2},
            {},
            0,
            false,
        },
        {
            {[1] = 2},
            {[2] = 3},
            3,
            true,
        },
    }

    for i, tt in ipairs(tests) do
        local in_player_character_tbl, in_character_vehicle_tbl, want_vehicle_id, want_is_success = table.unpack(tt)
        t:reset()
        t.env.server._player_character_tbl = in_player_character_tbl
        t.env.server._character_vehicle_tbl = in_character_vehicle_tbl
        t.fn()

        local got_vehicle_id, got_is_success = t.env.getPlayerVehicle(1)
        assertEqual(want_vehicle_id, got_vehicle_id)
        assertEqual(want_is_success, got_is_success)
    end
end

function test_decl.testRingNew(t)
    local tests = {
        {2, {buf = {}, idx = 1, len = 0, cap = 2}},
        {1, {buf = {}, idx = 1, len = 0, cap = 1}},
        {"1", nil},
        {1.1, nil},
        {0, nil},
    }

    for i, tt in ipairs(tests) do
        local in_cap, want_ring = table.unpack(tt)
        t:reset()
        t.fn()

        local got_ring = t.env.ringNew(in_cap)
        assertEqual(want_ring, got_ring)
    end
end

function test_decl.testRingClear(t)
    local tests = {
        {
            {buf = {}, idx = 1, len = 0, cap = 4},
            {buf = {}, idx = 1, len = 0, cap = 4},
        },
        {
            {buf = {"A", "B"}, idx = 1, len = 2, cap = 4},
            {buf = {}, idx = 1, len = 0, cap = 4},
        },
        {
            {buf = {"E", "B", "C", "D"}, idx = 2, len = 4, cap = 4},
            {buf = {}, idx = 1, len = 0, cap = 4},
        },
    }

    for i, tt in ipairs(tests) do
        local got_ring, want_ring = table.unpack(tt)
        t:reset()
        t.fn()

        t.env.ringClear(got_ring)
        assertEqual(want_ring, got_ring)
    end
end

function test_decl.testRingSet(t)
    local tests = {
        {
            {buf = {}, idx = 1, len = 0, cap = 1},
            "A",
            {buf = {"A"}, idx = 1, len = 1, cap = 1},
        },
        {
            {buf = {}, idx = 2, len = 0, cap = 1},
            "A",
            {buf = {"A"}, idx = 1, len = 1, cap = 1},
        },
        {
            {buf = {"A"}, idx = 1, len = 1, cap = 1},
            "B",
            {buf = {"B"}, idx = 1, len = 1, cap = 1},
        },
        {
            {buf = {"A"}, idx = 1, len = 2, cap = 1},
            "B",
            {buf = {"B"}, idx = 1, len = 1, cap = 1},
        },
        {
            {buf = {"A"}, idx = 2, len = 1, cap = 1},
            "B",
            {buf = {"B"}, idx = 1, len = 1, cap = 1},
        },
        {
            {buf = {}, idx = 1, len = 0, cap = 3},
            "A",
            {buf = {"A"}, idx = 1, len = 1, cap = 3},
        },
        {
            {buf = {"A"}, idx = 1, len = 1, cap = 3},
            "B",
            {buf = {"A", "B"}, idx = 1, len = 2, cap = 3},
        },
        {
            {buf = {"A", "B"}, idx = 1, len = 2, cap = 3},
            "C",
            {buf = {"A", "B", "C"}, idx = 1, len = 3, cap = 3},
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 3, cap = 3},
            "D",
            {buf = {"D", "B", "C"}, idx = 2, len = 3, cap = 3},
        },
        {
            {buf = {"D", "B", "C"}, idx = 2, len = 3, cap = 3},
            "E",
            {buf = {"D", "E", "C"}, idx = 3, len = 3, cap = 3},
        },
        {
            {buf = {"D", "E", "C"}, idx = 3, len = 3, cap = 3},
            "F",
            {buf = {"D", "E", "F"}, idx = 1, len = 3, cap = 3},
        },
        {
            {buf = {}, idx = 1, len = 0, cap = 2},
            nil,
            {buf = {}, idx = 1, len = 1, cap = 2},
        },
        {
            {buf = {}, idx = 1, len = 1, cap = 2},
            "A",
            {buf = {[2] = "A"}, idx = 1, len = 2, cap = 2},
        },
    }

    for i, tt in ipairs(tests) do
        local got_ring, in_item, want_ring = table.unpack(tt)
        t:reset()
        t.fn()

        t.env.ringSet(got_ring, in_item)
        assertEqual(want_ring, got_ring)
    end
end

function test_decl.testRingGet(t)
    local tests = {
        {
            {buf = {"A"}, idx = 1, len = 1, cap = 1},
            1,
            "A",
        },
        {
            {buf = {"A"}, idx = 1, len = 0, cap = 1},
            1,
            nil,
        },
        {
            {buf = {"A"}, idx = 1, len = 1, cap = 1},
            "1",
            nil,
        },
        {
            {buf = {"A"}, idx = 1, len = 1, cap = 1},
            1.1,
            nil,
        },
        {
            {buf = {"A"}, idx = 1, len = 1, cap = 1},
            0,
            nil,
        },
        {
            {buf = {"A"}, idx = 1, len = 1, cap = 1},
            2,
            nil,
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 1, cap = 3},
            0,
            nil,
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 0, cap = 3},
            1,
            nil,
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 1, cap = 3},
            1,
            "A",
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 1, cap = 3},
            2,
            nil,
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 2, cap = 3},
            2,
            "B",
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 2, cap = 3},
            3,
            nil,
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 3, cap = 3},
            3,
            "C",
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 3, cap = 3},
            4,
            nil,
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 3, cap = 3},
            1,
            "A",
        },
        {
            {buf = {"A", "B", "C"}, idx = 2, len = 3, cap = 3},
            1,
            "B",
        },
        {
            {buf = {"A", "B", "C"}, idx = 3, len = 3, cap = 3},
            1,
            "C",
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 3, cap = 3},
            2,
            "B",
        },
        {
            {buf = {"A", "B", "C"}, idx = 2, len = 3, cap = 3},
            2,
            "C",
        },
        {
            {buf = {"A", "B", "C"}, idx = 3, len = 3, cap = 3},
            2,
            "A",
        },
        {
            {buf = {"A", "B", "C"}, idx = 1, len = 3, cap = 3},
            3,
            "C",
        },
        {
            {buf = {"A", "B", "C"}, idx = 2, len = 3, cap = 3},
            3,
            "A",
        },
        {
            {buf = {"A", "B", "C"}, idx = 3, len = 3, cap = 3},
            3,
            "B",
        },
    }
end

function test_decl.testRingGetSet(t)
    t:reset()
    t.fn()

    local ring = t.env.ringNew(3)
    assertEqual(nil, t.env.ringGet(ring, 1))
    assertEqual(nil, t.env.ringGet(ring, 2))
    assertEqual(nil, t.env.ringGet(ring, 3))

    t.env.ringSet(ring, "A")
    assertEqual("A", t.env.ringGet(ring, 1))
    assertEqual(nil, t.env.ringGet(ring, 2))
    assertEqual(nil, t.env.ringGet(ring, 3))

    t.env.ringSet(ring, "B")
    assertEqual("A", t.env.ringGet(ring, 1))
    assertEqual("B", t.env.ringGet(ring, 2))
    assertEqual(nil, t.env.ringGet(ring, 3))

    t.env.ringSet(ring, "C")
    assertEqual("A", t.env.ringGet(ring, 1))
    assertEqual("B", t.env.ringGet(ring, 2))
    assertEqual("C", t.env.ringGet(ring, 3))

    t.env.ringSet(ring, "D")
    assertEqual("B", t.env.ringGet(ring, 1))
    assertEqual("C", t.env.ringGet(ring, 2))
    assertEqual("D", t.env.ringGet(ring, 3))

    t.env.ringSet(ring, "E")
    assertEqual("C", t.env.ringGet(ring, 1))
    assertEqual("D", t.env.ringGet(ring, 2))
    assertEqual("E", t.env.ringGet(ring, 3))

    t.env.ringSet(ring, "F")
    assertEqual("D", t.env.ringGet(ring, 1))
    assertEqual("E", t.env.ringGet(ring, 2))
    assertEqual("F", t.env.ringGet(ring, 3))

    t.env.ringSet(ring, "G")
    assertEqual("E", t.env.ringGet(ring, 1))
    assertEqual("F", t.env.ringGet(ring, 2))
    assertEqual("G", t.env.ringGet(ring, 3))
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
        _popup = {},
        _popup_update_cnt = 0,
        _player_list = {},
        _player_character_tbl = {},
        _character_vehicle_tbl = {},
        _object_pos_tbl = {},
        _vehicle_pos_tbl = {},
    }

    function server.getAddonIndex(name)
        return server._addon_idx, server._addon_idx_exists
    end

    function server.getAddonData(addon_index)
        return server._addon_tbl[addon_index]
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
