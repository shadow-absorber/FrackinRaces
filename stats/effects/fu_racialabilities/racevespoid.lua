function init()
  baseValue = config.getParameter("healthBonus",0)*(status.resourceMax("health"))
  baseValue2 = config.getParameter("energyBonus",0)*(status.resourceMax("energy"))
  
  effect.addStatModifierGroup({
    {stat = "maxHealth", amount = baseValue },
    {stat = "maxEnergy", amount = baseValue2 },
    {stat = "beestingImmunity", amount = 1},
    {stat = "honeyslowImmunity", amount = 1},
    {stat = "fallDamageMultiplier", effectiveMultiplier = 0.20},
    {stat = "physicalResistance", amount = 0},
    {stat = "fireResistance", amount = -0.5},
    {stat = "iceResistance", amount = -0.3},
    {stat = "electricResistance", amount = 0},
    {stat = "poisonResistance", amount = 0.5},
    {stat = "shadowResistance", amount = 0}
  })

  self.movementParams = mcontroller.baseParameters()  
  local bounds = mcontroller.boundBox()	
  script.setUpdateDelta(10)
end

function update(dt)
	mcontroller.controlModifiers({
	 speedModifier = 1.10,
	 stickyForce = 2,
	 airForce = 65.0,
	 liquidForce = 20.0
	})
end

function uninit()
  
end