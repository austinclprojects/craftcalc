_addon.commands = {'craftcalc', 'cc'}

function split(msg, match)
    if msg == nil then return '' end
    local length = msg:len()
    local splitarr = {}
    local u = 1
    while u <= length do
        local nextanch = msg:find(match,u)
        if nextanch ~= nil then
            splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
            if nextanch~=length then
                u = nextanch+match:len()
            else
                u = length
            end
        else
            splitarr[#splitarr+1] = msg:sub(u,length)
            u = length+1
        end
    end
    return splitarr
end

function length(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function set_initial_odds(gap)
    if gap < 0 then
        return 0
    elseif gap < 11 then
        return 0.02
    elseif gap < 31 then
        return 0.0825
    elseif gap < 51 then
        return 0.25
    elseif gap < 81 then
        return 0.50
    else
        return 0.60
    end
end

function moon_skill_mod(phase) 
    return (-1 + phase/50)
end

function moon_hq_mod(phase) 
    return -((phase-50)/150)
end



function day_skill_mod(affinity)
    if affinity ==  'strong' then
        return 1
    elseif affinity == 'weak' then
        return -1
    else
        return  0 
    end
end

function day_hq_mod(affinity)
    if affinity ==  'strong' then
        return -1/3
    elseif affinity == 'weak' then
        return 1/3
    else
        return 0 
    end
end

function get_odds(phase,affinity,skill,difficulty)
    day_skill = day_skill_mod(affinity)
    day_hq =  day_hq_mod(affinity)
    moon_skill = moon_skill_mod(phase)
    moon_hq = moon_hq_mod(phase)
    skill = skill + day_skill + moon_skill + 0.5
    odds = set_initial_odds(skill-difficulty)
    odds = odds * (1+day_hq+moon_hq)
    return odds
end

function best_case(skill,difficulty)  
    phases = {0,25,50,75,100}
    affinities = {'weak','strong','neutral'}
    local best_odd = 0
    for phase_key, phase_value in pairs(phases) do
        for affinity_key, affinity_value in pairs(affinities) do
            _ = get_odds(phase_value,affinity_value,skill,difficulty)
            if _ > best_odd then
                best_odd = _
            end
        end    
    end
    local best = {}
    for phase_key, phase_value in pairs(phases) do
        for affinity_key, affinity_value in pairs(affinities) do
            _ = get_odds(phase_value,affinity_value,skill,difficulty)
            if _ == best_odd and _ ~= 0 then
                table.insert(best,_)
                table.insert(best,phase_value)
                table.insert(best,affinity_value)                
            end
        end    
    end

    return best
end

    

windower.register_event('addon command', function (...)
	local command = table.concat({...}, ' ')
	arr = split(command, ' ')
	best_outcome = best_case(tonumber(arr[1]),tonumber(arr[2]))
    combos = math.floor(length(best_outcome)/3)
    if combos == 0 then
        windower.add_to_chat(55,'No HQ Chance')
    else
        for i = 1,combos do
            windower.add_to_chat(55, 'HQ Odds: '..tonumber(string.format("%.4f", best_outcome[i*3-2]))..' Moon Phase: '..best_outcome[i*3-1]..' Day Affinity: '..best_outcome[i*3])
        end
    windower.add_to_chat(55, 'ALWAYS STAND IN NQ DIRECTION FOR .5 SKILL')
    end
        end )


