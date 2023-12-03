

local movePoint = function()
                return CGeoPoint:new_local(2000,-1000)
end 

local moveDir = function(role)
                return player.toTheirGoalDir(role)
end 


gPlayTable.CreatePlay{

firstState = "test",

["test"] = {

        switch = function()
                debugEngine:gui_debug_x(movePoint(),1);
                debugEngine:gui_debug_x(player.pos("a"),2); 
                debugEngine:gui_debug_msg(CGeoPoint:new_local(-2000,-1000),"位置偏差值:"..tostring(movePoint():dist(player.pos("a"))),3)
        end,
        a = whtCommonTask.goCmuRush(movePoint,moveDir,_,flag.nothing),
        -- a = whtCommonTask.goCmuRush(movePoint,moveDir,6000,flag.nothing),
        -- a = whtCommonTask.goCmuRush(movePoint,moveDir,2000,flag.nothing),
        match = "{a}"
},

name = "test1-03",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
