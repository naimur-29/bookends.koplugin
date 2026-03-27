-- Fix: enable swipe pagination in CoverBrowser list/mosaic views.
--
-- CoverBrowser's CoverMenu.updateItems calls UIManager:setDirty but
-- the screen doesn't actually refresh after swipe-triggered page changes
-- in History, Collections, etc. This patch forces the refresh.
--
-- Also adds north/south (up/down) swipe support for page navigation,
-- which feels more natural in list views.

local BD = require("ui/bidi")
local Menu = require("ui/widget/menu")
local UIManager = require("ui/uimanager")

local orig_onSwipe = Menu.onSwipe

function Menu:onSwipe(arg, ges_ev)
    -- Only patch CoverBrowser views (history, collections, coll_list)
    if not self._coverbrowser_overridden then
        return orig_onSwipe(self, arg, ges_ev)
    end

    local direction = BD.flipDirectionIfMirroredUILayout(ges_ev.direction)
    local old_page = self.page

    if direction == "west" or direction == "north" then
        self:onNextPage()
    elseif direction == "east" or direction == "south" then
        self:onPrevPage()
    end

    if self.page ~= old_page then
        UIManager:setDirty(self.show_parent, "ui")
    end
    return true
end
