--map screen
print ("This is _H: ".._H)
module(..., package.seeall)

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
--[[
	local menuDescr
	if numberCompleted == 0 then
	 menuDescr = "Hello! Meet me here to see your first clue."
	elseif questionsRemaining == 0 then
	 menuDescr = "You did it! You can rest now."
	else
	 menuDescr = "Well Done! Now meet me here."
	end
	local menuInstr = " "
]]	
	
-----------------------------------------------------------------------------------------------------------------------------

-- Start map stuff

-----------------------------------------------------------------------------------------------------------------------------
	
	
	-- Load large map image and make it scrollable
	
	local widget = require "widget"
	
	--Calculate and display max Texture size
	local tileWorldSize = system.getInfo("maxTextureSize")
	print ("Maximum dimensions of Tile World: "..tileWorldSize.."px x "..tileWorldSize.."px")

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
--[[
	local function getPos (event)
		if event.phase = "ended" then
			print( self.x.."x, "..self.y.."y" )
		end
	end
	Runtime:addEventListener("touch", getPos)
]]

	-- Position image group
	imageGroup.y = 0
	imageGroup.x = 0

	--Destroy globals to clean up memory
	y = nil
	x = nil


-----------------------------------------------------------------------------------------------------------------------------

-- I need to get the array function worked out

-----------------------------------------------------------------------------------------------------------------------------	







	-- Create a new ScrollView widget and insert imageGroup:
	local scrollView = widget.newScrollView{
		width = display.contentWidth,
		height = display.contentHeight - 54,
		scrollWidth = iW,
		scrollHeight = iH,
		-- start the avatar at the front door of the museum
		left = 0,
		top = 0,
		listener = scrollViewListener
	}
	scrollView:insert( imageGroup )
	
	local currentContentPos = scrollView:getContentPosition()
	print ( currentContentPos )
	
	-- Create a function that takes as its arguments map coordinates to simulate moving the avatar to a new position	
	local dx = {-800}
	local dy = {-1600}
	
	
	local function moveDino ()
		
		scrollView.content.x = dx[1]
		scrollView.content.y = dy[1]
--		scrollView:scrollToPosition( dX[1], dY[1], 10 )

	end
	
	local tmrDinoMove = timer.performWithDelay (0, moveDino, 1)

	localGroup:insert (scrollView)
	
	
	
	
	
	
	
	
	
	
	
-----------------------------------------------------------------------------------------------------------------------------

-- End map stuff

-----------------------------------------------------------------------------------------------------------------------------	
	
	-- Load bottom bar image and icon buttons
	local bottombar = display.newImageRect("images/bottombar320x54.png", 320, 54)
	bottombar:setReferencePoint(display.CenterReferencePoint)
	bottombar.x = bottombar.width/2
	bottombar.y = _H - 27
	localGroup:insert(bottombar)
	
	local btn_picker = display.newImageRect("images/btn_picker44x44.png", 44, 44)
	btn_picker:setReferencePoint(display.CenterReferencePoint)
	btn_picker.x = bottombar.width/6
	btn_picker.y = bottombar.y
	btn_picker.scene = "picker"
	localGroup:insert(btn_picker)
	
	local btn_map= display.newImageRect("images/btn_map44x44.png", 44,44)
	btn_map:setReferencePoint(display.CenterReferencePoint)
	btn_map.x = bottombar.width/2
	btn_map.y = bottombar.y
	btn_map.scene = "map"
	localGroup:insert(btn_map)
	
	local btn_bag = display.newImageRect("images/btn_bag44X44.png", 44,44)
	btn_bag:setReferencePoint(display.CenterReferencePoint)
	btn_bag.x = bottombar.width - bottombar.width/6
	btn_bag.y = bottombar.y
	btn_bag.scene = "bag"
	localGroup:insert(btn_bag)
	
	-- Wrap text function (way too long in my opinion...)
	local function autoWrappedText(text, font, size, color, width)
	--print("text: " .. text)
	  if text == '' then return false end
	  font = font or native.systemFont
	  size = tonumber(size) or 12
	  color = color or {255, 255, 255}
	  width = width or display.stageWidth
	 
	  local result = display.newGroup()
	  local lineCount = 0
	  -- do each line separately
	  for line in string.gmatch(text, "[^\n]+") do
		local currentLine = ''
		local currentLineLength = 0 -- the current length of the string in chars
		local currentLineWidth = 0 -- the current width of the string in pixs
		local testLineLength = 0 -- the target length of the string (starts at 0)
		-- iterate by each word
		for word, spacer in string.gmatch(line, "([^%s%-]+)([%s%-]*)") do
		  local tempLine = currentLine..word..spacer
		  local tempLineLength = string.len(tempLine)
		  -- test to see if we are at a point to try to render the string
		  if testLineLength > tempLineLength then
			currentLine = tempLine
			currentLineLength = tempLineLength
		  else
			-- line could be long enough, try to render and compare against the max width
			local tempDisplayLine = display.newText(tempLine, 0, 0, font, size)
			local tempDisplayWidth = tempDisplayLine.width
			tempDisplayLine:removeSelf();
			tempDisplayLine=nil;
			if tempDisplayWidth <= width then
			  -- line not long enough yet, save line and recalculate for the next render test
			  currentLine = tempLine
			  currentLineLength = tempLineLength
			  testLineLength = math.floor((width*0.9) / (tempDisplayWidth/currentLineLength))
			else
			  -- line long enough, show the old line then start the new one
			  local newDisplayLine = display.newText(currentLine, 0, (size * 1.3) * (lineCount - 1), font, size)
			  newDisplayLine:setTextColor(color[1], color[2], color[3])
			  result:insert(newDisplayLine)
			  lineCount = lineCount + 1
			  currentLine = word..spacer
			  currentLineLength = string.len(word)
			end
		  end
		end
		-- finally display any remaining text for the current line
		local newDisplayLine = display.newText(currentLine, 0, (size * 1.3) * (lineCount - 1), font, size)
		newDisplayLine:setTextColor(color[1], color[2], color[3])
		result:insert(newDisplayLine)
		lineCount = lineCount + 1
		currentLine = ''
		currentLineLength = 0
	  end
	  result:setReferencePoint(display.TopLeftReferencePoint)
	  return result
	end

	-- Change scene when you click on the dinosaur
	function changeScene(event)
		if(event.phase == "moved") then
			local dx = math.abs( event.x - event.xStart )
			local dy = math.abs( event.y - event.yStart )
			-- Get position of scroll view to mark coordinates for array
			print (scrollView:getScrollPosition())
			-- if finger drags button more than 5 pixels, pass focus to scrollView
			if dx > 5 or dy > 5 then
				scrollView:takeFocus( event )
			end
			
			local currentContentPos = scrollView:getContentPosition()
			print ( currentContentPos )
			
		elseif(event.phase == "ended") then
			audio.play(click)
			director:changeScene(params,event.target.scene,"fade")
		end
		
		return true
	end
	
	btn_picker:addEventListener("touch", changeScene)
	btn_map:addEventListener("touch", changeScene)
	btn_bag:addEventListener("touch", changeScene)


--[[	
	local myInstr = autoWrappedText(menuInstr, native.systemFont, 18, {100, 30, 30}, display.contentWidth - 25);
	myInstr:setReferencePoint(display.CenterReferencePoint)
	myInstr.x = bottombar.width/2
	myInstr.y = bottombar.height + myInstr.height/2 + 20
	localGroup:insert(myInstr)

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


	local myDescr = autoWrappedText(menuDescr, native.systemFont, 14, {0,0,0}, display.contentWidth/3);
	myDescr:setReferencePoint(display.TopLeftReferencePoint)
	myDescr.y = marker.y + 15
	local wordBalloon
	if (locationXDivisor > 4) then
		myDescr.x = marker.x - (myDescr.width)
		wordBalloon = display.newRoundedRect(marker.x-myDescr.width-10,marker.y+15,myDescr.width*1.2,myDescr.height*1.1,4)
	else 
		myDescr.x = marker.x + 10
		wordBalloon = display.newRoundedRect(marker.x,marker.y+15,myDescr.width*1.2,myDescr.height*1.1,4)
	end
	
	markerGroup:insert(wordBalloon)
	markerGroup:insert(myDescr)
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
]]		
	
	
	return localGroup
end