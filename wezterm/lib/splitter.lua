local function splitter(text, delimiter)
	local result = {}
	local pattern = "(.-)" .. delimiter

	local last_pos = 1
	for part in text:gmatch(pattern) do
			table.insert(result, part)
			last_pos = last_pos + #part + #delimiter
	end

	-- Add any remaining text after the last delimiter
	local remaining_part = text:sub(last_pos)
	if remaining_part ~= "" then
			table.insert(result, remaining_part)
	end

	return result
end

return splitter