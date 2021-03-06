--[[
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]--

local unicode = {}

local mattata = require('mattata')
local json = require('dkjson')

function unicode:init(configuration)
    unicode.arguments = 'unicode <text>'
    unicode.commands = mattata.commands(
        self.info.username,
        configuration.command_prefix
    ):command('unicode').table
    unicode.help = configuration.command_prefix .. 'unicode <text> - Returns the given text as a json-encoded table of Unicode (UTF-32) values.'
end

function unicode:on_message(message)
    local input = mattata.input(message.text)
    if not input then
        return mattata.send_reply(
            message,
            unicode.help
        )
    end
    input = tostring(input)
    local res = {}
    local seq = 0
    local val = nil
    for i = 1, #input do
        local char = input:byte(i)
        if seq == 0 then
            table.insert(
                res,
                val
            )
            seq = char < 0x80 and 1 or char < 0xE0 and 2 or char < 0xF0 and 3 or char < 0xF8 and 4 or error('invalid UTF-8 character sequence')
            val = bit32.band(
                char,
                2 ^ (8 - seq) - 1
            )
        else
            val = bit32.bor(
                bit32.lshift(
                    val,
                    6
                ),
                bit32.band(
                    char,
                    0x3F
                )
            )
        end
        seq = seq - 1
    end
    table.insert(
        res,
        val
    )
    return mattata.send_message(
        message.chat.id,
        '<pre>' .. json.encode(res) .. '</pre>',
        'html'
    )
end

return unicode