local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

function M.parent_pattern_exists(root_patterns)
	return vim.fs.dirname(vim.fs.find(root_patterns, { upward = true })[1])
end

function M.is_worktree()
	return M.parent_pattern_exists({ "packed-refs" }) ~= nil
end

function M.is_submodule()
	return M.parent_pattern_exists({ ".gitmodules" }) ~= nil
end

-- Find nodes by type
local function find_parent_by_types(expr, types)
	while expr do
		if types[expr:type()] then
			return expr
		end
		expr = expr:parent()
	end
	return nil
end

-- Find child nodes by type
local function find_child_by_types(expr, types)
	local id = 0
	local expr_child = expr:child(id)
	while expr_child do
		if types[expr_child:type()] then
			return expr_child
		end
		id = id + 1
		expr_child = expr:child(id)
	end

	return nil
end

local CLASS_TYPES = {
	class_declaration = true, -- Java
	class_definition = true, -- Python
}

local METHOD_TYPES = {
	method_declaration = true, -- Java
	function_definition = true, -- Python
}

local NAME_TYPES = {
	identifier = true,
	name = true,
}

-- Get Current Method Name
function M.get_current_method_name()
	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		return nil
	end

	local expr = find_parent_by_types(current_node, METHOD_TYPES)
	if not expr then
		return nil
	end

	local child = find_child_by_types(expr, NAME_TYPES)
	if not child then
		return nil
	end
	return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Class Name
function M.get_current_class_name()
	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		return nil
	end

	local class_declaration = find_parent_by_types(current_node, CLASS_TYPES)
	if not class_declaration then
		return nil
	end

	local child = find_child_by_types(class_declaration, NAME_TYPES)
	if not child then
		return nil
	end
	return vim.treesitter.get_node_text(child, 0)
end

-- Get Current Package Name
function M.get_current_package_name()
	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		return nil
	end

	local program_expr = find_parent_by_types(current_node, { program = true })
	if not program_expr then
		return nil
	end
	local package_expr = find_child_by_types(program_expr, { package_declaration = true })
	if not package_expr then
		return nil
	end

	local child = find_child_by_types(package_expr, { scoped_identifier = true })
	if not child then
		return nil
	end
	return vim.treesitter.query.get_node_text(child, 0)
end

-- Get Current Full Class Name
function M.get_current_full_class_name()
	local package = M.get_current_package_name()
	local class = M.get_current_class_name()
	if not class then
		return nil
	end
	if package then
		return package .. "." .. class
	end
	return class
end

-- Get Current Full Method Name with delimiter or default '.'
function M.get_current_full_method_name(delimiter)
	delimiter = delimiter or "."
	local full_class_name = M.get_current_full_class_name()
	local method_name = M.get_current_method_name()
	if not method_name then
		return nil
	end
	if full_class_name then
		return full_class_name .. delimiter .. method_name
	end
	return method_name
end

local function escape_pattern(text)
	return text:gsub("([^%w])", "%%%1")
end

function M.get_maven_module()
	local utils = require("jonathan.core.utils")
	local current_file = vim.fn.expand("%:p")
	local is_java_file = vim.bo.filetype == "java" -- just in case this isn't used in ftplugin/java.lua
	local root_dir = utils.parent_pattern_exists({ "pom.xml" })
	if not root_dir or not is_java_file then
		return nil
	end
	local relative_path_to_current_file = current_file:gsub(escape_pattern(root_dir .. "/"), "")
	local first_element = vim.split(relative_path_to_current_file, "/")[1]
	local root_contents = vim.split(vim.fn.glob(root_dir .. "/*"), "\n", { trimempty = true })
	local module_paths = vim.split(vim.fn.glob(root_dir .. "/*/pom.xml"), "\n")
	local modules_exist = #module_paths > 0
	if modules_exist then
		-- check if the current file is in a maven module
		for _, path in ipairs(root_contents) do
			local file_or_dir = vim.fn.fnamemodify(path, ":t")
			if vim.fn.isdirectory(path) == 1 and first_element == file_or_dir then
				-- the first element of the relative path to the current file is a directory
				-- and we know we are in a multi-module maven project
				return first_element
			end
		end
	end
	return nil
end

-- Check if the root .gitignore contains .fdb_latexmk (which should be ignored in a LaTeX project)
function M.is_tex_project()
	local root = require("jonathan.core.utils").parent_pattern_exists(".gitignore")

	if not root then
		return false
	end

	local lines = vim.fn.readfile(root .. "/.gitignore")

	if #lines == 0 then
		return false
	end

	for _, line in ipairs(lines) do
		if line:match("%.fdb_latexmk") then
			return true
		end
	end
	return false
end

return M
