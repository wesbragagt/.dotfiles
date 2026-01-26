WALLPAPER_DIR="${HOME}/wallpapers"

OLDIFS=$IFS
IFS=$'\n'
for wallpaper in $(hyprctl hyprpaper listloaded); do
	hyprctl hyprpaper unload "$wallpaper"
done
IFS=$OLDIFS

for display in $(hyprctl monitors | grep "Monitor" | cut -d " " -f 2); do
	wallpaper="$(find "$WALLPAPER_DIR" -type f | shuf -n 1)"
	hyprctl hyprpaper preload "$wallpaper"
	hyprctl hyprpaper wallpaper "$display,$wallpaper"
done
