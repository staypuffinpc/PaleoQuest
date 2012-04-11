display.setStatusBar( display.HiddenStatusBar )

--[[ to do still
1. when the user answers all the questions correctly, show a quick animation of the card being shrunk and added to their pack of cards.
]]

module(..., package.seeall)
--init globals
_H = display.contentHeight;
_W = display.contentWidth;

local director = require ("director")
local widget = require "widget"

function changeScene(event)
		if(event.phase == "ended") then
			audio.play(click)
			director:changeScene(event.target.scene,"fade")
		end
end

----------------------------------------------------
--get db info
----------------------------------------------------
require "sqlite3"

--frst, figure out how many questions there are in this quest
local questPath = system.pathForFile("tp_quests.sqlite",system.ResourceDirectory)
questDB = sqlite3.open(questPath)
local query = "SELECT COUNT(question_id) as totalNum FROM `quest_questions` WHERE quest_id = ".._G.questID
local questInfo ={}
for row in questDB:nrows(query) do
	if row.totalNum > 5 then
		questInfo.totalNum = row.totalNum
	else questInfo.totalNum = 6
	end
end
print("there are "..questInfo.totalNum.." questions in this quest")

--also need to know the appropriate card for this quest.  Get this once you update the db
query = "SELECT topic, dino_card FROM `QuestInfo` WHERE questID = ".._G.questID
for row in questDB:nrows(query) do 
	questInfo.dino = row.dino_card
	questInfo.era = row.topic
end
questInfo.dinoCard = questInfo.era.."/"..questInfo.dino..".jpg"
print("Card is "..questInfo.dinoCard)
questDB:close()

--now find out how many questions have been answered
--I first have to grab the progress ID, using the user_id and the quest_id
local userPath = system.pathForFile("tp_user.sqlite",system.DocumentsDirectory)
userDB = sqlite3.open(userPath)
query = "SELECT prog_id FROM progress WHERE user_id=1 AND quest_id=1"
for row in userDB:nrows(query) do 
	questInfo.progress_id = row.prog_id
end

--with the prog_id in hand I can now figure out how many questions the user has answered in this quest
query = "SELECT COUNT(question_completed) as complete FROM questions_completed WHERE progress_id=1"
for row in userDB:nrows(query) do
	if row.complete > 0 then
		questInfo.completed = row.complete
	else questInfo.completed = 0
	end
end

print ("User has answered "..questInfo.completed.." of "..questInfo.totalNum.." questions in this quest")
--print ("the progress ID is:" .. questInfo.progress_id)
userDB:close()
-------------------------// end db stuff //------------------------------

function new()
			
	localGroup = display.newGroup()
	
	-------------------------// Start mask stuff //------------------------------

	--function to add a mask to a puzzle piece.  
	function createPuzzlePiece ( puzzleImg, maskImg )
		
		--[[	--show default img (back of the card)
			local defaultCard = display.newImageRect("images/cards/defaultCard.jpg",320,440)
			defaultCard:setReferencePoint(display.TopLeftReferencePoint)
			defaultCard.x = 0;
			defaultCard.y =0;
			localGroup:insert(defaultCard)
		]]

		--get puzzle image
		if (questInfo.completed ~= 0) then
			local img = display.newImage( puzzleImg )
			img:setReferencePoint(display.CenterReferencePoint)
			img.width = display.contentWidth
			img.height = display.contentHeight

			--now create a mask
			local mask = graphics.newMask(maskImg)
			--apply the mask to the image
			img:setMask(mask)
			
			localGroup:insert( img )
			
			if (questInfo.completed == questInfo.totalNum) then
				--the user has answered all the questions, so don't apply a mask to the img.  There's also no need to show the back of the card
				local msg = "You've earned the "..questInfo.dino.." card!"
				local congratsText = display.newText (msg, 20,0, native.systemFontBold, 16)
				congratsText:setReferencePoint( display.CenterReferencePoint )
				congratsText:setTextColor (255)
				congratsText.x = _W/2
				congratsText.y = _H/2 + 30
				
				--To Do: make sure to add the card to the user's deck in the datbase
				
				local id = ""
				local avatar = _G.avatarID
				--print("Your avatar is "..avatar)
							
				if (avatar == 1) then
					id = "Rex"
				elseif (avatar == 2) then
					id = "Spike"
				elseif (avatar == 3) then
					id = "Amber"
				else 
					id = "Ruby"
				end
				
				--create a sound
				local mySound = audio.loadSound(string.lower(id).."Congratulations.wav")
				audio.play(mySound)
							
			end
			
			return img

		end
	end


	--create the puzzle image
	local picPath = "images/cards/"..questInfo.dinoCard
	local maskPath = "images/puzzles/"..questInfo.totalNum.."/"..questInfo.completed..".jpg"
	local cardImg = createPuzzlePiece ( picPath, maskPath )
	
-------------------------// End mask stuff //------------------------------
		
	-- Load bottom bar image and icon buttons
	
	local function onBtnPress( event )
	
		audio.play(click)
		director:changeScene(event.target.id,"fade")
		
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