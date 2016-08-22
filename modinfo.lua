name = "Minimap HUD MZ"
description = "Adds a minimap to the HUD with More customiZable and more controlable configuration options in game mode are added. "
author = "pigshaam" -- Original: "squeek"
version = "1.1.6"
forumthread = "" -- Original: "/files/file/352-minimap-hud/"
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- this setting is dumb; this mod is likely compatible with all future versions
api_version = 6

client_only_mod = true
dst_compatible = true
dont_starve_compatible = true
reign_of_giants_compatible = true
all_clients_require_mod = false
shipwrecked_compatible = true

configuration_options =
{
    {
        name = "Map Size",
        options =
        {
            {description = "Tiny",             data = 0.125},
            {description = "Small",            data = 0.175},
            {description = "Medium (default)", data = 0.225},
            {description = "Large",            data = 0.275},
            {description = "Huge",             data = 0.325},
            {description = "Giant",            data = 0.375},
        },
        default = 0.225,
    },
    {
        name = "Position",
        options =
        {
            {description = "Top Right",          data = "top_right"},
            {description = "Top Left (default)", data = "top_left"},
            {description = "Top Center",         data = "top_center"},
            {description = "Middle Left",        data = "middle_left"},
            {description = "Middle Center",      data = "middle_center"},
            {description = "Middle Right",       data = "middle_right"},
            {description = "Bottom Left",        data = "bottom_left"},
            {description = "Bottom Center",      data = "bottom_center"},
            {description = "Bottom Right",       data = "bottom_right"},
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
            {description = "6 (default)",  data = 12.5*5},
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
            {description = "2 (default)",  data = 12.5*1},
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
            {description = "4 (default)",       data = 4},
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
            {description = "False (default)", data = false},
            {description = "True",            data = true},
        },
        default = false,
    },
    {
        name = "Pause if focused",
        options =
        {
            {description = "False (default)",        data = false},
            {description = "True (not work in DST)", data = true},
        },
        default = false,
    },
    {
        name = "! FACTORY RESET !",
        options =
        {
            {description = "No (default)", data = false},
            {description = "Yes",          data = true},
        },
        default = false,
    },
}
