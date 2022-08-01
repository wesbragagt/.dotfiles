local function clear_buffer(buf_nbr)
	vim.api.nvim_buf_set_lines(buf_nbr, 0, -1, false, { "" })
end

local function output_buffer(buf_nbr, data)
	vim.api.nvim_buf_set_lines(buf_nbr, -1, -1, false, data)
end

local function attatch_buff_number(buffer_number, pattern, command)
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("WesDev", { clear = true }),
		pattern = pattern,
		callback = function()
			clear_buffer(buffer_number)
			local append_buffer = function(_, data)
				output_buffer(buffer_number, data)
			end
			vim.fn.jobstart(command, {
				stdout_buffered = true,
				on_stdout = append_buffer,
				on_stderr = append_buffer,
			})
		end,
	})
end

local function split_into_new_buffer()
	vim.cmd("vsplit")
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_win_set_buf(win, buf)
	return buf
end

local function create_playground(name, pattern, command)
	vim.api.nvim_create_user_command(name, function()
		local run_buffer = split_into_new_buffer()
		attatch_buff_number(tonumber(run_buffer), pattern, command)
	end, {})
end

vim.api.nvim_create_user_command("AutoRun", function()
	local run_buffer = split_into_new_buffer()
	local pattern = vim.fn.input("Pattern: ")
	local command = vim.split(vim.fn.input("Command: "), " ")

	attatch_buff_number(tonumber(run_buffer), pattern, command)
end, {})

create_playground("TSPlayground", "*.ts", "ts-node playground.ts")
create_playground("BashPlayground", "*.sh", "bash playground.sh")
