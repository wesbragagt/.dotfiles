local status_ok, statusline = pcall(require, "feline")

if not status_ok then
	return
end

statusline.setup()
