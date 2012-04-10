-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local widget = require "widget"

local dinoGroup = display.newGroup ()
local skullGroup = display.newGroup ()
--Counter to control the reset function
local rNum = 0
--Coutner to track the number of photos snapped correctly
local picsMatched = 0

--turn on physics, set gravity to 0, etc.
local physics = require "physics"
physics.start()
physics.setGravity(0,0)


--------------------/Begin Functions/---------------------------------------------


-- Function to snap objects together when a match is made
local function onCollision ( event )
	
	local dino = event.target
	local skull = event.other
	
	if event.phase == "began" then
		if (string.sub(skull.id, 6,6)) == (string.sub(dino.id, 5,5)) then
			transition.to (skull, { time=50, x = dino.x , y = dino.y})
			system.vibrate()
			display.getCurrentStage():setFocus(nil)
			
			--update the number of pics matched
			picsMatched = picsMatched + 1
			
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


-- Create a function that generates a random array of numbers for making the pics show in a random order
-- from http://developer.anscamobile.com/forum/2011/12/06/code-optimization-generate-random-list-numbers-no-repeats
function randomsNonRepeat(low,high, num)
	local numList = {}
	local randoms={}
	local temp
	
	for i=low, high do
		numList[#numList + 1] = i
	end
	
	for j=1, num do
		temp=math.random(low, #numList)
		randoms[#randoms+1] = numList[temp]
		table.remove(numList, temp)
	end
	
	return randoms
end


--Function to reset the pics
local function resetPics ()
	
	--Remove all current skulls
	if rNum == 0 then
		display.getCurrentStage():remove(2)
	else
		display.getCurrentStage():remove(4)
	end
	
	--Generate new skulls
	--Random order for skull pics
	local randSkulls = randomsNonRepeat(1,4, 4)
	
	local skullGroup = display.newGroup()

	--Dynamically generate dino skulls
	for i=1,4 do
		
		local skull = "skull"..randSkulls[i]
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
	
	rNum = rNum + 1
	picsMatched = 0
	
end


--------------------/End Functions/---------------------------------------------

--------------------/Begin Objects/---------------------------------------------

--Random order for dino pics
local randDinos = randomsNonRepeat(1,4, 4)

--Dynamically generate initial dino images
for i=1,4 do
	
	local dino = "dino"..randDinos[i]
	local dinoPath = "images/"..dino..".jpg"

	local dinoPic = display.newImage (dinoPath,0,0)
	print ("Dino height = "..dinoPic.height.."\n".."Dino width = "..dinoPic.width)
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


--Random order for skull pics
local randSkulls = randomsNonRepeat(1,4, 4)

--Dynamically generate dino skulls
for i=1,4 do
	
	local skull = "skull"..randSkulls[i]
	local skullPath = "images/"..skull..".jpg"

	local skullPic = display.newImage (skullPath,0,0)
	print ("Skull height = "..skullPic.height.."\n".."Skull width = "..skullPic.width)
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




