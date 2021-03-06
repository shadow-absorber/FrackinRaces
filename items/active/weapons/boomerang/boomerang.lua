require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/activeitem/stances.lua"

function init()
self.critChance = config.getParameter("critChance", 0)
self.critBonus = config.getParameter("critBonus", 0)
  --*************************************    
  -- FU/FR ADDONS
   if self.blockCount == nil then 
     self.blockCount = 0 
     self.blockCount2 = 0
     self.blockCount3 = 0
   end

local species = world.entitySpecies(activeItem.ownerEntityId())
   


if species == "fenerox" then  
  local heldItem = world.entityHandItem(activeItem.ownerEntityId(), "primary")
  if heldItem then
     if root.itemHasTag(heldItem, "boomerang") or root.itemHasTag(heldItem, "chakram") then 
	  status.setPersistentEffects("bonusdmg", {
	    {stat = "powerMultiplier", baseMultiplier = 1.1},
	    {stat = "critChance", amount = 2 }
	    })  	
	    local bounds = mcontroller.boundBox()
     end
  end
  heldItem = world.entityHandItem(activeItem.ownerEntityId(), "alt")
  if heldItem then
     if root.itemHasTag(heldItem, "boomerang") or root.itemHasTag(heldItem, "chakram") then 
	  self.blockCount = self.blockCount + 0.10
	  self.blockCount2 = 1
	  status.setPersistentEffects("bonusdmg", {
	    {stat = "powerMultiplier", baseMultiplier = 1.1},
	    {stat = "critChance", amount = 2 }
	    })  	
	    local bounds = mcontroller.boundBox()
     end  
   end
end


if species == "lamia" then  
  local heldItem = world.entityHandItem(activeItem.ownerEntityId(), "primary")
  if heldItem then
     if root.itemHasTag(heldItem, "chakram") then 
	  self.blockCount = self.blockCount + 0.10
	  self.blockCount2 = 1.10
	  self.blockCount3 = 1.12
	  status.setPersistentEffects("bonusdmg", {
	    {stat = "powerMultiplier", amount = self.blockCount},
	    {stat = "maxHealth", baseMultiplier = self.blockCount2 },
	    {stat = "grit", baseMultiplier = self.blockCount3 }
	    })  	
	    local bounds = mcontroller.boundBox()
     end
  end
  heldItem = world.entityHandItem(activeItem.ownerEntityId(), "alt")
  if heldItem then
     if root.itemHasTag(heldItem, "chakram") then 
	  self.blockCount = self.blockCount + 0.10
	  self.blockCount2 = 1.10
	  self.blockCount3 = 1.12
	  status.setPersistentEffects("bonusdmg2", {
	    {stat = "powerMultiplier", amount = self.blockCount},
	    {stat = "maxHealth", baseMultiplier = self.blockCount2 },
	    {stat = "grit", baseMultiplier = self.blockCount3}
	    })  	
	    local bounds = mcontroller.boundBox()
     end  
   end
end


if species == "bunnykin" then  
  local heldItem = world.entityHandItem(activeItem.ownerEntityId(), "primary")
  if heldItem then
     if root.itemHasTag(heldItem, "boomerang") or root.itemHasTag(heldItem, "chakram") then  
	  status.setPersistentEffects("bonusdmg", {
	    {stat = "critChance", amount = 10},
	    {stat = "critBonus", amount = 20}
	  })  
     end
  end
  heldItem = world.entityHandItem(activeItem.ownerEntityId(), "alt")
  if heldItem then
     if root.itemHasTag(heldItem, "boomerang") or root.itemHasTag(heldItem, "chakram") then 
	  status.setPersistentEffects("bonusdmg", {
	    {stat = "critChance", amount = 10},
	    {stat = "critBonus", amount = 20}
	  })  
     end  
   end
end

if species == "elunite" then  
  local heldItem = world.entityHandItem(activeItem.ownerEntityId(), "primary")
  if heldItem then
     if root.itemHasTag(heldItem, "boomerang") or root.itemHasTag(heldItem, "chakram") then  
	  self.blockCount = self.blockCount + 0.125
	  status.setPersistentEffects("bonusdmg", {
	    {stat = "powerMultiplier", amount = self.blockCount},
	    {stat = "protection", amount = 2}
	  }) 
     end
  end
  heldItem = world.entityHandItem(activeItem.ownerEntityId(), "alt")
  if heldItem then
     if root.itemHasTag(heldItem, "boomerang") or root.itemHasTag(heldItem, "chakram") then 
	  self.blockCount = self.blockCount + 0.125
	  status.setPersistentEffects("bonusdmg", {
	    {stat = "powerMultiplier", amount = self.blockCount},
	    {stat = "protection", amount = 2}
	  }) 
     end  
   end
end
           
--************************************** 
  self.projectileType = config.getParameter("projectileType")
  self.projectileParameters = config.getParameter("projectileParameters")
  self.projectileParameters.power = self.projectileParameters.power * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1))
  initStances()

  self.cooldownTime = config.getParameter("cooldownTime", 0)
  self.cooldownTimer = self.cooldownTime

  checkProjectiles()
  if storage.projectileIds then
    setStance("throw")
  else
    setStance("idle")
  end

end



  -- *******************************************************
  -- FU Crit Damage Script

function setCritDamageBoomerang(damage)
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
  self.critChance = (self.critChance  + config.getParameter("critChanceMultiplier",0) + status.stat("critChanceMultiplier",0) + status.stat("critChance",0)) 
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
  -- *******************************************************



function update(dt, fireMode, shiftHeld)
  updateStance(dt)
  checkProjectiles()

  self.cooldownTimer = math.max(0, self.cooldownTimer - dt)

  if self.stanceName == "idle" and fireMode == "primary" and self.cooldownTimer == 0 then
    self.cooldownTimer = self.cooldownTime
    setStance("windup")
  end

  if self.stanceName == "throw" then
    if not storage.projectileIds then
      setStance("catch")
    end
  end
  
  local species = world.entitySpecies(activeItem.ownerEntityId())

  updateAim()
end

function uninit()
  status.clearPersistentEffects("bonusdmg")
  status.clearPersistentEffects("bonusdmg2")
  self.blockCount = 0
end

function fire()
  if world.lineTileCollision(mcontroller.position(), firePosition()) then
    setStance("idle")
    return
  end

  local params = copy(self.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.ownerAimPosition = activeItem.ownerAimPosition()
  
  params.power = setCritDamageBoomerang(params.power)
  
        local species = world.entitySpecies(activeItem.ownerEntityId())
	if species == "floran" then  --florans use food when attacking
	    status.modifyResource("food", (status.resource("food") * -0.005) )
	end
	
	
  if self.aimDirection < 0 then params.processing = "?flipx" end
  local projectileId = world.spawnProjectile(
      self.projectileType,
      firePosition(),
      activeItem.ownerEntityId(),
      aimVector(),
      false,
      params
    )
  if projectileId then
    storage.projectileIds = {projectileId}
  end
  animator.playSound("throw")
end

function checkProjectiles()
  if storage.projectileIds then
    local newProjectileIds = {}
    for i, projectileId in ipairs(storage.projectileIds) do
      if world.entityExists(projectileId) then
        local updatedProjectileIds = world.callScriptedEntity(projectileId, "projectileIds")

        if updatedProjectileIds then
          for j, updatedProjectileId in ipairs(updatedProjectileIds) do
            table.insert(newProjectileIds, updatedProjectileId)
          end
        end
      end
    end
    storage.projectileIds = #newProjectileIds > 0 and newProjectileIds or nil
  end
end