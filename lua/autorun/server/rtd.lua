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
		//	return //true/false if the function succeeded/failed
		//end,
		//["Weight"] = 30, //Weight of the action
		//["Message"] = function( ply )
			//function called when roll is successful, should be used for calling a success message
		//end,
	//}
	[1] = { //Add 5 Health
		["Effect"] = function( ply )
			local old = ply:Health()
			ply:SetHealth( ply:Health() + 5)
			return (old < ply:Health() and true or false)
		end,
		["Weight"] = 30,
		["Message"] = function( ply )
			ply:ChatPrint( "Your health has been set to "..ply:Health().."!" )
		end,
	},
	[2] = { //Add 5 Armor
		["Effect"] = function( ply )
			ply:SetArmor( ply:Armor() + 5)
			return (old < ply:Armor() and true or false)
		end,
		["Weight"] = 30,
		["Message"] = function( ply )
			ply:ChatPrint( "Your Armor has been set to "..ply:Armor().."!" )
		end,
	},
	[3] = { //Kill the player
		["Effect"] = function( ply )
			ply:Kill()
			return not ply:Alive()
		end,
		["Weight"] = 1,
		["Message"] = function( ply )
			ply:ChatPrint( "Your have been murdered by the dice! :(" )
		end,
	},
	[4] = { //Strip weapons
		["Effect"] = function( ply )
			ply:StripWeapons()
			
			return (#ply:GetWeapons()==0)
		end,
		["Weight"] = 1,
		["Message"] = function( ply )
			ply:ChatPrint( "Your weapons were stripped!" )
		end,
	},
	[5] = { //Low gravity for 10 seconds
		["Effect"] = function( ply )
			ply.oldg = ply:GetGravity()
			ply:SetGravity( 0.5 )
			timer.Simple(10, function()
				if IsValid(ply) and ply.oldg != ply:GetGravity() then
					ply:SetGravity(1)
					ply:ChatPrint( "Your gravity is now normal!" )
				end
			end)
			return (ply:GetGravity()==0.5)
		end,
		["Weight"] = 10,
		["Message"] = function( ply )
			ply:ChatPrint( "You now have low gravity for 10 seconds!" )
		end,
	},
	[6] = { //High gravity for 10 seconds
		["Effect"] = function( ply )
			ply.oldg = ply:GetGravity()
			//ply:SetGravity( 2 )
			timer.Simple(10, function()
				if IsValid(ply) and ply.oldg != ply:GetGravity() then
					ply:SetGravity(1)
					ply:ChatPrint( "You gravity is now normal!" )
				end
			end)
			return (ply:GetGravity()==2)
		end,
		["Weight"] = 1,
		["Message"] = function( ply )
			ply:ChatPrint( "You now have High gravity for 10 seconds!" )
		end,
	},
	[7] = { //Add spawn a few sent_ball
		["Effect"] = function( ply )
			local succ = pcall( createBall( ply ))
			return succ
		end,
		["Weight"] = 30,
		["Message"] = function( ply )
			ply:ChatPrint( "Spawning a ball!" )
		end,
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
	//return IsValid(ball)
end
local fails = 0
function rollTheDice( ply )
	if fails > 2 then print("EXITING!!!") return end
	if not IsValid( ply ) then return end
	//local choice = math.random(#Rolls)
	local choice = 6
	if not WeightedChances then
		local succ = Rolls[choice].Effect( ply )
		if not succ then 
			fails = fails + 1
			print("Failed :(")
			rollTheDice()
		else
			Rolls[choice].Message( ply )
		end
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
		return not tobool(HideChat)
	end
end
hook.Add( "PlayerSay", "RTD_Call", callRTD )