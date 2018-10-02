function T(s, a, sp)
    
    # if we feed the baby, probability that it becomes not hungry is 1.0
    if a == :feed
        if sp == :not_hungry
            return 1.0
        else
            return 0.0
        end
    
    # if we don't feed baby...
    else
        # baby remains hungry if unfed
        if s == :hungry
            if sp == :hungry
                return 1.0
            else
                return 0.0
            end
        else
            # 10% chance of baby becoming hungry given it is not hungry and unfed
            if sp == :hungry
                return 0.1
            else
                return 0.9
            end
        end
    end
                
end

function O(a, sp, o)
    if sp == :hungry
        p_cry = 0.8
    else
        p_cry = 0.1
    end
    
    if o == :cry
        return p_cry
    else
        return 1.0 - p_cry
    end 
end

function update_belief(b, a, o)
    bp = Dict()
    for sp in [:hungry, :not_hungry]
        sum_over_s = 0.0
        for s in [:hungry, :not_hungry]
            sum_over_s += T(s, a, sp) * b[s]
        end
        bp[sp] = O(a, sp, o) * sum_over_s
    end

    # normalize so that probabilities sum to 1
    bp_sum = bp[:hungry] + bp[:not_hungry]
    bp[:hungry] = bp[:hungry] / bp_sum
    bp[:not_hungry] = bp[:not_hungry] / bp_sum

    return bp
end
