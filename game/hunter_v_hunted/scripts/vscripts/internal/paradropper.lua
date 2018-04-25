PARADROPPER_HEIGHT = 2200.0
PARADROPPER_HEIGHT_WHEN_CAMERA_RESETS = 800.0

PARADROPPER_MAX_VELOCITY = 450.0
PARADROPPER_FORWARD_ACCEL_PER_FRAME = 50.0
PARADROPPER_MAX_HORIZONTAL_ACCEL = 600
PARADROPPER_CONSTANT_VERTICAL_ACCEL = 200
PARADROPPER_FASTER_DROP_COEFFICIENT = 64

if HVHParadropper == nil then
	HVHParadropper = DeclareClass({}, function(self, unit)
		self.unit = unit
		self.initialize(self)
	end)
end

-- game mode setup
function HVHParadropper:Setup()
	local heroList = HeroList:GetAllHeroes()
	for _,hero in pairs(heroList) do
		local team = hero:GetTeam()
		if team == DOTA_TEAM_GOODGUYS then
		  HVHParadropper:Begin(hero)
		end
	end
end

-- called from outside
function HVHParadropper:Begin(unit)
	Timers:CreateTimer(0.25, function()
		if not unit.Paradropper then
			unit.Paradropper = HVHParadropper(unit)
		end
	end)
end

----------------------------------------
------- INITIALIZER --------------------
----------------------------------------
function HVHParadropper:initialize()
	self.active = true
	self.player = nil
	self.playerID = nil
	self.paradropDummy = nil
	self.paradropAbility = nil
	self.defaultAcquisitionRange = self.unit:GetAcquisitionRange()
	self.cameraStarted = false

	self:CheckForPlayerOwner()
	self:StartPhysics()
	self:StartCamera()
	self:ApplyModifiers()
	self:StartPhysicsUpdater()

	Timers:CreateTimer(0.1, function()
		if self.active then
			self:Think()
			return 0.1
		else
			return nil
		end
	end)
end

-- check for distance to ground less frequently than every physics update
function HVHParadropper:Think()
	local pos = self.unit:GetAbsOrigin()
	local groundHeight = GetGroundHeight(pos, self.unit)
	local distanceToGround = pos.z - groundHeight - 16.0 -- slight offset

	--print("Accel: " .. tostring(self.unit:GetPhysicsAcceleration()))
	--print("Veloc: " .. tostring(self.unit:GetPhysicsVelocity()))

	-- died en route
	if self.unit:IsNull() or not self.unit:IsAlive() then
		self:EndCamera()
		self:ParadropEnd()
	end

	-- switch player cam back to normal
	if self.cameraStarted and distanceToGround <= PARADROPPER_HEIGHT_WHEN_CAMERA_RESETS then
		self:EndCamera()
	end

	if distanceToGround <= 0 then
		self:ParadropEnd()
	end

	if HasFallenOffWorld(groundHeight, pos.z) then
		-- center of map
		self.unit:SetAbsOrigin(Vector(-3600,3400,PARADROPPER_HEIGHT_WHEN_CAMERA_RESETS+100))
	end
end

function HVHParadropper:CheckForPlayerOwner()
	if self.unit:IsHero() then
		self.player = self.unit:GetPlayerOwner()
		if self.player then
			self.playerID = self.player:GetPlayerID()
		else
			self.player = nil
			self.playerID = nil
		end
	else
		self.player = nil
		self.playerID = nil
	end
end

function HasFallenOffWorld(groundHeight, posZ)
	return (groundHeight < -16000 and posZ < PARADROPPER_HEIGHT_WHEN_CAMERA_RESETS)
end

----------------------------------------
------- PHYSICS ------------------------
----------------------------------------
function HVHParadropper:StartPhysics()
	if not IsPhysicsUnit(self.unit) then
		Physics:Unit(self.unit)
	end
	-- Clears any current command
	self.unit:Stop()

	self.unit:PreventDI(true)
	self.unit:SetAutoUnstuck(false)
	self.unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	self.unit:FollowNavMesh(false) 
	self.unit:SetFriction(0.0)

	self.unit:SetAbsOrigin(self.unit:GetAbsOrigin() + (self.unit:GetUpVector() * PARADROPPER_HEIGHT))
	self.unit:AddPhysicsAcceleration(self.unit:GetUpVector() * -1.0)
	self.unit:SetPhysicsVelocityMax(PARADROPPER_MAX_VELOCITY)

	self.paradropDummy = CreateUnitByName("npc_dummy_paradropper", self.unit:GetAbsOrigin(),
	  false, nil, nil, DOTA_TEAM_GOODGUYS)
	self.paradropAbility = self.paradropDummy:FindAbilityByName("paradropper")
end

function HVHParadropper:StartPhysicsUpdater()
	local pos = nil
	local fasterDropCoefficient = 1

	self.unit:OnPhysicsFrame(function()
		--DebugSpeed(self.unit)
		pos = self.unit:GetAbsOrigin()
		self.paradropDummy:SetOrigin(pos)

		-- update camera constantly if we're still plummeting
		if self.cameraStarted then
			CustomGameEventManager:Send_ServerToPlayer(self.player, "paradropCam_onPhysicsFrame", { height = pos.z })
		-- after the camera changes, increase speed dramatically
		else
			self.unit:SetPhysicsVelocityMax(0.0)
			fasterDropCoefficient = PARADROPPER_FASTER_DROP_COEFFICIENT
		end

		-- apply acceleration from faced direction with constant downward acceleration
		local a = self.unit:GetPhysicsAcceleration()
		local newAccel = self.unit:GetForwardVector() * PARADROPPER_FORWARD_ACCEL_PER_FRAME
		a = a + newAccel
		a.x = ClampToRange(a.x, -PARADROPPER_MAX_HORIZONTAL_ACCEL, PARADROPPER_MAX_HORIZONTAL_ACCEL) -- clamp xy accel
		a.y = ClampToRange(a.y, -PARADROPPER_MAX_HORIZONTAL_ACCEL, PARADROPPER_MAX_HORIZONTAL_ACCEL) -- clamp xy accel
		a.z = -PARADROPPER_CONSTANT_VERTICAL_ACCEL * fasterDropCoefficient -- negative because we're going down
		self.unit:SetPhysicsAcceleration(a)
	end)
end

function HVHParadropper:EndPhysics()
	self.unit:SetPhysicsAcceleration(Vector(0,0,0))
	self.unit:SetPhysicsVelocity(Vector(0,0,0))
	self.unit:SetPhysicsVelocityMax(0.0)
	self.unit:OnPhysicsFrame(nil) -- end physics updater
	self.unit:PreventDI(false)
	self.unit:SetNavCollisionType(PHYSICS_NAV_SLIDE)
	self.unit:SetAutoUnstuck(true)
	self.unit:FollowNavMesh(true)
	self.unit:SetFriction(0.05)
	FindClearSpaceForUnit(self.unit, self.unit:GetAbsOrigin(), false)
end

----------------------------------------
------- CAMERA -------------------------
----------------------------------------
function HVHParadropper:StartCamera()
	if not self.player then return end
	PlayerResource:SetCameraTarget(self.playerID, self.unit)
	CustomGameEventManager:Send_ServerToPlayer(self.player, "paradropCam_start", {})
	self.cameraStarted = true
end

function HVHParadropper:EndCamera()
	if not self.player then return end
	PlayerResource:SetCameraTarget(self.playerID, nil)
	CustomGameEventManager:Send_ServerToPlayer(self.player, "paradropCam_end", {})
	self.cameraStarted = false
end

----------------------------------------
------- MODIFIERS / ANIMATIONS----------
----------------------------------------

function HVHParadropper:ApplyModifiers()
	EmitSoundOnClient("WhooshingSound", self.player)
	self.paradropAbility:ApplyDataDrivenModifier(self.paradropDummy, self.unit, "modifier_paradropped_unit", nil)
	StartAnimation(self.unit, {duration=999, activity=ACT_DOTA_FLAIL, rate=1.0})
	self.unit:SetAcquisitionRange(0.0)
end

function HVHParadropper:RemoveModifiers()
	-- End paradrop modifiers and animation
	StopSoundOn("WhooshingSound", self.player)
	self.unit:RemoveModifierByName("modifier_paradropped_unit")
	EndAnimation(self.unit)
end

----------------------------------------
------- END / CLEANUP ------------------
----------------------------------------
function HVHParadropper:ParadropEnd()
	--GridNav:DestroyTreesAroundPoint(self.unit:GetAbsOrigin(), 200.0, true)
	local impactParticle = ParticleManager:CreateParticle( "particles/paradropimpact.vpcf", PATTACH_ABSORIGIN, self.unit )
    ParticleManager:SetParticleControl(impactParticle, 3, GetGroundPosition(self.unit:GetAbsOrigin(), self.unit))
	EmitSoundOn("Hero_Techies.Suicide", self.unit)

	self.paradropDummy:ForceKill(false)
	self.unit:SetAcquisitionRange(self.defaultAcquisitionRange)
	self:EndPhysics()
	self:RemoveModifiers()

	self.active = false
	self.unit.Paradropper = nil
end