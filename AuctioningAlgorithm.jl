function FindIndex(array::Union{Array{Float64,1},Array{Int64,1}}, value::Union{Float64,Int64})
    value_to_return = -1 #Preset return value
    for i = 1:length(array) #For length of array
        if array[i] == value #If the value is the value we're looking for
            value_to_return = i # Change value to return to index
            return value_to_return #Return index
        end
    end
    return value_to_return #Otherwise return -1
end

function GetBestOption(agent_number::Int64 , matrix::Vector{Vector{Float64}}, costs::Vector{Vector{Float64}})
    diff_list = Float64[] #Array that stores the delta values between the specified agents' values for the list of objects and their actual costs
    highest_val = Float64 #Float value for the highest delta value in the diff_list
    ind_highest_val = Int #Index of the above value
    second_highest_val = Float64 #Float value for the second-highest delta value in the diff_list
    ind_second_highest_val = Int #Index of the above value

    for i = 1:length(costs) #For i in range 1 to length of costs array
        push!(diff_list, matrix[agent_number][i] - costs[i][2]) #Append/Push into the diff_list the delta value between the agents value for object i, and object i's cost
    end

    highest_val = maximum(diff_list) #Find the highest delta value in the list
    ind_highest_val = FindIndex(diff_list,highest_val) #Find first instance of value and return index
    diff_list[ind_highest_val] = -1000000000.0 #Change the highest value in the list to something greatly negative to now find the second highest value
    second_highest_val = maximum(diff_list) #Find the (second) highest value in the list now
    ind_second_highest_val = FindIndex(diff_list,second_highest_val) #Find first instance of value and return index

    return highest_val,ind_highest_val,second_highest_val,ind_second_highest_val
end


function CheckHappiness(agent_matrix::Vector{Vector{Int64}},payoff_matrix::Vector{Vector{Float64}}, cost_list::Vector{Vector{Float64}})
    for i = 1:length(agent_matrix) #For i in range 1 to number of agents
        if agent_matrix[i][3] == 0 #If the agent is unhappy then
            high,ind_high,sec_high,sec_ind_high = GetBestOption(i,payoff_matrix,cost_list) #Check to see what their best option is
            if ind_high == agent_matrix[i][2] #If their best option is what they're currently matched with
                agent_matrix[i][3] = 1 #Change the agent from unhappy to happy
            end
        end
    end
    return agent_matrix
end

function FindIndexOfValue(agent_matrix::Vector{Vector{Int64}},value::Union{Float64,Int64})
    l = Int64[] #Initialize array of 64-bit integers
    for i = 1:length(agent_matrix) #For i in range 1 to length of the agent matrix
        push!(l,agent_matrix[i][2]) #Append/Push the assignment values for each agent
    end
    return FindIndex(l,value) #Return the index of the assigned value
end



function SophisticatedAuction(epsilon::Float64, agents::Vector{Vector{Int64}}, payoff_matrix::Vector{Vector{Float64}}, cost_list::Vector{Vector{Float64}})
    not_finished = true #Is everyone happy or not
    while not_finished == true #While not everyone is happy
        overall_sum = 0 #Overall sum of whether all agents are happy. When overall_sum = length of agents matrix, then all agents are happy. Since 1 = agent is happy and 0 =  agent is unhappy
        for i = 1:length(agents) #For each agent
            overall_sum += agents[i][3] #Sum up the happiness
        end
        if overall_sum != length(agents) #If overall_sum != length of agents matrix, then all agents are not happy
            for n = 1:length(agents) #For each agent
                CheckHappiness(agents,payoff_matrix,cost_list) #Check happiness
                if agents[n][3] == 0 #If an agent is unhappy
                    high,ind_high,sec_high,sec_ind_high = GetBestOption(n,payoff_matrix,cost_list) #Find which offer is best for him
                    switch_index = FindIndexOfValue(agents,ind_high) #Find which agent currently has this offer
                    agents[switch_index][3] = 0 #Turn the agent that previously had that offer now to unhappy
                    agents[n][3] = 1 #Turn current agent to happy
                    agents[switch_index][2] = agents[n][2] #Switch their assigned offers
                    agents[n][2] = ind_high #Switch their assigned offers
                    cost_list[ind_high][2] = cost_list[ind_high][2] + abs(((payoff_matrix[n][ind_high] - cost_list[ind_high][2]) - (payoff_matrix[n][sec_ind_high] - cost_list[sec_ind_high][2]))) + epsilon #Update the bid of the offer
                end
            end

        else
            not_finished = false #Everyone is happy, can stop running loop
        end

    end

    for agent = 1:length(agents) #For each agent
        println("Agent #$(agents[agent][1]) will pay \$$(round(cost_list[agents[agent][2]][2],digits = 2)) to Agent #$(cost_list[agents[agent][2]][1]). They were originally willing to pay \$$(payoff_matrix[agent][agents[agent][2]])") #Print the algorithm results
    end


end


### Test EXAMPLE ###

epsilon = 0.01 #Epsilon value for each offer
agents = [[12,3,0],[23,2,0],[43,1,0]] #[Agent ID, Which Offer they're taking, If they're happy or not]
payoff_matrix = [[6.0,7.0,6.0],[12.0,23.0,10.0],[19.0,23.0,21.0]] #[Each agents' value of each offer]
cost_list = [[22,3.25],[16,2.12],[94,4.74]] #[Offer ID, Offer price]

SophisticatedAuction(epsilon,agents,payoff_matrix,cost_list)
