--[[
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]--

local binary = {}

local mattata = require('mattata')

function binary:init(configuration)
    binary.arguments = 'binary <number>'
    binary.commands = mattata.commands(
        self.info.username,
        configuration.command_prefix
    ):command('binary'):command('bin').table
    binary.help = configuration.command_prefix .. 'binary <number> - Converts the given number to binary. Alias: ' .. configuration.command_prefix .. 'bin.'
end

function binary:on_message(message, configuration)
    local input = mattata.input(message.text)
    if not input then
        return mattata.send_reply(
            message,
            binary.help
        )
    elseif tonumber(input) == nil then
        return mattata.send_reply(
            message,
            'You must enter a numerical value!'
        )
    end
    local result = ''
    local split, integer, fraction
    repeat
        split = tonumber(input) / 2
        integer, fraction = math.modf(split)
        input = integer
        result = math.ceil(fraction) .. result
    until input == 0
    local str = result:format('s')
    local zero = 16 - str:len()
    return mattata.send_message(
        message.chat.id,
        '<pre>' .. string.rep('0', zero) .. str .. '</pre>',
        'html'
    )
end

return binary