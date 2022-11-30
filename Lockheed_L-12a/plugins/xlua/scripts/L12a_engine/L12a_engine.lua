------------------------------------------------------------
-- XLUA script to regulate engine manifold pressure and BHP
-- in Lockheed L-12A by Steve Baugh
--
-- Bumps up MP and power at altitude
-- Works with power setting to 1.13 (113%) in ACF file
------------------------------------------------------------

----------------------------------- SET UP DATAREFS -----------------------------------
simDR_current_mp01 = find_dataref("sim/flightmodel/engine/ENGN_MPR[0]")
simDR_current_mp02 = find_dataref("sim/flightmodel/engine/ENGN_MPR[1]")

simDR_acf_mp_max = find_dataref("sim/aircraft/engine/acf_mpmax")
simDR_acf_power_max = find_dataref("sim/aircraft/engine/acf_throtmax_FWD")
	-- 1 = 100%, 1.1 = 110% etc, 1.13 = 113% [current]

local original_power_max = 0.0		-- mirrors simDR_acf_power_max in acf
-- local L12a_mp_limit = 0.0			-- mirrors MP limit in acf + tweek up


--------------------------------- FUNCTIONS TO CALL BACK ---------------------------------

-- NONE

------------------------------- CREATE COMMANDS -------------------------------

-- NONE

--------------------------------- DO THIS EACH FLIGHT START ---------------------------------

function flight_start()

	original_power_max = simDR_acf_power_max
--	L12a_mp_limit = (simDR_acf_mp_max + 0.1) -- tweeks MP power up 0.1"

end

-- REGULAR RUNTIME
function after_physics()
	
	if simDR_current_mp01 > simDR_acf_mp_max
		or simDR_current_mp02 > simDR_acf_mp_max then 	-- LIMIT power if over MP limit in acf"
		simDR_acf_power_max = 1.0						-- this drops power available to standard 100%
		
		if simDR_current_mp01 > simDR_acf_mp_max then	-- Either or both engines MP is over max
			simDR_current_mp01 = simDR_acf_mp_max		-- 	find out which one and reduce to max
		end
		if simDR_current_mp02 > simDR_acf_mp_max then	-- same as for engine 01
			simDR_current_mp02 = simDR_acf_mp_max
		end
		
	else
		simDR_acf_power_max = original_power_max		-- otherwise go back to acf setting which is higher than 100%
	end
	
end
