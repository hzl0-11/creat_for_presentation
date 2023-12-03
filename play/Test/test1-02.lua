

local movePoint = function()
                return CGeoPoint:new_local(3000,000)
end 


local moveDir = function(role)
                return player.toTheirGoalDir(role)
end 


gPlayTable.CreatePlay{

firstState = "test",

["test"] = {

        switch = function()
                debugEngine:gui_debug_line(player.pos("a"),player.pos("a")+Utils.Polar2Vector(1000 ,player.dir("a")),1);
                debugEngine:gui_debug_line(player.pos("a"),player.pos("a")+Utils.Polar2Vector(3000 ,player.toTheirGoalDir("a")),2);  
                debugEngine:gui_debug_msg(CGeoPoint:new_local(-2000,-1000),"角度偏差值:"..tostring(player.toTheirGoalDir("a")-player.dir("a")),3)
                -- debugEngine:gui_debug_msg(CGeoPoint:new_local(-2000,1000),"坐标:"..tostring(ball.pos()),3)
        end,
        a = whtCommonTask.goCmuRush(movePoint,moveDir,_,flag.nothing),
        match = "{a}"
},

name = "test1-02",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
