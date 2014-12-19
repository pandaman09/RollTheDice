//CONFIGURATION//

HideChat = true
//Hide the chat when someone uses the command

WeightedChances = false
//Sets the probibility of getting a roll

RollTime = 10
//Time until a player can roll again in seconds

MaxRand = 50
//Maximum random amount of health or armor that can be given

ForceRank = false
ForceTeam = false
//Force player to part of a specific group/team to use the command

AllowedRanks = {
	"guest",
	"member",
	"admin",
	"super-admin",
}
// Rank allowed to use the command. CASE SENSETIVE!

AllowedTeams = {
	"runners",
	"murderer",
}
// Team name or number that can use the command. CASE SENSETIVE!

ChatText = {
	"rtd",
	"roll",
	"rollthedice",
}
//All commands used to run roll the dice

Prefix = {
	"!",
	".",
	"/",
}
//All possible chat prefixes

Rolls = {
	//["Unique Name"] = {
		//["Effect"] = function( ply )
			//What happens to the player goes here
			//return    //true/false if the function succeeded/failed
		//end,
		//["Weight"] = 30, //Weight of the action
		//["Message"] = function( ply )
			//function called when roll is successful, should be used for calling a success message
		//end,
	//}
	{ //Add random Health
		["Effect"] = function( ply )
			local old = ply:Health()
			ply:SetHealth( ply:Health() + math.random(MaxRand) )
			return ( old < ply:Health() and true or false )
		end,
		["Weight"] = 30,
		["Message"] = function( ply )
			ply:ChatPrint( "Your health has been set to "..ply:Health().."!" )
		end,
	},
	{ //Add random Armor
		["Effect"] = function( ply )
			local old = ply:Armor()
			ply:SetArmor( ply:Armor() + math.random(MaxRand) )
			return ( old < ply:Armor() and true or false )
		end,
		["Weight"] = 30,
		["Message"] = function( ply )
			ply:ChatPrint( "Your Armor has been set to "..ply:Armor().."!" )
		end,
	},
	{ //Kill the player
		["Effect"] = function( ply )
			ply:Kill()
			return not ply:Alive()
		end,
		["Weight"] = 1,
		["Message"] = function( ply )
			ply:ChatPrint( "Your have been murdered by the dice! :(" )
		end,
	},
	{ //Strip weapons
		["Effect"] = function( ply )
			ply.oldw = ply:GetWeapons()
			local old = ply:GetWeapons()
			ply:StripWeapons()
			timer.Simple( 10, function()
				if IsValid( ply ) and ply.oldw == old then
					for k,v in pairs(old) do
						if not ply:HasWeapon( v ) then
							ply:Give( v )
						end
					end
					ply:ChatPrint( "Your weapons have been returned" )
				end
			end )
			return ( #ply:GetWeapons()==0 )
		end,
		["Weight"] = 1,
		["Message"] = function( ply )
			ply:ChatPrint( "Your weapons were stripped for 10 seconds!" )
		end,
	},
	{ //Low gravity for 10 seconds
		["Effect"] = function( ply )
			ply.oldg = ply:GetGravity()
			ply:SetGravity( 0.5 )
			timer.Simple( 10, function()
				if IsValid(ply) and ply.oldg != ply:GetGravity() then
					ply:SetGravity(1)
					ply:ChatPrint( "Your gravity is now normal!" )
				end
			end )
			return ( ply:GetGravity()==0.5 )
		end,
		["Weight"] = 10,
		["Message"] = function( ply )
			ply:ChatPrint( "You now have low gravity for 10 seconds!" )
		end,
	},
	{ //High gravity for 10 seconds
		["Effect"] = function( ply )
			ply.oldg = ply:GetGravity()
			//ply:SetGravity( 2 )
			timer.Simple( 10, function()
				if IsValid(ply) and ply.oldg != ply:GetGravity() then
					ply:SetGravity(1)
					ply:ChatPrint( "You gravity is now normal!" )
				end
			end )
			return (ply:GetGravity()==2)
		end,
		["Weight"] = 1,
		["Message"] = function( ply )
			ply:ChatPrint( "You now have High gravity for 10 seconds!" )
		end,
	},
	{ //Add spawn a sent_ball
		["Effect"] = function( ply )
			local succ = pcall( function() 
				local ball = ents.Create( "sent_ball" )
				ball:SetPos( ply:EyePos() + ply:EyeAngles():Forward() * 50 )
				ball:SetBallSize( 40 )
				ball:Spawn()
				ball:Activate()
				return IsValid( ball )
			end)
			return succ
		end,
		["Weight"] = 30,
		["Message"] = function( ply )
			ply:ChatPrint( "Spawning a ball!" )
		end,
	},
	{ //Set on fire
		["Effect"] = function( ply )
			ply:Ignite( 5 )
			return ply:IsOnFire()
		end,
		["Weight"] = 30,
		["Message"] = function( ply )
			ply:ChatPrint( "You have been set a blaze for 5 seconds" )
		end,
	},
}
//END OF CONFIGURATION//

local fails = 0
function rollTheDice( ply )
	if fails > 2 then fails = 0 return end
	if not IsValid( ply ) then return end
	ply.lastRoll = ply.lastRoll or 1
	if ( ply.lastRoll + RollTime ) > CurTime() then 
		local nexttime = math.Round( ( ply.lastRoll + RollTime )-CurTime() )
		ply:ChatPrint("You cannot roll the dice for another ".. nexttime .. " seconds!")
		return
	end
	//local choice = math.random( #Rolls )
	local choice = 8
	if not WeightedChances then
		local succ = Rolls[choice].Effect( ply )
		if not succ then 
			fails = fails + 1
			print( "Failed :(" )
			rollTheDice( ply )
		else
			Rolls[choice].Message( ply )
		end
	else
		MsgN("Woah there, you can't use weighted chances yet. Defaulting to random selection")
		WeightedChances = false
	end
	ply.lastRoll = CurTime()
end

function callRTD(ply, text, team)
	if not IsValid( ply ) then return end
	local cprefix = string.sub( text, 1, 1 )
	local roll = false
	local command = false
	local rankallow = false
	local teamallow = false
	for k, v in pairs( ChatText ) do
		local cstart = string.find( text, v, 1, false )
		cstart = cstart or 255
		if cstart == 2 then
			roll = true
		end
	end
	for k, v in pairs( Prefix ) do
		if cprefix == v then
			command = true
		end
	end
	if ForceRank then
		for k, v in pairs( AllowedRanks ) do
			if ply:IsUserGroup( v ) or ply:CheckGroup( v ) or ply:GetNWString( "UserGroup" ) == v or ply:GetRank() == v then
			//Default group check, ULib group check, ULX/Assmod group check, Exsto group check, no user group
				rankallow = true
			end
		end
	else
		rankallow = true
	end
	if ForceTeam then
		for k, v in pairs( AllowedTeams ) do
			if team.GetName( ply:Team() ) == v or ply:Team() == v then
				teamallow = true
			end
		end
	else
		teamallow = true
	end
	if command and roll and rankallow and teamallow then
		print( "Rolling" )
		rollTheDice( ply )
		return not tobool( HideChat )
	end
end
hook.Add( "PlayerSay", "RTD_Call", callRTD )