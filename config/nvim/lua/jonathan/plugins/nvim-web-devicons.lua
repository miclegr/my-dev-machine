local aura = {
	icon = "",
	color = "#4E9A06",
	cterm_color = "71",
	name = "Aura",
}

return {
	"nvim-tree/nvim-web-devicons",
	opts = {
		override = {
			cmp = aura,
			auradoc = aura,
			design = aura,
		},
	},
}
