local M = {}

local mark_ns = vim.api.nvim_create_namespace("qfsync")

-- -- debug
-- vim.api.nvim_set_hl(0, "QfSyncDebugHighlight", {
-- 	undercurl = true,
-- 	sp = "#FF8800",
-- })

function M.sync()
	local qf = vim.fn.getqflist()
	if #qf == 0 then
		return
	end

	for _, item in ipairs(qf) do
		if item.user_data ~= nil and item.user_data.ext_id ~= nil then
			local mark =
				vim.api.nvim_buf_get_extmark_by_id(item.bufnr, mark_ns, item.user_data.ext_id, { details = true })

			if mark then
				item.lnum = mark[1] + 1
				item.col = mark[2] + 1

				if mark[3] then
					if item.end_lnum and item.end_lnum ~= 0 and mark[3].end_row then
						item.end_lnum = mark[3].end_row + 1
					end

					if item.end_col and item.end_col ~= 0 and mark[3].end_col then
						item.end_col = mark[3].end_col + 1
					end
				end
			end
		end
	end

	vim.fn.setqflist(qf, "r")
end

-- Buffer上のmarkをいじる
function M.add_marks()
	local qf = vim.fn.getqflist()
	if #qf == 0 then
		return
	end

	for _, item in ipairs(qf) do
		if not (item.user_data and item.user_data.ext_id) then
			-- まだないからはやす
			local start_row = item.lnum - 1
			local start_col = item.col - 1

			local end_row = (item.end_lnum and item.end_lnum > 0) and (item.end_lnum - 1) or start_row
			local end_col = (item.end_col and item.end_col > 0) and (item.end_col - 1) or start_col

			item.user_data = item.user_data or {}

			item.user_data.ext_id = vim.api.nvim_buf_set_extmark(item.bufnr, mark_ns, start_row, start_col, {
				end_row = end_row,
				end_col = end_col,
				strict = false,
				-- -- debug
				-- hl_group = "QfSyncDebugHighlight",
				-- virt_text = { { "▶", "QfSyncDebugHighlight" } },
				-- virt_text_pos = "overlay",
			})
		end
	end

	vim.fn.setqflist(qf, "r")
end

function M.sync_all()
	M.add_marks()
	M.sync()
end

function M.setup()
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "QuickFixCmdPost" }, {
		pattern = "*",
		callback = function()
			if vim.bo.buftype ~= "quickfix" then
				return
			end

			M.sync_all()
		end,
	})

	vim.api.nvim_create_user_command(
		"QfSyncAll", --
		function(_)
			M.sync_all()
		end,
		{
			desc = "Sync All Quickfix items using extmarks",
		}
	)
end

return M
