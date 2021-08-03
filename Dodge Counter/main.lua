DodgeCounter = DodgeCounter or {}
DodgeCounter.dodges = 0
DodgeCounter.total_hits = 0
DodgeCounter.percentage = 0
DodgeCounter.color = Color(255, 0, 170, 255) / 255
DodgeCounter.explosion = false

function DodgeCounter.Reset()
	DodgeCounter.dodges = 0
	DodgeCounter.total_hits = 0
	DodgeCounter.percentage = 0
end

function DodgeCounter.AddHit()
	DodgeCounter.total_hits = DodgeCounter.total_hits + 1
end

function DodgeCounter.RemoveHit()
	DodgeCounter.total_hits = DodgeCounter.total_hits - 1
end

function DodgeCounter.RemoveDodge()
	DodgeCounter.dodges = DodgeCounter.dodges - 1
end

function DodgeCounter.AddDodge()
	DodgeCounter.dodges = DodgeCounter.dodges + 1
	DodgeCounter.AddHit()
end

function DodgeCounter.CalculatePercentage()
	if DodgeCounter.total_hits ~= 0 then
		DodgeCounter.percentage = DodgeCounter.dodges / DodgeCounter.total_hits * 100
		DodgeCounter.percentage = math.floor(DodgeCounter.percentage)
	else
		DodgeCounter.percentage = 0
	end
end

function DodgeCounter.SetupHooks() 
	if RequiredScript == "lib/states/missionendstate" then
		Hooks:PostHook(MissionEndState,"at_enter", "post_results", function(self, ...)

			DodgeCounter.CalculatePercentage()
			managers.chat:_receive_message(managers.chat.GAME, "Dodge Counter", "You dodged a total of: " .. DodgeCounter.dodges .. " out of " .. DodgeCounter.total_hits .. " hits!", DodgeCounter.color)
			managers.chat:_receive_message(managers.chat.GAME, "Dodge Counter", "With a percentage of: " .. DodgeCounter.percentage .. "%!", DodgeCounter.color)

			DodgeCounter.Reset()
		end )
	elseif RequiredScript == "lib/managers/playermanager" then
		Hooks:PostHook(PlayerManager,"init", "register_dodge", function(self, ...)

			self:register_message(Message.OnPlayerDodge, "register_dodge", function()
				DodgeCounter.AddDodge()
				-- managers.chat:_receive_message(managers.chat.GAME, "debug", "you just dodged", DodgeCounter.color)
				-- managers.chat:_receive_message(managers.chat.GAME, "debug", "Dodges: " .. tostring(DodgeCounter.dodges), DodgeCounter.color)
				-- managers.chat:_receive_message(managers.chat.GAME, "debug", "-Hits-: " .. tostring(DodgeCounter.total_hits), DodgeCounter.color)
			end)
			self:register_message(Message.OnPlayerDamage, "register_hit", function()

				if DodgeCounter.explosion == true then
					-- managers.chat:_receive_message(managers.chat.GAME, "debug", "Your hit was removed from ff", DodgeCounter.color)
				else
					DodgeCounter.AddHit()
				end

				-- managers.chat:_receive_message(managers.chat.GAME, "debug", "callback - " .. tostring(DodgeCounter.explosion), DodgeCounter.color)
				-- managers.chat:_receive_message(managers.chat.GAME, "debug", "you just got hit", DodgeCounter.color)
				-- managers.chat:_receive_message(managers.chat.GAME, "debug", "Dodges: " .. tostring(DodgeCounter.dodges), DodgeCounter.color)
				-- managers.chat:_receive_message(managers.chat.GAME, "debug", "-Hits-: " .. tostring(DodgeCounter.total_hits), DodgeCounter.color)

			end)
			
		end )
	elseif RequiredScript == "lib/units/beings/player/playerdamage" then
		Hooks:PreHook(PlayerDamage,"damage_explosion", "detect_explosion", function(self, ...)

			DodgeCounter.explosion = true
		end )
		Hooks:PreHook(PlayerDamage,"damage_bullet", "reset_explosion", function(self, ...)

			DodgeCounter.explosion = false
		end )
		Hooks:PreHook(PlayerDamage,"_bleed_out_damage", "register hit", function(self, ...)
		
			-- managers.chat:_receive_message(managers.chat.GAME, "debug", "downhit worky", DodgeCounter.color)
			DodgeCounter.AddHit()
		end )
	-- 	Hooks:PostHook(PlayerDamage,"play_whizby", "determine_dodge", function(self, ...)

	-- 		DodgeCounter.AddDodge()
	-- 		managers.chat:_receive_message(managers.chat.GAME, "debug", "you just dodged", DodgeCounter.color)
	-- 	end )
	end
end

DodgeCounter.SetupHooks()

