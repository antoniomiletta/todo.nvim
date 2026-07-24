local M = {}

local state = {
	win = nil,
}

local default_opts = {
	target_file = "~/todo.nvim/todo.md",
	border = "single",
	width = 0.8,
	height = 0.8,
	position = "center",
	auto_save = true,
}

local function expand_path(path)
	if path:sub(1, 1) == "~" then
		return os.getenv("HOME") .. path:sub(2)
	end
	return path
end

local function calculate_position(position)
	local x, y = 0.5, 0.5

	if type(position) == "table" then
		x, y = position[1], position[2]
	end

	if position == "center" then
		x, y = 0.5, 0.5
	elseif position == "topleft" then
		x, y = 0, 0
	elseif position == "topright" then
		x, y = 1, 0
	elseif position == "bottomleft" then
		x, y = 0, 1
	elseif position == "bottomright" then
		x, y = 1, 1
	end

	return x, y
end

local function win_config(opts)
	local width = math.min(math.floor(vim.o.columns * opts.width), 64)
	local height = math.floor(vim.o.lines * opts.height)

	local posx, posy = calculate_position(opts.position)

	local col = math.floor((vim.o.columns - width) * posx)
	local row = math.floor((vim.o.lines - height) * posy)

	return {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		border = opts.border,
	}
end

local function close_window()
	if state.win ~= nil and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
	end
	state.win = nil
end

local function save_buffer(buf)
	vim.api.nvim_buf_call(buf, function()
		vim.cmd("write")
	end)
end

local function setup_keymaps(buf, opts)
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		noremap = true,
		silent = true,
		callback = function()
			if vim.api.nvim_get_option_value("modified", { buf = buf }) then
				if opts.auto_save then
					save_buffer(buf)
					close_window()
					vim.notify("(todo.nvim) Changes saved automatically", vim.log.levels.INFO)
				else
					vim.notify("(todo.nvim) Save your changes, please", vim.log.levels.WARN)
				end
			else
				close_window()
			end
		end,
	})
end

local function open_floating_file(opts)
	if state.win ~= nil and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_set_current_win(state.win)
		return
	end

	local expanded_path = expand_path(opts.target_file)

	if vim.fn.filereadable(expanded_path) == 0 then
		vim.notify("(todo.nvim) target file does not exist at directory: " .. expanded_path, vim.log.levels.ERROR)
		return
	end

	local buf = vim.fn.bufnr(expanded_path, true)

	if buf == -1 then
		buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(buf, expanded_path)
	end

	vim.bo[buf].swapfile = false

	state.win = vim.api.nvim_open_win(buf, true, win_config(opts))
	setup_keymaps(buf, opts)
end

M.setup = function(opts)
	opts = vim.tbl_deep_extend("force", default_opts, opts or {})

	vim.api.nvim_create_user_command("Td", function()
		open_floating_file(opts)
	end, {})
end

return M
