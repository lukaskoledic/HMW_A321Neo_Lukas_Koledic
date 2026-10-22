FCTL.AIL.STAT = {
    L  = {
        controlled = true,
        data_avail = true,
        total_hyd_press = 0,
        failure_dataref = FAILURE_FCTL_LAIL,
        hyd_sys = {
            Hydraulic_G_press,
            Hydraulic_B_press,
        },
        computer_priority = {
            {ELAC_1_status, Hydraulic_B_press},
            {ELAC_2_status, Hydraulic_G_press},
        }
    },
    R  = {
        controlled = true,
        data_avail = true,
        total_hyd_press = 0,
        failure_dataref = FAILURE_FCTL_RAIL,
        hyd_sys = {
            Hydraulic_G_press,
            Hydraulic_B_press,
        },
        computer_priority = {
            {ELAC_1_status, Hydraulic_G_press},
            {ELAC_2_status, Hydraulic_B_press},
        }
    },
}

local function COMPUTE_AIL_STAT(fctl_table)
    for key, val in pairs(fctl_table) do
        local ACTIVE_CTL_PAIRS = 0
        local ACTIVE_COMPUTER = 0
        for i = 1, #val.computer_priority do
            --count the number of active computers--
            if get(val.computer_priority[i][1]) == 1 then
                ACTIVE_COMPUTER = ACTIVE_COMPUTER + 1
            end
            --count the number of active control pairs--
            if get(val.computer_priority[i][1]) == 1 and get(val.computer_priority[i][2]) >= 1450 then
                ACTIVE_CTL_PAIRS = ACTIVE_CTL_PAIRS + 1
            end
        end

        --decide if surface is controlled by any computer--
        if ACTIVE_CTL_PAIRS >= 1 and get(val.failure_dataref) == 0 then
            val.controlled = true
        else
            val.controlled = false
        end

        --calculate total hydraulic pressure to the surface--
        val.total_hyd_press = 0
        for i = 1, #val.hyd_sys do
            val.total_hyd_press = val.total_hyd_press + get(val.hyd_sys[i])
        end

        --see if data of the surface is available--
        if ACTIVE_COMPUTER >= 1 and (get(FCDC_1_status) == 1 or get(FCDC_2_status) == 1) then
            val.data_avail = true
        else
            val.data_avail = false
        end

        --debugging--
        if get(Print_ail_status) == 1 then
            print(key .. " AIL:")
            print("CONTROLLED:   " .. tostring(val.controlled))
            print("DATA AVIAL:   " .. tostring(val.data_avail))
            print("ACT PAIR:     " .. ACTIVE_CTL_PAIRS)
            print("ACT COMPUTER: " .. ACTIVE_COMPUTER)
            print("TOTAL PRESS:  " .. val.total_hyd_press)
        end
    end
end

function update()
    COMPUTE_AIL_STAT(FCTL.AIL.STAT)
end