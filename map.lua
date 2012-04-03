--map screen
print ("This is _H: ".._H)
module(..., package.seeall)

local widget = require "widget"

function new(params)

	-- create variable to represent hunt as it will be passed from previous screen

	local questID = _G.questID
	local userID = _G.userID
	local avatarID = _G.avatarID

	local localGroup = display.newGroup()
		
	-- include sqlite library
	require "sqlite3"

	--set the database paths
	local dbpath = system.pathForFile("tp_quests.sqlite")
	local dbpath2 = system.pathForFile("tp_user.sqlite")

	--open dbs
	database = sqlite3.open(dbpath)
	user_database = sqlite3.open(dbpath2)

	--handle the applicationExit to close the db
	local function onSystemEvent(event)
		if(event.type == "applicationExit") then
			database:close()
			user_database:close()
		end
	end

	local prog_id

	-- Find the user's progress for this quest
	local sql = "SELECT prog_id FROM progress WHERE user_id = 1 AND quest_id = "..questID
	for row in user_database:nrows(sql) do
		prog_id = row.prog_id
		print ("The progress id is established: "..prog_id)
		_G.prog_id = row.prog_id
	end


	--get completed question IDs
	sql = "SELECT question_completed FROM questions_completed WHERE progress_id = "..prog_id
	local i = 1
	local unavailableQuestions = {}
	for row in user_database:nrows(sql) do
		unavailableQuestions[i] = row.question_completed
		print ("The question is unavailable: "..i..": "..row.question_completed)
		i = i+1
	end


	--get question IDs
	local sql = "SELECT question_id FROM quest_questions WHERE quest_id = "..questID.." AND question_id NOT IN ( "
	i=1
	for k,v in ipairs(unavailableQuestions) do
		sql = sql..unavailableQuestions[i]..","
		i=i+1
	end
	local numberCompleted = i-1
	sql = string.sub(sql,1,-2)
	sql = sql..")"
	print (sql.." Minus the last comma")

	i=1
	local questionTable = {}
	questionTable[1] = 0
	for row in database:nrows(sql) do	
		questionTable[i] = row.question_id
		print("Question table -- "..questionTable[i])
		i = i+1
	end

	local questionsRemaining = i - 1
	print("It breaks here? " .. questionsRemaining .. " And more to boot")
	--get question information
	-- Find out which questions remain to be completed from the quest

	print("Why stop there?")

	-- Choose which question to deliver)
	local params = {}
	if questionsRemaining ~= 0 then
		local sql = "SELECT question_type,question_location_id FROM questions WHERE question_id = "..questionTable[1]
		print (sql)
		params ={
			questionID = questionTable[1]
			}
		for row in database:nrows(sql) do	
			params.questionType = row.question_type
			params.question_location = row.question_location_id
		end
	else 
		params.questionType = 0
		params.question_location = 3
	end
		
	-- create variable to select correct question to advance to on next screen
		
	local click = audio.loadSound("click.wav")

	local menuDescr

	if numberCompleted == 0 then
	 menuDescr = "Hello! Meet me here to see your first clue."
	elseif questionsRemaining == 0 then
	 menuDescr = "You did it! You can rest now."
	else
	 menuDescr = "Well Done! Now meet me here."
	end

	local menuInstr = " "

	
-----------------------------------------------------------------------------------------------------------------------------

-- Start map stuff

-----------------------------------------------------------------------------------------------------------------------------
	
	
	-- Load large map image and make it scrollable
	-- Set image sheet options - width, height, and number of frames = rect image info
	local options =
	{
		width = 128,
		height = 128,
		numFrames = 256,

		-- Retina image info

		sheetContentWidth = 2048, -- width of original 1x size of entire sheet
		sheetContentHeight = 2048 -- height of original 1x size of entire sheet
	}

	-- Create image sheet from image and load into variable
	local imageSheet = graphics.newImageSheet ("images/museum.png", options)
	iW = sheetContentWidth
	iH = sheetContentHeight

	-- Create display group
	local imageGroup = display.newImageGroup (imageSheet)

	--function to get position of tapped tile
	local function tileInfo (event)
		local tile = event.target
		print ("Tile "..tile.id.."\n".."Position: "..tile.x.."x, "..tile.y.."y")
	end

	--Dynamically generate and position tiles of image sheet
	for i=1,256 do
		local mapTile = display.newImageRect (imageSheet, i, 128, 128)
		mapTile.id = i
		mapTile:setReferencePoint( display.TopLeftReferencePoint )
		
		--dynamically generate the y-offset for each row
		if i < 17 then
			y = 0
		else
			y = (math.floor ( (i-1)/16 )) * 128
		end
		mapTile.y = y
		
		--dynamically cerate the x-offset for each collumn
		x = math.floor(((i-1)%16)*128)
		mapTile.x = x	
		
		imageGroup:insert ( mapTile )

		
		--add event listener to make tile into a button
		mapTile:addEventListener("touch", tileInfo)
	end

	-- Position image group
	imageGroup.y = 0
	imageGroup.x = 0

	--Destroy globals to clean up memory
	y = nil
	x = nil


-----------------------------------------------------------------------------------------------------------------------------

-- Need to get the array coordinates of the path through the museum as soon as we get a decent map

-----------------------------------------------------------------------------------------------------------------------------	

	-- Create a new ScrollView widget and insert imageGroup:
	local scrollView = widget.newScrollView{
		width = display.contentWidth,
		height = display.contentHeight - 50,
		scrollWidth = iW,
		scrollHeight = iH,
		-- start the avatar at the front door of the museum
		left = 0,
		top = 0,
		listener = scrollViewListener
	}
	
	scrollView:insert( imageGroup )
	
	-- Create a function that takes as its arguments map coordinates to simulate moving the avatar to a new position	
	local dx = {-800}
	local dy = {-1600}
	
	
	local function moveDino ()
		scrollView.content.x = dx[1]
		scrollView.content.y = dy[1]
	end
	
	local tmrDinoMove = timer.performWithDelay (0, moveDino, 1)

	localGroup:insert (scrollView)
	
	
	
-----------------------------------------------------------------------------------------------------------------------------

-- End map stuff

-----------------------------------------------------------------------------------------------------------------------------	
	
	-- Load bottom bar image and icon buttons
	
	local function onBtnPress( event )
	
		if (event.name == "tabButtonPress") then
			print (event.target.id)
			audio.play(click)
			director:changeScene(params,event.target.id,"fade")
		elseif (event.phase == "moved") then
			local dx = math.abs( event.x - event.xStart )
			local dy = math.abs( event.y - event.yStart )
			-- if finger drags button more than 5 pixels, pass focus to scrollView
			if dx > 5 or dy > 5 then
				scrollView:takeFocus( event )
			end
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
	
------------------------ End tabbar stuff --------------------------------------------------------------------------------	
	
	-- Change scene when you click on the dinosaur
	function changeScene(event)
		if(event.phase == "moved") then
			local dx = math.abs( event.x - event.xStart )
			local dy = math.abs( event.y - event.yStart )
			-- if finger drags button more than 5 pixels, pass focus to scrollView
			if dx > 5 or dy > 5 then
				scrollView:takeFocus( event )
			end
		elseif(event.phase == "ended") then
			audio.play(click)
			director:changeScene(params,event.target.scene,"fade")
		end
		
		return true
	end

--need to loop these onto the map
	if avatarID == 1 then
		avatarColor = "blue"
	elseif avatarID == 2 then
		avatarColor = "green"
	elseif avatarID == 3 then
		avatarColor = "orange"
	elseif avatarID == 4 then
		avatarColor = "red"
	end
	
	local locationXDivisor
	local locationYDivisor
	if params.question_location == 1 or params.question_location == 5 or (params.question_location == 9) then
		locationXDivisor = 1
		if (params.question_location == 1) then
			locationYDivisor = 3
		elseif (params.question_location == 5) then
			locationYDivisor = 5
		else
			locationYDivisor = 7
		end
	elseif (params.question_location == 2) or (params.question_location == 6) or (params.question_location == 10) then
		locationXDivisor = 3
			
		if (params.question_location == 2) then
			locationYDivisor = 3
		elseif (params.question_location == 6) then
			locationYDivisor = 5
		else
			locationYDivisor = 7
		end
	elseif (params.question_location == 3) or (params.question_location == 7) or(params.question_location == 11) then
		locationXDivisor = 5
			
		if (params.question_location == 3) then
			locationYDivisor = 3
		elseif (params.question_location == 7) then
			locationYDivisor = 5
		else
			locationYDivisor = 7
		
		end
	else
		locationXDivisor = 7
			
		if (params.question_location == 4) then
			locationYDivisor = 3
		elseif (params.question_location == 8) then
			locationYDivisor = 5
		else
			locationYDivisor = 7
		end
	end
--	print("Location X "..locationXDivisor)
--	print("Location Y "..locationYDivisor)

	-- Make clickable dinosaur to advance to question screen
	markerGroup = display.newGroup()
	
	local marker = display.newImageRect("images/avatar_"..avatarColor..".png", 64, 44)
	marker:setReferencePoint(display.CenterReferencePoint)
	marker.x = _W/8*locationXDivisor
	marker.y = _H/16*locationYDivisor

	markerGroup:insert(marker)
	
	--data driven indicator of question type
	if params.questionType == 3 then
		markerGroup.scene = "draggable"
	elseif params.questionType == 2 then
		markerGroup.scene = "multichoice"
	elseif params.questionType == 1 then
		markerGroup.scene = "FIB"
	elseif params.questionType == 0 then
		markerGroup.scene = "picker"
	end
	localGroup:insert(markerGroup)
	markerGroup:addEventListener("touch", changeScene)


	return localGroup
end

