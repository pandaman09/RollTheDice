//CONFIGURATION//

HideChat = true
//Hide the chat when someone uses the command

WeightedChances = false
//Sets the probibility of getting a roll

ChatText = {
	[1] = "rtd",
	[2] = "roll",
	[3] = "rollthedice",
}
//All commands used to run roll the dice

Prefix = {
	[1] = "!",
	[2] = ".",
	[3] = "/",
}
//All possible chat prefixes

Rolls = {
	//["Unique Name"] = {
		//["Effect"] = function( ply ) //What happens to the player goes here
		//end,
		//["Weight"] = 30 //Weight of the action
	//}
	[1] = { //Add 5 Health
		["Effect"] = function( ply )
			local old = ply:Health()
			ply:SetHealth( ply:Health() + 5)
			ply:ChatPrint( "Your health has been set to "..ply:Health().."!" )
		end,
		["Weight"] = 30,
	},
	[2] = { //Add 5 Armor
		["Effect"] = function( ply )
			ply:SetArmor( ply:Armor() + 5)
			ply:ChatPrint( "Your Armor has been set to "..ply:Armor().."!" )
			return true
		end,
		["Weight"] = 30
	},
	[3] = { //Kill the player
		["Effect"] = function( ply )
			ply:Kill()
			ply:ChatPrint( "Your have been murdered by the dice! :(" )
			return true
		end,
		["Weight"] = 1
	},
	[4] = { //Strip weapons
		["Effect"] = function( ply )
			ply:StripWeapons()
			ply:ChatPrint( "Your weapons were stripped!" )
			return true
		end,
		["Weight"] = 1
	},
	[5] = { //Low gravity for 10 seconds
		["Effect"] = function( ply )
			ply:SetGravity( 0.5 )
			ply:ChatPrint( "You now have low gravity for 10 seconds!" )
			timer.Simple(10, function()
				if IsValid(ply) then
					ply:SetGravity(1)
					ply:ChatPrint( "Your gravity is now normal!" )
				end
			end)

		end,
		["Weight"] = 10
	},
	[6] = { //High gravity for 10 seconds
		["Effect"] = function( ply )
			ply:SetGravity( 2 )
			ply:ChatPrint( "You now have High gravity for 10 seconds!" )
			timer.Simple(10, function()
				if IsValid(ply) then
					ply:SetGravity(1)
					ply:ChatPrint( "You gravity is now normal!" )
				end
			end)
		end,
		["Weight"] = 1
	},
	[7] = { //Add spawn a few sent_ball
		["Effect"] = function( ply )
			local ball
			local succ err = xpcall( createBall(), function(err) print("Error:",err) end, ply )
			ply:ChatPrint( "Spawning a ball!" )
		end,
		["Weight"] = 30,
	},
}
//END OF CONFIGURATION//

function createBall( ply ) //DO NOT CALL WITHOUT PCALL
	if not IsValid( ply ) then return end
	local ball = ents.Create("sent_ball")
	local trace = ply:GetEyeTrace()
	ball:SetPos( trace.HitPos + trace.HitNormal * 40 )
	ball:SetBallSize( 40 )
	ball:Spawn()
	ball:Activate()
end

function rollTheDice( ply )
	if not IsValid( ply ) then return end
	local choice = math.random(#Rolls)
	if not WeightedChances then
		Rolls[choice].Effect( ply )
	else
		print("Weighted")
	end
end

function callRTD(ply, text, team)
	if not IsValid(ply) then return end
	local cprefix = string.sub( text, 1, 1 )
	local roll = false
	for k, v in pairs(ChatText) do
		local cstart = string.find(text, v, 1, false)
		cstart = cstart or 255
		if cstart == 2 then
			roll = true
		end
	end
	for k, v in pairs(Prefix) do
		if cprefix == v then
			command = true
		end
	end
	if command and roll then
		print("Rolling")
		rollTheDice( ply )
		return tobool(HideChat)
	end
end
hook.Add( "PlayerSay", "RTD_Call", callRTD )