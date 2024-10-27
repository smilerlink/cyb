local M = {}

local function index_of(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

local function create_state(players)
    return {
        players = players or {}
    }
end

local function get_player_by_id(state, player)
    for _, p in ipairs(state.players) do
        if p.id == player then return p end
    end

    return false
end

local function check_winner(state)
    if #state.players == 1 then
        state.winner = state.players[1]
    end
end

function M.new_game()
    return create_state()
end

function M.rematch(state)
    assert(state)
    assert(#state.players >= 2, 'Game must have at least two players')
    return create_state(state.players)
end

function M.add_player(state, player_id)
    assert(state)
    assert(player_id)
    if #state.players == 1 then
        assert(state.players[1] ~= player_id, 'The player has already been added to the match')
    end
    state.players[#state.players + 1] = {
        id = player_id,
        x = 0,
        y = 0,
        hp = 100
    }
    return state
end

function M.player_count(state)
    assert(state)
    return #state.players
end

function M.player_move(state, player, x, y)
    assert(state)
    assert(player)
    assert(x)
    assert(y)
    local p = get_player_by_id(state, player)
    p.x = x
    p.y = y
    return state
end

function M.player_hit(state, player, damage)
    assert(state)
    assert(damage)
    local p = get_player_by_id(state, player)
    p.hp = p.hp - damage
    if p.hp <= 0 then
        local i = index_of(state.players, player)
        if i then state.players[i] = nil end
    end
    check_winner(state)
    return state
end

return M

