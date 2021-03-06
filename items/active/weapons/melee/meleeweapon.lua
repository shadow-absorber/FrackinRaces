require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

function init()
self.critChance = config.getParameter("critChance", 0)
self.critBonus = config.getParameter("critBonus", 0)
  animator.setGlobalTag("paletteSwaps", config.getParameter("paletteSwaps", ""))
  animator.setGlobalTag("directives", "")
  animator.setGlobalTag("bladeDirectives", "")

  self.weapon = Weapon:new()

  self.weapon:addTransformationGroup("weapon", {0,0}, util.toRadians(config.getParameter("baseWeaponRotation", 0)))
  self.weapon:addTransformationGroup("swoosh", {0,0}, math.pi/2)

  local primaryAbility = getPrimaryAbility()
  self.weapon:addAbility(primaryAbility)

  local secondaryAttack = getAltAbility()
  if secondaryAttack then
    self.weapon:addAbility(secondaryAttack)
  end



-- **************************************************
-- FR EFFECTS
-- **************************************************
     local species = world.entitySpecies(activeItem.ownerEntityId())
     -- Primary hand, or single-hand equip  
     local heldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand())
     --used for checking dual-wield setups
     local opposedhandHeldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand() == "primary" and "alt" or "primary")
     -- if we want more control over each hand...
     local heldItem1 = world.entityHandItem(activeItem.ownerEntityId(), "primary")
     local heldItem2 = world.entityHandItem(activeItem.ownerEntityId(), "alt")
  
     local randValue = math.random(100)  -- chance for projectile  
     
 	if status.isResource("energy") then
	  self.energyValue = status.resource("energy")  --check our Food level
	else
	  self.energyValue = 80
	end    
	if status.isResource("food") then
	  self.foodValue = status.resource("food")  --check our Food level
	else
	  self.foodValue = 60
	end
-- for mcontroller application within init
--mcontroller.setAutoClearControls(false)

   if self.meleeCount == nil then 
     self.meleeCount = 0
   end
   if self.meleeCount2 == nil then 
     self.meleeCount2 = 0
   end       
   	
if species == "hylotl" and heldItem then  --hylotls have a lot of particular sword skills, each conveying minor bonuses

     if root.itemHasTag(heldItem, "shortsword") or root.itemHasTag(heldItem, "broadsword") or root.itemHasTag(heldItem, "katana") then 
	self.healthRatio = (status.resource("health") / status.stat("maxHealth")) * 100
	if heldItem and self.healthRatio >= 75 then  
		  status.setPersistentEffects("combobonusdmg", {
		    {stat = "critChance", amount = 2}
		  }) 
	end  
     end 
     if root.itemHasTag(heldItem, "shortsword") then 
       status.setPersistentEffects("weaponbonusdualwield", {
         {stat = "powerMultiplier", baseMultiplier = 1.06}
       })   
     end  
     if root.itemHasTag(heldItem, "katana") and not opposedhandHeldItem then 
       status.setPersistentEffects("weaponbonusdualwield", {
         {stat = "powerMultiplier", baseMultiplier = 1.10},
         {stat = "critBonus", amount = 5}  
       })   
     end      
     if root.itemHasTag(heldItem, "katana") and opposedhandHeldItem and root.itemHasTag(opposedhandHeldItem, "dagger") then 
       status.setPersistentEffects("weaponbonusdualwield", {
         {stat = "protection", amount = 4},
         {stat = "critChance", amount = 1}  
       })   
     end     
     if root.itemHasTag(heldItem, "quarterstaff") then 
       status.setPersistentEffects("weaponbonusdmg", {
         {stat = "protection", amount = 6}  
       })   
     end      
end
       
if species == "human" then  -- Humans do more damage with shortswords and resist knockback
  if heldItem then
     if root.itemHasTag(heldItem, "shortsword") then 
	  status.setPersistentEffects("weaponbonusdmg", {
	    {stat = "powerMultiplier", baseMultiplier = 1.12},
	    {stat = "grit", amount = 0.20}
	  })   
     end
  end
end

if species == "floran" then   -- floran get spear bonus
  if heldItem then
     if root.itemHasTag(heldItem, "spear") then 
	  self.meleeCount = self.meleeCount + 0.08
	  status.setPersistentEffects("weaponbonusdmg", {
	    {stat = "powerMultiplier", amount = self.meleeCount}
	  })  
     end
     if root.itemHasTag(heldItem, "dagger") then 
	  self.meleeCount = self.meleeCount + 0.08
	  status.setPersistentEffects("weaponbonusdmg", {
	    {stat = "powerMultiplier", amount = self.meleeCount}
	  })  
     end     
  end
end

if species == "wasphive" then   --wasps daggers do 25% more damage
  if heldItem then
     if root.itemHasTag(heldItem, "dagger") then 
	  self.meleeCount = self.meleeCount + 0.25
	  status.setPersistentEffects("weaponbonusdmg", {{stat = "powerMultiplier", amount = self.meleeCount}})  
     end
  end
end

if species == "apex" then   --apex love axes and hammers
  if heldItem then
     if root.itemHasTag(heldItem, "hammer") then 
	status.setPersistentEffects("weaponbonusdmg", {
	  {stat = "powerMultiplier", baseMultiplier = 1.1}
	})    	
     end
  end
end  

if species == "elunite" then   --elunite get defense bonuses with swords
  if heldItem then
     if root.itemHasTag(heldItem, "dagger") or root.itemHasTag(heldItem, "shortsword") or root.itemHasTag(heldItem, "broadsword") then 
	self.meleeCount = self.meleeCount + 2
	status.setPersistentEffects("weaponbonusdmg", {
	  {stat = "protection", amount = self.meleeCount},
	  {stat = "energyRegenPercentageRate", amount = 0.48}
	}) 
     end
  end
end  

if species == "kineptic" then  --kineptic get dmg and protection increase with quarterstaves
  if heldItem then
     if root.itemHasTag(heldItem, "quarterstaff") then 
	self.meleeCount = self.meleeCount + 3
	self.meleeCount2 = 0.15
	status.setPersistentEffects("weaponbonusdmg", {
	{stat = "protection", amount = self.meleeCount},
	{stat = "powerMultiplier", amount = self.meleeCount2}
	})  
     end
   end
end  

if species == "fenerox" then  --fenerox get dmg and protection increase with spears
  if heldItem then
     if root.itemHasTag(heldItem, "spear") then 
	status.setPersistentEffects("weaponbonusdmg", {
	{stat = "critChance", amount = 2},
	{stat = "powerMultiplier", baseMultiplier = 1.1}
	})  
     end
   end
end  

if species == "vulpes" then  --vulpes get protection when swinging blades
  if heldItem then
     if root.itemHasTag(heldItem, "dagger") or root.itemHasTag(heldItem, "shortsword") or root.itemHasTag(heldItem, "broadsword") then 
	self.meleeCount = self.meleeCount + 2
	status.setPersistentEffects("weaponbonusdmg", {{stat = "protection", amount = self.meleeCount}})   
     end
  end
end 

 if species == "sergal" then  --sergal get health and protection with spears
  if heldItem then
     if root.itemHasTag(heldItem, "spear") then 
	self.meleeCount = self.meleeCount + 2
	status.setPersistentEffects("weaponbonusdmg", {
	{stat = "protection", amount = self.meleeCount},
	{ stat = "maxHealth", baseMultiplier = 1.25 }
	})     
     end
  end
end            

if species == "orcana" and heldItem then  --orcana get health and protection with spears
     if root.itemHasTag(heldItem, "spear") then 
	status.setPersistentEffects("weaponbonusdmg", {
	{stat = "critChance", amount = 3},
	{ stat = "powerMultiplier", baseMultiplier = 1.2 }
	})        
     end
end  

 if species == "avali" and heldItem then  --orcana get health and protection with spears
     if root.itemHasTag(heldItem, "spear") then 
	status.setPersistentEffects("weaponbonusdmg", {
	  {stat = "critChance", amount = 2}
	})        
     end
end 

 if species == "argonian" and heldItem then  --argonian do extra damage with spears
     if root.itemHasTag(heldItem, "spear") then 
	status.setPersistentEffects("weaponbonusdmg", {
	{stat = "powerMultiplier", baseMultiplier = 1.1},
	{ stat = "maxEnergy", baseMultiplier = 1.25 }
	})        
     end
     if root.itemHasTag(heldItem, "shortspear") then 
	status.setPersistentEffects("weaponbonusdmg", {
	{stat = "powerMultiplier", baseMultiplier = 1.1},
	{ stat = "protection", baseMultiplier = 1.1 }
	})        
     end     
 end  

 if species == "neko" and heldItem then  --neko do extra damage with fists, daggers and shortswords
     if root.itemHasTag(heldItem, "fist") then 
	status.setPersistentEffects("weaponbonusdmg", {
	  {stat = "critBonus", amount = 2},
	  {stat = "critChance", amount = 5}
	})     
     end
     if root.itemHasTag(heldItem, "shortsword") or root.itemHasTag(heldItem, "dagger") then 
	status.setPersistentEffects("weaponbonusdmg", {
	  {stat = "powerMultiplier", baseMultiplier = 1.1},
	  {stat = "protection", baseMultiplier = 1.05}
	})     
     end     
 end  

 if species == "kemono" then   --kemono are brutal with swords
  if heldItem then
     if root.itemHasTag(heldItem, "dagger") or root.itemHasTag(heldItem, "shortsword") or root.itemHasTag(heldItem, "broadsword") then 
	self.meleeCount = 0.3
	status.setPersistentEffects("weaponbonusdmg", {{stat = "powerMultiplier", amount = self.meleeCount}}) 
     end
  end
 end  

 if species == "avikan" and heldItem then   --avikan are brutal spears and daggers
     if root.itemHasTag(heldItem, "dagger") or root.itemHasTag(heldItem, "spear") then 
	status.setPersistentEffects("weaponbonusdmg", {
	{stat = "powerMultiplier", baseMultiplier = 1.05},
	{stat = "critChance", amount = 2}
	})   
     end
 end  
 
 if species == "gyrusen" then   --gyrusens are brutal with axes and hammers
  if heldItem then
     if root.itemHasTag(heldItem, "axe") or root.itemHasTag(heldItem, "hammer") then 
	self.meleeCount = 0.20
	status.setPersistentEffects("weaponbonusdmg", {{stat = "powerMultiplier", amount = self.meleeCount}})   
     end
  end
 end  

 if species == "kazdra" then   --kazdra are brutal with broadswords
  if heldItem then
     if root.itemHasTag(heldItem, "broadsword") then 
	self.meleeCount = 0.20
	status.setPersistentEffects("weaponbonusdmg", {{stat = "powerMultiplier", amount = self.meleeCount}})     
     end
  end
end  

-- *************************************************** 
-- *********** DUAL WIELD POWERS
-- *************************************************** 
if species == "viera" then  --viera are dangerous with daggers
  if heldItem then
     if root.itemHasTag(heldItem, "dagger") then 
	self.meleeCount = self.meleeCount + 1
	self.meleeCount2 = 0.10
	status.setPersistentEffects("weaponbonusdmg", {
	{stat = "protection", amount = self.meleeCount},
	{stat = "powerMultiplier", amount = self.meleeCount2}
	})  
     end
     if root.itemHasTag(heldItem, "dagger") and opposedhandHeldItem and root.itemHasTag(opposedhandHeldItem, "dagger") then -- viera are dangerous with two daggers
       self.meleeCount = 0.10
       self.meleeCount3 = 0.25
       status.setPersistentEffects("weaponbonusdualwield", {
            {stat = "physicalResistance", amount = self.meleeCount},
	    {stat = "powerMultiplier", amount = self.meleeCount3}   
         })   
     end     
  end
end  


if species == "munari" then  
  if heldItem then
     if root.itemHasTag(heldItem, "spear") then
       status.setPersistentEffects("weaponbonusdualwield", {
	    {stat = "critChance", amount = 2},
	    {stat = "powerMultiplier", baseMultiplier = 1.1} 
         })   
     end  
     if root.itemHasTag(heldItem, "fist") then
       status.setPersistentEffects("weaponbonusdualwield", {
	    {stat = "critChance", amount = 3}      
         })   
     end
     if root.itemHasTag(heldItem, "shortspear") then 
       status.setPersistentEffects("weaponbonusdualwield", {
	    {stat = "critChance", amount = 2},
	    {stat = "physicalResistance", baseMultiplier = 1.05}    
         })   
     end    
  end
end

if species == "ningen" and heldItem then  
     if root.itemHasTag(heldItem, "shortspear") then
       status.setPersistentEffects("weaponbonusdualwield", {
	    {stat = "powerMultiplier", baseMultiplier = 1.12},
	    {stat = "grit", amount = 0.2}      
         })   
     end    
end

if species == "felin" then  
  if heldItem then
     if root.itemHasTag(heldItem, "fist") and opposedhandHeldItem and root.itemHasTag(opposedhandHeldItem, "fist") then --felin are lethal with two fists
       status.setPersistentEffects("weaponbonusdualwield", {
	    {stat = "powerMultiplier", baseMultiplier = 1.03},
	    {stat = "critDamage", baseMultiplier = 1.10}      
         })   
     end
     if root.itemHasTag(heldItem, "dagger") and opposedhandHeldItem and root.itemHasTag(opposedhandHeldItem, "dagger") then -- felin are dangerous and defensive with daggers
       status.setPersistentEffects("weaponbonusdualwield", {
	    {stat = "powerMultiplier", baseMultiplier = 1.03},
	    {stat = "critDamage", baseMultiplier = 1.10}    
         })   
     end
      if root.itemHasTag(heldItem, "fist") then  
 	status.setPersistentEffects("weaponbonusdmg3", {
 	  {stat = "powerMultiplier", amount = 1.12}
 	})     
      end
      if root.itemHasTag(heldItem, "dagger") then
 	status.setPersistentEffects("weaponbonusdmg3", {
 	  {stat = "critChance", amount = 1}
 	})     
      end      
  end
end

if species == "nightar" and heldItem then  
    self.meleeCount = self.meleeCount + 0.12
     if root.itemHasTag(heldItem, "shortsword") and opposedhandHeldItem and root.itemHasTag(opposedhandHeldItem, "shield") then 
       status.setPersistentEffects("weaponbonusdualwield", {
            {stat = "shieldBash", amount = 2},
            {stat = "shieldBashPush", amount = 2},
	    {stat = "powerMultiplier", amount = self.meleeCount},
	    {stat = "grit", amount = self.meleeCount}
         })        
     end
     if root.itemHasTag(heldItem, "shortsword") and opposedhandHeldItem and root.itemHasTag(opposedhandHeldItem, "shortsword") then 
       status.setPersistentEffects("weaponbonusdualwield", {
	    {stat = "powerMultiplier", amount = self.meleeCount}
         })   
     end
     if root.itemHasTag(heldItem, "shortsword") then 
	  status.setPersistentEffects("weaponbonusdmg", {
	    {stat = "powerMultiplier", amount = self.meleeCount},
	    {stat = "grit", amount = self.meleeCount2}
	  })  
     end     
     if root.itemHasTag(heldItem, "broadsword") or root.itemHasTag(heldItem, "longsword") then 
	  status.setPersistentEffects("weaponbonusdmg", {
	    {stat = "powerMultiplier", baseMultiplier = 1.05},
	    {stat = "critChance", amount = 2}
	  })  
     end
end

-- ***************************************************   
-- END FR STUFF
-- ***************************************************   
  self.weapon:init()
end

function update(dt, fireMode, shiftHeld)
-- ***************************************************   
--FR stuff
-- ***************************************************   
  local heldItem = world.entityHandItem(activeItem.ownerEntityId(), "primary")
  local heldItem2 = world.entityHandItem(activeItem.ownerEntityId(), "alt")
  local opposedhandHeldItem = world.entityHandItem(activeItem.ownerEntityId(), activeItem.hand() == "primary" and "alt" or "primary")
  local species = world.entitySpecies(activeItem.ownerEntityId())
-- ***********  Nightar  movement bonuses ***************
if species == "nightar" and heldItem then  --nightar gain speed wielding dual shortswords
     if root.itemHasTag(heldItem, "shortsword") and opposedhandHeldItem and root.itemHasTag(opposedhandHeldItem, "shortsword") then
       mcontroller.controlModifiers({ speedModifier = 1.05 })
     end    
end
-- ***********  apex  movement bonuses ***************
if species == "apex" then   --apex move faster with hammers
  if heldItem then
     if root.itemHasTag(heldItem, "hammer") then    	
	mcontroller.controlModifiers({ speedModifier = 1.15 }) 
     end
  end
end  


-- ************** Hylotl *****************************
if species == "hylotl" and heldItem then  
     if root.itemHasTag(heldItem, "quarterstaff") then 
       mcontroller.controlModifiers({ speedModifier = 1.12 })   
     end 
     if root.itemHasTag(heldItem, "shortsword") then 
       mcontroller.controlModifiers({ speedModifier = 1.04 })   
     end 
     if root.itemHasTag(heldItem, "katana") and opposedhandHeldItem and root.itemHasTag(opposedhandHeldItem, "dagger") then 
       mcontroller.controlModifiers({ speedModifier = 1.08 })   
     end      
end

 
-- ***************************************************   
-- END FR STUFF
-- ***************************************************   

  self.weapon:update(dt, fireMode, shiftHeld)
end


function uninit()
  bonusApply = 0
  status.clearPersistentEffects("hylotlbonusdmg")
  status.clearPersistentEffects("weaponbonusdmg")
  status.clearPersistentEffects("weaponbonusdmg2")
  status.clearPersistentEffects("weaponbonusdmg3")
  status.clearPersistentEffects("weaponbonusdmg4")
  status.clearPersistentEffects("weaponbonusdualwield")
  status.clearPersistentEffects("glitchEnergyPowerBonus")
  self.meleeCount = 0
  self.meleeCount2 = 0
  self.weapon:uninit()
end
