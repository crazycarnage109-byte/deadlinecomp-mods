--!strict

function get_page<T>(list: {T}, page_length: number, want_page: number): ({T}, number)
	local max_page = math.ceil( #list / page_length )
	local returned_page = math.clamp(want_page, 1, max_page)

	local start_index = page_length * (returned_page-1) + 1
	local end_index = math.min(start_index + page_length - 1, #list)

	local output: {T} = {}
	return table.move(list, start_index, end_index, 1, output), returned_page
end

function in_filter<T>(values: {T}, filter: {T}): {T}
	local output = {}
    for _, v in pairs(values) do
        if table.find(filter, v) then
           continue 
        end
        table.insert(output, v)
    end

	return output
end

function not_in_filter<T>(values: {T}, filter: {T}): {T}
    local output = {}
    for _, value in pairs(values) do
        if not table.find(filter, value) then
            table.insert(output, value)
        end
    end

    return output
end

shared.dlcomp_table = {
	get_page = get_page,
	in_filter = in_filter,
    not_in_filter = not_in_filter,
}
