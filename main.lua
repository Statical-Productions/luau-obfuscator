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

function Initialize(Source: string, Watermark: string, Identifier: string, OutputStringVariable: StringValue?)
	warn("[OBFUSCATOR] The obfuscation has been started.")

	local function SanitizeIdentifier(Id)
		-- Replace any character that is not a letter, digit, or underscore with an underscore.
		return Id:gsub("[^%w_]", "_")
	end
	
	-- Use the provided identifier or generate a GUID; append an underscore.
	local IdentifierString = SanitizeIdentifier(Identifier or HttpService:GenerateGUID()) .. "_"
	-- Inject the watermark into the source.
	local WatermarkedSource = "local Watermark = " .. Watermark .. ";" .. (Source or [[print("Hello World!")]])
	local StartTime = tick()

	-- Generate a random alphanumeric string of given length.
	local function Random_(Length)
		local Letters = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
		local Code = (math.random(1,2) == 1) and Letters[math.random(1,26)] or string.upper(Letters[math.random(1,26)])
		for I = 1, tonumber(Length) do
			if math.random(1,2) == 1 then
				local GetLetter = Letters[math.random(1,26)]
				Code = Code .. ((math.random(1,2) == 1) and string.upper(GetLetter) or GetLetter)
			else
				Code = Code .. tostring(math.random(0,9))
			end
		end
		return Code
	end

	-- Convert a string to a binary representation (kept as is).
	local function StringToBinary(InputString: string)
		local BinaryArray = {}
		for Character in InputString:split('') do
			local Byte = Character:byte()
			local Binary = ""
			while Byte > 0 do
				Binary = tostring(Byte % 2) .. Binary
				Byte = math.modf(Byte / 2)
			end
			table.insert(BinaryArray, string.format("%.8d", Binary))
		end
		return table.concat(BinaryArray, " ")
	end

	-- Minimal dummy code insertion (adjustable).
	local DummyCode = "local _dummy = (function() return true end)(); "

	-- Convert the watermarked source into a byte array.
	local SourceByteArray = ""
	for I = 1, string.len(WatermarkedSource) do
		SourceByteArray = SourceByteArray .. '"\\' .. string.byte(WatermarkedSource, I) .. '", '
	end
	local TableByteCode = "local " .. IdentifierString .. "TableByte = {" .. SourceByteArray .. "}"

	-- Build a loadstring code block that will later execute the obfuscated byte array.
	local LoadstringCode = "local " .. IdentifierString .. "Load = loadstring(table.concat({\"\\114\",\"\\101\",\"\\116\",\"\\117\",\"\\114\",\"\\110\"}))"

	-- Assemble the final obfuscated code string.
	local ObfuscatedString = DummyCode .. LoadstringCode .. "; " .. TableByteCode .. "; " ..
		"(" .. IdentifierString .. "Load)(" .. IdentifierString .. "TableByte);"

	-- Minify the output by removing extra whitespace and newlines.
	ObfuscatedString = ObfuscatedString:gsub("%s+", "")

	if OutputStringVariable then
		OutputStringVariable.Value = ObfuscatedString
	else
		print(ObfuscatedString)
	end

	warn("[OBFUSCATOR] The obfuscation has been completed in " .. tostring(os.clock()) .. "s.")
end

-- // Initialize
return function(Source: string, Watermark: string, Identifier: string, OutputStringVariable: StringValue)
	task.spawn(Initialize, Source, Watermark, Identifier, OutputStringVariable)
end
