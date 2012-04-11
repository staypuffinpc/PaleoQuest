--set globals
_W = display.contentWidth
_H = display.contentHeight

--display.setStatusBar( display.HiddenStatusBar )

--====================================================================--
-- DIRECTOR CLASS SAMPLE
--====================================================================--

--[[

 - Version: 1.3
 - Made by Ricardo Rauber Pereira @ 2010
 - Blog: http://rauberlabs.blogspot.com/
 - Mail: ricardorauber@gmail.com

******************
 - INFORMATION
******************

  - This is a little sample of what Director Class does.
  - If you like Director Class, please help us donating at my blog, so I could
	keep doing it for free. http://rauberlabs.blogspot.com/

--]]

--====================================================================--
-- IMPORT DIRECTOR CLASS
--====================================================================--

local director = require("director")

--====================================================================--
-- CREATE A MAIN GROUP
--====================================================================--

local mainGroup = display.newGroup()

--====================================================================--
-- MAIN FUNCTION
--====================================================================--

local main = function ()
	
	------------------
	-- Add the group from director class
	------------------
	
	mainGroup:insert(director.directorView)
		
	------------------
	-- Move the SQLite file from the Resource directory to the Documents directory
	------------------	
	
	--Check if a file exists in a target directory.  If not, copy it from a base directory to the target Directory
	local function checkForFile (file)
		
		local checkPath = system.pathForFile(file,system.DocumentsDirectory)
		local isFileThere = io.open(checkPath,"r")
		
		if isFileThere == nil then
		
		--file doesn't exist, so copy file from base directory to target Directory)
			local existingPath = system.pathForFile(file,system.ResourceDirectory)
			--print (existingPath)
			
			if existingPath == nil then
				--print ("ERROR: There is no "..file.." in the Resource Directory")
			else -- file exists, so copy it from the Resource Directory to the Documents directory
				local readFile = io.open(existingPath,"r")
				fileContents = readFile:read("*a")
				io.close(readFile)
				readFile = nil
				path = nil
				--now copy to new directory
				local newPath = system.pathForFile(file,system.DocumentsDirectory)
				local newFile = io.open(newPath,"w")
				newFile:write(fileContents)
				io.close(newFile)
				newFile = nil
				path2 = nil
				--print (file.." copied successfully")
			end
			
		else --file already exists
			--print(file.." already exists in the Documents Directory")
		end
	end
	 
	checkForFile("tp_user.sqlite")
	
	------------------
	-- Change scene without effects
	------------------
	
	director:changeScene("menu")
	
	------------------
	-- Return
	------------------
	
	return true
end

--====================================================================--
-- BEGIN
--====================================================================--

main()

-- It's that easy! :-)