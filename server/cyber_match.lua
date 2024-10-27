local cyber = require 'cyber_state'
local nk = require 'nakama'

local M = {}

local OP_CODE_MOVE = 1
local OP_CODE_STATE = 2
local OP_CODE_HIT = 3

local function pprint(t)
    if type(t) ~= 'table' then
        nk.logger_info(tostring(t))
    else
        for k,v in pairs(t) do
            nk.logger_info(string.format('%s = %s', tostring(k), tostring(v)))
        end
    end
end

local function broadcast_gamestate_to_recipient(dispatcher, gamestate, recipient)
    nk.logger_info('broadcast_gamestate')
    local message = {
        state = gamestate
    }
    local encoded_message = nk.json_encode(message)
    dispatcher.broadcast_message(OP_CODE_STATE, encoded_message, { recipient })
end

local function broadcast_gamestate(dispatcher, gamestate)
    for _, p in ipairs(gamestate.players) do
        broadcast_gamestate_to_recipient(dispatcher, gamestate, p.id)
    end
end

function M.match_init(context, setupstate)
    nk.logger_info('match_init')
    local gamestate = cyber.new_game()
    local tickrate = 1 -- per sec
    local label = ""
    return gamestate, tickrate, label
end

function M.match_join_attempt(context, dispatcher, tick, gamestate, presence, metadata)
    nk.logger_info('match_join_attempt')
    local acceptuser = true
    return gamestate, acceptuser
end

function M.match_join(context, dispatcher, tick, gamestate, presences)
    nk.logger_info('match_join')
    for _, presence in ipairs(presences) do
        cyber.add_player(gamestate, presence)
    end
    if cyber.player_count(gamestate) == 2 then
        broadcast_gamestate(dispatcher, gamestate)
    end
    return gamestate
end

function M.match_leave(context, dispatcher, tick, gamestate, presences)
    nk.logger_info('match_leave')
    -- end match if someone leaves
    return nil
end

function M.match_loop(context, dispatcher, tick, gamestate, messages)
    nk.logger_info('match_loop')

    for _, message in ipairs(messages) do
        nk.logger_info(string.format('Received %s from %s', message.data, message.sender.username))
        pprint(message)

        if message.op_code == OP_CODE_MOVE then
            local decoded = nk.json_decode(message.data)
            gamestate = cyber.player_move(gamestate, decoded.player, decoded.x, decoded.y)
        elseif message.op_code == OP_CODE_HIT then
            local decoded = nk.json_decode(message.data)
            gamestate = cyber.player_hit(gamestate, decoded.damage)
            if gamestate.winner or gamestate.draw then
                gamestate.rematch_countdown = 10
            end
        end
    end
    if gamestate.rematch_countdown then
        gamestate.rematch_countdown = gamestate.rematch_countdown - 1
        if gamestate.rematch_countdown == 0 then
            gamestate = cyber.rematch(gamestate)
        end
    end
    
    broadcast_gamestate(dispatcher, gamestate)
    
    return gamestate
end

function M.match_signal(context, dispatcher, tick, state, data)
    return state, 'signal received: ' .. data
end

function M.match_terminate(context, dispatcher, tick, gamestate, grace_seconds)
    nk.logger_info('match_terminate')
    local message = 'Server shutting down in ' .. grace_seconds .. ' seconds'
    dispatcher.broadcast_message(OP_CODE_STATE, message)
    return nil
end

return M

