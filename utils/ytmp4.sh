#!/usr/bin/env bash

if [[ -z "$1" || "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: ytmp4 <url>"
    echo ""
    echo "Download a YouTube video as MP4 (best quality) into a"
    echo "folder named after the video title (kebab-case)."
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    exit 0
fi

url="$1"
format="bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
output_template="--restrict-filenames -o %(title)s.%(ext)s"

dir_name=$(yt-dlp $output_template --get-filename "$url" | sed 's/\.[^.]*$//' | tr '[:upper:]' '[:lower:]' | tr '_' '-')

mkdir -p "$dir_name"
yt-dlp -f "$format" --merge-output-format mp4 $output_template \
    -P "$dir_name" \
    --progress "$url"
