name = "Minimap HUD MZ"
description = "Adds a minimap to the HUD with More customiZable"
author = "pigshaam" -- Original: "squeek"
version = "1.1.7"
forumthread = "" -- Original: "/files/file/352-minimap-hud/"
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- this setting is dumb; this mod is likely compatible with all future versions
api_version = 6

-- compatiblity
dst_compatible = true
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

client_only_mod = true
all_clients_require_mod = false

configuration_options =
{
    {
        name = "Map Size",
        options =
        {
            {description = "Tiny",   data = 0.125},
            {description = "Small",  data = 0.175},
            {description = "Medium", data = 0.225},
            {description = "Large",  data = 0.275},
            {description = "Huge",   data = 0.325},
            {description = "Giant",  data = 0.375},
        },
        default = 0.225,
    },
    {
        name = "Position",
        options =
        {
            {description = "Top Right",     data = "top_right"},
            {description = "Top Left",      data = "top_left"},
            {description = "Top Center",    data = "top_center"},
            {description = "Middle Left",   data = "middle_left"},
            {description = "Middle Center", data = "middle_center"},
            {description = "Middle Right",  data = "middle_right"},
            {description = "Bottom Left",   data = "bottom_left"},
            {description = "Bottom Center", data = "bottom_center"},
            {description = "Bottom Right",  data = "bottom_right"},
        },
        default = "top_left"
    },
    {
        name = "Horizontal Margin",
        options =
        {
            {description = "0",            data = 0},
            {description = "1",            data = 5},
            {description = "2",            data = 12.5*1},
            {description = "3",            data = 12.5*2},
            {description = "4",            data = 12.5*3},
            {description = "5",            data = 12.5*4},
            {description = "6",            data = 12.5*5},
            {description = "7",            data = 12.5*6},
            {description = "8",            data = 12.5*7},
            {description = "9",            data = 12.5*8},
            {description = "10",           data = 12.5*9},
            {description = "11",           data = 12.5*10},
            {description = "12",           data = 12.5*11},
            {description = "13",           data = 12.5*12},
            {description = "14",           data = 12.5*13},
            {description = "15",           data = 12.5*14},
            {description = "16",           data = 12.5*15},
            {description = "17",           data = 12.5*16},
            {description = "18",           data = 12.5*17},
            {description = "19",           data = 12.5*18},
            {description = "20",           data = 12.5*19},
            {description = "21",           data = 12.5*20},
            {description = "22",           data = 12.5*21},
            {description = "23",           data = 12.5*22},
            {description = "24",           data = 12.5*23},
            {description = "25",           data = 12.5*24},
            {description = "26",           data = 12.5*25},
            {description = "27",           data = 12.5*26},
            {description = "28",           data = 12.5*27},
            {description = "29",           data = 12.5*28},
            {description = "30",           data = 12.5*29},
        },
        default = 12.5*5
    },
    {
        name = "Vertical Margin",
        options =
        {
            {description = "0",            data = 0},
            {description = "1",            data = 5},
            {description = "2",            data = 12.5*1},
            {description = "3",            data = 12.5*2},
            {description = "4",            data = 12.5*3},
            {description = "5",            data = 12.5*4},
            {description = "6",            data = 12.5*5},
            {description = "7",            data = 12.5*6},
            {description = "8",            data = 12.5*7},
            {description = "9",            data = 12.5*8},
            {description = "10",           data = 12.5*9},
            {description = "11",           data = 12.5*10},
            {description = "12",           data = 12.5*11},
            {description = "13",           data = 12.5*12},
            {description = "14",           data = 12.5*13},
            {description = "15",           data = 12.5*14},
            {description = "16",           data = 12.5*15},
            {description = "17",           data = 12.5*16},
            {description = "18",           data = 12.5*17},
            {description = "19",           data = 12.5*18},
            {description = "20",           data = 12.5*19},
            {description = "21",           data = 12.5*20},
            {description = "22",           data = 12.5*21},
            {description = "23",           data = 12.5*22},
            {description = "24",           data = 12.5*23},
            {description = "25",           data = 12.5*24},
            {description = "26",           data = 12.5*25},
            {description = "27",           data = 12.5*26},
            {description = "28",           data = 12.5*27},
            {description = "29",           data = 12.5*28},
            {description = "30",           data = 12.5*29},
        },
        default = 12.5*1
    },
    {
        name = "Default Zoom",
        options =
        {
            {description = "0 (Most ZoomIn)",   data = 0},
            {description = "1",                 data = 1},
            {description = "2",                 data = 2},
            {description = "3",                 data = 3},
            {description = "4",                 data = 4},
            {description = "5",                 data = 5},
            {description = "6",                 data = 6},
            {description = "7",                 data = 7},
            {description = "8",                 data = 8},
            {description = "9",                 data = 9},
            {description = "10",                data = 10},
            {description = "11",                data = 11},
            {description = "12",                data = 12},
            {description = "13",                data = 13},
            {description = "14",                data = 14},
            {description = "15",                data = 15},
            {description = "16",                data = 16},
            {description = "17",                data = 17},
            {description = "18",                data = 18},
            {description = "19",                data = 19},
            {description = "20 (Most ZoomOut)", data = 20},
        },
        default = 4,
    },
    {
        name = "Close when open chest",
        options =
        {
            {description = "False", data = false},
            {description = "True", data = true},
        },
        default = false,
    },
    {
        name = "Pause if focused",
        options =
        {
            {description = "False",                  data = false},
            {description = "True (not work in DST)", data = true},
        },
        default = false,
    },
    {
        name = "Horizontal Scale",
        options =
        {
            {description = "1.0", data = 1.0},
            {description = "1.1", data = 1.1},
            {description = "1.2", data = 1.2},
            {description = "1.3", data = 1.3},
            {description = "1.4", data = 1.4},
            {description = "1.5", data = 1.5},
            {description = "1.6", data = 1.6},
            {description = "1.7", data = 1.7},
            {description = "1.8", data = 1.8},
            {description = "1.9", data = 1.9},
            {description = "2.0", data = 2.0},
            {description = "2.1", data = 2.1},
            {description = "2.2", data = 2.2},
            {description = "2.3", data = 2.3},
            {description = "2.4", data = 2.4},
            {description = "2.5", data = 2.5},
            {description = "2.6", data = 2.6},
            {description = "2.7", data = 2.7},
            {description = "2.8", data = 2.8},
            {description = "2.9", data = 2.9},
            {description = "3.0", data = 3.0},
            {description = "3.1", data = 3.1},
            {description = "3.2", data = 3.2},
            {description = "3.3", data = 3.3},
            {description = "3.4", data = 3.4},
            {description = "3.5", data = 3.5},
            {description = "3.6", data = 3.6},
            {description = "3.7", data = 3.7},
            {description = "3.8", data = 3.8},
            {description = "3.9", data = 3.9},
            {description = "4.0", data = 4.0},
            {description = "4.1", data = 4.1},
            {description = "4.2", data = 4.2},
            {description = "4.3", data = 4.3},
            {description = "4.4", data = 4.4},
            {description = "4.5", data = 4.5},
            {description = "4.6", data = 4.6},
            {description = "4.7", data = 4.7},
            {description = "4.8", data = 4.8},
            {description = "4.9", data = 4.9},
            {description = "5.0", data = 5.0},
        },
        default = 1.0,
    },
    {
        name = "Vertical Scale",
        options =
        {
            {description = "1.0", data = 1.0},
            {description = "1.1", data = 1.1},
            {description = "1.2", data = 1.2},
            {description = "1.3", data = 1.3},
            {description = "1.4", data = 1.4},
            {description = "1.5", data = 1.5},
            {description = "1.6", data = 1.6},
            {description = "1.7", data = 1.7},
            {description = "1.8", data = 1.8},
            {description = "1.9", data = 1.9},
            {description = "2.0", data = 2.0},
            {description = "2.1", data = 2.1},
            {description = "2.2", data = 2.2},
            {description = "2.3", data = 2.3},
            {description = "2.4", data = 2.4},
            {description = "2.5", data = 2.5},
            {description = "2.6", data = 2.6},
            {description = "2.7", data = 2.7},
            {description = "2.8", data = 2.8},
            {description = "2.9", data = 2.9},
            {description = "3.0", data = 3.0},
            {description = "3.1", data = 3.1},
            {description = "3.2", data = 3.2},
            {description = "3.3", data = 3.3},
            {description = "3.4", data = 3.4},
            {description = "3.5", data = 3.5},
            {description = "3.6", data = 3.6},
            {description = "3.7", data = 3.7},
            {description = "3.8", data = 3.8},
            {description = "3.9", data = 3.9},
            {description = "4.0", data = 4.0},
            {description = "4.1", data = 4.1},
            {description = "4.2", data = 4.2},
            {description = "4.3", data = 4.3},
            {description = "4.4", data = 4.4},
            {description = "4.5", data = 4.5},
            {description = "4.6", data = 4.6},
            {description = "4.7", data = 4.7},
            {description = "4.8", data = 4.8},
            {description = "4.9", data = 4.9},
            {description = "5.0", data = 5.0},
        },
        default = 1.0,
    },
    {
        name = "Show BG Image",
        options =
        {
            {description = "False", data = false},
            {description = "True", data = true},
        },
        default = true,
    },
    {
        name = "Map Blend Mode",
        options =
        {
            {description = "Disabled", data = 0},
            {description = "AlphaBlended", data = 1},
            {description = "Additive", data = 2},
            {description = "Premultiplied", data = 3},
            {description = "InverseAlpha", data = 4},
        },
        default = 2,
    },
    {
        name = "BG Image Blend Mode",
        options =
        {
            {description = "Disabled", data = 0},
            {description = "AlphaBlended", data = 1},
            {description = "Additive", data = 2},
            {description = "Premultiplied", data = 3},
            {description = "InverseAlpha", data = 4},
        },
        default = 3,
    },
    {
        name = "Map Clickable",
        options =
        {
            {description = "False", data = false},
            {description = "True", data = true},
        },
        default = true,
    },
    {
        name = "Map Transparency",
        options =
        {
            {description = "0.10", data = 0.10},
            {description = "0.15", data = 0.15},
            {description = "0.20", data = 0.20},
            {description = "0.25", data = 0.25},
            {description = "0.30", data = 0.30},
            {description = "0.35", data = 0.35},
            {description = "0.40", data = 0.40},
            {description = "0.45", data = 0.45},
            {description = "0.50", data = 0.50},
            {description = "0.55", data = 0.55},
            {description = "0.60", data = 0.60},
            {description = "0.65", data = 0.65},
            {description = "0.70", data = 0.70},
            {description = "0.75", data = 0.75},
            {description = "0.80", data = 0.80},
            {description = "0.85", data = 0.85},
            {description = "0.90", data = 0.90},
            {description = "0.95", data = 0.95},
            {description = "1.00", data = 1.00},
        },
        default = 1.00,
    },
    {
        name = "BG Image Transparency",
        options =
        {
            {description = "0.10", data = 0.10},
            {description = "0.15", data = 0.15},
            {description = "0.20", data = 0.20},
            {description = "0.25", data = 0.25},
            {description = "0.30", data = 0.30},
            {description = "0.35", data = 0.35},
            {description = "0.40", data = 0.40},
            {description = "0.45", data = 0.45},
            {description = "0.50", data = 0.50},
            {description = "0.55", data = 0.55},
            {description = "0.60", data = 0.60},
            {description = "0.65", data = 0.65},
            {description = "0.70", data = 0.70},
            {description = "0.75", data = 0.75},
            {description = "0.80", data = 0.80},
            {description = "0.85", data = 0.85},
            {description = "0.90", data = 0.90},
            {description = "0.95", data = 0.95},
            {description = "1.00", data = 1.00},
        },
        default = 0.75,
    },
    {
        name = "Button Scale",
        options =
        {
            {description = "0.1", data = 0.1},
            {description = "0.2", data = 0.2},
            {description = "0.3", data = 0.3},
            {description = "0.4", data = 0.4},
            {description = "0.5", data = 0.5},
            {description = "0.6", data = 0.6},
            {description = "0.7", data = 0.7},
            {description = "0.8", data = 0.8},
            {description = "0.9", data = 0.9},
            {description = "1.0", data = 1.0},
        },
        default = 0.4,
    },
    {
        name = "ToggleButton Show",
        options =
        {
            {description = "False", data = false},
            {description = "True", data = true},
        },
        default = true,
    },
    {
        name = "ToggleButton Horiz Pos",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 1,
    },
    {
        name = "ToggleButton Vert Pos",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 0,
    },
    {
        name = "ConfigButton Show",
        options =
        {
            {description = "False", data = false},
            {description = "True", data = true},
        },
        default = true,
    },
    {
        name = "ConfigButton Horiz Pos",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 4,
    },
    {
        name = "ConfigButton Vert Pos",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 0,
    },
    {
        name = "QuickSaveButton Show",
        options =
        {
            {description = "False", data = false},
            {description = "True", data = true},
        },
        default = true,
    },
    {
        name = "QuickSaveButton Horiz Pos",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 10,
    },
    {
        name = "QuickSaveButton Vert Pos",
        options =
        {
            {description = "0", data = 0},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
        },
        default = 0,
    },
    {
        name = "ToggleKey",
        options =
        {
            {description = "Disable", data = "0"},
        },
        --default = "1+1+103+0+0+0",
        default = "1+1+0+0+0+0",
    },
    {
        name = "CenterResetKey",
        options =
        {
            {description = "Disable", data = "0"},
        },
        default = "1+1+0+0+0+0",
    },
    {
        name = "ConfigKey",
        options =
        {
            {description = "Disable", data = "0"},
        },
        --default = "1+2+401+99+0+0",
        default = "1+1+0+0+0+0",
    },
    {
        name = "! FACTORY RESET !",
        options =
        {
            {description = "No", data = false},
            {description = "Yes", data = true},
        },
        default = false,
    },
}
