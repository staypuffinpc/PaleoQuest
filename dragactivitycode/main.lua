-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local widget = require "widget"

local dinoGroup = display.newGroup ()
local skullGroup = display.newGroup ()

--turn on physics, set gravity to 0, etc.
local physics = require "physics"
physics.start()
physics.setGravity(0,0)

-- Function to snap objects together when a match is made
local function onCollision ( event )
	
	local dino = event.target
	local skull = event.other
	
	if event.phase == "began" then
		if (string.sub(skull.id, 6,6)) == (string.sub(dino.id, 5,5)) then
			transition.to (skull, { time=50, x = dino.x , y = dino.y})
			display.getCurrentStage():setFocus(nil)			
		end
	end
		
	return true

end

-- Function to allow skullPic to be dragged
local function skullDrag ( event )
	
	local t = event.target
	local phase = event.phase
	
	if "began" == phase then
		display.getCurrentStage():setFocus(t)
		t.isFocus = true
		
		--Store inital position
		t.x0 = event.x - t.x
		t.y0 = event.y - t.y
		
	elseif t.isFocus then
		if "moved" == phase then
			t.x = event.x - t.x0
			t.y = event.y - t.y0
		elseif "ended" == phase then
			display.getCurrentStage():setFocus(nil)
			t.isFocus = false
		end
	end
	
	return true	
end

--Dynamically generate initial dino images
for i=1,4 do

	local dino = "dino"..i
	local dinoPath = "images/"..dino..".jpg"

	local dinoPic = display.newImage (dinoPath,0,0)
	dinoPic.id = dino
	dinoPic:setReferencePoint ( display.CenterReferencePoint )
	dinoPic.y = dinoPic.height * 1.5 * i
	dinoPic.x = display.contentWidth - dinoPic.width
	dinoPic:addEventListener ( "collision", onCollision )
	dinoGroup:insert(dinoPic)

	-- Make dinoPic a snesor to detect if the correct skull is dragged over it
	physics.addBody( dinoPic )
	dinoPic.isSensor = "true"

end

dinoGroup:setReferencePoint ( display.TopCenterReferencePoint )
dinoGroup.y = 30

--Dynamically generate dino skulls
for i=1,4 do

	local skull = "skull"..i
	local skullPath = "images/"..skull..".jpg"

	local skullPic = display.newImage (skullPath,0,0)
	skullPic.id = skull
	skullPic:setReferencePoint ( display.CenterReferencePoint )
	skullPic.x = skullPic.width
	skullPic.y = skullPic.height * 1.5 * i
	skullPic:addEventListener("touch", skullDrag )
	skullGroup:insert(skullPic)

	-- Add physics to skullPic to allow dinoPic sensor to detect it
	physics.addBody(skullPic)
	skullPic.bodyType = "kinematic"
end

skullGroup:setReferencePoint ( display.TopCenterReferencePoint )
skullGroup.y = 30


-- Create instructions
local instructionsText = display.newText ("Drag the skull on the left to the matching dino on the right", 0,0, native.systemFontBold, 24)
instructionsText:setReferencePoint ( display.CenterReferencePoint )
instructionsText.x = display.contentWidth/2
instructionsText.y = skullGroup.height + 80


--Function to reset the pics
local function resetPics ()
	print ("Let's reset!")
end


-- Create a reset button
local resetBtn = widget.newButton{
        id = "btn001",
        left = display.contentWidth/2 - 90,
        top = instructionsText.y + 40,
        label = "Reset",
        width = 180, height = 80,
        cornerRadius = 36,
		fontSize = 36,
		strokeWidth = 10,
        onPress = resetPics
    }




