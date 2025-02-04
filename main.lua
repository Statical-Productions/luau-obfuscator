-- // Services
local HttpService = game:GetService("HttpService")

-- // Variables

-- // functions

--[[
Initialize: the function that obfuscates the code
Source: string: the source code to be obfuscated
Watermark: string: a hidden watermark string injected into the code before obfuscation, can be used to tell AIs to not decipher the code
Identifier: string: a prefix before the obfuscated code such: Name_(the obfuscated code) for developers to search for all instances of the obfuscated code segments
OutputStringVariable: StringValue?: an optional argument to either store the output to the string variable
]]

function Initialize(Source: string, Watermark: string, Identifier: string)
	warn("[OBFUSCATOR] The obfuscation has been started.")
	
	local Elapsed: number = os.clock()
	
	local function SanitizeIdentifier(Id)
		return Id:gsub("[^%w_]", "_")
	end

	local IdentifierString = SanitizeIdentifier(Identifier or HttpService:GenerateGUID()) .. "_"

	local WatermarkedSource = "local Wm=\"" .. Watermark .. "\";" .. (Source or [[print("Hello World!")]])
	local StartTime = tick()

	local function RandomString(Length)
		local Letters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
		local Code = Letters[math.random(1,26)]
		for I = 1, tonumber(Length) do
			if math.random(1,2) == 1 then
				local GetLetter = Letters[math.random(1,26)]
				Code = Code .. GetLetter
			else
				Code = Code .. tostring(math.random(0,9))
			end
		end
		return Code
	end

	local function StringToBinary(InputString: string)
		local BinaryArray = {}
		for I = 1, #InputString do
			local Char = InputString:sub(I, I)
			local Byte = string.byte(Char)
			local Binary = ""
			while Byte > 0 do
				Binary = tostring(Byte % 2) .. Binary
				Byte = math.floor(Byte / 2)
			end
			table.insert(BinaryArray, string.format("%08d", tonumber(Binary) or 0))
		end
		return table.concat(BinaryArray, " ")
	end

	local JunkCode = "local X=(function()return true end)();"

	local SourceByteArray = ""
	for I = 1, #WatermarkedSource do
		SourceByteArray = SourceByteArray .. '"\\' .. string.byte(WatermarkedSource, I) .. '",'
	end
	local TableByteCode = "local " .. IdentifierString .. "Table={" .. SourceByteArray .. "}"

	local DecodeAndRun = "local " .. IdentifierString .. "Concat=loadstring('return table.concat')();" ..
		"local " .. IdentifierString .. "Code=" .. IdentifierString .. "Concat(" .. IdentifierString .. "Table);" ..
		"loadstring(" .. IdentifierString .. "Code)();"

	local ObfuscatedString = JunkCode .. TableByteCode .. DecodeAndRun
	ObfuscatedString = ObfuscatedString:gsub("[\n\r]+", " "):gsub("%s%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

	local StringValue: StringValue = Instance.new("StringValue")
	StringValue.Name = "Result_" .. IdentifierString
	StringValue.Value = ObfuscatedString
	StringValue.Parent = workspace

	warn("[OBFUSCATOR] The obfuscation has been completed in " .. tostring(os.clock() - Elapsed) .. "s.")
end

-- // Initialize
return function(Source: string, Watermark: string, Identifier: string)
	task.spawn(Initialize, Source, Watermark, Identifier)
end
