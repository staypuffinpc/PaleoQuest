module(..., package.seeall)

local widget = require "widget"

--turn on physics, set gravity to 0, etc.
local physics = require "physics"
physics.start()
physics.setGravity(0,0)


--Counter to control the reset function
local rNum = 0
--Coutner to track the number of photos snapped correctly
local picsMatched = 0


--New Director function
new = function (params)

	local dinoGroup = display.newGroup ()
	local skullGroup = display.newGroup ()
	local localGroup = display.newGroup ()
	
	-- Parameters
	local question_ID

	if type(params) == "table" then
		print("It is a table.")
		question_ID = params.questionID
	end
		
	function changeScene(event)
		if(event.phase == "ended") then
			director:changeScene(event.target.scene,"fade")
		end
	end
	
--	print ("Map question passed: "..question_ID)	

--------------------/Begin DB stuff/---------------------------------------------

	-- include sqlite library
	require "sqlite3"

	--set the database path
	local dbpath = system.pathForFile("tp_quests.sqlite", system.ResourceDirectory)

	--open dbs
	database = sqlite3.open(dbpath)

	--handle the applicationExit to close the db
	local function onSystemEvent(event)
		if(event.type == "applicationExit") then
			database:close()
		end
	end

--------------------/End DB stuff/---------------------------------------------

--------------------/Begin functions/------------------------------------------

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
				print("Made"..picsMatched.."matches")
				
				--Queue victory function if all pics are matched				
				if picsMatched == 4 then
					
					-- Mark progress for this question in database
					--set the database path
					local user_dbpath = system.pathForFile("tp_user.sqlite", system.DocumentsDirectory)

					--open dbs
					local database2 = sqlite3.open(user_dbpath)

					--handle the applicationExit to close the db
					local function onSystemEvent(event)
						if (event.type == "applicationExit") then
							database2:close()
						end
					end

					-- Submit progress to database
					local sql = "INSERT INTO questions_completed (progress_id, question_completed) VALUES (".._G.prog_id..","..question_ID..")"
					database2:exec(sql)
					print (sql)
					
					director:changeScene("success","fade")
				end
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
		
		print (localGroup.numChildren)
		
		--Remove all current skulls
		if rNum == 0 then
			localGroup:remove(2)
		else
			localGroup:remove(5)
		end
		
		--Generate new skulls
		--Random order for skull pics
		local randSkulls = randomsNonRepeat(1,4, 4)
		
		local skullGroup = display.newGroup()

		--Dynamically generate dino skulls
		for i=1,4 do
			
			local skull = "skull"..randSkulls[i]
			local skullPath = "images/"..skull..".jpg"

			local skullPic = display.newImageRect (skullPath,90,60)
			skullPic.id = skull
			skullPic:setReferencePoint ( display.CenterReferencePoint )
			skullPic.x = skullPic.width
			skullPic.y = skullPic.height * 1.2 * i
			skullPic:addEventListener("touch", skullDrag )
			skullGroup:insert(skullPic)

			-- Add physics to skullPic to allow dinoPic sensor to detect it
			physics.addBody(skullPic)
			skullPic.bodyType = "kinematic"
		end

		skullGroup:setReferencePoint ( display.TopCenterReferencePoint )
		skullGroup.y = 30
		localGroup:insert(skullGroup)
		
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

		local dinoPic = display.newImageRect (dinoPath,90,60)
		dinoPic.id = dino
		dinoPic:setReferencePoint ( display.CenterReferencePoint )
		dinoPic.y = dinoPic.height * 1.2 * i
		dinoPic.x = display.contentWidth - dinoPic.width
		dinoPic:addEventListener ( "collision", onCollision )
		dinoGroup:insert(dinoPic)

		-- Make dinoPic a snesor to detect if the correct skull is dragged over it
		physics.addBody( dinoPic )
		dinoPic.isSensor = "true"

	end

	dinoGroup:setReferencePoint ( display.TopCenterReferencePoint )
	dinoGroup.y = 30
	localGroup:insert(dinoGroup)

	--Random order for skull pics
	local randSkulls = randomsNonRepeat(1,4, 4)

	--Dynamically generate dino skulls
	for i=1,4 do
		
		local skull = "skull"..randSkulls[i]
		local skullPath = "images/"..skull..".jpg"

		local skullPic = display.newImageRect (skullPath, 90,60)
		skullPic.id = skull
		skullPic:setReferencePoint ( display.CenterReferencePoint )
		skullPic.x = skullPic.width
		skullPic.y = skullPic.height * 1.2 * i
		skullPic:addEventListener("touch", skullDrag )
		skullGroup:insert(skullPic)

		-- Add physics to skullPic to allow dinoPic sensor to detect it
		physics.addBody(skullPic)
		skullPic.bodyType = "kinematic"
	end

	skullGroup:setReferencePoint ( display.TopCenterReferencePoint )
	skullGroup.y = 30
	localGroup:insert(skullGroup)


	-- Create instructions
	local instructionsText = display.newText ("Drag the skull to its dino", 0,0, native.systemFontBold, 12)
	instructionsText:setReferencePoint ( display.CenterReferencePoint )
	instructionsText.x = display.contentWidth/2
	instructionsText.y = skullGroup.height + 65


	-- Create a reset button
	local resetBtn = widget.newButton{
			id = "btn001",
			left = display.contentWidth/2 - 30,
			top = instructionsText.y + 30,
			label = "Reset",
			width = 60, height = 30,
			cornerRadius = 12,
			fontSize = 12,
			strokeWidth = 6,
			onPress = resetPics
		}
	
--------------------/End Objects/--------------------------------------------

--------------------/Begin tabbar stuff/--------------------------------------------

	-- Load bottom bar image and icon buttons
		
		local function onBtnPress( event )
		
			if (event.name == "tabButtonPress") then
				audio.play(click)
				director:changeScene(event.target.id,"fade")
			end
			
			return true
		end
	 
		local tabButtons = {
			{
				id = "picker",
				baseDir = system.ResourceDirectory,
				--label="quests",
				up="images/btn_picker44x44.png",
				down="images/btn_picker44x44.png",
				width=44, height=44,
				onPress=onBtnPress,
				--selected=true,
				scene = "picker"
			},
			{
				id = "map",
				baseDir = system.ResourceDirectory,
				--label="map",
				up="images/btn_map44x44.png",
				down="images/btn_map44x44.png",
				width=44, height=44,
				onPress=onBtnPress,
				scene = "map"
			},
			 {	
				id = "bag",
				baseDir = system.ResourceDirectory,
				--label="cards",
				up="images/btn_bag44X44.png",
				down="images/btn_bag44X44.png",
				width=44, height=44,
				onPress=onBtnPress,
				scene = "bag"
			},
		}
		
		local bottomBar = widget.newTabBar{
			baseDir = system.ResourceDirectory,
			background = "images/bottombar320x54.png",
			top=display.contentHeight - 50,
			buttons=tabButtons
		}	

	return localGroup

end
