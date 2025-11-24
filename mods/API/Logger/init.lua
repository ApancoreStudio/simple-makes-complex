Logger = {}

---@param text  string
---@param ...   any
function Logger.infoLog(text, ...)
	text = core.colorize('#00BFFF', '[SMC] '..text:format(...))

	core.log('info', text)
end