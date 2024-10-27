local nk = require 'nakama'

local function log(fmt, ...)
    nk.logger_info(string.format(fmt, ...))
end

-- callback when two players have been matched
-- create a match with match logic from cyber_match.lua
-- return match id
local function makematch(context, matched_users)
    log('Creating Cyber match')

    -- print matched users
    for _, user in ipairs(matched_users) do
        local presence = user.presence
        log('Matched user \'%s\' named \'%s\'', presence.user_id, presence.username)
    end

    local modulename = 'cyber_match'
    local setupstate = { invited = matched_users }
    local matchid = nk.match_create(modulename, setupstate)

    return matchid
end

nk.run_once(function(ctx)
    local now = os.time()
    log('Backend loaded at %d', now)
    nk.register_matchmaker_matched(makematch)
end)
