require "/scripts/util.lua"
require "/scripts/interp.lua"

-- Base gun fire ability
GunFire = WeaponAbility:new()

function GunFire:init()
self.critChance = config.getParameter("critChance", 0)
self.critBonus = config.getParameter("critBonus", 0)
-- **** FR ADDITIONS
  daytime = daytimeCheck()
  underground = undergroundCheck()
  lightLevel = 1
  
  self.species = world.entitySpecies(activeItem.ownerEntityId())
  local heldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand())
  --used for checking dual-wield setups
  local opposedhandHeldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand() == "primary" and "alt" or "primary")  
  local weaponModifier = config.getParameter("critChance",0)  
  
  -- bonus add for novakids with pistols when sped up, specifically to energy and damage equations at end of file so that they still damage and consume energy at high speed
  self.energyMax = 1
-- ** END FR ADDITIONS

  self.weapon:setStance(self.stances.idle)
  self.cooldownTimer = self.fireTime

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
  
end


-- ****************************************
-- FR FUNCTIONS

function GunFire:setCritDamage(damage)
	if not self.critChance then 
		self.critChance = config.getParameter("critChance", 0)
	end
	if not self.critBonus then
		self.critBonus = config.getParameter("critBonus", 0)
	end
     -- check their equipped weapon
     -- Primary hand, or single-hand equip  
     local heldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand())
     --used for checking dual-wield setups
     local opposedhandHeldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand() == "primary" and "alt" or "primary")  
     local weaponModifier = config.getParameter("critChance",0)
     
  if heldItem then
        self.critChance = 0 + weaponModifier
  end

  self.critBonus = (status.stat("critBonus",0) + config.getParameter("critBonus",0))/2  
  self.critChance = (self.critChance  + config.getParameter("shieldCritChance",0) + config.getParameter("critChanceMultiplier",0) + status.stat("critChanceMultiplier",0) + status.stat("critChance",0)) 
  self.critRoll = math.random(200)
  
  local crit = self.critRoll <= self.critChance
  damage = crit and ((damage*2) + self.critBonus) or damage
  self.critChance = 0

  if crit then
    if heldItem then
      -- exclude mining lasers
      if not root.itemHasTag(heldItem, "mininggun") then 
        status.addEphemeralEffect("crithit", 0.3, activeItem.ownerEntityId())
      end
    end
  end

  return damage
end

function daytimeCheck()
	return world.timeOfDay() < 0.5 -- true if daytime
end

function undergroundCheck()
	return world.underground(mcontroller.position()) 
end

function getLight()
  local position = mcontroller.position()
  position[1] = math.floor(position[1])
  position[2] = math.floor(position[2])
  local lightLevel = world.lightLevel(position)
  lightLevel = math.floor(lightLevel * 100)
  return lightLevel
end
-- ***********************************************************************************************************
-- ***********************************************************************************************************


function GunFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt )
  if not self.energyMax then self.energyMax = 1 end
  self.cooldownTimer = self.cooldownTimer * self.energyMax -- FR
  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end
  if self.fireMode == (self.activatingFireMode or self.abilitySlot)
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    if self.fireType == "auto" and status.overConsumeResource("energy", self:energyPerShot()) then
      self:setState(self.auto)
    elseif self.fireType == "burst" then
      self:setState(self.burst)
    end
  end
end


function GunFire:auto()
-- ***********************************************************************************************************
-- FR SPECIALS  (Weapon speed and other such things)
-- ***********************************************************************************************************
  daytime = daytimeCheck()
  underground = undergroundCheck()
  lightLevel = getLight()
  local heldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand())
  local heldItem2 = world.entityHandItem(activeItem.ownerEntityId(), "alt")
  local opposedhandHeldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand() == "primary" and "alt" or "primary")  
  
  -- Novakid get increased pistol fire time during the daylight hours
  if self.species == "novakid" and daytime then
    if heldItem and root.itemHasTag(heldItem, "pistol") then  -- novakid fire pistols faster when the sun is out..even underground!
      self.energyMax = 1.0 - (lightLevel / 200)
    end
  else
    self.energyMax = 1 
  end  
  
  self.weapon:setStance(self.stances.fire)


  self:fireProjectile()
  self:muzzleFlash()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end
  if not self.energyMax then 
    self.energyMax = 1 
  end
  self.cooldownTimer = self.fireTime * self.energyMax  -- ** FR adds to this with energyMax
      --sb.logInfo("lightLevel = "..lightLevel)
      --sb.logInfo("energyMax = "..self.energyMax)
      --sb.logInfo("cooldownTimer = "..self.cooldownTimer)
  self:setState(self.cooldown)
end

function GunFire:burst()

  -- Novakid get increased pistol fire time during the daylight hours
  if self.species == "novakid" and daytime then
    if heldItem and root.itemHasTag(heldItem, "pistol") then  -- novakid fire pistols faster when the sun is out..even underground!
      self.energyMax = 1.0 - (lightLevel / 200)

    end
  else
    self.energyMax = 1 
  end   
  
  self.weapon:setStance(self.stances.fire)

  local shots = self.burstCount
  while shots > 0 and status.overConsumeResource("energy", self:energyPerShot()) do
    self:fireProjectile()
    self:muzzleFlash()
    shots = shots - 1

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.armRotation))

    util.wait(self.burstTime)
  end
  if not self.energyMax then self.energyMax = 1 end
  self.cooldownTimer = ((self.fireTime - self.burstTime) * self.burstCount ) * self.energyMax -- ** FR adds to this with energyMax
end

function GunFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
end

function GunFire:muzzleFlash()
  animator.setPartTag("muzzleFlash", "variant", math.random(1, 3))
  animator.setAnimationState("firing", "fire")
  animator.burstParticleEmitter("muzzleFlash")
  animator.playSound("fire")

  animator.setLightActive("muzzleFlash", true)
end

function GunFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
  params.power = self:damagePerShot()
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)

  if not projectileType then
    projectileType = self.projectileType
  end
  if type(projectileType) == "table" then
    projectileType = projectileType[math.random(#projectileType)]
  end

  local projectileId = 0
  for i = 1, (projectileCount or self.projectileCount) do
    if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
    end

    projectileId = world.spawnProjectile(
        projectileType,
        firePosition or self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(inaccuracy or self.inaccuracy),
        false,
        params
      )
  end

  return projectileId
end

function GunFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function GunFire:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function GunFire:energyPerShot()
  return self.energyUsage * self.fireTime * (self.energyUsageMultiplier or 1.0) 
end

function GunFire:damagePerShot()     
     return  GunFire:setCritDamage(self.baseDamage or (self.baseDps * self.fireTime ) * (self.baseDamageMultiplier or 1.0) * config.getParameter("damageLevelMultiplier") / self.projectileCount) 
end  


function GunFire:uninit()
end
