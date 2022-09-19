local ls_ok, ls = pcall(require, "luasnip")

if not ls_ok then
	return
end

local s = ls.s
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local i = ls.insert_node

ls.config.set_config({
	history = false,
})

-- wip
-- ls.add_snippets("typescript", {
-- 	ls.parser.parse_snippet(
-- 		"nst",
-- 		"import { Injectable } from '@nestjs/common';\nimport { Logger } from 'winston';\n\n@Injectable()\nexport class $1 {\n constructor($2){}$0\n}"
-- 	),
-- })

ls.add_snippets("lua", {
	s(
		"wes_req",
		fmt("local {} = require('{}')", {
			i(1, "default"),
			rep(1),
		})
	),
})
