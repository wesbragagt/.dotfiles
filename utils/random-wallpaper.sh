    #!/usr/bin/bash

    WALLPAPERS_DIR=~/wallpapers/anime-original-freedom-flight.jpg # Adjust this path as needed
    WALLPAPER=$(find "$WALLPAPERS_DIR" -type f | shuf -n 1) # Randomly select an image
    swww img "$WALLPAPER" --transition-type wipe --transition-duration 2
