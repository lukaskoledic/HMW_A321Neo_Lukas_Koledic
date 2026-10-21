--HMW A321neo EFB Home widgets (page 1)
--Light theme, MacOS-style widgets, HMW branding
include("efb_home_widgets.lua")

--MOUSE & BUTTONS--
function EFB_execute_page_1_buttons()
    EFB_home_buttons()
end

--UPDATE LOOPS--
function EFB_update_page_1()
    EFB_home_update()
end

--DRAW LOOPS--
function EFB_draw_page_1()
    EFB_home_draw()
end