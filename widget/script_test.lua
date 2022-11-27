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

local function buildMockServer()
    local server = {
        _addon_idx = 0,
        _addon_idx_exists = false,
        _addon_tbl = {},
        _popup = {},
        _popup_update_cnt = 0,
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
