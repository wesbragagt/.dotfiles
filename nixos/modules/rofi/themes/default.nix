{ pkgs, lib }:

{
  # Simple Nord theme (default)
  default = {
    content = ''
* {
    bg0:    #2E3440F2;
    bg1:    #3B4252;
    bg2:    #4C566A80;
    bg3:    #88C0D0F2;
    fg0:    #D8DEE9;
    fg1:    #ECEFF4;
    fg2:    #D8DEE9;
    fg3:    #4C566A;
}

window {
    background-color: @bg0;
    border-radius: 12px;
    padding: 8px;
}

inputbar {
    background-color: @bg1;
    border-radius: 8px;
    padding: 8px 16px;
    children: [ prompt, entry ];
}

listview {
    background-color: transparent;
    lines: 8;
    spacing: 4px;
}

element {
    background-color: transparent;
    border-radius: 8px;
    padding: 8px 16px;
}

element selected {
    background-color: @bg3;
    text-color: @bg1;
}

prompt {
    text-color: @fg2;
}

entry {
    text-color: @fg1;
}
    '';
  };

  # Raycast Nord theme with high contrast (from dotfiles)
  raycast-nord = {
    content = ''
configuration {
    font: "JetBrains Mono 12";
    show-icons: true;
    icon-theme: "Papirus-Dark";
    display-drun: " ";
    display-run: " ";
    display-window: " ";
}

* {
    nord0:   #2E3440;
    nord1:   #3B4252;
    nord3:   #4C566A;
    nord4:   #D8DEE9;
    nord6:   #ECEFF4;
    nord8:   #88C0D0;
    nord9:   #81A1C1;
    nord11:  #BF616A;
    nord13:  #EBCB8B;

    background-color:   transparent;
    text-color:         @nord6;

    margin:     0px;
    padding:    0px;
    spacing:    0px;
}

window {
    location:       center;
    width:          600;
    border-radius:  14px;

    background-color:   @nord0;
    padding:        24px;
}

mainbox {
    spacing:    20px;
    children:   [ inputbar, listview ];
}

inputbar {
    background-color:   @nord1;
    border-radius:  12px;

    padding:    14px 18px;
    spacing:    14px;
    children:   [ prompt, entry ];
}

prompt {
    text-color: @nord8;
}

entry {
    placeholder:        "Search";
    placeholder-color:  @nord3;
    text-color:     @nord6;
    background-color: transparent;
}

listview {
    background-color:   transparent;

    margin:     0;
    lines:      8;
    columns:    1;
    spacing:    6px;

    fixed-height: false;
    scrollbar: false;
}

element {
    padding:        12px 16px;
    spacing:        14px;
    border-radius:  10px;
    background-color: transparent;
    children: [ element-icon, element-text ];
}

element normal normal {
    text-color: @nord4;
}

element normal active {
    text-color: @nord8;
}

element normal urgent {
    text-color: @nord11;
}

element selected normal, element selected active {
    background-color:   @nord8;
    text-color: @nord0;
}

element selected urgent {
    background-color:   @nord11;
    text-color: @nord6;
}

element alternate normal {
    text-color: @nord4;
}

element alternate active {
    text-color: @nord8;
}

element alternate urgent {
    text-color: @nord11;
}

element alternate selected normal, element alternate selected active {
    background-color:   @nord8;
    text-color: @nord0;
}

element alternate selected urgent {
    background-color:   @nord11;
    text-color: @nord6;
}

element-icon {
    size:           32px;
    vertical-align: 0.5;
}

element-text {
    text-color: inherit;
}

textbox {
    text-color: @nord6;
}
    '';
  };

  # Rounded Nord Dark theme (from newmanls)
  rounded-nord-dark = {
    content = ''
/* ROUNDED THEME FOR ROFI */
/* Author: Newman Sanchez (https://github.com/newmanls) */

* {
    bg0:    #2E3440F2;
    bg1:    #3B4252;
    bg2:    #4C566A80;
    bg3:    #88C0D0F2;
    fg0:    #D8DEE9;
    fg1:    #ECEFF4;
    fg2:    #D8DEE9;
    fg3:    #4C566A;
}

* {
    font:   "Roboto 12";

    background-color:   transparent;
    text-color:         @fg0;

    margin:     0px;
    padding:    0px;
    spacing:    0px;
}

window {
    location:       north;
    y-offset:       calc(50% - 176px);
    width:          480;
    border-radius:  24px;

    background-color:   @bg0;
}

mainbox {
    padding:    12px;
}

inputbar {
    background-color:   @bg1;
    border-color:       @bg3;

    border:         2px;
    border-radius:  16px;

    padding:    8px 16px;
    spacing:    8px;
    children:   [ prompt, entry ];
}

prompt {
    text-color: @fg2;
}

entry {
    placeholder:        "Search";
    placeholder-color:  @fg3;
}

message {
    margin:             12px 0 0;
    border-radius:      16px;
    border-color:       @bg2;
    background-color:   @bg2;
}

textbox {
    padding:    8px 24px;
}

listview {
    background-color:   transparent;

    margin:     12px 0 0;
    lines:      8;
    columns:    1;

    fixed-height: false;
}

element {
    padding:        8px 16px;
    spacing:        8px;
    border-radius:  16px;
}

element normal active {
    text-color: @bg3;
}

element alternate active {
    text-color: @bg3;
}

element selected normal, element selected active {
    background-color:   @bg3;
}

element-icon {
    size:           1em;
    vertical-align: 0.5;
}

element-text {
    text-color: inherit;
}
    '';
  };

  # Dracula theme
  dracula = {
    content = ''
* {
    bg0:    #282a36D0;
    bg1:    #44475a;
    bg2:    #6272a4;
    bg3:    #bd93f9;
    fg0:    #f8f8f2;
    fg1:    #ffffff;
    fg2:    #bdc3c7;
    fg3:    #6272a4;
}

window {
    background-color: @bg0;
    border-radius: 12px;
    padding: 8px;
}

inputbar {
    background-color: @bg1;
    border-radius: 8px;
    padding: 8px 16px;
    children: [ prompt, entry ];
}

listview {
    background-color: transparent;
    lines: 8;
    spacing: 4px;
}

element {
    background-color: transparent;
    border-radius: 8px;
    padding: 8px 16px;
}

element selected {
    background-color: @bg3;
    text-color: @bg1;
}

prompt {
    text-color: @fg2;
}

entry {
    text-color: @fg1;
}
    '';
  };

  # Gruvbox Dark theme
  gruvbox = {
    content = ''
* {
    bg0:    #282828D0;
    bg1:    #3c3836;
    bg2:    #504945;
    bg3:    #ebdbb2;
    fg0:    #ebdbb2;
    fg1:    #fbf1c7;
    fg2:    #d5c4a1;
    fg3:    #665c54;
}

window {
    background-color: @bg0;
    border-radius: 12px;
    padding: 8px;
}

inputbar {
    background-color: @bg1;
    border-radius: 8px;
    padding: 8px 16px;
    children: [ prompt, entry ];
}

listview {
    background-color: transparent;
    lines: 8;
    spacing: 4px;
}

element {
    background-color: transparent;
    border-radius: 8px;
    padding: 8px 16px;
}

element selected {
    background-color: #d79921;
    text-color: @bg1;
}

prompt {
    text-color: @fg2;
}

entry {
    text-color: @fg1;
}
    '';
  };

  # Catppuccin Mocha theme
  catppuccin = {
    content = ''
* {
    bg0:    #1e1e2eD0;
    bg1:    #313244;
    bg2:    #45475a;
    bg3:    #cba6f7;
    fg0:    #cdd6f4;
    fg1:    #ffffff;
    fg2:    #a6adc8;
    fg3:    #6c7086;
}

window {
    background-color: @bg0;
    border-radius: 12px;
    padding: 8px;
}

inputbar {
    background-color: @bg1;
    border-radius: 8px;
    padding: 8px 16px;
    children: [ prompt, entry ];
}

listview {
    background-color: transparent;
    lines: 8;
    spacing: 4px;
}

element {
    background-color: transparent;
    border-radius: 8px;
    padding: 8px 16px;
}

element selected {
    background-color: @bg3;
    text-color: @bg1;
}

prompt {
    text-color: @fg2;
}

entry {
    text-color: @fg1;
}
    '';
  };

  # Fresh theme (clean blue)
  fresh = {
    content = ''
* {
    bg0:    #0f172aD0;
    bg1:    #1e293b;
    bg2:    #334155;
    bg3:    #3b82f6;
    fg0:    #f1f5f9;
    fg1:    #ffffff;
    fg2:    #cbd5e1;
    fg3:    #64748b;
}

window {
    background-color: @bg0;
    border-radius: 12px;
    padding: 8px;
}

inputbar {
    background-color: @bg1;
    border-radius: 8px;
    padding: 8px 16px;
    children: [ prompt, entry ];
}

listview {
    background-color: transparent;
    lines: 8;
    spacing: 4px;
}

element {
    background-color: transparent;
    border-radius: 8px;
    padding: 8px 16px;
}

element selected {
    background-color: @bg3;
    text-color: @fg1;
}

prompt {
    text-color: @fg2;
}

entry {
    text-color: @fg1;
}
    '';
  };
}
