--FIB.lua for Fill-In the Blank Questions
module(..., package.seeall)

local widget = require "widget"

--init globals
_H = display.contentHeight
_W = display.contentWidth

local director=require("director")

local questionDescription
local qID
local correct
local answer1 -- forward reference (needed for Lua closure)
local answerText

--local successGroup = display.newGroup()
--successGroup.alph = 0

new = function (params)

	if type(params) == "table" then
		qID = params.questionID
	end

	print(qID)

	--new group function for director
	--function new()
		localGroup = display.newGroup()


	--import the ui file to create buttons
	local ui = require("ui")

	--change scene function for director
	function changeScene(event)
		if(event.phase == "ended") then
			audio.play(click)
			director:changeScene(event.target.scene,"fade")
		end
	end



	--include sqlite db
	require "sqlite3"

	--set the database path 
	local path = system.pathForFile("tp_quests.sqlite",system.ResourceDirectory)

	--open dbs
	db = sqlite3.open(path)

	--handle the applicationExit even to close the db
	local function onSystemEvent (event)
		if (event.type == "applicationExit") then
			db:close()
		end
	end

	local sqlQuery = "SELECT * FROM type_fill_in_blank WHERE question_id = "..qID

	db:exec(sqlQuery)

	for row in db:nrows(sqlQuery) do 
		questionDescription = row.stem
		correct = row.answer
		--choices = {row.answer, row.distractor1, row.distractor2, row.distractor3}
	 end
	 
	 print(questionDescription)

	local correctSound = audio.loadSound("correct.wav")
	local errorSound = audio.loadSound("incorrect.wav")

	local answer1 = ""
	local wrongAnswer = ""


	-- TextField Listener
	local function fieldHandler( getObj )
			
			return function( event )
	 
					--print( "TextField Object is: " .. tostring( getObj() ) )
					
					if ( "began" == event.phase ) then
							-- This is the "keyboard has appeared" event
							print("began")
							if(wrongAnswer.alpha == 1) then
								print("get rid of the sorry message")
								wrongAnswer.alpha = 0
							end
					
					elseif ( "ended" == event.phase ) then
							-- This event is called when the user stops editing a field:
							-- for example, when they touch a different field or keyboard focus goes away
					
							--print( "Text entered = " .. tostring( getObj().text ) )         -- display the text entered
							answerText = tostring(getObj().text)
							--answerVerify()

					elseif ( "submitted" == event.phase ) then
							-- This event occurs when the user presses the "return" key
							-- (if available) on the onscreen keyboard
							
							-- Hide keyboard
							native.setKeyboardFocus( nil )
							--answerVerify()
							
					end
					
			end     -- "return function()"
	 
	end
	 
	answer1 = native.newTextField( _W/2-100, _H/2, 200, 50,
		  fieldHandler( function() return answer1 end ) )
	-- passes the text field object


	----------------------------------------
	-- This correct answer would be retrieved from the database associated with question1
	----------------------------------------

	--correct1 = "carnivore"

	----------------------------------------
	-- This code is the function to verify the answer
	----------------------------------------

	local answerVerify = function (event)
		answer1.inputType = "default"
		answerText = answer1.text;
		answerText = (string.lower(answerText))

		
		if(correct == answerText) then
			audio.play(correctSound)
			director:changeScene("success")
		
			-- Mark progress for this question in database
			--set the database path
				local user_dbpath = system.pathForFile("tp_user.sqlite", system.DocumentsDirectory)

			--open dbs
				local database2 = sqlite3.open(user_dbpath)
				
			-- Submit progress to database
			local sql = "INSERT INTO questions_completed (progress_id, question_completed) VALUES (".._G.prog_id..","..qID..")"
				database2:exec(sql)
			print (sql)

			--handle the applicationExit to close the db
			local function onSystemEvent(event)
				if(event.type == "applicationExit") then
				database2:close()
			end
		end
				
	--	local titleText = display.newText("You are now at the next scene", 0, 0, native.systemFontBold, 14)
	--	titleText:setTextColor(100, 200, 200)
	--	titleText.x = display.contentWidth/2
	--	titleText.y = display.contentHeight/2
	--	localGroup:insert(titleText)


	--[[	local successMessage = display.newRect(0,0,176,33)
					successMessage.scene = "bag"
					local messageLabel = display.newText("Return to Hunt ...", successMessage.width/4,0,"Helvetica",13)
					messageLabel:setTextColor(0,0,0)
	--local successGroup = display.newGroup()
					successGroup:insert(successMessage)
					successGroup:insert(messageLabel)
					successGroup:setReferencePoint(display.CenterReferencePoint)
					successGroup.x = _W/2
					successGroup.y = _H/3*2
					successGroup.alpha = 1
					localGroup:insert(successGroup)
					successMessage:addEventListener("touch",changeScene)
					database2:close()]]
	end

	--[[
			local params = {correctAnswered = qID}
			print(params)
			--director:changeScene(params, "bag")
		end]]--
		
		if(correct ~= answerText) then
			audio.play(errorSound)
			print("that is the wrong answer")
			if(wrongAnswer.alpha == 0) then
				wrongAnswer.alpha = 1
			else 
				wrongAnswer = display.newRetinaText("Sorry! Try Again", 0, 0,"Helvetica",18)
				wrongAnswer:setReferencePoint(display.CenterReferencePoint)
				wrongAnswer.x = _H/6 * 2
				wrongAnswer.y = _W/6 * 4
			end

			--display.getCurrentStage():setFocus(answer1)

			--winLose("wrong")
		end
	end
			

	----------------------------------------
	-- loads button on display for answer
	----------------------------------------

	local answerBtn = ui.newButton{
		default = "btn_answer.png",
		over = "btn_answer1.png",
		x = _W/2,
		y = _H - 125,
		--onPress=answerVerify
		}


-----------------------------------------------------------------------------------------------------------------------------

-- Begin tabbar stuff

-----------------------------------------------------------------------------------------------------------------------------	


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


	----------------------------------------
	-- This is the variable to display the stem
	----------------------------------------
	local askQuestion = display.newRetinaText(questionDescription, 0,0, display.contentWidth-10,0, native.systemFont, 18);
	askQuestion:setReferencePoint (display.TopLeftReferencePoint )
	askQuestion.x = 10
	askQuestion.y = 50

	----------------------------------------
	-- This code runs the answer verify function when the enter button is tapped
	----------------------------------------

	answerBtn:addEventListener( "tap", answerVerify )

	return localGroup
	
end
