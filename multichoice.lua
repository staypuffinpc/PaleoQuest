--multichoice.lua for multiple choice questions

module(..., package.seeall)

local widget = require "widget"

local questionDescription
local qID
local correct
local choices

new = function (params)

if type(params) == "table" then
	qID = params.questionID
end

print(qID)

localGroup = display.newGroup()

function changeScene(event)
		if(event.phase == "ended") then
			--audio.play(click)
			director:changeScene("success","fade")
		end
	end
	
--import the ui file to create buttons
local ui = require("ui")

--include sqlite db
require "sqlite3"

--set the database path 
local path = system.pathForFile("tp_quests.sqlite")

--open dbs
db = sqlite3.open(path)


--handle the applicationExit event to close the db
local function onSystemEvent (event)
	if (event.type == "applicationExit") then
		db:close()
	end
end

local sqlQuery = "SELECT * FROM type_multiple_choice WHERE question_id = "..qID
local rndize = math.random(1,4)
print(rndize)

db:exec(sqlQuery)

for row in db:nrows(sqlQuery) do 
	questionDescription = row.stem
 	correct = row.correct_response
 	if (rndize==1) then
 		choices = {row.correct_response, row.distractor_1, row.distractor_2, row.distractor_3}
	end
	if (rndize==2) then
 		choices = {row.distractor_1, row.correct_response, row.distractor_2, row.distractor_3}
	end
	if (rndize==3) then
 		choices = {row.distractor_1, row.distractor_2, row.correct_response,  row.distractor_3}
	end
	if (rndize==4) then
 		choices = { row.distractor_1, row.distractor_2, row.distractor_3, row.correct_response}
	end
 end
 
 print(questionDescription)
 print(choices[1]..", "..choices[2]..", "..choices[3]..", "..choices[4])


local correct_wav = audio.loadSound("correct.wav")
local incorrect_wav = audio.loadSound("incorrect.wav")

local function finishCorrect()
-- Mark progress for this question in database
				--set the database path
					local user_dbpath = system.pathForFile("tp_user.sqlite")

				--open dbs
					local database2 = sqlite3.open(user_dbpath)

				--handle the applicationExit to close the db
					local function onSystemEvent(event)
						if(event.type == "applicationExit") then
							database2:close()
						end
					end

				-- Submit progress to database
					local sql = "INSERT INTO questions_completed (progress_id, question_completed) VALUES (".._G.prog_id..","..qID..")"
					database2:exec(sql)
					print (sql)
				
				database2:close()
				director:changeScene("success")
end

local btnEventHandler = function (event)
	print(event.target.id)
	if(correct == event.target.id) then
		audio.play(correct_wav)
		timer.performWithDelay(3000, finishCorrect)
	end

	if(correct ~= event.target.id) then
		audio.play(incorrect_wav)
	end
end

--loop through each item in the array to: (a) loop through the table fed as an argument to load the sound, and (b) create the button 
	local function makeBtns(btnList,btnImg,layout,groupXPos,groupYPos)
		
		--first, let's place all the buttons inside a button group, so we can move them together
		local thisBtnGroup = display.newGroup();
		for index,value in ipairs(btnList) do 
			local img = btnImg
			local thisBtn = ui.newButton{
				default = img, defaultX = 200, defaultY = 50,
				overSrc = img, overX = 180, overY = 50,
				onPress = btnEventHandler,
				text = value,
				size = 14
			}
			thisBtn.id = value
			thisBtnGroup:insert(thisBtn)
			--lay the buttons out either horizontally or vertically
			if (layout == "horizontal") then 
				thisBtn.x = (index -1) * thisBtn.width
			elseif (layout == "vertical") then
				thisBtn.y = (index-1)*thisBtn.height
			end
		end
		
		thisBtnGroup:setReferencePoint( display.BottomCenterReferencePoint )
		thisBtnGroup.x = groupXPos; thisBtnGroup.y = groupYPos
		
		return thisBtnGroup
	end
	
	local myDescr = display.newRetinaText (questionDescription, 0,0, display.contentWidth-10,0, native.systemFont, 18)
	myDescr:setReferencePoint( display.TopLeftReferencePoint )
	myDescr.x = 10
	myDescr.y = 50
	localGroup:insert(myDescr)

	local myChoices = makeBtns(choices,"images/btn_choice.png","vertical",_W/2,display.contentHeight-75)
	localGroup:insert(myChoices)	
	
-----------------------------------------------------------------------------------------------------------------------------

-- Begin tabbar stuff

-----------------------------------------------------------------------------------------------------------------------------	
	
	-- Load bottom bar image and icon buttons
	
	local function onBtnPress( event )
	
		if (event.name == "tabButtonPress") then
			print (event.target.id)
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